import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lifelog/data/services/ai/ai_provider_presets.dart';

/// 一次 AI 调用需要的完整配置。
class AiConfig {
  const AiConfig({
    required this.providerId,
    required this.name,
    required this.style,
    required this.baseUrl,
    required this.chatPath,
    required this.model,
    required this.visionModel,
    required this.apiKey,
    this.extraHeaders = const <String, String>{},
  });

  final String providerId;
  final String name;
  final AiApiStyle style;
  final String baseUrl;
  final String chatPath;
  final String model;
  final String visionModel;
  final String apiKey;
  final Map<String, String> extraHeaders;

  /// 没单独配置视觉模型时，退回主模型。
  String get effectiveVisionModel {
    final String v = visionModel.trim();
    return v.isEmpty ? model.trim() : v;
  }
}

/// 统一的 AI 服务接口。整理、聊天、通知文案都走这里。
abstract class AiService {
  /// 用于日志展示，例如「DeepSeek / deepseek-flash」。
  String get providerName;
  String get modelName;

  static AiService fromConfig(AiConfig config) {
    if (config.baseUrl.trim().isEmpty) {
      throw const AiException('请先填写 API Base URL');
    }
    if (config.model.trim().isEmpty) {
      throw const AiException('请先填写模型名称');
    }

    return switch (config.style) {
      AiApiStyle.openAi => OpenAiCompatibleService(config),
      AiApiStyle.anthropic => AnthropicService(config),
      AiApiStyle.gemini => GeminiService(config),
    };
  }

  /// 纯文本对话。
  Future<String> chat({
    required String prompt,
    bool jsonMode = false,
    double temperature = 0.3,
  });

  /// 带图片的对话。[images] 是 `data:image/jpeg;base64,...` 形式。
  Future<String> chatWithImages({
    required String prompt,
    required List<String> images,
    bool jsonMode = false,
    double temperature = 0.3,
  });

  /// 连通性测试：发一句最短的话，只验证 Key / 地址 / 模型是否可用。
  Future<String> testConnection();
}

/// 所有 AI 相关错误的统一类型，UI 直接展示 message。
class AiException implements Exception {
  const AiException(this.message);

  final String message;

  @override
  String toString() => message;
}

// ── OpenAI 兼容 ─────────────────────────────────────────────
//
// DeepSeek、Kimi、智谱、通义千问、硅基流动、OpenRouter、Ollama 等
// 都走 /chat/completions，只是 baseUrl 和模型名不同。
class OpenAiCompatibleService implements AiService {
  OpenAiCompatibleService(this.config) : _dio = _createDio();

  final AiConfig config;
  final Dio _dio;

  @override
  String get providerName => config.name;

  @override
  String get modelName => config.model;

  @override
  Future<String> chat({
    required String prompt,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    return _send(
      prompt: prompt,
      images: const <String>[],
      model: config.model.trim(),
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  @override
  Future<String> chatWithImages({
    required String prompt,
    required List<String> images,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    final String model = config.effectiveVisionModel;
    if (model.isEmpty) {
      throw const AiException('当前供应商没有配置视觉模型，无法整理图片');
    }
    return _send(
      prompt: prompt,
      images: images,
      model: model,
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  Future<String> _send({
    required String prompt,
    required List<String> images,
    required String model,
    required bool jsonMode,
    required double temperature,
  }) async {
    final Object content = images.isEmpty
        ? prompt
        : <Map<String, dynamic>>[
            <String, dynamic>{'type': 'text', 'text': prompt},
            for (final String image in images)
              <String, dynamic>{
                'type': 'image_url',
                'image_url': <String, dynamic>{'url': image},
              },
          ];

    final Map<String, dynamic> body = <String, dynamic>{
      'model': model,
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{'role': 'user', 'content': content},
      ],
      'temperature': temperature,
      'stream': false,
      if (jsonMode) 'response_format': <String, dynamic>{'type': 'json_object'},
    };

    final String url = _joinUrl(
      config.baseUrl,
      config.chatPath.isEmpty ? '/chat/completions' : config.chatPath,
    );
    final Options options = Options(
      headers: <String, String>{
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        ...config.extraHeaders,
      },
    );

    try {
      final Response<dynamic> resp = await _dio.post<dynamic>(
        url,
        data: body,
        options: options,
      );
      return _extractContent(resp.data);
    } on DioException catch (e) {
      // 有些兼容接口不支持 response_format，400 时去掉它再试一次。
      // prompt 本身已经明确要求 JSON，去掉后通常也能正常返回。
      if (jsonMode && e.response?.statusCode == 400) {
        final Map<String, dynamic> retryBody = Map<String, dynamic>.of(body)
          ..remove('response_format');
        try {
          final Response<dynamic> resp = await _dio.post<dynamic>(
            url,
            data: retryBody,
            options: options,
          );
          return _extractContent(resp.data);
        } on DioException catch (retryError) {
          throw AiException(describeAiError(retryError));
        }
      }
      throw AiException(describeAiError(e));
    }
  }

  String _extractContent(Object? raw) {
    final Map<String, dynamic>? data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;
    if (data == null) {
      throw const AiException('接口返回格式异常');
    }

    final Object? choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw AiException('接口返回结构异常：${_truncate(jsonEncode(data))}');
    }

    final Object? first = choices.first;
    final Object? message = first is Map ? first['message'] : null;
    final Object? content = message is Map ? message['content'] : null;

    if (content is String && content.trim().isNotEmpty) return content;
    if (content is List) {
      final String text = content
          .whereType<Map>()
          .map((Map part) => part['text'])
          .whereType<String>()
          .join();
      if (text.trim().isNotEmpty) return text;
    }

    throw const AiException('模型没有返回文本内容');
  }

  @override
  Future<String> testConnection() {
    return chat(prompt: '回复两个字：正常', temperature: 0);
  }
}

// ── Anthropic Claude ────────────────────────────────────────
class AnthropicService implements AiService {
  AnthropicService(this.config) : _dio = _createDio();

  final AiConfig config;
  final Dio _dio;

  @override
  String get providerName => config.name;

  @override
  String get modelName => config.model;

  @override
  Future<String> chat({
    required String prompt,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    return _send(
      prompt: prompt,
      images: const <String>[],
      model: config.model.trim(),
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  @override
  Future<String> chatWithImages({
    required String prompt,
    required List<String> images,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    final String model = config.effectiveVisionModel;
    if (model.isEmpty) {
      throw const AiException('当前供应商没有配置视觉模型，无法整理图片');
    }
    return _send(
      prompt: prompt,
      images: images,
      model: model,
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  Future<String> _send({
    required String prompt,
    required List<String> images,
    required String model,
    required bool jsonMode,
    required double temperature,
  }) async {
    final List<Map<String, dynamic>> parts = <Map<String, dynamic>>[
      <String, dynamic>{'type': 'text', 'text': prompt},
    ];
    for (final String image in images) {
      final ({String mime, String data}) parsed = _parseDataUrl(image);
      parts.add(<String, dynamic>{
        'type': 'image',
        'source': <String, dynamic>{
          'type': 'base64',
          'media_type': parsed.mime,
          'data': parsed.data,
        },
      });
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'model': model,
      'max_tokens': 4096,
      'temperature': temperature,
      'messages': <Map<String, dynamic>>[
        <String, dynamic>{'role': 'user', 'content': parts},
      ],
      if (jsonMode) 'system': '只输出一个合法的 json 对象，不要 markdown 代码块或额外解释。',
    };

    final String url = _joinUrl(config.baseUrl, '/messages');
    try {
      final Response<dynamic> resp = await _dio.post<dynamic>(
        url,
        data: body,
        options: Options(
          headers: <String, String>{
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
            ...config.extraHeaders,
          },
        ),
      );
      return _extractContent(resp.data);
    } on DioException catch (e) {
      throw AiException(describeAiError(e));
    }
  }

  String _extractContent(Object? raw) {
    final Map<String, dynamic>? data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;
    if (data == null) {
      throw const AiException('接口返回格式异常');
    }

    final Object? content = data['content'];
    if (content is List) {
      final String text = content
          .whereType<Map>()
          .where((Map block) => block['type'] == 'text')
          .map((Map block) => block['text'])
          .whereType<String>()
          .join();
      if (text.trim().isNotEmpty) return text;
    }

    final Object? error = data['error'];
    if (error is Map && error['message'] is String) {
      throw AiException(error['message'] as String);
    }
    throw const AiException('模型没有返回文本内容');
  }

  @override
  Future<String> testConnection() {
    return chat(prompt: '回复两个字：正常', temperature: 0);
  }
}

// ── Google Gemini ───────────────────────────────────────────
class GeminiService implements AiService {
  GeminiService(this.config) : _dio = _createDio();

  final AiConfig config;
  final Dio _dio;

  @override
  String get providerName => config.name;

  @override
  String get modelName => config.model;

  @override
  Future<String> chat({
    required String prompt,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    return _send(
      prompt: prompt,
      images: const <String>[],
      model: config.model.trim(),
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  @override
  Future<String> chatWithImages({
    required String prompt,
    required List<String> images,
    bool jsonMode = false,
    double temperature = 0.3,
  }) {
    final String model = config.effectiveVisionModel;
    if (model.isEmpty) {
      throw const AiException('当前供应商没有配置视觉模型，无法整理图片');
    }
    return _send(
      prompt: prompt,
      images: images,
      model: model,
      jsonMode: jsonMode,
      temperature: temperature,
    );
  }

  Future<String> _send({
    required String prompt,
    required List<String> images,
    required String model,
    required bool jsonMode,
    required double temperature,
  }) async {
    final List<Map<String, dynamic>> parts = <Map<String, dynamic>>[
      <String, dynamic>{'text': prompt},
    ];
    for (final String image in images) {
      final ({String mime, String data}) parsed = _parseDataUrl(image);
      parts.add(<String, dynamic>{
        'inline_data': <String, dynamic>{
          'mime_type': parsed.mime,
          'data': parsed.data,
        },
      });
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'contents': <Map<String, dynamic>>[
        <String, dynamic>{'role': 'user', 'parts': parts},
      ],
      'generationConfig': <String, dynamic>{
        'temperature': temperature,
        if (jsonMode) 'responseMimeType': 'application/json',
      },
    };

    final String cleanModel = model
        .replaceFirst(RegExp(r'^models/'), '')
        .trim();
    final String url = _joinUrl(
      config.baseUrl,
      '/models/${Uri.encodeComponent(cleanModel)}:generateContent',
    );
    final Uri uri = Uri.parse(url)
        .replace(queryParameters: <String, String>{'key': config.apiKey});

    try {
      final Response<dynamic> resp = await _dio.post<dynamic>(
        uri.toString(),
        data: body,
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json',
            ...config.extraHeaders,
          },
        ),
      );
      return _extractContent(resp.data);
    } on DioException catch (e) {
      throw AiException(describeAiError(e));
    }
  }

  String _extractContent(Object? raw) {
    final Map<String, dynamic>? data = raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;
    if (data == null) {
      throw const AiException('接口返回格式异常');
    }

    final Object? candidates = data['candidates'];
    if (candidates is List && candidates.isNotEmpty) {
      final Object? first = candidates.first;
      final Object? content = first is Map ? first['content'] : null;
      final Object? parts = content is Map ? content['parts'] : null;
      if (parts is List) {
        final String text = parts
            .whereType<Map>()
            .map((Map part) => part['text'])
            .whereType<String>()
            .join();
        if (text.trim().isNotEmpty) return text;
      }
    }

    final Object? error = data['error'];
    if (error is Map && error['message'] is String) {
      throw AiException(error['message'] as String);
    }
    throw AiException('模型没有返回文本内容：${_truncate(jsonEncode(data))}');
  }

  @override
  Future<String> testConnection() {
    return chat(prompt: '回复两个字：正常', temperature: 0);
  }
}

// ── 公共工具 ────────────────────────────────────────────────

Dio _createDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 180),
      sendTimeout: const Duration(seconds: 60),
    ),
  );
}

String _joinUrl(String base, String path) {
  final String b = base.trim().replaceAll(RegExp(r'/+$'), '');
  final String p = path.trim();
  if (p.isEmpty) return b;
  return '$b/${p.replaceFirst(RegExp(r'^/+'), '')}';
}

/// 把 Dio 异常翻译成用户能看懂的话。
String describeAiError(DioException e) {
  final int? code = e.response?.statusCode;
  final String? detail = _providerError(e.response?.data);
  final String suffix = detail == null || detail.trim().isEmpty
      ? ''
      : '：${_truncate(detail)}';

  switch (code) {
    case 400:
      return '请求参数或模型名不正确（HTTP 400）$suffix';
    case 401:
      return 'API Key 无效或已过期（HTTP 401）';
    case 402:
      return '账户余额不足（HTTP 402）';
    case 403:
      return '没有权限访问该模型（HTTP 403）$suffix';
    case 404:
      return '接口地址或模型名不正确（HTTP 404）$suffix';
    case 429:
      return '请求过于频繁或额度用尽（HTTP 429）';
  }

  if (code != null) return 'HTTP $code$suffix';

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => '请求超时，请检查网络或接口地址',
    DioExceptionType.connectionError => '网络连接失败，请检查网络或 Base URL',
    _ => '请求失败：${e.message ?? e.type.name}',
  };
}

String? _providerError(Object? data) {
  if (data is Map) {
    final Object? error = data['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    if (error is String) return error;
    if (data['message'] is String) return data['message'] as String;
    if (data['detail'] is String) return data['detail'] as String;
  }
  if (data is String && data.trim().isNotEmpty) return data;
  return null;
}

({String mime, String data}) _parseDataUrl(String url) {
  final RegExpMatch? match = RegExp(
    r'^data:([^;]+);base64,(.+)$',
    dotAll: true,
  ).firstMatch(url);
  if (match == null) {
    throw const AiException('图片格式异常，无法发送给模型');
  }
  return (mime: match.group(1)!, data: match.group(2)!);
}

String _truncate(String text, [int max = 300]) {
  final String t = text.trim();
  return t.length <= max ? t : '${t.substring(0, max)}…';
}
