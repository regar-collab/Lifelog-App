import 'package:lifelog/data/db/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// 全局唯一的数据库实例。
///
/// 所有 DAO / Repository 都从这里取，不要各自 new AppDatabase()。
@riverpod
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}
