import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:lifelog/core/constants/app_constants.dart';

import 'tables/ai_runs.dart';
import 'tables/app_settings.dart';
import 'tables/daily_steps.dart';
import 'tables/inbox_item_revisions.dart';
import 'tables/inbox_items.dart';
import 'tables/schedules.dart';
import 'tables/track_points.dart';
import 'tables/track_sessions.dart';

// 把表定义转出去：引用 app_database.dart 的地方就能同时拿到
// 表类（InboxItems）和生成的行类（InboxItem），DAO 文件不必再逐个 import。
export 'tables/ai_runs.dart';
export 'tables/app_settings.dart';
export 'tables/daily_steps.dart';
export 'tables/inbox_item_revisions.dart';
export 'tables/inbox_items.dart';
export 'tables/schedules.dart';
export 'tables/track_points.dart';
export 'tables/track_sessions.dart';

part 'app_database.g.dart';

/// 应用主数据库。
///
/// 表结构改动时：递增 [schemaVersion]，并在 [migration] 的 onUpgrade 里
/// 补上对应的升级步骤。
///
/// 表结构变更历史：
/// - v1 → v2：新增条目变更历史表，收集箱加 organize_policy 字段
/// - v2 → v3：新增每日步数表
@DriftDatabase(
  tables: [
    InboxItems,
    InboxItemRevisions,
    Schedules,
    AiRuns,
    TrackSessions,
    TrackPoints,
    DailySteps,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 给测试用的构造：传入内存数据库执行器。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // 新增列。Drift 会自动带上默认值 'auto'。
            await m.addColumn(inboxItems, inboxItems.organizePolicy);
            await m.createTable(inboxItemRevisions);

            // 给已有条目补一条「创建」历史，否则老数据点进去历史是空的
            await m.database.customStatement(
              'INSERT INTO inbox_item_revisions (item_id, kind, content, recorded_at) '
              'SELECT id, \'created\', content, created_at FROM inbox_items',
            );
          }
          if (from < 3) {
            await m.createTable(dailySteps);
          }
          await _createIndexes();
        },
        beforeOpen: (OpeningDetails details) async {
          // 级联删除（轨迹点随会话、历史随条目）依赖这个开关
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Drift 不会为普通列自动建索引，这些查询在数据量上来后很关键。
  /// 用 IF NOT EXISTS，升级时重复执行也不会出错。
  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_inbox_status '
      'ON inbox_items(status, created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_revision_item '
      'ON inbox_item_revisions(item_id, recorded_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_schedule_start ON schedules(start_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_schedule_status '
      'ON schedules(status, start_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_point_session '
      'ON track_points(session_id, recorded_at)',
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: AppConstants.dbName);
}
