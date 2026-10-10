import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/core/utils/date_utils.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/features/track/application/track_providers.dart';
import 'package:lifelog/features/track/application/track_recorder.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/steps/application/step_tracker.dart';
import 'package:lifelog/features/track/data/track_repository.dart';
import 'package:lifelog/features/track/presentation/widgets/amap_view.dart';

/// 模块 4 定位轨迹。
///
/// 当前版本先做「采集 + 统计」：能录、能落库、能看到今天走了多远。
/// 地图绘制等配置好高德 Key 之后再接上。
class TrackPage extends ConsumerWidget {
  const TrackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    final TrackRecorderState recorder = ref.watch(trackRecorderProvider);
    final AsyncValue<TrackSummary> todayAsync = ref.watch(todaySummaryProvider);
    final AsyncValue<List<TrackSession>> sessionsAsync =
        ref.watch(trackSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('轨迹'),
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: '后台保活自检',
            onPressed: () => context.push('/track/health'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _buildTodayCard(theme, todayAsync),
          const SizedBox(height: 14),
          _buildStepsCard(ref, theme),
          const SizedBox(height: 14),
          _buildControlCard(context, ref, theme, recorder),
          const SizedBox(height: 14),
          _buildMap(ref, theme),
          const SizedBox(height: 26),
          Text(
            '历史记录',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          switch (sessionsAsync) {
            AsyncData(:final List<TrackSession> value) => value.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      '还没有记录过轨迹',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  )
                : Card(
                    child: Column(
                      children: [
                        for (int i = 0; i < value.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 16),
                          _SessionTile(session: value[i]),
                        ],
                      ],
                    ),
                  ),
            AsyncError(:final Object error) => Text('读取失败：$error'),
            _ => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
          },
        ],
      ),
    );
  }

  Widget _buildTodayCard(ThemeData theme, AsyncValue<TrackSummary> async) {
    final TrackSummary? summary = switch (async) {
      AsyncData(:final TrackSummary value) => value,
      _ => null,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('今天', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: summary == null ? '—' : summary.distanceKm,
                    unit: '公里',
                    label: '里程',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    value: summary == null
                        ? '—'
                        : '${summary.durationMinutes}',
                    unit: '分钟',
                    label: '时长',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    value: summary == null ? '—' : '${summary.pointCount}',
                    unit: '个',
                    label: '定位点',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    TrackRecorderState recorder,
  ) {
    final bool recording = recorder.recording;

    // 文案跟着当前精度档位走 —— 采样间距是随档位变的，不能写死
    final AsyncValue<TrackAccuracyLevel> accuracyAsync =
        ref.watch(trackAccuracyProvider);
    final TrackAccuracyLevel level = switch (accuracyAsync) {
      AsyncData(:final TrackAccuracyLevel value) => value,
      _ => TrackAccuracyLevel.balanced,
    };
    final int intervalM = switch (level) {
      TrackAccuracyLevel.low => 50,
      TrackAccuracyLevel.balanced => 15,
      TrackAccuracyLevel.high => 10,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recorder.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline,
                        size: 18, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recorder.error!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (recording) ...[
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '正在记录',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                  const Spacer(),
                  Text(
                    '已采集 ${recorder.bufferedCount} 个待写入',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
              if (recorder.lastLat != null) ...[
                const SizedBox(height: 6),
                Text(
                  '最近位置：${recorder.lastLat!.toStringAsFixed(5)}, '
                  '${recorder.lastLng!.toStringAsFixed(5)}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: recorder.starting
                  ? null
                  : () async {
                      final TrackRecorder notifier =
                          ref.read(trackRecorderProvider.notifier);
                      if (recording) {
                        await notifier.stop();
                      } else {
                        await notifier.start();
                      }
                    },
              icon: Icon(recording ? Icons.stop : Icons.play_arrow_rounded),
              label: Text(
                recorder.starting
                    ? '启动中…'
                    : (recording ? '停止记录' : '开始记录'),
              ),
              style: recording
                  ? FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    )
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              recording
                  ? '前台服务已启动，锁屏和切到后台都会继续记录。'
                      '如果轨迹还是断，请到系统设置里给 Lifelog 打开「自启动」'
                      '和「后台高耗电允许」。'
                  : '当前「${level.label}」档：移动约 $intervalM 米采集一个点，'
                      '静止时不耗电。想更细腻或更省电，去设置页切档位。',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  /// 今日步数。
  ///
  /// 数据和轨迹是两套独立机制：步数来自硬件计步芯片（微信运动用的也是它），
  /// 不用 GPS、不用前台服务，几乎不耗电。
  Widget _buildStepsCard(WidgetRef ref, ThemeData theme) {
    final StepTrackerState steps = ref.watch(stepTrackerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_walk,
                    color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text('今日步数', style: theme.textTheme.titleMedium),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${steps.todaySteps}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: ' 步',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (steps.error != null) ...[
              const SizedBox(height: 10),
              Text(
                steps.error!,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ] else if (!steps.available) ...[
              const SizedBox(height: 6),
              Text(
                '正在读取计步传感器…',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                '走一步就有一格，和微信运动用的是同一颗计步芯片，'
                '不用 GPS、不额外耗电。'
                '但芯片只报「开机以来的总数」，所以 App 没打开时那段路程'
                '要等下次打开才补上——建议每天早上打开一次。',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMap(WidgetRef ref, ThemeData theme) {
    final AsyncValue<List<LatLng>> pointsAsync =
        ref.watch(trackMapPointsProvider);

    final List<LatLng> points = switch (pointsAsync) {
      AsyncData(:final List<LatLng> value) => value,
      _ => const [],
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 320,
        child: Stack(
          children: [
            AmapView(points: points),
            if (points.isEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  color: theme.colorScheme.surface.withValues(alpha: 0.92),
                  child: Text(
                    '还没有轨迹点。点「开始记录」带着手机走一段，轨迹就会画在这里。',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}


class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.unit,
    required this.label,
  });

  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final TrackSession session;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool interrupted = session.status == 'interrupted';

    return ListTile(
      dense: true,
      leading: Icon(
        interrupted ? Icons.warning_amber_outlined : Icons.route_outlined,
        size: 20,
        color: interrupted
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      title: Text(AppDate.friendly(session.startAt)),
      subtitle: Text(
        '${(session.distanceM / 1000).toStringAsFixed(2)} 公里 · '
        '${session.pointCount} 个点'
        '${interrupted ? ' · 被系统中断' : ''}',
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.outline),
      ),
    );
  }
}
