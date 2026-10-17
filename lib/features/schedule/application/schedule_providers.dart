import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/schedule_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/schedule/data/schedule_repository.dart';

// 说明：这些 provider 是手写的，没用 @riverpod 生成。
// 原因见 inbox_providers.dart —— riverpod_generator 解析不了
// drift_dev 纯生成的行类（Schedule），会抛 InvalidTypeException。

/// 日程表的数据库操作。
final scheduleDaoProvider = Provider<ScheduleDao>(
  (Ref ref) => ScheduleDao(ref.watch(appDatabaseProvider)),
);

/// 日程业务入口。
final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (Ref ref) => ScheduleRepository(
    ref.watch(scheduleDaoProvider),
    ref.watch(inboxDaoProvider),
  ),
);

/// 全部日程，按开始时间正序。
final schedulesProvider = StreamProvider<List<Schedule>>(
  (Ref ref) => ref.watch(scheduleRepositoryProvider).watchAll(),
);

/// 某一周的日程。参数是这一周任意一天（内部会归到那天的 00:00 起 7 天）。
///
/// autoDispose：每次翻周参数都不同，不释放的话翻过的每一周都会留下
/// 一个永久存活的数据库监听器。
final weekSchedulesProvider = StreamProvider.autoDispose
    .family<List<Schedule>, DateTime>((Ref ref, DateTime anchor) {
      final DateTime from = DateTime(anchor.year, anchor.month, anchor.day);
      final DateTime to = from.add(const Duration(days: 7));

      return ref
          .watch(scheduleRepositoryProvider)
          .watchRange(from.millisecondsSinceEpoch, to.millisecondsSinceEpoch);
    });

/// 某条日程的来源收集箱条目。双击气泡展开时才需要，所以用 FutureProvider
/// 而不是 StreamProvider —— 它是按需拉一次的快照。
final scheduleSourceItemsProvider = FutureProvider.autoDispose
    .family<List<InboxItem>, int>((Ref ref, int scheduleId) async {
      final repo = ref.watch(scheduleRepositoryProvider);
      final Schedule? schedule = await repo.findById(scheduleId);
      if (schedule == null) return const [];
      return repo.getSourceItems(schedule);
    });
