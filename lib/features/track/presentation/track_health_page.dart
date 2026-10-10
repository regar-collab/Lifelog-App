import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifelog/features/track/application/track_foreground_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// 轨迹保活自检。
///
/// 「全天记录」要成立，需要三个权限/设置同时到位。国内 ROM（尤其 vivo/iQOO
/// 的 OriginOS）后台管控很激进，任何一项没开都会导致轨迹中途断掉。
/// 这个页面把它们集中列出来，缺哪项就直接跳到对应的系统设置页。
class TrackHealthPage extends ConsumerStatefulWidget {
  const TrackHealthPage({super.key});

  @override
  ConsumerState<TrackHealthPage> createState() => _TrackHealthPageState();
}

class _TrackHealthPageState extends ConsumerState<TrackHealthPage> {
  bool _loading = true;

  bool _notification = false;
  bool _batteryOptimized = true; // true = 还开着电池优化（不理想）
  bool _backgroundLocation = false;
  bool _foregroundLocation = false;
  bool _locationServiceOn = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);

    final NotificationPermission notif =
        await FlutterForegroundTask.checkNotificationPermission();
    final bool ignoringBattery =
        await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    final bool bg = await Permission.locationAlways.isGranted;
    final LocationPermission fg = await Geolocator.checkPermission();
    final bool serviceOn = await Geolocator.isLocationServiceEnabled();

    if (!mounted) return;
    setState(() {
      _notification = notif == NotificationPermission.granted;
      _batteryOptimized = !ignoringBattery;
      _backgroundLocation = bg;
      _foregroundLocation =
          fg == LocationPermission.always || fg == LocationPermission.whileInUse;
      _locationServiceOn = serviceOn;
      _loading = false;
    });
  }

  /// 三件套是否都齐了
  bool get _allGood =>
      _notification &&
      !_batteryOptimized &&
      _backgroundLocation &&
      _foregroundLocation &&
      _locationServiceOn;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('后台保活自检'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新检查',
            onPressed: _refresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(theme),
                const SizedBox(height: 20),

                _CheckTile(
                  title: '定位服务',
                  description: '系统总开关，关掉的话谁都拿不到位置',
                  ok: _locationServiceOn,
                  actionLabel: '去开启',
                  onAction: () async {
                    await Geolocator.openLocationSettings();
                    _refresh();
                  },
                ),
                _CheckTile(
                  title: '定位权限',
                  description: 'App 能读取你的位置',
                  ok: _foregroundLocation,
                  actionLabel: '去授权',
                  onAction: () async {
                    await Geolocator.openAppSettings();
                    _refresh();
                  },
                ),
                _CheckTile(
                  title: '始终允许定位',
                  description: '锁屏 / 退到后台后仍能记录轨迹。'
                      'Android 11+ 只能手动到设置页选「始终允许」',
                  ok: _backgroundLocation,
                  actionLabel: '去设置',
                  onAction: () async {
                    await Permission.locationAlways.request();
                    _refresh();
                  },
                ),
                _CheckTile(
                  title: '通知权限',
                  description: '前台服务的常驻通知需要它，没有的话服务会被系统拒绝',
                  ok: _notification,
                  actionLabel: '去授权',
                  onAction: () async {
                    await TrackForegroundService.ensureNotificationPermission();
                    _refresh();
                  },
                ),
                _CheckTile(
                  title: '忽略电池优化',
                  description: '国内 ROM 对后台限制极狠，不关掉的话前台服务也可能被掐',
                  ok: !_batteryOptimized,
                  actionLabel: '去关闭',
                  onAction: () async {
                    TrackForegroundService.requestIgnoreBatteryOptimization();
                    await Future<void>.delayed(const Duration(seconds: 2));
                    _refresh();
                  },
                ),

                const SizedBox(height: 24),
                _buildRomHint(theme),
              ],
            ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final bool ok = _allGood;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ok
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.verified_outlined : Icons.warning_amber_rounded,
            color: ok ? theme.colorScheme.primary : theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ok ? '保活配置已就绪' : '还有项目没配好',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  ok
                      ? '锁屏和切后台都能继续记录轨迹'
                      : '下面标红的项目会导致轨迹中途断开',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRomHint(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone_android,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('vivo / iQOO 额外两步', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '上面五项是 Android 通用的。你的 iQOO 用的是 OriginOS，'
              '还需要手动做这两件事，否则前面的设置也会被系统推翻：\n\n'
              '1. 设置 → 电池 → 后台高耗电 → 允许 Lifelog\n'
              '2. 设置 → 应用管理 → 自启动 → 允许 Lifelog\n\n'
              '最后，在最近任务里把 Lifelog 的卡片下拉锁定，'
              '这样一键清理时它不会被清掉。',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.title,
    required this.description,
    required this.ok,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String description;
  final bool ok;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Icon(
          ok ? Icons.check_circle : Icons.cancel_outlined,
          color: ok ? theme.colorScheme.primary : theme.colorScheme.error,
        ),
        title: Text(title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.outline, height: 1.4),
          ),
        ),
        trailing: ok
            ? null
            : TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
      ),
    );
  }
}
