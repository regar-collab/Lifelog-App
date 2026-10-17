import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifelog/core/utils/coordinate.dart';

/// 高德地图视图。
///
/// 原生侧实现在 android/app/src/main/kotlin/.../amap/ 里，
/// 只暴露 drawTrack / clearTrack 两个方法。
///
/// **传进来的点必须是 GCJ-02 坐标** —— 高德底图用的是加密坐标，
/// 直接喂 WGS84 会让整条轨迹偏到隔壁街区（实测偏 570 米）。
///
/// [apiKey] 由用户在设置页填，通过 creationParams 传给原生侧，
/// 原生侧在创建地图前用 MapsInitializer.setApiKey 注入。
/// 不填的话地图出不来，但不影响其它功能。
class AmapView extends StatefulWidget {
  const AmapView({super.key, this.points = const [], this.apiKey});

  /// 轨迹点（GCJ-02）。空列表表示只显示地图，不画线。
  final List<LatLng> points;

  /// 用户配置的高德 Android Key
  final String? apiKey;

  @override
  State<AmapView> createState() => _AmapViewState();
}

class _AmapViewState extends State<AmapView> {
  MethodChannel? _channel;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return const Center(child: Text('地图目前只做了 Android'));
    }

    final String apiKey = widget.apiKey?.trim() ?? '';

    return AndroidView(
      // creationParams 只在 PlatformView 创建时读取一次。用户第一次进入
      // 轨迹页时 Key 可能还在异步加载（空字符串），之后读到了也不会重建。
      // 用 Key 强制换一个实例，原生侧才能拿到新的 Key 重新初始化地图。
      key: ValueKey<String>('amap-$apiKey'),
      viewType: 'lifelog/amap',
      // Key 在建图之前就得给到原生侧，所以走 creationParams 而不是走 method channel
      creationParams: <String, Object?>{'apiKey': apiKey},
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }

  @override
  void didUpdateWidget(covariant AmapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 点数变了就重画（采集过程中会不断追加）
    if (widget.points.length != oldWidget.points.length) {
      _draw();
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('lifelog/amap_$id');
    _draw();
  }

  Future<void> _draw() async {
    final MethodChannel? channel = _channel;
    if (channel == null) return;

    try {
      if (widget.points.isEmpty) {
        await channel.invokeMethod<bool>('clearTrack');
        return;
      }

      await channel.invokeMethod<bool>('drawTrack', <String, Object>{
        'points': widget.points
            .map((LatLng p) => <double>[p.lat, p.lng])
            .toList(),
      });
    } on PlatformException {
      // 地图还没准备好或坐标异常，忽略这一帧，下一帧会重试
    }
  }
}
