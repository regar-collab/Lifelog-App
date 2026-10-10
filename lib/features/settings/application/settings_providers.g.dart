// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 已保存的 DeepSeek API Key。没配过时为 null。

@ProviderFor(deepSeekApiKey)
final deepSeekApiKeyProvider = DeepSeekApiKeyProvider._();

/// 已保存的 DeepSeek API Key。没配过时为 null。

final class DeepSeekApiKeyProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// 已保存的 DeepSeek API Key。没配过时为 null。
  DeepSeekApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepSeekApiKeyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepSeekApiKeyHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return deepSeekApiKey(ref);
  }
}

String _$deepSeekApiKeyHash() => r'971a8d35a81f9a6dc8e3994737fb64efcf20e92c';

/// 按当前 Key 构造好的 DeepSeek 客户端。
///
/// 没配 Key 时直接抛 [DeepSeekException]，让调用方给出友好提示；
/// 这样各功能模块都不需要自己判断 Key 是否存在。

@ProviderFor(deepSeekService)
final deepSeekServiceProvider = DeepSeekServiceProvider._();

/// 按当前 Key 构造好的 DeepSeek 客户端。
///
/// 没配 Key 时直接抛 [DeepSeekException]，让调用方给出友好提示；
/// 这样各功能模块都不需要自己判断 Key 是否存在。

final class DeepSeekServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeepSeekService>,
          DeepSeekService,
          FutureOr<DeepSeekService>
        >
    with $FutureModifier<DeepSeekService>, $FutureProvider<DeepSeekService> {
  /// 按当前 Key 构造好的 DeepSeek 客户端。
  ///
  /// 没配 Key 时直接抛 [DeepSeekException]，让调用方给出友好提示；
  /// 这样各功能模块都不需要自己判断 Key 是否存在。
  DeepSeekServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepSeekServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepSeekServiceHash();

  @$internal
  @override
  $FutureProviderElement<DeepSeekService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeepSeekService> create(Ref ref) {
    return deepSeekService(ref);
  }
}

String _$deepSeekServiceHash() => r'2e725dd7bd888daf777921690c5662d6b5af42a7';
