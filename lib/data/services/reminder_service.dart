import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:lifelog/core/router/app_router.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/schedule_dao.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// 日程提醒。
///
/// 设计成「监听日程表 → 全量重建提醒」，而不是在每个增删改入口手动调用。
/// 这样无论是手动建日程、AI 整理写入，还是修改/完成/删除，都会自动同步，
/// 不会漏掉某条路径。
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'lifelog_schedule_reminder';
  static const String _channelName = '日程提醒';
  static const String _channelDesc = '日程开始前提醒你';
  static const int _testNotificationId = 999999;

  bool _initialized = false;
  StreamSubscription<List<Schedule>>? _subscription;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // 拿不到系统时区时保留默认值；提醒仍能工作，只是极端时区下可能偏几小时
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _openSchedule(response.payload);
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// 启动监听。重复调用不会产生多个订阅。
  Future<void> start(ScheduleDao dao) async {
    await initialize();
    _subscription ??= dao.watchAll().listen((List<Schedule> schedules) {
      unawaited(sync(schedules));
    });
  }

  /// 按当前日程列表重建提醒。
  ///
  /// 只处理未来的 planned 日程；完成、取消、已过去的都不再提醒。
  Future<void> sync(List<Schedule> schedules) async {
    if (!_initialized) return;

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool enabled = await android?.areNotificationsEnabled() ?? true;
    if (!enabled) return;

    await _plugin.cancelAllPendingNotifications();

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final List<Schedule> upcoming =
        schedules
            .where((Schedule s) => s.status == 'planned' && s.startAt > nowMs)
            .toList()
          ..sort((Schedule a, Schedule b) => a.startAt.compareTo(b.startAt));

    for (final Schedule schedule in upcoming.take(50)) {
      try {
        await _scheduleOne(schedule);
      } catch (_) {
        // 单条失败不影响其它日程
      }
    }
  }

  Future<void> _scheduleOne(Schedule schedule) async {
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(
      schedule.startAt,
    );
    final DateTime now = DateTime.now();

    DateTime remindAt;
    String whenLabel;
    if (schedule.isAllDay) {
      remindAt = DateTime(start.year, start.month, start.day, 9, 0);
      whenLabel = '今天全天';
    } else {
      remindAt = start.subtract(const Duration(minutes: 10));
      whenLabel = '10 分钟后开始';
    }

    // 创建时已进入 10 分钟窗口，或已经过了提醒点：改为开始时提醒
    if (!remindAt.isAfter(now)) {
      if (!start.isAfter(now)) return;
      remindAt = start;
      whenLabel = '现在开始';
    }

    final List<String> parts = <String>[
      whenLabel,
      if (schedule.location?.trim().isNotEmpty == true)
        schedule.location!.trim(),
      if (schedule.description?.trim().isNotEmpty == true)
        schedule.description!.trim(),
    ];
    final String body = parts.join(' · ');

    final AndroidScheduleMode mode = await _scheduleMode();
    final NotificationDetails details = _details(body);

    try {
      await _plugin.zonedSchedule(
        id: schedule.id,
        title: schedule.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(remindAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: mode,
        payload: 'schedule:${schedule.id}',
      );
    } on PlatformException {
      // 没有精确闹钟权限时退回非精确模式，最多延迟几分钟
      await _plugin.zonedSchedule(
        id: schedule.id,
        title: schedule.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(remindAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'schedule:${schedule.id}',
      );
    }
  }

  /// 设置页的“测试提醒”：5 秒后发一条本地通知。
  Future<void> scheduleTest() async {
    await initialize();

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final AndroidScheduleMode mode = await _scheduleMode();
    await _plugin.zonedSchedule(
      id: _testNotificationId,
      title: 'Lifelog 提醒测试',
      body: '看到这条通知，说明日程提醒已经配置成功。',
      scheduledDate: tz.TZDateTime.now(tz.local)
          .add(const Duration(seconds: 5)),
      notificationDetails: _details('看到这条通知，说明日程提醒已经配置成功。'),
      androidScheduleMode: mode,
    );
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bool exact = await android?.canScheduleExactNotifications() ?? false;
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _details(String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      ),
    );
  }

  /// 点通知时打开对应日程。
  void _openSchedule(String? payload) {
    if (payload == null || !payload.startsWith('schedule:')) return;
    final int? id = int.tryParse(payload.substring('schedule:'.length));
    if (id == null) return;
    try {
      appRouter.push('/schedule/edit?id=$id');
    } catch (_) {
      // 路由还没准备好时忽略，用户仍可从日程页进入
    }
  }
}
