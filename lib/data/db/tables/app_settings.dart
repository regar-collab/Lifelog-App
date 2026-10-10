import 'package:drift/drift.dart';

/// 非敏感配置的键值表。
///
/// 注意：DeepSeek API Key 这类密钥不放这里，
/// 走 flutter_secure_storage（Android 上是 EncryptedSharedPreferences）。
@DataClassName('AppSetting')
class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();

  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
