// VoicePlayer: plays the recorded prompt for a prompt id in the screen's language, or reports it missing.
// Requirement: UserFlows §Design rules "Pictures and voice before words" (speaker icon plays a recorded voice
//   prompt; recorded Tamil voices, not text-to-speech); mobile-design.md §5 (missing clip -> text only +
//   counter, no TTS); D-016.
// Callers: VoicePromptBar and every widget-kit speaker (core/widgets) through voicePlayerProvider and
//   playPrompt; tests override voicePlayerProvider.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'prompt_catalog.dart';

/// Starts playing the bundled asset at the given path; completes once playback has started.
///
/// The only seam to the audio package, so tests can record calls instead of opening a platform player.
typedef ClipPlayer = Future<void> Function(String assetPath);

/// Plays bundled voice prompts and counts the ones that could not be played.
class VoicePlayer {
  /// Creates a player.
  ///
  /// [bundle] holds `assets/prompts.json` and the clips (read lazily on the first [play]); [playClip]
  /// starts one clip.
  VoicePlayer({required AssetBundle bundle, required ClipPlayer playClip}) : _bundle = bundle, _playClip = playClip;

  final AssetBundle _bundle;
  final ClipPlayer _playClip;
  late final Future<PromptCatalog> _catalog = PromptCatalog.load(_bundle);
  int _missingClips = 0;

  /// Number of prompts since start-up that had no clip or failed to play.
  ///
  /// shortcut: kept in memory only; ship it with the SyncMetrics envelope when M02 lands.
  int get missingClips => _missingClips;

  /// Plays [promptId] in [locale]'s language, replacing whatever is playing.
  ///
  /// Returns true when the clip started, false when it is not bundled or the player failed (the caller then
  /// shows text only); every false increments [missingClips]. Throws what [PromptCatalog.load] throws when
  /// the manifest itself is broken (a packaging bug).
  Future<bool> play(String promptId, Locale locale) async {
    final path = (await _catalog).assetFor(promptId, locale);
    if (path != null) {
      try {
        await _playClip(path);
        return true;
      } on Exception {
        // A corrupt or undecodable clip must not break the screen: fall through to text only.
      }
    }
    _missingClips++;
    return false;
  }
}

/// The app's single [VoicePlayer], backed by one just_audio player.
///
/// DECISION D-016: Tamil and English prompts are Opus clips bundled as assets, played by just_audio.
///   ADV: works offline on first run; ExoPlayer decodes Ogg/Opus on every Android 8+ phone.
///   COMPROMISE: clips add to the APK size; iOS AVPlayer cannot decode Ogg, so iOS needs .caf/.m4a copies
///   before an iOS pilot (see M05 report).
final voicePlayerProvider = Provider<VoicePlayer>((ref) {
  final audio = AudioPlayer();
  ref.onDispose(audio.dispose);
  return VoicePlayer(
    bundle: rootBundle,
    playClip: (path) async {
      await audio.setAsset(path);
      // play() completes when the clip ends; the screen must not wait for that.
      unawaited(audio.play());
    },
  );
});

/// Whether a screen plays its prompt by itself when it opens.
///
/// shortcut: always on; the Settings screen (M08) turns this into a persisted Notifier.
final voiceAutoplayProvider = Provider<bool>((ref) => true);

/// Plays [promptId] in the language of [context] through [voicePlayerProvider] read from [ref].
///
/// Returns what [VoicePlayer.play] returns. Throws nothing beyond [VoicePlayer.play].
Future<bool> playPrompt(WidgetRef ref, BuildContext context, String promptId) =>
    ref.read(voicePlayerProvider).play(promptId, Localizations.localeOf(context));
