package com.appvoyage.app_voyage

import android.content.Intent
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceFragmentActivity() {
    private val CHANNEL = "com.rayv.appvoyage/tts_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openTtsSettings") {
                    try {
                        val intent = Intent()
                        intent.action = "com.android.settings.TTS_SETTINGS"
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Could not open TTS settings", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
