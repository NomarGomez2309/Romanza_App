package com.example.romanza_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraCharacteristics
import android.content.Context

class MainActivity : FlutterActivity() {
    private var previousBrightness: Float? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "romanza/camera_flash")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "hasFlash" -> {
                            val manager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                            val id = call.argument<String>("cameraId")!!
                            result.success(manager.getCameraCharacteristics(id)
                                .get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true)
                        }
                        "beginScreenFlash" -> {
                            if (previousBrightness == null) previousBrightness = window.attributes.screenBrightness
                            window.attributes = window.attributes.apply { screenBrightness = 1f }
                            result.success(null)
                        }
                        "endScreenFlash" -> { restoreBrightness(); result.success(null) }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    restoreBrightness()
                    result.error("FLASH_UNAVAILABLE", "No se pudo usar el flash", null)
                }
            }
    }

    private fun restoreBrightness() {
        previousBrightness?.let { value ->
            window.attributes = window.attributes.apply { screenBrightness = value }
        }
        previousBrightness = null
    }
    override fun onPause() { restoreBrightness(); super.onPause() }
    override fun onDestroy() { restoreBrightness(); super.onDestroy() }
}
