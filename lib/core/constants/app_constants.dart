/// 全局常量集中管理，避免魔法字符串散落各处。
class AppConstants {
  AppConstants._();

  /// 启动器上显示的应用名（要改中文名就改这里）
  static const String appName = 'Lifelog';

  // ── 安全存储的 key（flutter_secure_storage）──────────────
  /// 旧版 DeepSeek Key，保留用于自动迁移到 ai_api_key_deepseek。
  static const String keyDeepSeekApiKey = 'deepseek_api_key';

  /// 各 AI 供应商的 Key 前缀，完整 key 形如 ai_api_key_deepseek。
  static const String keyAiApiKeyPrefix = 'ai_api_key_';

  static const String keyAmapApiKey = 'amap_api_key';

  // ── 数据库 ────────────────────────────────────────────────
  static const String dbName = 'lifelog_db';

  // ── 前台服务通知渠道 ──────────────────────────────────────
  static const String trackChannelId = 'lifelog_track_channel';
  static const String trackChannelName = '轨迹记录';
  static const String trackChannelDesc = '全天记录定位时显示的常驻通知';
  static const int trackNotificationId = 1001;

  // ── 轨迹采样默认值 ────────────────────────────────────────
  /// 采样间隔（秒）
  static const int defaultSampleIntervalSec = 15;

  /// 移动距离小于该值（米）则不记录，用于过滤静止时的漂移。
  /// geolocator 的 distanceFilter 参数就是 int，所以这里也用 int。
  static const int defaultDistanceFilterM = 15;
}
