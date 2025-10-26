import Flutter
import UIKit
import CoreHaptics

public class AdvancedHapticsPlugin: NSObject, FlutterPlugin {
  private var engine: CHHapticEngine?
  // Using a single, shared player for all haptic events ensures predictable state.
  private var advancedPlayer: CHHapticAdvancedPatternPlayer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.example/advanced_haptics", binaryMessenger: registrar.messenger())
    let instance = AdvancedHapticsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  override init() {
    super.init()
    setupHapticEngine()
  }

  private func setupHapticEngine() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
    do {
      engine = try CHHapticEngine()
      try engine?.start()

      engine?.resetHandler = { [weak self] in
        print("Haptic engine reset, restarting...")
        do {
          try self?.engine?.start()
        } catch {
          print("Failed to restart the haptic engine: \(error)")
        }
      }

      engine?.stoppedHandler = { reason in
        print("Haptic engine stopped for reason: \(reason.rawValue)")
      }

    } catch {
      print("Error creating haptic engine: \(error.localizedDescription)")
    }
  }

  // Create a private helper function to reduce duplication
  private func _playPattern(pattern: CHHapticPattern, atTime: TimeInterval, result: @escaping FlutterResult) {
    // Ensure engine is available and running
    do {
      try ensureEngineRunning()
    } catch {
      result(FlutterError(code: "ENGINE_ERROR", message: "Haptic engine unavailable", details: error.localizedDescription))
      return
    }

    guard let engine = engine else {
        result(FlutterError(code: "ENGINE_NIL", message: "Haptic engine is not available.", details: nil))
        return
    }

    do {
      // Stop and release the previous player before starting a new one.
      if let player = advancedPlayer {
        try? player.stop(atTime: CHHapticTimeImmediate)
        advancedPlayer = nil
      }

      advancedPlayer = try engine.makeAdvancedPlayer(with: pattern)
      advancedPlayer?.loopEnabled = false // Default to no loop
      // The completion handler could be used to send a message back to Dart if needed
      advancedPlayer?.completionHandler = { _ in
          // This runs on a background thread. For UI updates, dispatch to main.
      }
      try advancedPlayer?.start(atTime: atTime)
      result(nil)
    } catch let error as NSError {
      result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to play haptic pattern", details: "[\(error.domain):\(error.code)] \(error.localizedDescription)"))
    }
  }

  // Ensure haptic engine is running, recreate if needed
  private func ensureEngineRunning() throws {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
      throw NSError(domain: "AdvancedHaptics", code: -1, userInfo: [NSLocalizedDescriptionKey: "Haptics not supported"])
    }

    // Try to start existing engine
    if let existingEngine = engine {
      do {
        try existingEngine.start()
        return
      } catch let startError as NSError {
        // If already running (-4806), that's fine
        if startError.code == -4806 {
          return
        }
        // Other errors mean engine is invalid, recreate it
      }
    }

    // Create new engine
    engine = try CHHapticEngine()
    try engine?.start()

    // Invalidate the old player since engine was recreated
    advancedPlayer = nil

    // Re-setup handlers
    engine?.resetHandler = { [weak self] in
      print("Haptic engine reset, restarting...")
      do {
        try self?.engine?.start()
        // Also invalidate player when engine resets
        self?.advancedPlayer = nil
      } catch {
        print("Failed to restart the haptic engine: \(error)")
      }
    }

    engine?.stoppedHandler = { reason in
      print("Haptic engine stopped for reason: \(reason.rawValue)")
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let engine = engine else {
      if call.method == "hasCustomHapticsSupport" {
        result(false)
      } else {
        result(FlutterError(code: "UNSUPPORTED", message: "Core Haptics not supported on this device.", details: nil))
      }
      return
    }

    switch call.method {
    case "hasCustomHapticsSupport":
      result(CHHapticEngine.capabilitiesForHardware().supportsHaptics)

    case "playAhap":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            let startTime = args["atTime"] as? Double else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing 'path' or 'atTime' argument", details: nil))
        return
      }

      let key = FlutterDartProject.lookupKey(forAsset: path)
      guard let ahapUrl = Bundle.main.url(forResource: key, withExtension: nil) else {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "AHAP file not found in assets", details: path))
        return
      }

      do {
          let pattern: CHHapticPattern
          if #available(iOS 16.0, *) {
              pattern = try CHHapticPattern(contentsOf: ahapUrl)
          } else {
              let data = try Data(contentsOf: ahapUrl)
              let rawJson = try JSONSerialization.jsonObject(with: data)
              guard let raw = rawJson as? [String: Any] else {
                  throw NSError(domain: "HapticError", code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Invalid AHAP JSON"])
              }
              var typed: [CHHapticPattern.Key: Any] = [:]
              for (k, v) in raw {
                  // CHHapticPattern.Key's init(rawValue: String) is non-failable.
                  // It always creates a CHHapticPattern.Key, so 'if let' is not needed.
                  let key = CHHapticPattern.Key(rawValue: k)
                  typed[key] = v
              }
              pattern = try CHHapticPattern(dictionary: typed)
          }
            _playPattern(pattern: pattern, atTime: startTime, result: result)
      } catch {
        result(FlutterError(code: "PATTERN_ERROR", message: "Failed to create pattern from AHAP file.", details: error.localizedDescription))
      }

    case "playWaveform":
      guard let args = call.arguments as? [String: Any],
            let timings = args["timings"] as? [Double],
            let amplitudes = args["amplitudes"] as? [Double],
            let startTime = args["atTime"] as? Double else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for waveform", details: nil))
        return
      }

      guard timings.count == amplitudes.count else {
        result(FlutterError(code: "INVALID_ARGS", message: "The 'timings' and 'amplitudes' arrays must have the same length.", details: nil))
        return
      }
      
      var events = [CHHapticEvent]()
      var relativeTime: TimeInterval = 0

      for i in 0..<timings.count {
        let duration = timings[i] / 1000.0 // Convert milliseconds to seconds
        let amplitudeValue = amplitudes[i]

        // --- THE FIX ---
        // A continuous event must have both an amplitude AND a positive duration.
        // This prevents the -4823 error.
        if amplitudeValue > 0 && duration > 0 {
          let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(amplitudeValue / 255.0))
          let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)

          let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: relativeTime,
            duration: duration
          )
          events.append(event)
        }
        
        // Always advance the relative time for the next event, even for pauses or zero-duration segments.
        relativeTime += duration
      }

      // It's possible to have no valid events (e.g., all durations were 0).
      // In this case, we can just succeed without playing anything.
      guard !events.isEmpty else {
          result(nil)
          return
      }

      do {
        let pattern = try CHHapticPattern(events: events, parameters: [])
        _playPattern(pattern: pattern, atTime: startTime, result: result)
      } catch {
        result(FlutterError(code: "PATTERN_ERROR", message: "Failed to create pattern from waveform data.", details: error.localizedDescription))
      }
    case "success":
      // --- CHANGE 4: Make one-shot effects also use the shared player ---
      // This ensures that calling success() will correctly interrupt any ongoing haptic.
      do {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
        let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
        _playPattern(pattern: pattern, atTime: 0, result: result)
      } catch {
        result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to play success pattern", details: error.localizedDescription))
      }

    // --- CHANGE 5: Add guards to all player control methods ---
    case "pause", "resume", "seek", "stop":
      guard let player = advancedPlayer else {
          result(FlutterError(code: "PLAYER_NIL", message: "No haptic player is currently active.", details: nil))
          return
      }
      
      guard let args = call.arguments as? [String: Any] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments map.", details: nil))
          return
      }

      do {
        switch call.method {
            case "pause":
                let atTime = args["atTime"] as? Double ?? 0
                try player.pause(atTime: atTime)
            case "resume":
                let atTime = args["atTime"] as? Double ?? 0
                try player.resume(atTime: atTime)
            case "seek":
                let offset = args["offset"] as? Double ?? 0
                try player.seek(toOffset: offset)
            case "stop":
                let atTime = args["atTime"] as? Double ?? 0
                try player.stop(atTime: atTime)
                advancedPlayer = nil // Release the player after stopping
            default:
                break
        }
        result(nil)
      } catch {
          result(FlutterError(code: "PLAYER_CONTROL_ERROR", message: "Failed to execute player command: \(call.method)", details: error.localizedDescription))
      }

    case "cancel":
      // Cancel is special, it can be called even if the player is nil (it does nothing)
      do {
        try advancedPlayer?.cancel()
        result(nil)
      } catch {
        result(FlutterError(code: "CANCEL_ERROR", message: "Failed to cancel haptic playback", details: error.localizedDescription))
      }

    default:
      result(FlutterError(code: "NOT_IMPLEMENTED", message: "Method not implemented", details: nil))
    }
  }
}
