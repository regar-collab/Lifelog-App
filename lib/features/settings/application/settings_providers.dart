import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/services/secure_settings.dart';

/// 已保存的高德 Android Key。没配过时为 null。
///
/// 手写 provider（不用 @riverpod 生成），这样 AI 配置那部分可以独立演进，
/// 不必为了一个 provider 去跑 codegen。
final amapApiKeyProvider = FutureProvider<String?>(
  (Ref ref) => SecureSettings.instance.amapApiKey,
);
