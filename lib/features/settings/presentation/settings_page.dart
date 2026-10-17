import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifelog/core/constants/app_constants.dart';
import 'package:lifelog/data/services/ai/ai_provider_presets.dart';
import 'package:lifelog/data/services/ai/ai_service.dart';
import 'package:lifelog/data/services/reminder_service.dart';
import 'package:lifelog/data/services/secure_settings.dart';
import 'package:lifelog/features/settings/application/ai_providers.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/settings/application/settings_providers.dart';

/// 设置页：AI 供应商、高德 Key、轨迹精度。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _baseController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _visionController = TextEditingController();
  final TextEditingController _amapController = TextEditingController();

  bool _aiInitialized = false;
  String _providerId = 'deepseek';
  bool _aiLoading = false;
  bool _obscure = true;
  bool _saving = false;
  bool _testing = false;
  String? _result;
  bool _resultOk = false;

  bool _amapInitialized = false;
  bool _amapSaving = false;
  String? _amapResult;
  bool _amapResultOk = false;

  bool _reminderTesting = false;
  String? _reminderResult;
  bool _reminderResultOk = false;

  @override
  void dispose() {
    _keyController.dispose();
    _baseController.dispose();
    _modelController.dispose();
    _visionController.dispose();
    _amapController.dispose();
    super.dispose();
  }

  void _fillAi(AiConfig config) {
    _providerId = config.providerId;
    _baseController.text = config.baseUrl;
    _modelController.text = config.model;
    _visionController.text = config.visionModel;
    _keyController.text = config.apiKey;
    _aiInitialized = true;
  }

  Future<void> _selectProvider(String id) async {
    if (id == _providerId) return;
    setState(() {
      _providerId = id;
      _aiLoading = true;
      _result = null;
    });

    try {
      final AiConfig config = await loadAiProviderConfig(
        ref.read(settingsDaoProvider),
        id,
      );
      if (!mounted) return;
      setState(() {
        _baseController.text = config.baseUrl;
        _modelController.text = config.model;
        _visionController.text = config.visionModel;
        _keyController.text = config.apiKey;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiLoading = false;
        _resultOk = false;
        _result = '读取该供应商配置失败：$e';
      });
    }
  }

  Future<void> _saveAi() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      final dao = ref.read(settingsDaoProvider);
      await dao.set(SettingKeys.aiActiveProvider, _providerId);
      await dao.set(
        SettingKeys.aiBaseUrl(_providerId),
        _baseController.text.trim(),
      );
      await dao.set(
        SettingKeys.aiModel(_providerId),
        _modelController.text.trim(),
      );
      await dao.set(
        SettingKeys.aiVisionModel(_providerId),
        _visionController.text.trim(),
      );

      final String key = _keyController.text.trim();
      if (key.isEmpty) {
        await SecureSettings.instance.clearAiApiKey(_providerId);
      } else {
        await SecureSettings.instance.setAiApiKey(_providerId, key);
      }

      ref.invalidate(aiConfigProvider);
      ref.invalidate(aiServiceProvider);

      if (!mounted) return;
      setState(() {
        _saving = false;
        _resultOk = true;
        _result = '已保存到本机加密存储';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _resultOk = false;
        _result = '保存失败：$e';
      });
    }
  }

  Future<void> _testAi() async {
    FocusScope.of(context).unfocus();

    final String key = _keyController.text.trim();
    final String baseUrl = _baseController.text.trim();
    final String model = _modelController.text.trim();

    final bool keyOptional = _providerId == 'ollama' || _providerId == 'custom';
    if (key.isEmpty && !keyOptional) {
      setState(() {
        _resultOk = false;
        _result = '请先填入 API Key';
      });
      return;
    }
    if (baseUrl.isEmpty || model.isEmpty) {
      setState(() {
        _resultOk = false;
        _result = 'Base URL 和模型名称都要填';
      });
      return;
    }

    setState(() {
      _testing = true;
      _result = null;
    });

    try {
      final AiProviderPreset preset = AiProviderPresets.byId(_providerId);
      final AiConfig config = AiConfig(
        providerId: _providerId,
        name: preset.name,
        style: preset.style,
        baseUrl: baseUrl,
        chatPath: preset.chatPath,
        model: model,
        visionModel: _visionController.text.trim(),
        apiKey: key,
        extraHeaders: preset.extraHeaders,
      );

      final AiService service = AiService.fromConfig(config);
      final String reply = await service.testConnection();
      if (!mounted) return;
      setState(() {
        _resultOk = true;
        _result = '连接正常。模型回复：${reply.trim()}';
      });
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() {
        _resultOk = false;
        _result = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultOk = false;
        _result = '连接失败：$e';
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _testReminder() async {
    setState(() {
      _reminderTesting = true;
      _reminderResult = null;
    });

    try {
      await ReminderService.instance.scheduleTest();
      if (!mounted) return;
      setState(() {
        _reminderTesting = false;
        _reminderResultOk = true;
        _reminderResult = '已安排，5 秒后应收到通知';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reminderTesting = false;
        _reminderResultOk = false;
        _reminderResult = '发送失败：$e';
      });
    }
  }

  Future<void> _saveAmapKey() async {
    FocusScope.of(context).unfocus();
    setState(() => _amapSaving = true);

    final String key = _amapController.text.trim();
    if (key.isEmpty) {
      await SecureSettings.instance.delete(AppConstants.keyAmapApiKey);
    } else {
      await SecureSettings.instance.setAmapApiKey(key);
    }
    ref.invalidate(amapApiKeyProvider);

    if (!mounted) return;
    setState(() {
      _amapSaving = false;
      _amapResultOk = true;
      _amapResult = key.isEmpty ? '已清空高德 Key' : '已保存。回到轨迹页就能看到地图了。';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AsyncValue<AiConfig> configAsync = ref.watch(aiConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: switch (configAsync) {
        AsyncData(:final AiConfig value) => _buildForm(context, theme, value),
        AsyncError(:final Object error) => Center(child: Text('读取配置失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, AiConfig config) {
    if (!_aiInitialized) {
      _fillAi(config);
    }

    final AiProviderPreset preset = AiProviderPresets.byId(_providerId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('AI 模型'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(_providerId),
                  initialValue: _providerId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: '供应商',
                    prefixIcon: Icon(Icons.hub_outlined),
                  ),
                  items: [
                    for (final AiProviderPreset p in AiProviderPresets.all)
                      DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: _aiLoading
                      ? null
                      : (String? id) {
                          if (id != null) _selectProvider(id);
                        },
                ),
                const SizedBox(height: 10),
                Text(
                  preset.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    height: 1.45,
                  ),
                ),
                if (preset.docsUrl.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  SelectableText(
                    preset.docsUrl,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (_aiLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  AbsorbPointer(
                    absorbing: _aiLoading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _keyController,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: 'API Key',
                            hintText: preset.keyHint,
                            prefixIcon: const Icon(Icons.key_outlined),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? '显示' : '隐藏',
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _baseController,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            labelText: 'Base URL',
                            hintText: 'https://api.example.com/v1',
                            prefixIcon: Icon(Icons.link_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _modelController,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            labelText: '模型名称',
                            hintText: '例如 gpt-4o-mini',
                            prefixIcon: Icon(Icons.smart_toy_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _visionController,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: const InputDecoration(
                            labelText: '视觉模型（可选）',
                            hintText: '有图时整批改用这个模型；留空复用主模型',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _saveAi,
                                icon: _saving
                                    ? const _TinySpinner()
                                    : const Icon(Icons.save_outlined, size: 18),
                                label: const Text('保存'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _testing ? null : _testAi,
                                icon: _testing
                                    ? const _TinySpinner()
                                    : const Icon(
                                        Icons.wifi_tethering,
                                        size: 18,
                                      ),
                                label: const Text('测试连接'),
                              ),
                            ),
                          ],
                        ),
                        if (_result != null) ...[
                          const SizedBox(height: 12),
                          _ResultBox(
                            message: _result!,
                            ok: _resultOk,
                            theme: theme,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Key 按供应商分别保存在本机加密存储里，不会上传。'
                          '旧版 DeepSeek Key 会自动读取。\n'
                          '只要这批内容里有任意一张图，整次整理会改用「视觉模型」'
                          '发一次请求（文字和图片一起发），不会拆成两次请求；'
                          '纯文本批次才用主模型。视觉模型留空则复用主模型。',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.psychology_alt_outlined),
            title: const Text('AI 人设与记忆'),
            subtitle: const Text('名字、头像、长期记忆、知识库'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/ai/settings'),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('高德地图（轨迹功能用）'),
        _buildAmapCard(context, theme),
        const SizedBox(height: 24),
        const _SectionTitle('轨迹'),
        _buildAccuracyCard(theme),
        const SizedBox(height: 24),
        const _SectionTitle('提醒'),
        _buildReminderCard(theme),
        const SizedBox(height: 24),
        const _SectionTitle('关于'),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('版本'),
                subtitle: Text('0.2.0 · AI 助手 / 多模型 / 多图 / 提醒'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.storage_outlined),
                title: Text('数据库'),
                subtitle: Text('SQLite / Drift，本地保存'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAmapCard(BuildContext context, ThemeData theme) {
    final AsyncValue<String?> keyAsync = ref.watch(amapApiKeyProvider);

    if (!_amapInitialized) {
      switch (keyAsync) {
        case AsyncData(:final String? value):
          _amapController.text = value ?? '';
          _amapInitialized = true;
        default:
          break;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amapController,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: '高德 Android Key',
                hintText: '32 位十六进制串',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _amapSaving ? null : _saveAmapKey,
              icon: _amapSaving
                  ? const _TinySpinner()
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('保存'),
            ),
            if (_amapResult != null) ...[
              const SizedBox(height: 12),
              _ResultBox(
                message: _amapResult!,
                ok: _amapResultOk,
                theme: theme,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '地图底图由高德提供，需要一个 Android Key。'
              '去 lbs.amap.com 免费申请（要实名认证），'
              '填「包名 + 签名 SHA1」。\n\n'
              'Key 只存在这台手机上，不会上传。'
              '不填也能用其它功能，只是轨迹页看不到地图。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_active_outlined),
              title: Text('日程提醒'),
              subtitle: Text(
                '日程开始前 10 分钟通知；全天日程当天 09:00 提醒。\n'
                '点通知可以直接打开对应日程。',
              ),
            ),
            OutlinedButton.icon(
              onPressed: _reminderTesting ? null : _testReminder,
              icon: _reminderTesting
                  ? const _TinySpinner()
                  : const Icon(Icons.notifications_outlined, size: 18),
              label: const Text('发送测试提醒（5 秒后）'),
            ),
            if (_reminderResult != null) ...[
              const SizedBox(height: 12),
              _ResultBox(
                message: _reminderResult!,
                ok: _reminderResultOk,
                theme: theme,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '需要允许通知权限。Android 12+ 如果没有允许「闹钟和提醒」，'
              '通知可能延迟几分钟，可以到系统设置里给 Lifelog 打开精确闹钟。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyCard(ThemeData theme) {
    final AsyncValue<TrackAccuracyLevel> async = ref.watch(
      trackAccuracyProvider,
    );
    final TrackAccuracyLevel current = switch (async) {
      AsyncData(:final TrackAccuracyLevel value) => value,
      _ => TrackAccuracyLevel.balanced,
    };

    return Card(
      child: Column(
        children: [
          for (int i = 0; i < TrackAccuracyLevel.values.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16),
            ListTile(
              title: Text(TrackAccuracyLevel.values[i].label),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  TrackAccuracyLevel.values[i].description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    height: 1.4,
                  ),
                ),
              ),
              trailing: current == TrackAccuracyLevel.values[i]
                  ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                  : null,
              onTap: () async {
                await ref
                    .read(settingsDaoProvider)
                    .set(
                      SettingKeys.trackAccuracy,
                      TrackAccuracyLevel.values[i].id,
                    );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({
    required this.message,
    required this.ok,
    required this.theme,
  });

  final String message;
  final bool ok;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            (ok
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer)
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: ok ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _TinySpinner extends StatelessWidget {
  const _TinySpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
