package com.simple.lifelog

import com.simple.lifelog.amap.AmapViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册高德地图的 PlatformView。
        // viewType 要和 Dart 侧 AndroidView 里写的一致。
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "lifelog/amap",
            AmapViewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )
    }
}
