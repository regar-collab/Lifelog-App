import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lifelog/core/router/app_router.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/features/ai_chat/data/ai_chat_engine.dart';
import 'package:lifelog/features/ai_chat/data/chat_store.dart';
import 'package:lifelog/features/inbox/application/inbox_providers.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';
import 'package:lifelog/features/settings/application/app_settings_providers.dart';
import 'package:lifelog/features/steps/application/step_tracker.dart';
import 'package:lifelog/features/track/application/track_providers.dart';
import 'package:lifelog/features/track/application/track_recorder.dart';

/// 执行 AI 返回的操作。
///
/// 所有动作都走现有 Repository / Provider，不绕开业务层；
/// 动作结果会作为纯文本返回给模型，让模型继续用自然语言回复。
class ChatActionExecutor {
  ChatActionExecutor(this.ref);

  final WidgetRef ref;

  Future<String> execute(ChatAction action) async {
    try {
      switch (action.name) {
        case 'navigate':
          return await _navigate(action);
        case 'guide':
          return await _guide(action);
        case 'create_note':
          return await _createNote(action);
        case 'create_schedule':
          return await _createSchedule(action);
        case 'query':
          return await _query(action);
        case 'search':
          return await _search(action);
        case 'start_tracking':
          return await _startTracking();
        case 'stop_tracking':
          return await _stopTracking();
        case 'set_track_accuracy':
          return await _setTrackAccuracy(action);
        case 'open_location_settings':
          await Geolocator.openLocationSettings();
          return '已打开系统定位设置';
        case 'complete_schedule':
          return await _completeSchedule(action);
        case 'open_schedule':
          return await _openSchedule(action);
        case 'remember':
          return await _remember(action);
        case 'forget':
          return await _forget(action);
        case 'add_knowledge':
          return await _addKnowledge(action);
        default:
          return '暂不支持操作：${action.name}';
      }
    } catch (e) {
      return '操作 ${action.name} 失败：$e';
    }
  }

  Future<String> _navigate(ChatAction action) async {
    final String? route = action.stringArg('route')?.trim();
    if (route == null || route.isEmpty) return '缺少要打开的页面';
    _openRoute(route);
    return '已打开页面 $route';
  }

  Future<String> _guide(ChatAction action) async {
    final String? route = action.stringArg('route')?.trim();
    if (route == null || route.isEmpty) return '缺少要打开的页面';
    _openRoute(route);
    final String? tip = action.stringArg('tip')?.trim();
    return tip == null || tip.isEmpty ? '已打开页面 $route' : '已打开页面 $route；提示：$tip';
  }

  void _openRoute(String route) {
    const Set<String> tabRoutes = <String>{
      '/inbox',
      '/organize',
      '/schedule',
      '/track',
      '/ai',
    };
    if (tabRoutes.contains(route)) {
      appRouter.go(route);
    } else {
      appRouter.push(route);
    }
  }

  Future<String> _createNote(ChatAction action) async {
    final String content = action.stringArg('content')?.trim() ?? '';
    if (content.isEmpty) return '内容为空，没有写入收集箱';
    await ref.read(inboxRepositoryProvider).addText(content);
    return '已写入收集箱：${_short(content)}';
  }

  Future<String> _createSchedule(ChatAction action) async {
    final String title = action.stringArg('title')?.trim() ?? '';
    if (title.isEmpty) return '日程缺少标题';

    final DateTime? start = _parseDate(action.stringArg('start_at'));
    if (start == null) return '日程开始时间格式不正确';

    final DateTime? end = _parseDate(action.stringArg('end_at'));
    if (end != null && !end.isAfter(start)) {
      return '结束时间必须晚于开始时间';
    }

    final bool allDay = action.args['is_all_day'] == true;
    await ref
        .read(scheduleRepositoryProvider)
        .addManual(
          title: title,
          startAt: start,
          endAt: allDay ? null : end,
          description: action.stringArg('description')?.trim(),
          location: action.stringArg('location')?.trim(),
          isAllDay: allDay,
        );
    return '已创建日程：$title（${_formatDateTime(start)}）';
  }

  Future<String> _query(ChatAction action) async {
    final String target = action.stringArg('target')?.trim() ?? 'today';
    switch (target) {
      case 'inbox':
        return _queryInbox();
      case 'schedules':
        return _querySchedules();
      case 'steps':
        return _querySteps();
      case 'track':
        return _queryTrack();
      case 'today':
      default:
        return _queryToday();
    }
  }

  Future<String> _queryToday() async {
    final int pending =
        (await ref.read(inboxDaoProvider).getPendingItems()).length;
    final DailyStep? steps = await ref
        .read(stepDaoProvider)
        .getByDate(_dateKey(DateTime.now()));
    final summary = await ref.read(trackRepositoryProvider).todaySummary();
    final String schedules = await _upcomingScheduleText();
    return '待整理 $pending 条；今日步数 ${steps?.steps ?? 0}；'
        '今日轨迹 ${summary.distanceKm} 公里、${summary.pointCount} 个点；'
        '未来日程：${schedules.isEmpty ? '无' : schedules}';
  }

  Future<String> _queryInbox() async {
    final List<InboxItem> items = await ref
        .read(inboxDaoProvider)
        .watchAll()
        .first;
    if (items.isEmpty) return '收集箱是空的';
    return items
        .take(20)
        .map((InboxItem item) {
          final String content = item.content?.trim().isNotEmpty == true
              ? item.content!.trim()
              : '（图片/无备注）';
          return '${_short(content)} [${item.status}]';
        })
        .join('；');
  }

  Future<String> _querySchedules() async {
    final String text = await _upcomingScheduleText(limit: 20);
    return text.isEmpty ? '未来没有日程' : text;
  }

  Future<String> _upcomingScheduleText({int limit = 8}) async {
    final List<Schedule> all = await ref
        .read(scheduleDaoProvider)
        .watchAll()
        .first;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final List<Schedule> upcoming = all
        .where((Schedule s) => s.status == 'planned' && s.startAt > now)
        .take(limit)
        .toList();
    return upcoming
        .map((Schedule s) {
          return '${_formatDateTime(DateTime.fromMillisecondsSinceEpoch(s.startAt))} ${s.title}';
        })
        .join('；');
  }

  Future<String> _querySteps() async {
    final DailyStep? steps = await ref
        .read(stepDaoProvider)
        .getByDate(_dateKey(DateTime.now()));
    return '今天走了 ${steps?.steps ?? 0} 步';
  }

  Future<String> _queryTrack() async {
    final summary = await ref.read(trackRepositoryProvider).todaySummary();
    return '今天的轨迹：${summary.distanceKm} 公里，'
        '${summary.pointCount} 个定位点，约 ${summary.durationMinutes} 分钟';
  }

  Future<String> _search(ChatAction action) async {
    final String query = action.stringArg('query')?.trim().toLowerCase() ?? '';
    if (query.isEmpty) return '搜索词为空';

    final List<String> matches = <String>[];
    final List<InboxItem> inbox = await ref
        .read(inboxDaoProvider)
        .watchAll()
        .first;
    for (final InboxItem item in inbox) {
      final String text = item.content?.trim() ?? '';
      if (text.toLowerCase().contains(query)) {
        matches.add('收集箱：${_short(text)}');
      }
    }

    final List<Schedule> schedules = await ref
        .read(scheduleDaoProvider)
        .watchAll()
        .first;
    for (final Schedule s in schedules) {
      final String text = '${s.title} ${s.description ?? ''}';
      if (text.toLowerCase().contains(query)) {
        matches.add(
          '日程：${s.title}（${_formatDateTime(DateTime.fromMillisecondsSinceEpoch(s.startAt))}）',
        );
      }
    }

    return matches.isEmpty ? '没有找到和「$query」相关的内容' : matches.take(20).join('；');
  }

  Future<String> _startTracking() async {
    final TrackRecorder notifier = ref.read(trackRecorderProvider.notifier);
    await notifier.start();
    final TrackRecorderState state = ref.read(trackRecorderProvider);
    if (state.recording) return '已开始记录轨迹';
    return state.error ?? '未能开始记录，请到轨迹页检查定位和通知权限';
  }

  Future<String> _stopTracking() async {
    await ref.read(trackRecorderProvider.notifier).stop();
    return '已停止记录轨迹';
  }

  Future<String> _setTrackAccuracy(ChatAction action) async {
    final String level = action.stringArg('level')?.trim() ?? '';
    const Set<String> valid = <String>{'low', 'balanced', 'high'};
    if (!valid.contains(level)) return '精度只能是 low / balanced / high';
    await ref.read(settingsDaoProvider).set(SettingKeys.trackAccuracy, level);
    final String label = switch (level) {
      'low' => '省电',
      'high' => '高精度',
      _ => '平衡',
    };
    return '轨迹精度已切换为「$label」';
  }

  Future<String> _completeSchedule(ChatAction action) async {
    final Schedule? schedule = await _findSchedule(action);
    if (schedule == null) return '没有找到对应日程';
    await ref.read(scheduleRepositoryProvider).updateStatus(schedule, 'done');
    return '已把「${schedule.title}」标记为完成';
  }

  Future<String> _openSchedule(ChatAction action) async {
    final Schedule? schedule = await _findSchedule(action);
    if (schedule == null) return '没有找到对应日程';
    appRouter.push('/schedule/edit?id=${schedule.id}');
    return '已打开日程「${schedule.title}」';
  }

  Future<Schedule?> _findSchedule(ChatAction action) async {
    final int? id = action.intArg('id');
    final List<Schedule> all = await ref
        .read(scheduleDaoProvider)
        .watchAll()
        .first;
    if (id != null) {
      for (final Schedule s in all) {
        if (s.id == id) return s;
      }
    }
    final String title = action.stringArg('title')?.trim().toLowerCase() ?? '';
    if (title.isNotEmpty) {
      for (final Schedule s in all) {
        if (s.title.toLowerCase().contains(title)) return s;
      }
    }
    return null;
  }

  Future<String> _remember(ChatAction action) async {
    final String text = action.stringArg('text')?.trim() ?? '';
    if (text.isEmpty) return '记忆内容为空';
    final ChatStore store = ChatStore.instance;
    final List<ChatMemory> memories = await store.loadMemories();
    memories.add(ChatMemory(id: ChatStore.newId(), text: text, at: _nowMs));
    await store.saveMemories(memories);
    return '已记住：$text';
  }

  Future<String> _forget(ChatAction action) async {
    final String text = action.stringArg('text')?.trim().toLowerCase() ?? '';
    if (text.isEmpty) return '要忘记的内容为空';
    final ChatStore store = ChatStore.instance;
    final List<ChatMemory> memories = await store.loadMemories();
    final int before = memories.length;
    memories.removeWhere((ChatMemory m) => m.text.toLowerCase().contains(text));
    await store.saveMemories(memories);
    final int removed = before - memories.length;
    return removed == 0 ? '没有找到相关记忆' : '已删除 $removed 条相关记忆';
  }

  Future<String> _addKnowledge(ChatAction action) async {
    final String title = action.stringArg('title')?.trim() ?? '';
    final String content = action.stringArg('content')?.trim() ?? '';
    if (title.isEmpty || content.isEmpty) return '知识条目缺少标题或内容';
    final ChatStore store = ChatStore.instance;
    final List<ChatKnowledge> items = await store.loadKnowledge();
    items.add(
      ChatKnowledge(
        id: ChatStore.newId(),
        title: title,
        content: content,
        at: _nowMs,
      ),
    );
    await store.saveKnowledge(items);
    return '已写入知识库：$title';
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final String normalized = raw.trim().replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized)?.toLocal();
  }

  String _dateKey(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)}';
  }

  String _formatDateTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  int get _nowMs => DateTime.now().millisecondsSinceEpoch;

  String _short(String text, [int max = 60]) {
    final String t = text.replaceAll('\n', ' ').trim();
    return t.length <= max ? t : '${t.substring(0, max)}…';
  }
}
