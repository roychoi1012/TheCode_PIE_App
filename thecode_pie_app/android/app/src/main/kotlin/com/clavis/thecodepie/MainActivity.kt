package com.clavis.thecodepie

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val vibrationChannel = "com.clavis.thecodepie/vibration"
    private val logTag = "TheCodeVibration"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vibrationChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "vibrate" -> {
                        val pattern = call.argument<String>("pattern") ?: "select"
                        vibrate(pattern)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun vibrate(pattern: String) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        if (!vibrator.hasVibrator()) {
            Log.d(logTag, "vibrator unavailable")
            return
        }
        Log.d(logTag, "vibrate pattern=$pattern")

        when (pattern) {
            "correct" -> vibrateOneShot(vibrator, 90, VibrationEffect.DEFAULT_AMPLITUDE)
            "wrong" -> vibrateWaveform(
                vibrator,
                longArrayOf(0, 80, 55, 120),
                intArrayOf(0, 255, 0, 255)
            )
            else -> vibrateOneShot(vibrator, 55, VibrationEffect.DEFAULT_AMPLITUDE)
        }
    }

    private fun vibrateOneShot(vibrator: Vibrator, durationMs: Long, amplitude: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createOneShot(durationMs, amplitude))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(durationMs)
        }
    }

    private fun vibrateWaveform(vibrator: Vibrator, timings: LongArray, amplitudes: IntArray) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(timings, -1)
        }
    }
}
