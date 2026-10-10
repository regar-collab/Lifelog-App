import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lifelog/core/constants/app_constants.dart';

/// 密钥存储。Android 上落在 EncryptedSharedPreferences，不进数据库。
///
/// 第一版没有云端，Key 只能存在设备本地 —— 所以务必不要把 Key 写进代码、
/// 也不要提交到版本库。App 卸载重装需要重新填。
class SecureSettings {
  SecureSettings._();

  static final SecureSettings instance = SecureSettings._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  // ── DeepSeek ──────────────────────────────────────────────
  Future<String?> get deepSeekApiKey =>
      read(AppConstants.keyDeepSeekApiKey);

  Future<void> setDeepSeekApiKey(String value) =>
      write(AppConstants.keyDeepSeekApiKey, value);

  Future<void> clearDeepSeekApiKey() =>
      delete(AppConstants.keyDeepSeekApiKey);

  // ── 高德（轨迹模块用）────────────────────────────────────
  Future<String?> get amapApiKey => read(AppConstants.keyAmapApiKey);

  Future<void> setAmapApiKey(String value) =>
      write(AppConstants.keyAmapApiKey, value);
}
