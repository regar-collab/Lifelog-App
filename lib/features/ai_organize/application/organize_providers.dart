import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelog/data/db/daos/ai_run_dao.dart';
import 'package:lifelog/data/db/database_provider.dart';
import 'package:lifelog/features/ai_organize/data/organize_repository.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';

/// AI 整理记录的数据库操作。
final aiRunDaoProvider = Provider<AiRunDao>(
  (Ref ref) => AiRunDao(ref.watch(appDatabaseProvider)),
);

/// AI 整理业务入口。参数顺序：收集箱 → 日程 → 整理记录。
final organizeRepositoryProvider = Provider<OrganizeRepository>(
  (Ref ref) => OrganizeRepository(
    ref.watch(inboxDaoProvider),
    ref.watch(scheduleDaoProvider),
    ref.watch(aiRunDaoProvider),
  ),
);

/// 最近的整理记录，新→旧。
///
/// autoDispose + 摘要查询：离开整理页后释放订阅，且不把整段
/// prompt / rawResponse 留在内存里。
final aiRunsProvider = StreamProvider.autoDispose<List<AiRunSummary>>(
  (Ref ref) => ref.watch(aiRunDaoProvider).watchRecentSummaries(),
);
