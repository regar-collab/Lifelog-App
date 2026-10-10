package com.simple.lifelog

import android.content.pm.PackageManager
import com.simple.lifelog.amap.AmapViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 注册高德地图的 PlatformView。
        // viewType 要和 Dart 侧 AndroidView 里写的一致。
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "lifelog/amap",
            AmapViewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )

        // 把构建期注入到 AndroidManifest 的高德 Key 告诉 Dart 侧。
        //
        // 为什么需要：Key 有两个来源（构建时注入 / App 内填写），
        // 而 Dart 读不到 manifest。不告诉它的话，自己编译的版本
        // 明明有 Key，界面上却会误报「还没配置」。
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lifelog/config",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAmapKey" -> result.success(readAmapKeyFromManifest())
                else -> result.notImplemented()
            }
        }
    }

    /// 从 AndroidManifest 的 meta-data 里读高德 Key。
    /// 没配置的话返回空字符串。
    private fun readAmapKeyFromManifest(): String {
        return try {
            val appInfo = packageManager.getApplicationInfo(
                packageName,
                PackageManager.GET_META_DATA,
            )
            appInfo.metaData?.getString("com.amap.api.v2.apikey").orEmpty()
        } catch (e: Exception) {
            ""
        }
    }
}
