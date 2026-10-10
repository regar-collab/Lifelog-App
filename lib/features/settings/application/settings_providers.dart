import 'package:lifelog/data/services/deepseek_service.dart';
import 'package:lifelog/data/services/secure_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// 已保存的 DeepSeek API Key。没配过时为 null。
@riverpod
Future<String?> deepSeekApiKey(Ref ref) {
  return SecureSettings.instance.deepSeekApiKey;
}

/// 按当前 Key 构造好的 DeepSeek 客户端。
///
/// 没配 Key 时直接抛 [DeepSeekException]，让调用方给出友好提示；
/// 这样各功能模块都不需要自己判断 Key 是否存在。
@riverpod
Future<DeepSeekService> deepSeekService(Ref ref) async {
  final key = await ref.watch(deepSeekApiKeyProvider.future);
  if (key == null || key.trim().isEmpty) {
    throw const DeepSeekException('还没配置 DeepSeek API Key，请先到设置页填写');
  }
  return DeepSeekService(apiKey: key.trim());
}
