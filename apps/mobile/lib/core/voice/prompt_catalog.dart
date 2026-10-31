// PromptCatalog: which recorded voice clips ship in the app, read from assets/prompts.json.
// Requirement: UserFlows §Design rules "Pictures and voice before words" (recorded voices, not TTS);
//   mobile-design.md §5 (prompt id = string key, clip at assets/audio/{locale}/{promptId}.ogg, prompts.json,
//   missing clip -> text only); D-016 (ta + en bundled).
// Callers: voice_player.dart (voicePlayerProvider loads it once; VoicePlayer asks it for a clip path);
//   test/widget/voice_test.dart.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Locale;

/// The set of bundled clips per language, keyed by prompt id (the ARB string key).
class PromptCatalog {
  /// Creates a catalog from [clips]: language code (e.g. `ta`) to the prompt ids that have a clip.
  const PromptCatalog(this.clips);

  /// Asset path of the manifest.
  static const manifestPath = 'assets/prompts.json';

  /// Language code to the prompt ids recorded in that language.
  final Map<String, Set<String>> clips;

  /// Reads and parses [manifestPath] from [bundle].
  ///
  /// Returns the catalog. Throws a [FlutterError] when the manifest asset is missing and a
  /// [FormatException] or [TypeError] when it is not the expected JSON shape (`{"clips": {lang: [ids]}}`);
  /// both are packaging bugs caught by the widget tests, not runtime conditions.
  static Future<PromptCatalog> load(AssetBundle bundle) async {
    final json = jsonDecode(await bundle.loadString(manifestPath)) as Map<String, Object?>;
    final clips = json['clips'] as Map<String, Object?>;
    return PromptCatalog({
      for (final MapEntry(:key, :value) in clips.entries) key: (value as List<Object?>).cast<String>().toSet(),
    });
  }

  /// Returns the asset path of [promptId] in [locale]'s language, or null when that clip is not bundled.
  /// Throws nothing.
  String? assetFor(String promptId, Locale locale) {
    final lang = locale.languageCode;
    return (clips[lang]?.contains(promptId) ?? false) ? 'assets/audio/$lang/$promptId.ogg' : null;
  }
}
