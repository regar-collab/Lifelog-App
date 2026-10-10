import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/app.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/data/services/native_config.dart';
import 'package:lifelog/features/track/application/track_foreground_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 打开前台服务与主 isolate 之间的通信端口。
  // 必须在 runApp 之前调用。
  FlutterForegroundTask.initCommunicationPort();

  // 提前把图片根目录缓存起来，列表滚动时就不必每张图都查一次 path_provider
  await MediaStorage.warmUp();

  // 读一次构建期注入的高德 Key（在 manifest 里，Dart 侧看不到，得问原生）
  await NativeConfig.warmUp();

  // 前台服务只需初始化一次；没在记录轨迹时它不会真正启动
  TrackForegroundService.init();

  runApp(const ProviderScope(child: LifelogApp()));
}
