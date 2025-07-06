package com.example.advanced_haptics

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AdvancedHapticsPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var vibrator: Vibrator? = null
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example/advanced_haptics")
        channel.setMethodCallHandler(this)
        vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator?
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "hasCustomHapticsSupport" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    result.success(vibrator?.hasAmplitudeControl() ?: false)
                } else {
                    result.success(false)
                }
            }
            "playWaveform" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val timings = call.argument<ArrayList<Int>>("timings")?.map { it.toLong() }?.toLongArray()
                    val amplitudes = call.argument<ArrayList<Int>>("amplitudes")?.toIntArray()
                    if (timings != null && amplitudes != null) {
                        val effect = VibrationEffect.createWaveform(timings, amplitudes, -1) // -1 means no repeat
                        vibrator?.vibrate(effect)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "Timings or amplitudes are null", null)
                    }
                } else {
                    result.error("UNSUPPORTED_API", "Waveform vibrations require Android API 26+", null)
                }
            }
            "playAhap" -> {
                // Fallback for .ahap on Android
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val effect = VibrationEffect.createWaveform(longArrayOf(0, 100, 50, 100), intArrayOf(0, 255, 0, 150), -1)
                    vibrator?.vibrate(effect)
                } else {
                    vibrator?.vibrate(200) // Simple vibration for older APIs
                }
                result.success(null)
            }
            "success" -> {
                 if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val effect = VibrationEffect.createWaveform(longArrayOf(0, 50, 100, 50), intArrayOf(0, 150, 0, 150), -1)
                    vibrator?.vibrate(effect)
                } else {
                    vibrator?.vibrate(longArrayOf(0, 50, 100, 50), -1)
                }
                result.success(null)
            }
            "stop" -> {
                vibrator?.cancel()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        vibrator = null
    }
}