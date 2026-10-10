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
    return OrganizeDraft(
      title: _asString(json['title']) ?? '未命名',
      description: _asString(json['description']),
      startAt: _parseDate(json['start_at']) ?? DateTime.now(),
      endAt: _parseDate(json['end_at']),
      isAllDay: json['is_all_day'] == true,
      location: _asString(json['location']),
      priority: _asInt(json['priority']) ?? 0,
      sourceIndexes: (json['source_indexes'] as List<dynamic>?)
              ?.map(_asInt)
              .whereType<int>()
              .toList() ??
          const [],
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
    return DateTime.tryParse(normalized);
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
  });

  /// 本次整理在 ai_runs 里的记录 id
  final int aiRunId;

  final List<OrganizeDraft> drafts;

  /// 参与本次整理的收集箱条目 id
  final List<int> inboxItemIds;

  final String? rawResponse;
  final int? promptTokens;
  final int? completionTokens;
}
