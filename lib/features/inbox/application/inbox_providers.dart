import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/inbox_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';
import 'package:lifelog/features/inbox/data/inbox_repository.dart';

// 注意：这个文件里的 provider 是**手写**的，没有用 @riverpod 代码生成。
//
// 原因：riverpod_generator 解析不了 drift_dev 纯生成的行类（InboxItem），
// 会对返回 Stream<List<InboxItem>> 的 provider 抛
// InvalidTypeException: The type is invalid and cannot be converted to code.
// （返回 AppDatabase 那种手写类的 provider 则正常，所以 database_provider 仍用生成。）
//
// 手写一行等价于生成的一行，行为完全一致。

/// 收集箱的数据库操作。
final inboxDaoProvider = Provider<InboxDao>(
  (Ref ref) => InboxDao(ref.watch(appDatabaseProvider)),
);

/// 收集箱业务入口，UI 只跟它打交道。
final inboxRepositoryProvider = Provider<InboxRepository>(
  (Ref ref) => InboxRepository(ref.watch(inboxDaoProvider)),
);

/// 全部条目（不含归档）。数据库一变就自动推送新列表。
final inboxItemsProvider = StreamProvider<List<InboxItem>>(
  (Ref ref) => ref.watch(inboxRepositoryProvider).watchAll(),
);

/// 待整理条数，给 Tab 角标用。
final inboxPendingCountProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(inboxRepositoryProvider).watchPendingCount(),
);

/// 某个条目的完整变更历史（创建 + 每次编辑），旧→新。
final inboxRevisionsProvider =
    StreamProvider.family<List<InboxItemRevision>, int>(
  (Ref ref, int itemId) =>
      ref.watch(inboxRepositoryProvider).watchRevisions(itemId),
);
