import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';
import 'package:lifelog/features/schedule/presentation/widgets/schedule_bubble.dart';
import 'package:lifelog/features/schedule/presentation/widgets/time_axis.dart';

/// 模块 3 日程表：一周视图。
///
/// 布局思路刻意区别于课表：
/// - 左侧是一把「时间尺」，不是等高格子
/// - 每条日程按真实时刻连续定位，30 分钟就是一道窄条，3 小时就是一根长条
/// - 中间的空隙就是真实的空闲时间
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  static const double hourHeight = 76;
  static const double axisWidth = 92;
  static const double dayWidth = 300;
  static const double headerHeight = 62;

  /// 纵向显示的小时范围。全天 24 小时（半夜也可能有安排）。
  static const int startHour = 0;
  static const int endHour = 24;

  late DateTime _anchor;

  final ScrollController _vController = ScrollController();
  final ScrollController _hBody = ScrollController();
  final ScrollController _hHead = ScrollController();
  bool _syncing = false;

  /// 当前展开的那条日程（双击展开来源原文）
  int? _expandedId;

  @override
  void initState() {
    super.initState();
    _anchor = DateTime.now();
    _hBody.addListener(_syncHeader);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToNow());
  }

  @override
  void dispose() {
    _hBody.removeListener(_syncHeader);
    _vController.dispose();
    _hBody.dispose();
    _hHead.dispose();
    super.dispose();
  }

  /// 表头跟着网格横向同步 —— 两个 ScrollController 手拉手。
  void _syncHeader() {
    if (_syncing || !_hHead.hasClients || !_hBody.hasClients) return;
    _syncing = true;
    final double target = _hBody.offset.clamp(
      0.0,
      _hHead.position.maxScrollExtent,
    );
    _hHead.jumpTo(target);
    _syncing = false;
  }

  /// 打开时滚到「现在」——垂直方向让当前时刻落在屏幕偏上位置，
  /// 横向滚到今天那一列。
  ///
  /// 首帧时 ScrollController 可能还没 attach（hasClients 为 false），
  /// 或者 maxScrollExtent 仍是 0（内容还没测量），所以带重试。
  void _jumpToNow({int attempt = 0}) {
    if (attempt > 12) return;

    final bool vReady =
        _vController.hasClients && _vController.position.maxScrollExtent > 0;
    final bool hReady =
        _hBody.hasClients && _hBody.position.maxScrollExtent > 0;

    if (!vReady || !hReady) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _jumpToNow(attempt: attempt + 1),
      );
      return;
    }

    final DateTime now = DateTime.now();

    final double y = (now.hour + now.minute / 60) * hourHeight - 240;
    _vController.jumpTo(y.clamp(0.0, _vController.position.maxScrollExtent));

    final double x = (now.weekday - 1) * dayWidth - 20;
    _hBody.jumpTo(x.clamp(0.0, _hBody.position.maxScrollExtent));
  }

  void _shiftWeek(int delta) {
    setState(() {
      _anchor = _anchor.add(Duration(days: 7 * delta));
      _expandedId = null;
    });
  }

  void _backToToday() {
    setState(() {
      _anchor = DateTime.now();
      _expandedId = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToNow());
  }

  Future<void> _confirmDelete(Schedule schedule) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('删除这条日程？'),
        content: Text('「${schedule.title}」将被删除，来源的收集箱条目不受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(scheduleRepositoryProvider).delete(schedule.id);
    if (!mounted) return;
    setState(() => _expandedId = null);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime monday = _mondayOf(_anchor);
    final AsyncValue<List<Schedule>> weekAsync = ref.watch(
      weekSchedulesProvider(monday),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('日程'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            tooltip: '回到本周',
            onPressed: _backToToday,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'schedule-new-fab',
        onPressed: () => context.push('/schedule/new'),
        icon: const Icon(Icons.add),
        label: const Text('新建日程'),
      ),
      body: Column(
        children: [
          _buildWeekNav(theme, monday),
          const Divider(height: 1),
          _buildHeaderRow(theme, monday),
          const Divider(height: 1),
          Expanded(
            child: switch (weekAsync) {
              AsyncData(:final List<Schedule> value) => _buildScrollableGrid(
                theme,
                monday,
                value,
              ),
              AsyncError(:final Object error) => Center(
                child: Text('读取失败：$error'),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  // ── 周导航 ────────────────────────────────────────────────

  Widget _buildWeekNav(ThemeData theme, DateTime monday) {
    final DateTime sunday = monday.add(const Duration(days: 6));
    final bool isThisWeek = _sameDay(monday, _mondayOf(DateTime.now()));

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: '上一周',
            onPressed: () => _shiftWeek(-1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isThisWeek
                      ? '本周'
                      : '${monday.month}月${monday.day}日 — '
                            '${sunday.month}月${sunday.day}日',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${monday.year} 年',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: '下一周',
            onPressed: () => _shiftWeek(1),
          ),
        ],
      ),
    );
  }

  // ── 星期表头（固定，横向与网格同步）──────────────────────

  Widget _buildHeaderRow(ThemeData theme, DateTime monday) {
    return SizedBox(
      height: headerHeight,
      child: Row(
        children: [
          SizedBox(width: axisWidth),
          Expanded(
            child: SingleChildScrollView(
              controller: _hHead,
              scrollDirection: Axis.horizontal,
              // 表头不让用户直接滑，只跟随网格
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  for (int i = 0; i < 7; i++)
                    _DayHeaderCell(
                      date: monday.add(Duration(days: i)),
                      width: dayWidth,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 网格（纵向滚动 + 横向滚动）────────────────────────────

  Widget _buildScrollableGrid(
    ThemeData theme,
    DateTime monday,
    List<Schedule> schedules,
  ) {
    final double totalHeight = (endHour - startHour) * hourHeight;

    return SingleChildScrollView(
      controller: _vController,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimeAxis(
            hourHeight: hourHeight,
            width: axisWidth,
            startHour: startHour,
            endHour: endHour,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _hBody,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: dayWidth * 7,
                height: totalHeight,
                child: Row(
                  children: [
                    for (int i = 0; i < 7; i++)
                      _DayColumn(
                        date: monday.add(Duration(days: i)),
                        schedules: schedules.where((Schedule s) {
                          final DateTime d =
                              DateTime.fromMillisecondsSinceEpoch(s.startAt);
                          return _sameDay(d, monday.add(Duration(days: i)));
                        }).toList(),
                        hourHeight: hourHeight,
                        dayWidth: dayWidth,
                        startHour: startHour,
                        endHour: endHour,
                        expandedId: _expandedId,
                        onToggleExpand: (int id) => setState(
                          () => _expandedId = _expandedId == id ? null : id,
                        ),
                        onEdit: (Schedule s) =>
                            context.push('/schedule/edit?id=${s.id}'),
                        onDelete: _confirmDelete,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 单天列 ──────────────────────────────────────────────────

class _DayColumn extends ConsumerWidget {
  const _DayColumn({
    required this.date,
    required this.schedules,
    required this.hourHeight,
    required this.dayWidth,
    required this.startHour,
    required this.endHour,
    required this.expandedId,
    required this.onToggleExpand,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime date;
  final List<Schedule> schedules;
  final double hourHeight;
  final double dayWidth;
  final int startHour;
  final int endHour;
  final int? expandedId;
  final ValueChanged<int> onToggleExpand;
  final ValueChanged<Schedule> onEdit;
  final ValueChanged<Schedule> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isToday = _sameDay(date, DateTime.now());
    final int hours = endHour - startHour;
    // 再复制一层：即使 _layoutColumns 以后改成返回只读列表也不会崩
    final List<_Laid> laid = [..._layoutColumns(schedules)];

    // 展开的那条排到最后画，保证它在最上层，不会被下面的气泡压住
    laid.sort((_Laid a, _Laid b) {
      final bool ea = a.schedule.id == expandedId;
      final bool eb = b.schedule.id == expandedId;
      if (ea == eb) return 0;
      return ea ? 1 : -1;
    });

    return Container(
      width: dayWidth,
      height: hours * hourHeight,
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.025)
            : null,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Stack(
        children: [
          // 小时刻度线
          for (int i = 0; i <= hours; i++)
            Positioned(
              top: i * hourHeight,
              left: 0,
              right: 0,
              child: Container(
                height: 0.5,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
            ),

          // 当前时刻指示线
          if (isToday) _nowIndicator(theme),

          // 日程气泡
          for (final _Laid item in laid) _buildBubble(context, ref, item),
        ],
      ),
    );
  }

  Widget _buildBubble(BuildContext context, WidgetRef ref, _Laid item) {
    final Schedule s = item.schedule;
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(s.startAt);

    final double top = ((start.hour * 60 + start.minute) / 60) * hourHeight;

    final DateTime end = s.endAt != null
        ? DateTime.fromMillisecondsSinceEpoch(s.endAt!)
        : start.add(const Duration(minutes: 45));
    final int minutes = end.difference(start).inMinutes.clamp(20, 24 * 60);

    final double slotWidth = dayWidth / item.totalColumns;
    final double left = item.column * slotWidth + 2;
    final bool isExpanded = s.id == expandedId;

    List<InboxItem>? sourceItems;
    bool sourceLoading = false;
    if (isExpanded) {
      final AsyncValue<List<InboxItem>> async = ref.watch(
        scheduleSourceItemsProvider(s.id),
      );
      switch (async) {
        case AsyncData(:final List<InboxItem> value):
          sourceItems = value;
        case AsyncError():
          sourceItems = const [];
        default:
          sourceLoading = true;
      }
    }

    // 不展开时给死高度：高度 = 时长占比，最短 40（保证可点、能放下标题）
    final double bubbleHeight = (minutes / 60 * hourHeight).clamp(
      40.0,
      24 * hourHeight,
    );

    return Positioned(
      top: top,
      left: left,
      width: slotWidth - 4,
      // 展开时高度置空，让详情内容自己撑开
      height: isExpanded ? null : bubbleHeight,
      child: ScheduleBubble(
        schedule: s,
        minHeight: bubbleHeight,
        isExpanded: isExpanded,
        onDoubleTap: () => onToggleExpand(s.id),
        onEdit: () => onEdit(s),
        onDelete: () => onDelete(s),
        sourceItems: sourceItems,
        sourceLoading: sourceLoading,
      ),
    );
  }

  Widget _nowIndicator(ThemeData theme) {
    final DateTime now = DateTime.now();
    final double top = ((now.hour * 60 + now.minute) / 60) * hourHeight;

    return Positioned(
      top: top - 2,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeaderCell extends StatelessWidget {
  const _DayHeaderCell({required this.date, required this.width});

  final DateTime date;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isToday = _sameDay(date, DateTime.now());

    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: isToday
              ? BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdayName(date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isToday ? theme.colorScheme.primary : null,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 重叠布局 ────────────────────────────────────────────────

class _Laid {
  const _Laid(this.schedule, this.column, this.totalColumns);

  final Schedule schedule;
  final int column;
  final int totalColumns;
}

/// 把一天里时间重叠的日程并排摆开。
///
/// 贪心分配：按开始时间排序，每条找第一个「已经空出来」的列；
/// 一列都塞不下就新开一列。同一天共用同一个总列数 ——
/// 算法简单、结果稳定，复杂排布以后再说。
List<_Laid> _layoutColumns(List<Schedule> items) {
  // 必须返回可增长列表：调用方要对结果 sort，
  // 而 const [] 是不可变的，sort 会抛 Unsupported operation
  if (items.isEmpty) return <_Laid>[];

  final List<Schedule> sorted = [...items]
    ..sort((Schedule a, Schedule b) => a.startAt.compareTo(b.startAt));

  final List<int> columnEnds = [];
  final List<int> assigned = [];

  for (final Schedule s in sorted) {
    final int start = s.startAt;
    final int end = s.endAt ?? (start + 30 * 60 * 1000);

    int col = -1;
    for (int i = 0; i < columnEnds.length; i++) {
      if (columnEnds[i] <= start) {
        col = i;
        break;
      }
    }

    if (col == -1) {
      columnEnds.add(end);
      col = columnEnds.length - 1;
    } else {
      columnEnds[col] = end;
    }
    assigned.add(col);
  }

  final int total = columnEnds.length;
  // 用 List.generate 而不是 […]，因为调用方还要按「展开的排最后」重排一次，
  // 而定长列表不支持 sort
  return List<_Laid>.generate(
    sorted.length,
    (int i) => _Laid(sorted[i], assigned[i], total),
  );
}

// ── 日期小工具 ──────────────────────────────────────────────

DateTime _mondayOf(DateTime d) {
  final DateTime day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: d.weekday - 1));
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _weekdayName(DateTime d) {
  const List<String> names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return names[d.weekday - 1];
}
