// Voice prompts: the bundled manifest matches the clips and the ARB keys; VoicePromptBar autoplays, replays
//   and falls back to text (counting the miss) when a clip is missing.
// Requirement: mobile-design.md §5 (prompt id = string key; assets/audio/{locale}/{promptId}.ogg with
//   prompts.json; missing clip -> text only + counter, no TTS); UserFlows §Design rules "Pictures and voice
//   before words"; D-016.
// Callers: flutter test (CI mobile job).

import 'dart:convert';
import 'dart:io';

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/voice/prompt_catalog.dart';
import 'package:agritrace/core/widgets/voice_prompt_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kit_harness.dart';

/// Manifest packaging checks, then VoicePromptBar behaviour.
void main() {
  test('every manifest clip exists as a file and is an ARB key in both languages', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final catalog = await PromptCatalog.load(rootBundle);
    expect(catalog.clips.keys, containsAll(['ta', 'en']));
    for (final MapEntry(key: lang, value: ids) in catalog.clips.entries) {
      final arb = jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync()) as Map<String, Object?>;
      expect(ids, isNotEmpty);
      for (final id in ids) {
        final path = catalog.assetFor(id, Locale(lang))!;
        expect(File(path).existsSync(), isTrue, reason: '$path listed in prompts.json but missing');
        expect(arb.containsKey(id), isTrue, reason: 'prompt id $id is not a key of app_$lang.arb');
      }
    }
  });

  test('assetFor returns the per-language path, or null when not bundled', () {
    const catalog = PromptCatalog({
      'ta': {'gpsHold'},
    });
    expect(catalog.assetFor('gpsHold', tamil), 'assets/audio/ta/gpsHold.ogg');
    expect(catalog.assetFor('gpsHold', english), isNull);
    expect(catalog.assetFor('retake', tamil), isNull);
  });

  for (final locale in [tamil, english]) {
    final l10n = lookupAppLocalizations(locale);
    final lang = locale.languageCode;

    testWidgets('VoicePromptBar $lang autoplays a bundled clip and replays it on tap', (tester) async {
      final player = await pumpKit(
        tester,
        VoicePromptBar(promptId: 'gpsHold', text: l10n.gpsHold),
        locale: locale,
      );
      await tester.pump();
      expect(player.played, ['assets/audio/$lang/gpsHold.ogg']);
      expect(player.missingClips, 0);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(l10n.playVoice));
      await tester.pump();
      expect(player.played, hasLength(2));
    });

    testWidgets('VoicePromptBar $lang falls back to text and counts a missing clip', (tester) async {
      final player = await pumpKit(
        tester,
        VoicePromptBar(promptId: 'photoNotClear', text: l10n.photoNotClear),
        locale: locale,
      );
      await tester.pump();
      expect(player.played, isEmpty);
      expect(player.missingClips, 1);
      expect(find.text(l10n.photoNotClear), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.bySemanticsLabel(l10n.voiceMissing), findsOneWidget);
    });
  }

  testWidgets('VoicePromptBar stays silent when autoplay is off', (tester) async {
    final l10n = lookupAppLocalizations(tamil);
    final player = await pumpKit(tester, VoicePromptBar(promptId: 'gpsHold', text: l10n.gpsHold), autoplay: false);
    await tester.pump();
    expect(player.played, isEmpty);
  });
}
