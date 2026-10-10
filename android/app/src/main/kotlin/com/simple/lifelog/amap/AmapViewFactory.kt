package com.simple.lifelog.amap

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * 把 AmapPlatformView 注册给 Flutter。
 *
 * Dart 侧用 AndroidView(viewType: "lifelog/amap") 创建，
 * 通过 creationParams 把用户配置的高德 Key 传进来。
 */
class AmapViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // creationParams 是 Map<String, Object?>，拿 Key
        val params = args as? Map<*, *>
        val apiKey = params?.get("apiKey") as? String

        return AmapPlatformView(context, messenger, viewId, apiKey)
    }
}
