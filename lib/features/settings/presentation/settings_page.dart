import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/core/constants/app_constants.dart';
import 'package:lifelog/data/services/deepseek_service.dart';
import 'package:lifelog/data/services/secure_settings.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/settings/application/settings_providers.dart';

/// 设置页。阶段 0 只做 DeepSeek API Key 的配置与连通性测试 ——
/// 有了这个按钮，才好在写 AI 整理之前先确认 Key 和网络是通的。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _amapController = TextEditingController();

  /// 只在首次拿到已保存的 Key 时回填一次，避免每次重建都覆盖用户输入
  bool _initialized = false;
  bool _amapInitialized = false;
  bool _obscure = true;
  bool _saving = false;
  bool _testing = false;
  String? _result;
  bool _resultOk = false;

  bool _amapSaving = false;
  String? _amapResult;
  bool _amapResultOk = false;

  @override
  void dispose() {
    _keyController.dispose();
    _amapController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final key = _keyController.text.trim();
    if (key.isEmpty) {
      await SecureSettings.instance.clearDeepSeekApiKey();
    } else {
      await SecureSettings.instance.setDeepSeekApiKey(key);
    }
    ref.invalidate(deepSeekApiKeyProvider);

    if (!mounted) return;
    setState(() {
      _saving = false;
      _resultOk = true;
      _result = key.isEmpty ? '已清空 API Key' : '已保存到本机加密存储';
    });
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
      _amapResult = key.isEmpty
          ? '已清空高德 Key'
          : '已保存。回到轨迹页就能看到地图了。';
    });
  }

  Future<void> _test() async {
    FocusScope.of(context).unfocus();
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      setState(() {
        _resultOk = false;
        _result = '请先填入 API Key';
      });
      return;
    }

    setState(() {
      _testing = true;
      _result = null;
    });

    try {
      final reply = await DeepSeekService(apiKey: key).testConnection();
      if (!mounted) return;
      setState(() {
        _resultOk = true;
        _result = '连接正常。模型回复：${reply.trim()}';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final int? code = e.response?.statusCode;
      final Object? detail = e.response?.data;
      setState(() {
        _resultOk = false;
        _result = switch (code) {
          401 => '连接失败（HTTP 401）：API Key 无效或已过期',
          402 => '连接失败（HTTP 402）：账户余额不足',
          429 => '连接失败（HTTP 429）：请求过于频繁，稍后再试',
          null => '连接失败：${e.message}（检查网络）',
          _ => '连接失败（HTTP $code）：$detail',
        };
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AsyncValue<String?> keyValue = ref.watch(deepSeekApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: switch (keyValue) {
        AsyncData(:final String? value) => _buildForm(context, theme, value),
        AsyncError(:final Object error) =>
          Center(child: Text('读取配置失败：$error')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(BuildContext context, ThemeData theme, String? savedKey) {
    if (!_initialized) {
      _keyController.text = savedKey ?? '';
      _initialized = true;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('DeepSeek'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                    hintText: 'sk-...',
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? '显示' : '隐藏',
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const _TinySpinner()
                            : const Icon(Icons.save_outlined, size: 18),
                        label: const Text('保存'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _test,
                        icon: _testing
                            ? const _TinySpinner()
                            : const Icon(Icons.wifi_tethering, size: 18),
                        label: const Text('测试连接'),
                      ),
                    ),
                  ],
                ),
                if (_result != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_resultOk
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.errorContainer)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _resultOk
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          size: 18,
                          color: _resultOk
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _result!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Key 只存在这台手机的加密存储里（EncryptedSharedPreferences），'
                  '不会上传到任何第三方。AI 整理统一使用 ${AppConstants.deepseekModel}。',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('高德地图（轨迹功能用）'),
        _buildAmapCard(context, theme),
        const SizedBox(height: 24),
        const _SectionTitle('轨迹'),
        _buildAccuracyCard(theme),
        const SizedBox(height: 24),
        const _SectionTitle('关于'),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('版本'),
                subtitle: Text('0.1.0 · 阶段 0（地基）'),
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

  /// 高德地图 Key 的配置卡片。
  ///
  /// 为什么要在 App 里填而不是打包进 APK：高德 Key 绑定使用者的
  /// 签名 SHA1，每个人都不一样，没法预先打包。所以由使用者自己申请、
  /// 自己填，存在手机本地。
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_amapResultOk
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer)
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _amapResultOk
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: _amapResultOk
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_amapResult!,
                          style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '地图底图由高德提供，需要一个 Android Key。'
              '去 lbs.amap.com 免费申请（要实名认证），'
              '填「包名 + 签名 SHA1」。\n\n'
              'Key 只存在这台手机上，不会上传。'
              '不填也能用其它功能，只是轨迹页看不到地图。',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 轨迹精度选择。精度越高耗电越多，这是用户自己的取舍。
  Widget _buildAccuracyCard(ThemeData theme) {
    final AsyncValue<TrackAccuracyLevel> async =
        ref.watch(trackAccuracyProvider);
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
                await ref.read(settingsDaoProvider).set(
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
