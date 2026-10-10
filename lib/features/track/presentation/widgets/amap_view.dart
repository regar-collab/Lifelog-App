import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifelog/core/utils/coordinate.dart';

/// 高德地图视图。
///
/// 原生侧实现在 android/app/src/main/kotlin/.../amap/ 里，
/// 只暴露 drawTrack / clearTrack / moveTo 三个方法。
///
/// **传进来的点必须是 GCJ-02 坐标** —— 高德底图用的是加密坐标，
/// 直接喂 WGS84 会让整条轨迹偏到隔壁街区（实测偏 570 米）。
class AmapView extends StatefulWidget {
  const AmapView({super.key, this.points = const []});

  /// 轨迹点（GCJ-02）。空列表表示只显示地图，不画线。
  final List<LatLng> points;

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

    return AndroidView(
      viewType: 'lifelog/amap',
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
