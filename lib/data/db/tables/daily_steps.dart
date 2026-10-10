import 'package:drift/drift.dart';

/// 每日步数。
///
/// 硬件计步传感器（`TYPE_STEP_COUNTER`）给的是「**开机以来**的累计步数」，
/// 重启手机会清零 —— 所以不能直接拿它当「今天走了多少」。
///
/// 这张表存两个值来还原每日步数：
/// - [lastRaw]：上次读到的传感器原始值
/// - [steps]：按天累计出来的真实步数
///
/// 每次读到新值时用增量累加；如果新值反而更小，说明手机重启过，就重设基线。
@DataClassName('DailyStep')
class DailySteps extends Table {
  @override
  String get tableName => 'daily_steps';

  /// 日期键，格式 `yyyy-MM-dd`
  TextColumn get dateKey => text()();

  /// 当天累计步数
  IntColumn get steps => integer().withDefault(const Constant(0))();

  /// 上次读到的传感器原始累计值
  IntColumn get lastRaw => integer().withDefault(const Constant(0))();

  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {dateKey};
}
