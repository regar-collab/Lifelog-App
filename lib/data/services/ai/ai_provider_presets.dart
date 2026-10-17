/// 不同厂商 API 的请求格式。
enum AiApiStyle {
  /// OpenAI `/chat/completions` 格式。国内大多数厂商都兼容，
  /// 包括 DeepSeek、Kimi、智谱、通义千问、硅基流动、OpenRouter、Ollama 等。
  openAi,

  /// Anthropic Messages API。
  anthropic,

  /// Google Gemini generateContent API。
  gemini,
}

/// 一个供应商预设。
///
/// baseUrl / model / visionModel 都只是默认值，设置页里可以改。
/// 各家的模型名更新很快，预设只负责让用户少查一次文档。
class AiProviderPreset {
  const AiProviderPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    required this.baseUrl,
    required this.model,
    this.visionModel = '',
    this.chatPath = '/chat/completions',
    this.keyHint = 'sk-...',
    this.docsUrl = '',
    this.extraHeaders = const <String, String>{},
  });

  final String id;
  final String name;
  final String description;
  final AiApiStyle style;
  final String baseUrl;
  final String model;
  final String visionModel;
  final String chatPath;
  final String keyHint;
  final String docsUrl;
  final Map<String, String> extraHeaders;

  bool get supportsVision =>
      visionModel.isNotEmpty ||
      style == AiApiStyle.anthropic ||
      style == AiApiStyle.gemini;
}

/// 内置供应商。顺序即设置页下拉框顺序。
class AiProviderPresets {
  AiProviderPresets._();

  static const AiProviderPreset custom = AiProviderPreset(
    id: 'custom',
    name: '自定义（OpenAI 兼容）',
    description:
        '任何兼容 OpenAI /chat/completions 的接口。'
        'Base URL 一般以 /v1 结尾，例如 https://example.com/v1。',
    style: AiApiStyle.openAi,
    baseUrl: '',
    model: '',
    visionModel: '',
    keyHint: '填写服务商提供的 Key',
  );

  static const List<AiProviderPreset> all = <AiProviderPreset>[
    AiProviderPreset(
      id: 'deepseek',
      name: 'DeepSeek',
      description: '国内直连、价格较低。deepseek-flash 支持图片理解。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://api.deepseek.com',
      model: 'deepseek-flash',
      visionModel: 'deepseek-flash',
      docsUrl: 'https://api-docs.deepseek.com/',
    ),
    AiProviderPreset(
      id: 'openai',
      name: 'OpenAI',
      description: 'GPT 系列。gpt-4o-mini 便宜且支持图片；需要能访问 OpenAI。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://api.openai.com/v1',
      model: 'gpt-4o-mini',
      visionModel: 'gpt-4o-mini',
      docsUrl: 'https://platform.openai.com/docs',
    ),
    AiProviderPreset(
      id: 'anthropic',
      name: 'Anthropic Claude',
      description: 'Claude 系列，长文本和理解能力好。默认用便宜的 Haiku。',
      style: AiApiStyle.anthropic,
      baseUrl: 'https://api.anthropic.com/v1',
      model: 'claude-haiku-4-5-20251001',
      visionModel: 'claude-haiku-4-5-20251001',
      chatPath: '/messages',
      keyHint: 'sk-ant-...',
      docsUrl: 'https://docs.anthropic.com/',
    ),
    AiProviderPreset(
      id: 'gemini',
      name: 'Google Gemini',
      description: 'Gemini 2.5 Flash 便宜、速度快、支持图片。',
      style: AiApiStyle.gemini,
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      model: 'gemini-2.5-flash',
      visionModel: 'gemini-2.5-flash',
      chatPath: '',
      keyHint: 'AIza...',
      docsUrl: 'https://ai.google.dev/gemini-api/docs',
    ),
    AiProviderPreset(
      id: 'kimi',
      name: 'Kimi（Moonshot）',
      description: '月之暗面 Kimi。kimi-latest 支持长上下文；图片用视觉预览模型。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://api.moonshot.cn/v1',
      model: 'kimi-latest',
      visionModel: 'moonshot-v1-8k-vision-preview',
      docsUrl: 'https://platform.moonshot.cn/docs',
    ),
    AiProviderPreset(
      id: 'zhipu',
      name: '智谱 GLM',
      description: 'glm-4-flash 有免费额度；图片用 glm-4v-flash。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      model: 'glm-4-flash',
      visionModel: 'glm-4v-flash',
      docsUrl: 'https://open.bigmodel.cn/dev/api',
    ),
    AiProviderPreset(
      id: 'qwen',
      name: '通义千问（DashScope）',
      description: '阿里云百炼兼容模式。qwen-plus 文本，qwen-vl-plus 图片。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
      model: 'qwen-plus',
      visionModel: 'qwen-vl-plus',
      docsUrl: 'https://help.aliyun.com/zh/model-studio/',
    ),
    AiProviderPreset(
      id: 'siliconflow',
      name: '硅基流动 SiliconFlow',
      description: '聚合多家开源模型。模型名形如 Qwen/Qwen2.5-7B-Instruct。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://api.siliconflow.cn/v1',
      model: 'Qwen/Qwen2.5-7B-Instruct',
      visionModel: 'Qwen/Qwen2-VL-7B-Instruct',
      docsUrl: 'https://docs.siliconflow.cn/',
    ),
    AiProviderPreset(
      id: 'openrouter',
      name: 'OpenRouter',
      description: '一个 Key 调多家模型，适合比价。模型名形如 openai/gpt-4o-mini。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://openrouter.ai/api/v1',
      model: 'openai/gpt-4o-mini',
      visionModel: 'openai/gpt-4o-mini',
      docsUrl: 'https://openrouter.ai/docs',
      extraHeaders: <String, String>{
        'HTTP-Referer': 'https://github.com/regar-collab/Lifelog-App',
        'X-Title': 'Lifelog',
      },
    ),
    AiProviderPreset(
      id: 'doubao',
      name: '豆包（火山方舟）',
      description: '在火山方舟控制台创建推理接入点，把「接入点 ID」填到模型名里。',
      style: AiApiStyle.openAi,
      baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
      model: '',
      visionModel: '',
      docsUrl: 'https://www.volcengine.com/docs/82379',
    ),
    AiProviderPreset(
      id: 'ollama',
      name: 'Ollama（本地/局域网）',
      description:
          '把 IP 换成运行 Ollama 的电脑地址，手机和电脑要同一 Wi-Fi。'
          '模型示例：llama3.1；图片示例：llava。',
      style: AiApiStyle.openAi,
      baseUrl: 'http://192.168.1.100:11434/v1',
      model: 'llama3.1',
      visionModel: 'llava',
      docsUrl: 'https://ollama.com/',
    ),
    custom,
  ];

  static AiProviderPreset byId(String id) {
    return all.firstWhere(
      (AiProviderPreset p) => p.id == id,
      orElse: () => custom,
    );
  }
}
