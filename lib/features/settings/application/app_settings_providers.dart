import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/daos/settings_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';

/// 配置项的键。集中放这里，避免字符串散落各处写错。
class SettingKeys {
  SettingKeys._();

  /// 轨迹定位精度：high | balanced | low
  static const String trackAccuracy = 'track_accuracy';

  /// 移动多少米才采集一个点
  static const String trackDistanceFilter = 'track_distance_filter';
}

/// 轨迹精度的三档，附带给用户看的说明。
enum TrackAccuracyLevel {
  low(
    id: 'low',
    label: '省电',
    description: '约 100~500 米精度。轨迹只能看出大致的区域范围，最省电。',
  ),
  balanced(
    id: 'balanced',
    label: '平衡',
    description: '约 30~100 米精度。能看出走过的大致路线，耗电适中。',
  ),
  high(
    id: 'high',
    label: '高精度',
    description: '约 5~30 米精度。能看出具体的路线和拐弯，最耗电。',
  );

  const TrackAccuracyLevel({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;

  static TrackAccuracyLevel fromId(String? id) {
    return values.firstWhere(
      (TrackAccuracyLevel e) => e.id == id,
      orElse: () => TrackAccuracyLevel.balanced,
    );
  }
}

final settingsDaoProvider = Provider<SettingsDao>(
  (Ref ref) => SettingsDao(ref.watch(appDatabaseProvider)),
);

/// 当前轨迹精度档位。
final trackAccuracyProvider = StreamProvider<TrackAccuracyLevel>(
  (Ref ref) => ref
      .watch(settingsDaoProvider)
      .watchOrDefault(
        SettingKeys.trackAccuracy,
        TrackAccuracyLevel.balanced.id,
      )
      .map(TrackAccuracyLevel.fromId),
);
