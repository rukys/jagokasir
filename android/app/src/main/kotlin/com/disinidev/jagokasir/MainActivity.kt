package com.disinidev.jagokasir

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.disinidev/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFreeSpace") {
                try {
                    val stat = StatFs(filesDir.absolutePath)
                    val bytesAvailable = stat.availableBlocksLong * stat.blockSizeLong
                    result.success(bytesAvailable)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Failed to get free space", e.message)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
