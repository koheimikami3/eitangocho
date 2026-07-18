import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player_provider.g.dart';

/// 発音再生用の AudioPlayer。多重生成を避けるためアプリ全体で
/// 1 インスタンスを keepAlive で共有する(同時再生は想定しない)。
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
}
