import 'package:intl/intl.dart';

/// 时间展示统一走这里，避免各页面各写一套格式。
class AppDate {
  AppDate._();

  static final DateFormat _hm = DateFormat('HH:mm');
  static final DateFormat _md = DateFormat('MM-dd');
  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');

  /// 拟人化时间：今天 14:30 / 昨天 09:05 / 3 天前 18:20 / 10-08 07:00
  static String friendly(int millis) {
    final t = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(t.year, t.month, t.day);
    final diff = today.difference(thatDay).inDays;

    if (diff == 0) return '今天 ${_hm.format(t)}';
    if (diff == 1) return '昨天 ${_hm.format(t)}';
    if (diff > 1 && diff < 7) return '$diff 天前 ${_hm.format(t)}';
    if (t.year == now.year) return '${_md.format(t)} ${_hm.format(t)}';
    return '${_ymd.format(t)} ${_hm.format(t)}';
  }

  /// 短时间，用于列表右侧：14:30 / 10-08 / 2025-10-08
  static String short(int millis) {
    final t = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(t.year, t.month, t.day);
    final diff = today.difference(thatDay).inDays;

    if (diff == 0) return _hm.format(t);
    if (t.year == now.year) return _md.format(t);
    return _ymd.format(t);
  }
}
