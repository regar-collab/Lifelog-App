import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';

part 'settings_dao.g.dart';

/// 非敏感配置的键值读写。
///
/// 敏感数据（API Key）不走这里，走 flutter_secure_storage。
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> get(String key) async {
    final AppSetting? row =
        await (select(appSettings)..where((t) => t.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  /// 读一个值，没有就用默认值。
  Future<String> getOrDefault(String key, String fallback) async {
    return (await get(key)) ?? fallback;
  }

  /// 写值（存在就覆盖）。
  Future<void> set(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: Value(value)),
    );
  }

  /// 订阅某个键，设置一变 UI 就能跟着刷新。
  Stream<String?> watch(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((AppSetting? row) => row?.value);
  }

  Stream<String> watchOrDefault(String key, String fallback) {
    return watch(key).map((String? v) => v ?? fallback);
  }
}
