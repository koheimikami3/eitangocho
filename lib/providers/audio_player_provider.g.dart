// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_player_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 発音再生用の AudioPlayer。多重生成を避けるためアプリ全体で
/// 1 インスタンスを keepAlive で共有する(同時再生は想定しない)。

@ProviderFor(audioPlayer)
final audioPlayerProvider = AudioPlayerProvider._();

/// 発音再生用の AudioPlayer。多重生成を避けるためアプリ全体で
/// 1 インスタンスを keepAlive で共有する(同時再生は想定しない)。

final class AudioPlayerProvider
    extends $FunctionalProvider<AudioPlayer, AudioPlayer, AudioPlayer>
    with $Provider<AudioPlayer> {
  /// 発音再生用の AudioPlayer。多重生成を避けるためアプリ全体で
  /// 1 インスタンスを keepAlive で共有する(同時再生は想定しない)。
  AudioPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioPlayerHash();

  @$internal
  @override
  $ProviderElement<AudioPlayer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioPlayer create(Ref ref) {
    return audioPlayer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioPlayer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioPlayer>(value),
    );
  }
}

String _$audioPlayerHash() => r'da4907d740d3974621d680b1ce2ac2a61956bb40';
