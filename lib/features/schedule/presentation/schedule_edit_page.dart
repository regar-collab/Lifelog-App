import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/features/schedule/application/schedule_providers.dart';

/// 手动新建 / 编辑日程。
///
/// AI 生成的日程也能在这里改 —— 模型排的时间不一定合你意。
class ScheduleEditPage extends ConsumerStatefulWidget {
  const ScheduleEditPage({super.key, this.scheduleId});

  final int? scheduleId;

  @override
  ConsumerState<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends ConsumerState<ScheduleEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late DateTime _startAt;
  DateTime? _endAt;
  bool _isAllDay = false;
  int _priority = 0;

  Schedule? _editing;
  bool _loading = false;
  bool _saving = false;

  bool get _isEditMode => widget.scheduleId != null;

  @override
  void initState() {
    super.initState();

    // 新建时默认排到下一个整点，持续一小时
    final DateTime now = DateTime.now();
    _startAt = DateTime(now.year, now.month, now.day, now.hour + 1);
    _endAt = _startAt.add(const Duration(hours: 1));

    if (_isEditMode) {
      _loading = true;
      _load();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final Schedule? s = await ref
        .read(scheduleRepositoryProvider)
        .findById(widget.scheduleId!);
    if (!mounted) return;
    if (s == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _editing = s;
      _titleController.text = s.title;
      _descController.text = s.description ?? '';
      _locationController.text = s.location ?? '';
      _startAt = DateTime.fromMillisecondsSinceEpoch(s.startAt);
      _endAt = s.endAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(s.endAt!);
      _isAllDay = s.isAllDay;
      _priority = s.priority;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null || !mounted) return;

    // 保留「跨夜」信息：原来结束是次日 01:00，换日期后仍然是次日 01:00
    final DateTime? oldEnd = _endAt;
    int endDayOffset = 0;
    if (oldEnd != null) {
      final DateTime oldStartDay = DateTime(
        _startAt.year,
        _startAt.month,
        _startAt.day,
      );
      final DateTime oldEndDay = DateTime(
        oldEnd.year,
        oldEnd.month,
        oldEnd.day,
      );
      endDayOffset = oldEndDay.difference(oldStartDay).inDays;
    }

    setState(() {
      _startAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _startAt.hour,
        _startAt.minute,
      );
      if (oldEnd != null) {
        _endAt = DateTime(
          picked.year,
          picked.month,
          picked.day + endDayOffset,
          oldEnd.hour,
          oldEnd.minute,
        );
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final DateTime base = isStart
        ? _startAt
        : (_endAt ?? _startAt.add(const Duration(hours: 1)));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (picked == null || !mounted) return;

    setState(() {
      final DateTime dt = DateTime(
        _startAt.year,
        _startAt.month,
        _startAt.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _startAt = dt;
        // 结束时间不晚于开始时间就顺手推后一小时，避免存出负数时长
        if (_endAt != null && !_endAt!.isAfter(_startAt)) {
          _endAt = _startAt.add(const Duration(hours: 1));
        }
      } else {
        // 选到比开始更早的时刻，视为次日（例如 23:00 → 01:00）
        _endAt = dt.isAfter(_startAt) ? dt : dt.add(const Duration(days: 1));
      }
    });
  }

  /// 结束时间可能落在次日，显示时要说清楚，避免用户以为是同一天。
  String _endTimeLabel(DateTime end) {
    final DateTime startDay = DateTime(
      _startAt.year,
      _startAt.month,
      _startAt.day,
    );
    final DateTime endDay = DateTime(end.year, end.month, end.day);
    final int offset = endDay.difference(startDay).inDays;
    final String time = DateFormat('HH:mm').format(end);
    if (offset <= 0) return time;
    if (offset == 1) return '次日 $time';
    return '+$offset 天 $time';
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    final String title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('给它起个标题吧')));
      return;
    }

    if (!_isAllDay && _endAt != null && !_endAt!.isAfter(_startAt)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('结束时间必须晚于开始时间')));
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(scheduleRepositoryProvider);
    final String desc = _descController.text.trim();
    final String loc = _locationController.text.trim();

    try {
      if (!_isEditMode) {
        await repo.addManual(
          title: title,
          startAt: _startAt,
          description: desc.isEmpty ? null : desc,
          endAt: _isAllDay ? null : _endAt,
          isAllDay: _isAllDay,
          location: loc.isEmpty ? null : loc,
          priority: _priority,
        );
      } else {
        final Schedule? s = _editing;
        if (s == null) {
          setState(() => _saving = false);
          return;
        }
        await repo.edit(
          s,
          title: title,
          description: desc,
          startAt: _startAt,
          endAt: _isAllDay ? null : _endAt,
          clearEndAt: _isAllDay || _endAt == null,
          isAllDay: _isAllDay,
          location: loc,
          priority: _priority,
        );
      }

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('保存失败：$e')));
    }
  }

  Future<void> _delete() async {
    final Schedule? s = _editing;
    if (s == null) return;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('删除这条日程？'),
        content: const Text('删除后无法恢复。来源的收集箱条目不受影响。'),
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
    if (ok != true || !mounted) return;

    await ref.read(scheduleRepositoryProvider).delete(s.id);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _toggleDone() async {
    final Schedule? s = _editing;
    if (s == null) return;
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.updateStatus(s, s.status == 'done' ? 'planned' : 'done');
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '编辑日程' : '新建日程'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中…' : '保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _titleController,
                  autofocus: !_isEditMode,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    hintText: '要做什么',
                  ),
                ),
                const SizedBox(height: 14),

                // 日期
                _FieldTile(
                  icon: Icons.calendar_today_outlined,
                  label: '日期',
                  value: _fullDate(_startAt),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 8),

                // 全天
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isAllDay,
                  onChanged: (bool v) => setState(() => _isAllDay = v),
                  title: const Text('全天'),
                  dense: true,
                ),

                if (!_isAllDay) ...[
                  _FieldTile(
                    icon: Icons.schedule_outlined,
                    label: '开始',
                    value: DateFormat('HH:mm').format(_startAt),
                    onTap: () => _pickTime(isStart: true),
                  ),
                  const SizedBox(height: 8),
                  _FieldTile(
                    icon: Icons.schedule_outlined,
                    label: '结束',
                    value: _endAt == null ? '未设置' : _endTimeLabel(_endAt!),
                    onTap: () => _pickTime(isStart: false),
                    trailing: _endAt == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: '清除结束时间',
                            onPressed: () => setState(() => _endAt = null),
                          ),
                  ),
                ],

                const SizedBox(height: 14),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: '地点',
                    hintText: '可以留空',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    hintText: '可以留空',
                  ),
                ),
                const SizedBox(height: 18),

                Text('优先级', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(value: 0, label: Text('普通')),
                    ButtonSegment<int>(value: 1, label: Text('重要')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (Set<int> v) =>
                      setState(() => _priority = v.first),
                ),

                if (_isEditMode) ...[
                  const SizedBox(height: 28),
                  if (_editing?.origin.startsWith('ai') ?? false) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '这条是 AI 整理的产物',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: _toggleDone,
                    icon: Icon(
                      _editing?.status == 'done'
                          ? Icons.undo
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      _editing?.status == 'done' ? '标记为未完成' : '标记为已完成',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除这条日程'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

/// 手写完整日期，避免为了中文 locale 去初始化 intl 的 locale 数据。
String _fullDate(DateTime d) {
  const List<String> names = ['一', '二', '三', '四', '五', '六', '日'];
  return '${d.year}年${d.month}月${d.day}日 星期${names[d.weekday - 1]}';
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Text(label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
