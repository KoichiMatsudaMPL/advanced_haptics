import Flutter
import UIKit
import CoreHaptics

public class AdvancedHapticsPlugin: NSObject, FlutterPlugin {
    private var engine: CHHapticEngine?

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
            
            // Handle engine resets
            engine?.resetHandler = { [weak self] in
                print("Haptic engine reset")
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart the engine: \(error)")
                }
            }
            
            // Handle engine stop
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped for reason: \(reason.rawValue)")
            }
            
        } catch {
            print("Error creating haptic engine: \(error.localizedDescription)")
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
                  let path = args["path"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing 'path' argument", details: nil))
                return
            }
            
            // Find the asset in the app bundle
            let key = FlutterDartProject.lookupKey(forAsset: path)
            guard let ahapUrl = Bundle.main.url(forResource: key, withExtension: nil) else {
                 result(FlutterError(code: "FILE_NOT_FOUND", message: "AHAP file not found in assets", details: path))
                 return
            }

            do {
                try engine.playPattern(from: ahapUrl)
                result(nil)
            } catch {
                result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to play AHAP pattern", details: error.localizedDescription))
            }

        case "playWaveform":
            // Emulation of waveform on iOS
            // This is a simple interpretation. A more complex one could be built.
            guard let args = call.arguments as? [String: Any],
                  let timings = args["timings"] as? [Double],
                  let amplitudes = args["amplitudes"] as? [Double] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for waveform", details: nil))
                return
            }

            var events = [CHHapticEvent]()
            var relativeTime: TimeInterval = 0
            for i in 0..<timings.count {
                if i % 2 != 0 { // Only create events for the "on" durations
                    let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(amplitudes[i] / 255.0))
                    let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                    let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: relativeTime)
                    events.append(event)
                }
                relativeTime += timings[i] / 1000.0 // Convert ms to seconds
            }

            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
                result(nil)
            } catch {
                result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to play emulated waveform", details: error.localizedDescription))
            }

        case "success":
             do {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
                let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.1)
                let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
                result(nil)
            } catch {
                result(FlutterError(code: "PLAYBACK_ERROR", message: "Failed to play success pattern", details: error.localizedDescription))
            }
            
        case "stop":
            engine.stop(completionHandler: nil)
            result(nil)
            
        default:
            result(FlutterError(code: "NOT_IMPLEMENTED", message: "Method not implemented", details: nil))
        }
    }
}