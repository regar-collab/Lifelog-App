package com.simple.lifelog.amap

import android.content.Context
import android.graphics.Color
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.MapsInitializer
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.MarkerOptions
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * 高德地图的 PlatformView。
 *
 * 只暴露三个能力，够画轨迹就行：
 * - drawTrack  画一条轨迹线（含起终点标记）并自动缩放到整条轨迹
 * - clearTrack 清空地图
 * - moveTo     移动到某个坐标
 *
 * 数据通道：Dart 侧用 MethodChannel("lifelog/amap_<viewId>") 调用。
 */
class AmapPlatformView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    apiKey: String?,
) : PlatformView, MethodChannel.MethodCallHandler {

    // 注意：Kotlin 的属性初始化在 init 块之前执行。如果在这里直接
    // `= MapView(context)`，MapView 会先于下面的 setApiKey / 隐私声明创建，
    // 正好和高德的要求相反（表现为灰网格且不报错）。
    private lateinit var mapView: MapView
    private val channel = MethodChannel(messenger, "lifelog/amap_$id")
    private var polyline: Polyline? = null

    init {
        // 用户自己在设置页配的 Key 优先。
        // 这条必须在创建 MapView 之前调用，且会覆盖 AndroidManifest 里
        // 那个空的 ${AMAP_KEY} 占位符。
        if (!apiKey.isNullOrBlank()) {
            MapsInitializer.setApiKey(apiKey)
        }

        // 高德 SDK 8.1.0 起强制要求先声明隐私合规，
        // 不调用的话地图只会显示一片灰色网格（而且不报错，很难查）。
        MapsInitializer.updatePrivacyShow(context, true, true)
        MapsInitializer.updatePrivacyAgree(context, true)

        // 以上都完成后才能创建 MapView
        mapView = MapView(context)
        mapView.onCreate(null)
        mapView.onResume()

        channel.setMethodCallHandler(this)

        // 先缩到全国视野，等 Dart 侧给了轨迹再移动
        mapView.map.moveCamera(CameraUpdateFactory.zoomTo(4f))
        mapView.map.mapType = AMap.MAP_TYPE_NORMAL
    }

    override fun getView(): View = mapView

    override fun dispose() {
        channel.setMethodCallHandler(null)
        mapView.onDestroy()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "drawTrack" -> {
                drawTrack(call)
                result.success(true)
            }

            "clearTrack" -> {
                mapView.map.clear()
                polyline = null
                result.success(true)
            }

            "moveTo" -> {
                val lat = call.argument<Double>("lat")
                val lng = call.argument<Double>("lng")
                val zoom = call.argument<Double>("zoom") ?: 16.0
                if (lat != null && lng != null) {
                    mapView.map.moveCamera(
                        CameraUpdateFactory.newLatLngZoom(LatLng(lat, lng), zoom.toFloat())
                    )
                    result.success(true)
                } else {
                    result.error("BAD_ARGS", "moveTo 需要 lat / lng", null)
                }
            }

            else -> result.notImplemented()
        }
    }

    /**
     * 画轨迹。
     *
     * 传进来的点必须已经是 GCJ-02 坐标 —— 高德底图用的是加密坐标，
     * 直接喂 WGS84 的话整条线会偏移几百米。转换在 Dart 侧做（CoordinateConverter）。
     */
    private fun drawTrack(call: MethodCall) {
        val raw = call.argument<List<List<Double>>>("points")
        if (raw.isNullOrEmpty()) return

        // 过滤掉明显无效的坐标，避免高德 SDK 抛异常
        val latLngs = raw
            .filter { it.size >= 2 && it[0] != 0.0 && it[1] != 0.0 }
            .map { LatLng(it[0], it[1]) }

        if (latLngs.isEmpty()) return

        mapView.map.clear()

        if (latLngs.size == 1) {
            // 只有一个点（刚开始记录），就画个标记
            mapView.map.addMarker(MarkerOptions().position(latLngs.first()).title("当前位置"))
            mapView.map.moveCamera(
                CameraUpdateFactory.newLatLngZoom(latLngs.first(), 16f)
            )
            return
        }

        polyline = mapView.map.addPolyline(
            PolylineOptions()
                .addAll(latLngs)
                .width(12f)
                .color(Color.parseColor("#3B6EF6"))
                .geodesic(true)
        )

        mapView.map.addMarker(
            MarkerOptions().position(latLngs.first()).title("起点")
        )
        mapView.map.addMarker(
            MarkerOptions().position(latLngs.last()).title("终点")
        )

        // 自动缩放到能装下整条轨迹
        try {
            val builder = LatLngBounds.Builder()
            latLngs.forEach { builder.include(it) }
            mapView.map.moveCamera(
                CameraUpdateFactory.newLatLngBounds(builder.build(), 100)
            )
        } catch (e: Exception) {
            // 点太密集或分布异常时 newLatLngBounds 可能算不出边界，退化成定位到起点
            mapView.map.moveCamera(
                CameraUpdateFactory.newLatLngZoom(latLngs.first(), 14f)
            )
        }
    }
}
