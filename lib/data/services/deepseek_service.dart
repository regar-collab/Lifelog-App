import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lifelog/core/constants/app_constants.dart';

/// DeepSeek API 客户端。
///
/// 走 OpenAI 兼容的 `/chat/completions`。图片输入用多模态消息格式
/// （base64 内联），由 [chatWithImages] 负责。
class DeepSeekService {
  DeepSeekService({required String apiKey, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.deepseekBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 180),
                sendTimeout: const Duration(seconds: 60),
                headers: {
                  'Authorization': 'Bearer $apiKey',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final Dio _dio;

  /// 纯文本对话。
  ///
  /// [jsonMode] 打开后模型会强制返回 JSON 对象。注意：DeepSeek 要求
  /// prompt 里必须出现 "json" 字样，否则接口会报错。
  Future<String> chat({
    required String prompt,
    String model = AppConstants.deepseekModel,
    bool jsonMode = false,
    double temperature = 0.3,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
      'temperature': temperature,
      'stream': false,
      if (jsonMode) 'response_format': {'type': 'json_object'},
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      AppConstants.deepseekChatPath,
      data: body,
    );
    return _extractContent(resp.data);
  }

  /// 带图片的对话。图片以 base64 data URL 内联传入。
  ///
  /// [images] 每项是形如 `data:image/jpeg;base64,xxxx` 的字符串。
  Future<String> chatWithImages({
    required String prompt,
    required List<String> images,
    String model = AppConstants.deepseekModel,
    bool jsonMode = false,
    double temperature = 0.3,
  }) async {
    final content = <Map<String, dynamic>>[
      {'type': 'text', 'text': prompt},
      for (final img in images)
        {
          'type': 'image_url',
          'image_url': {'url': img},
        },
    ];

    final body = <String, dynamic>{
      'model': model,
      'messages': [
        {'role': 'user', 'content': content},
      ],
      'temperature': temperature,
      'stream': false,
      if (jsonMode) 'response_format': {'type': 'json_object'},
    };

    final resp = await _dio.post<Map<String, dynamic>>(
      AppConstants.deepseekChatPath,
      data: body,
    );
    return _extractContent(resp.data);
  }

  /// 连通性测试：发一句最短的话，只验证 Key 是否有效。
  Future<String> testConnection() {
    return chat(prompt: '回复两个字：正常', temperature: 0);
  }

  String _extractContent(Map<String, dynamic>? data) {
    if (data == null) {
      throw const DeepSeekException('接口返回为空');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw DeepSeekException('返回结构异常：${jsonEncode(data)}');
    }
    final first = choices.first;
    if (first is! Map) {
      throw const DeepSeekException('choices 元素结构异常');
    }
    final message = first['message'];
    if (message is! Map) {
      throw const DeepSeekException('message 字段缺失');
    }
    final content = message['content'];
    if (content is! String) {
      throw const DeepSeekException('返回内容不是文本');
    }
    return content;
  }
}

/// DeepSeek 调用相关的异常，统一成一种类型方便 UI 层兜底。
class DeepSeekException implements Exception {
  const DeepSeekException(this.message);

  final String message;

  @override
  String toString() => message;
}
