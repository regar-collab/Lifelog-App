import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lifelog/core/utils/coordinate.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/services/native_config.dart';
import 'package:lifelog/features/settings/application/settings_providers.dart';
import 'package:lifelog/features/track/application/track_providers.dart';
import 'package:lifelog/features/track/presentation/widgets/amap_view.dart';

/// 历史轨迹会话详情：统计信息 + 这条轨迹的地图。
///
/// 地图只在打开详情时创建，关掉就释放，不额外常驻显存。
class TrackSessionDetailSheet extends ConsumerStatefulWidget {
  const TrackSessionDetailSheet({super.key, required this.session});

  final TrackSession session;

  @override
  ConsumerState<TrackSessionDetailSheet> createState() =>
      _TrackSessionDetailSheetState();
}

class _TrackSessionDetailSheetState
    extends ConsumerState<TrackSessionDetailSheet> {
  static final DateFormat _fmt = DateFormat('MM-dd HH:mm');

  late final Future<List<TrackPoint>> _pointsFuture;

  @override
  void initState() {
    super.initState();
    _pointsFuture = ref
        .read(trackRepositoryProvider)
        .getPoints(widget.session.id);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TrackSession session = widget.session;

    final AsyncValue<String?> keyAsync = ref.watch(amapApiKeyProvider);
    final String? userKey = switch (keyAsync) {
      AsyncData(:final String? value) => value,
      _ => null,
    };
    final String? apiKey = (userKey != null && userKey.trim().isNotEmpty)
        ? userKey.trim()
        : NativeConfig.bundledAmapKey;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text('轨迹详情', style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: '关闭',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _MetaRow(
                  label: '开始',
                  value: _fmt.format(
                    DateTime.fromMillisecondsSinceEpoch(session.startAt),
                  ),
                ),
                _MetaRow(
                  label: '结束',
                  value: session.endAt == null
                      ? '—'
                      : _fmt.format(
                          DateTime.fromMillisecondsSinceEpoch(session.endAt!),
                        ),
                ),
                _MetaRow(label: '时长', value: _durationLabel(session)),
                _MetaRow(
                  label: '里程',
                  value: '${(session.distanceM / 1000).toStringAsFixed(2)} 公里',
                ),
                _MetaRow(label: '定位点', value: '${session.pointCount} 个'),
                _MetaRow(
                  label: '状态',
                  value: switch (session.status) {
                    'recording' => '记录中',
                    'interrupted' => '被系统中断',
                    'finished' => '正常结束',
                    _ => session.status,
                  },
                ),
                const SizedBox(height: 18),
                FutureBuilder<List<TrackPoint>>(
                  future: _pointsFuture,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<TrackPoint>> snapshot,
                      ) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final List<LatLng> points = (snapshot.data ?? const [])
                            .where(
                              (TrackPoint p) =>
                                  p.latGcj != null && p.lngGcj != null,
                            )
                            .map((TrackPoint p) => LatLng(p.latGcj!, p.lngGcj!))
                            .toList();

                        if (points.isEmpty) {
                          return Container(
                            height: 160,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '这次会话没有可绘制的轨迹点',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          );
                        }

                        if (apiKey == null) {
                          return Container(
                            height: 160,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '配置高德 Key 后可以在这里查看当时的轨迹',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 300,
                            child: AmapView(points: points, apiKey: apiKey),
                          ),
                        );
                      },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(TrackSession session) {
    final int end = session.endAt ?? session.startAt;
    final int minutes = ((end - session.startAt) / 60000).round();
    if (minutes < 60) return '$minutes 分钟';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    return m == 0 ? '$h 小时' : '$h 小时 $m 分钟';
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
