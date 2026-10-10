/// 全局常量集中管理，避免魔法字符串散落各处。
class AppConstants {
  AppConstants._();

  /// 启动器上显示的应用名（要改中文名就改这里）
  static const String appName = 'Lifelog';

  // ── DeepSeek ──────────────────────────────────────────────
  static const String deepseekBaseUrl = 'https://api.deepseek.com';
  static const String deepseekChatPath = '/chat/completions';

  /// AI 整理统一用这个模型。
  ///
  /// deepseek-flash 是原生多模态的，纯文本和图片都能处理，
  /// 所以不需要按「有没有图」切换模型。
  /// 不使用 deepseek-reasoner（推理模型）：慢、贵，整理日程这种任务用不上。
  static const String deepseekModel = 'deepseek-flash';

  // ── 安全存储的 key（flutter_secure_storage）──────────────
  static const String keyDeepSeekApiKey = 'deepseek_api_key';
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
