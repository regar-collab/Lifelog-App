/// AI 整理产出的一条日程草案。
///
/// 这是「还没写进数据库」的中间形态 —— 用户确认之前不碰 schedules 表。
/// 手写 fromJson 而不是用 codegen：模型偶尔会漏字段或给错类型，
/// 这里要能宽容地兜住，不能一有偏差就整批崩掉。
class OrganizeDraft {
  const OrganizeDraft({
    required this.title,
    required this.startAt,
    this.description,
    this.endAt,
    this.isAllDay = false,
    this.location,
    this.priority = 0,
    this.sourceIndexes = const [],
  });

  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final bool isAllDay;
  final String? location;
  final int priority;

  /// 来源收集箱条目的序号（从 1 开始），用于溯源
  final List<int> sourceIndexes;

  factory OrganizeDraft.fromJson(Map<String, dynamic> json) {
    final String? title = _asString(json['title']);
    if (title == null) {
      throw const FormatException('草案缺少标题');
    }

    // 时间缺失/非法时直接丢弃这条草案。以前会静默回退到“现在”，
    // 用户很容易把一条时间错误的日程写进日程表。
    final DateTime? startAt = _parseDate(json['start_at']);
    if (startAt == null) {
      throw const FormatException('草案缺少合法的开始时间');
    }

    final DateTime? rawEnd = _parseDate(json['end_at']);
    final int? priority = _asInt(json['priority']);
    final Object? rawIndexes = json['source_indexes'];

    return OrganizeDraft(
      title: title,
      description: _asString(json['description']),
      startAt: startAt,
      endAt: (rawEnd != null && rawEnd.isAfter(startAt)) ? rawEnd : null,
      isAllDay: json['is_all_day'] == true,
      location: _asString(json['location']),
      priority: priority == 1 ? 1 : 0,
      sourceIndexes: rawIndexes is List
          ? rawIndexes.map(_asInt).whereType<int>().toList()
          : const <int>[],
    );
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _asInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    // 模型有时会给 "2026-10-11 15:00:00"（空格而非 T），统一成标准格式
    final normalized = value.trim().replaceFirst(' ', 'T');
    final DateTime? parsed = DateTime.tryParse(normalized);
    // 带 Z / +08:00 时 tryParse 返回 UTC，直接取 hour 会差时区；
    // 统一转成本地时间，预览和入库都用同一套时刻。
    return parsed?.toLocal();
  }
}

/// 一次整理的结果。
class OrganizeOutcome {
  const OrganizeOutcome({
    required this.aiRunId,
    required this.drafts,
    required this.inboxItemIds,
    this.rawResponse,
    this.promptTokens,
    this.completionTokens,
    this.skippedDrafts = 0,
  });

  /// 本次整理在 ai_runs 里的记录 id
  final int aiRunId;

  final List<OrganizeDraft> drafts;

  /// 参与本次整理的收集箱条目 id
  final List<int> inboxItemIds;

  final String? rawResponse;
  final int? promptTokens;
  final int? completionTokens;

  /// 模型返回了、但字段不合法而被跳过的草案数量。
  final int skippedDrafts;
}
