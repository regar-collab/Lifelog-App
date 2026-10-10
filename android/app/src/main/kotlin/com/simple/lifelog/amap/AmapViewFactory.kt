package com.simple.lifelog.amap

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * 把 AmapPlatformView 注册给 Flutter。
 *
 * Dart 侧用 AndroidView(viewType: "lifelog/amap") 创建。
 */
class AmapViewFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return AmapPlatformView(context, messenger, viewId)
    }
}
