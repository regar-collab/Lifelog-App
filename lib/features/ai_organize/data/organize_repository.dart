import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lifelog/core/constants/app_constants.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/ai_run_dao.dart';
import 'package:lifelog/data/db/daos/inbox_dao.dart';
import 'package:lifelog/data/db/daos/schedule_dao.dart';
import 'package:lifelog/data/services/deepseek_service.dart';
import 'package:lifelog/data/services/media_storage.dart';
import 'package:lifelog/features/ai_organize/domain/organize_draft.dart';
import 'package:lifelog/features/ai_organize/domain/organize_prompt.dart';
import 'package:path/path.dart' as p;

/// AI 整理的业务逻辑。
///
/// 分成两步是刻意的：
/// - [generateDrafts] 只调模型、拿草案，**不写日程表**
/// - [commit] 在用户确认之后才落库
///
/// 这样模型抽风生成的离谱日程不会直接污染用户的日程表。
class OrganizeRepository {
  /// 三个 DAO 按「收集箱 → 日程 → 整理记录」的顺序传入。
  OrganizeRepository(this._inboxDao, this._scheduleDao, this._aiRunDao);

  final InboxDao _inboxDao;
  final ScheduleDao _scheduleDao;
  final AiRunDao _aiRunDao;

  /// 单次整理最多带多少张图，防止请求体过大和费用失控。
  static const int maxImages = 10;

  /// 第一步：收集待整理条目 → 调模型 → 返回草案（不写库）。
  ///
  /// [ai] 由调用方传入：API Key 存在安全存储里，读取是异步的，
  /// 没法在 Repository 构造时同步拿到。
  Future<OrganizeOutcome> generateDrafts(DeepSeekService ai) async {
    final List<InboxItem> items = await _inboxDao.getPendingItems();

    if (items.isEmpty) {
      throw const OrganizeException('收集箱里没有待整理的内容');
    }

    final DateTime now = DateTime.now();
    const String model = AppConstants.deepseekModel;

    final int runId = await _aiRunDao.insertRun(
      AiRunsCompanion.insert(
        status: 'running',
        model: model,
        inputItemIds: Value(jsonEncode(items.map((e) => e.id).toList())),
        startedAt: now.millisecondsSinceEpoch,
      ),
    );

    try {
      final String prompt = buildOrganizePrompt(items: items, now: now);
      final List<String> images = await _collectImages(items);

      // 统一用同一个多模态模型：有没有图都用它，不必切换。
      final String reply = images.isEmpty
          ? await ai.chat(
              prompt: prompt,
              model: model,
              jsonMode: true,
              temperature: 0.2,
            )
          : await ai.chatWithImages(
              prompt: prompt,
              images: images,
              model: model,
              jsonMode: true,
              temperature: 0.2,
            );

      final List<OrganizeDraft> drafts = _parseDrafts(reply);

      await _aiRunDao.updateRun(
        AiRun(
          id: runId,
          status: 'success',
          model: model,
          inputItemIds: jsonEncode(items.map((e) => e.id).toList()),
          requestPrompt: prompt,
          rawResponse: reply,
          createdCount: drafts.length,
          errorMessage: null,
          promptTokens: null,
          completionTokens: null,
          startedAt: now.millisecondsSinceEpoch,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      return OrganizeOutcome(
        aiRunId: runId,
        drafts: drafts,
        inboxItemIds: items.map((e) => e.id).toList(),
        rawResponse: reply,
      );
    } catch (e) {
      await _aiRunDao.updateRun(
        AiRun(
          id: runId,
          status: 'failed',
          model: model,
          inputItemIds: jsonEncode(items.map((e) => e.id).toList()),
          requestPrompt: null,
          rawResponse: null,
          createdCount: 0,
          errorMessage: e.toString(),
          promptTokens: null,
          completionTokens: null,
          startedAt: now.millisecondsSinceEpoch,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      rethrow;
    }
  }

  /// 第二步：把用户勾选的草案写进日程表，并把对应的收集箱条目标记为已整理。
  ///
  /// 注意：只要这次整理跑成功了，无论用户勾选了几条（哪怕一条都没勾），
  /// 参与整理的收集箱条目都会标记为 processed —— 否则它们会一直挂在待整理里。
  Future<int> commit({
    required OrganizeOutcome outcome,
    required List<OrganizeDraft> selected,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    // 草案里的 source_indexes 是 1-based 序号，按顺序对应参与整理的收集箱条目
    final Map<int, int> sourceIndexToItemId = {
      for (int i = 0; i < outcome.inboxItemIds.length; i++)
        i + 1: outcome.inboxItemIds[i],
    };

    final List<SchedulesCompanion> rows = selected.map((draft) {
      final List<int> itemIds = draft.sourceIndexes
          .map((idx) => sourceIndexToItemId[idx])
          .whereType<int>()
          .toList();

      return SchedulesCompanion.insert(
        title: draft.title,
        description: Value(draft.description),
        startAt: draft.startAt.millisecondsSinceEpoch,
        endAt: Value(draft.endAt?.millisecondsSinceEpoch),
        isAllDay: Value(draft.isAllDay),
        location: Value(draft.location),
        priority: Value(draft.priority),
        origin: const Value('ai'),
        aiRunId: Value(outcome.aiRunId),
        sourceItemIds: Value(itemIds.isEmpty ? null : jsonEncode(itemIds)),
        createdAt: now,
        updatedAt: now,
      );
    }).toList();

    if (rows.isNotEmpty) {
      await _scheduleDao.insertAll(rows);
    }

    await _inboxDao.markProcessed(outcome.inboxItemIds);

    return rows.length;
  }

  /// 把图片读出来转成 base64 data URL。
  ///
  /// 超过 [maxImages] 的图片会被丢掉 —— 宁可少看几张，也不要让请求超时。
  Future<List<String>> _collectImages(List<InboxItem> items) async {
    final List<String> dataUrls = [];

    for (final InboxItem item in items) {
      if (dataUrls.length >= maxImages) break;
      final String? path = item.imagePath;
      if (path == null) continue;

      try {
        final file = await MediaStorage.resolve(path);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
        final mime = switch (ext) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/jpeg',
        };
        dataUrls.add('data:$mime;base64,${base64Encode(bytes)}');
      } catch (_) {
        // 单张图读失败不该让整次整理失败
        continue;
      }
    }

    return dataUrls;
  }

  List<OrganizeDraft> _parseDrafts(String reply) {
    final String cleaned = _stripCodeFence(reply);
    final Object? decoded = jsonDecode(cleaned);

    if (decoded is! Map) {
      throw const OrganizeException('模型返回的不是 json 对象');
    }

    final Object? raw = decoded['schedules'];
    if (raw is! List) {
      throw const OrganizeException('模型返回里没有 schedules 字段');
    }

    return raw
        .whereType<Map>()
        .map((Map m) => OrganizeDraft.fromJson(m.cast<String, dynamic>()))
        .toList();
  }

  /// 有些模型会无视指令，把 json 包在 ```json ... ``` 里。
  String _stripCodeFence(String text) {
    String t = text.trim();
    if (!t.startsWith('```')) return t;

    final int firstNewline = t.indexOf('\n');
    if (firstNewline != -1) t = t.substring(firstNewline + 1);
    if (t.endsWith('```')) t = t.substring(0, t.length - 3);
    return t.trim();
  }
}

/// 整理过程中的业务异常，UI 直接展示它的 message。
class OrganizeException implements Exception {
  const OrganizeException(this.message);

  final String message;

  @override
  String toString() => message;
}
