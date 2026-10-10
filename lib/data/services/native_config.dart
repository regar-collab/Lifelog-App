import 'package:flutter/services.dart';

/// 读取原生侧的构建期配置。
///
/// 目前只有一个用途：拿到构建时注入到 AndroidManifest 的高德 Key。
///
/// 为什么需要它 —— 高德 Key 有两个来源：
/// - **构建时注入**：从 android/local.properties 的 AMAP_KEY 写进 manifest。
///   自己编译的版本走这条，装完就能看地图。
/// - **App 内配置**：用户在设置页填，存进加密存储。
///   下载 APK 的人走这条（因为 Key 绑定签名，没法预先打包给别人）。
///
/// Dart 侧读不到 manifest，所以要向原生问一次。
class NativeConfig {
  NativeConfig._();

  static const MethodChannel _channel = MethodChannel('lifelog/config');

  static String? _bundledAmapKey;

  /// App 启动时调一次。
  static Future<void> warmUp() async {
    try {
      final String? key =
          await _channel.invokeMethod<String>('getAmapKey');
      _bundledAmapKey = (key == null || key.trim().isEmpty) ? null : key.trim();
    } catch (_) {
      // 拿不到就当没有（比如在非 Android 平台跑）
      _bundledAmapKey = null;
    }
  }

  /// 构建时注入到 AndroidManifest 的高德 Key。没注入则为 null。
  static String? get bundledAmapKey => _bundledAmapKey;
}
