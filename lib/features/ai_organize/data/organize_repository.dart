import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lifelog/data/db/app_database.dart';
import 'package:lifelog/data/db/daos/ai_run_dao.dart';
import 'package:lifelog/data/db/daos/inbox_dao.dart';
import 'package:lifelog/data/db/daos/schedule_dao.dart';
import 'package:lifelog/data/services/ai/ai_service.dart';
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
  Future<OrganizeOutcome> generateDrafts(AiService ai) async {
    final List<InboxItem> items = await _inboxDao.getPendingItems();

    if (items.isEmpty) {
      throw const OrganizeException('收集箱里没有待整理的内容');
    }

    final DateTime now = DateTime.now();
    final String model = '${ai.providerName} / ${ai.modelName}';

    final int runId = await _aiRunDao.insertRun(
      AiRunsCompanion.insert(
        status: 'running',
        model: model,
        inputItemIds: Value(jsonEncode(items.map((e) => e.id).toList())),
        startedAt: now.millisecondsSinceEpoch,
      ),
    );

    // 失败时也尽量保留 prompt 和模型原始返回，方便事后排查/救数据
    String? prompt;
    String? reply;

    try {
      // 先收集图片，再拼 prompt：prompt 必须知道哪些图真的发出去了
      final _ImageBundle bundle = await _collectImages(items);

      prompt = buildOrganizePrompt(
        items: items,
        now: now,
        sentImageCounts: bundle.sentCounts,
        totalImageCounts: bundle.totalCounts,
      );

      // 有没有图都走同一个服务；没有图时用主模型，有图时用视觉模型。
      reply = bundle.dataUrls.isEmpty
          ? await ai.chat(prompt: prompt, jsonMode: true, temperature: 0.2)
          : await ai.chatWithImages(
              prompt: prompt,
              images: bundle.dataUrls,
              jsonMode: true,
              temperature: 0.2,
            );

      final _ParsedDrafts parsed = _parseDrafts(reply);

      await _aiRunDao.updateRun(
        AiRun(
          id: runId,
          status: 'success',
          model: model,
          inputItemIds: jsonEncode(items.map((e) => e.id).toList()),
          requestPrompt: prompt,
          rawResponse: reply,
          createdCount: parsed.drafts.length,
          errorMessage: null,
          promptTokens: null,
          completionTokens: null,
          startedAt: now.millisecondsSinceEpoch,
          finishedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      return OrganizeOutcome(
        aiRunId: runId,
        drafts: parsed.drafts,
        skippedDrafts: parsed.skipped,
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
          requestPrompt: prompt,
          rawResponse: reply,
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

    final List<SchedulesCompanion> rows = <SchedulesCompanion>[];
    final Set<int> selectedItemIds = <int>{};

    for (final OrganizeDraft draft in selected) {
      final List<int> itemIds = draft.sourceIndexes
          .map((int idx) => sourceIndexToItemId[idx])
          .whereType<int>()
          .toList();
      selectedItemIds.addAll(itemIds);

      rows.add(
        SchedulesCompanion.insert(
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
        ),
      );
    }

    // 日程写入与收集箱标记必须是原子的：中途失败会导致同一批内容
    // 下次整理时再生成一遍，出现重复日程。
    return _scheduleDao.transaction(() async {
      // 重新整理时，先删掉上一轮由 AI 生成、用户没有编辑过的旧日程。
      // origin 变成 ai-edited 的说明用户手动改过，不能覆盖。
      final List<Schedule> stale = await _scheduleDao
          .getAiSchedulesBySourceItemIds(selectedItemIds.toList());
      if (stale.isNotEmpty) {
        await _scheduleDao.deleteByIds(
          stale.map((Schedule s) => s.id).toList(),
        );
      }

      if (rows.isNotEmpty) {
        await _scheduleDao.insertAll(rows);
      }

      await _inboxDao.markProcessed(outcome.inboxItemIds);
      return rows.length;
    });
  }

  /// 单张图的上限。超过就不发，避免 OOM/请求超时。
  static const int maxImageBytes = 8 * 1024 * 1024;

  /// 一次请求里所有图片的原始字节总预算（base64 后约 ×1.33）。
  static const int maxTotalImageBytes = 20 * 1024 * 1024;

  /// 把图片读出来转成 base64 data URL。
  ///
  /// 超过 [maxImages]、单张过大或总量超预算的图片会被跳过；
  /// 跳过了哪些条目会写进 prompt，让模型知道“这条只有备注可参考”。
  Future<_ImageBundle> _collectImages(List<InboxItem> items) async {
    final _ImageBundle bundle = _ImageBundle();
    int totalBytes = 0;

    for (final InboxItem item in items) {
      final List<String> paths = MediaStorage.parsePaths(item.imagePath);
      if (paths.isEmpty) continue;

      bundle.totalCounts[item.id] = paths.length;
      int sent = 0;

      for (final String path in paths) {
        if (bundle.dataUrls.length >= maxImages) break;

        try {
          final file = await MediaStorage.resolve(path);
          if (!await file.exists()) continue;

          final int size = await file.length();
          if (size > maxImageBytes || totalBytes + size > maxTotalImageBytes) {
            continue;
          }

          final bytes = await file.readAsBytes();
          final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
          final mime = switch (ext) {
            'png' => 'image/png',
            'webp' => 'image/webp',
            'gif' => 'image/gif',
            _ => 'image/jpeg',
          };
          bundle.dataUrls.add('data:$mime;base64,${base64Encode(bytes)}');
          sent++;
          totalBytes += bytes.length;
        } catch (_) {
          // 单张图读失败不该让整次整理失败
        }
      }

      if (sent > 0) {
        bundle.sentCounts[item.id] = sent;
      }
    }

    return bundle;
  }

  _ParsedDrafts _parseDrafts(String reply) {
    final String cleaned = _stripCodeFence(reply);
    final Object? decoded = jsonDecode(cleaned);

    if (decoded is! Map) {
      throw const OrganizeException('模型返回的不是 json 对象');
    }

    final Object? raw = decoded['schedules'];
    if (raw is! List) {
      throw const OrganizeException('模型返回里没有 schedules 字段');
    }

    final List<OrganizeDraft> drafts = <OrganizeDraft>[];
    int skipped = 0;

    // 单条草案格式错误只跳过这一条，不能让整批整理失败
    for (final Object? entry in raw) {
      if (entry is! Map) {
        skipped++;
        continue;
      }
      try {
        drafts.add(OrganizeDraft.fromJson(entry.cast<String, dynamic>()));
      } catch (_) {
        skipped++;
      }
    }

    return _ParsedDrafts(drafts, skipped);
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

class _ParsedDrafts {
  const _ParsedDrafts(this.drafts, this.skipped);

  final List<OrganizeDraft> drafts;
  final int skipped;
}

class _ImageBundle {
  final List<String> dataUrls = <String>[];

  /// 每个条目实际发送了几张图 / 一共有几张图
  final Map<int, int> sentCounts = <int, int>{};
  final Map<int, int> totalCounts = <int, int>{};
}

/// 整理过程中的业务异常，UI 直接展示它的 message。
class OrganizeException implements Exception {
  const OrganizeException(this.message);

  final String message;

  @override
  String toString() => message;
}
