import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/daos/settings_dao.dart';
import 'package:lifelog/data/services/ai/ai_provider_presets.dart';
import 'package:lifelog/data/services/ai/ai_service.dart';
import 'package:lifelog/data/services/secure_settings.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';

/// 当前生效的 AI 配置。设置页保存后 invalidate 即可刷新。
final aiConfigProvider = FutureProvider<AiConfig>((Ref ref) async {
  final SettingsDao dao = ref.watch(settingsDaoProvider);
  final String providerId = await dao.getOrDefault(
    SettingKeys.aiActiveProvider,
    'deepseek',
  );
  return loadAiProviderConfig(dao, providerId);
});

/// 按当前配置构造出的 AI 服务。
final aiServiceProvider = FutureProvider<AiService>((Ref ref) async {
  final AiConfig config = await ref.watch(aiConfigProvider.future);

  // Ollama / 自定义本地接口通常不需要 Key，其余供应商需要。
  final bool keyOptional =
      config.providerId == 'ollama' || config.providerId == 'custom';
  if (!keyOptional && config.apiKey.trim().isEmpty) {
    throw const AiException('还没配置 AI API Key，请先到设置页填写');
  }

  return AiService.fromConfig(config);
});

/// 读取某个供应商的配置。
///
/// 每一项都优先读用户保存过的值，没有则用预设默认值。
/// DeepSeek 首次升级时会自动读取旧版的 deepseek_api_key。
Future<AiConfig> loadAiProviderConfig(
  SettingsDao dao,
  String providerId,
) async {
  final AiProviderPreset preset = AiProviderPresets.byId(providerId);

  final String baseUrl = await dao.getOrDefault(
    SettingKeys.aiBaseUrl(providerId),
    preset.baseUrl,
  );
  final String model = await dao.getOrDefault(
    SettingKeys.aiModel(providerId),
    preset.model,
  );
  final String visionModel = await dao.getOrDefault(
    SettingKeys.aiVisionModel(providerId),
    preset.visionModel,
  );

  String? key = await SecureSettings.instance.aiApiKey(providerId);
  if ((key == null || key.trim().isEmpty) && providerId == 'deepseek') {
    key = await SecureSettings.instance.deepSeekApiKey;
  }

  return AiConfig(
    providerId: providerId,
    name: preset.name,
    style: preset.style,
    baseUrl: baseUrl,
    chatPath: preset.chatPath,
    model: model,
    visionModel: visionModel,
    apiKey: key ?? '',
    extraHeaders: preset.extraHeaders,
  );
}
