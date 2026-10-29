// GpsRing: a ring that fills as the GPS fix gets more accurate and turns green at <= 20 m; after 60 s a
//   "Save anyway" button appears.
// Requirement: UserFlows §Onboarding step 4 ("A circle fills as the GPS gets accurate; when it turns green,
//   the pin saves. No map, no typing.") and §When things go wrong (Weak GPS: filling circle, "Hold the phone
//   up, finding your location"; after 60 seconds "Save anyway"); "Colour plus shape".
// Callers: onboarding location step (M09), event capture when GPS is weak (M07); test/widget/kit_*.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';
import 'farmer_button.dart';
import 'voice_prompt_bar.dart';

/// Accuracy-driven progress ring with a spoken status sentence ([VoicePromptBar]), and a "Save anyway" button after [saveAnywayAfter].
///
/// The ring is a Material [CircularProgressIndicator]: empty with no fix, full at [goodAccuracyMetres],
/// linear in between from [startAccuracyMetres]. Green plus a tick icon once good (shape, not colour alone).
class GpsRing extends ConsumerStatefulWidget {
  /// Creates the ring.
  ///
  /// [accuracyMetres] is the latest fix accuracy (horizontal, 68 %) in metres, or null before the first fix;
  /// [onSaveAnyway] saves the location with its current accuracy and is offered once [saveAnywayAfter] has
  /// passed without a good fix.
  const GpsRing({super.key, required this.accuracyMetres, required this.onSaveAnyway});

  /// Accuracy in metres at or below which the ring is full and green (UserFlows: 20 m).
  static const goodAccuracyMetres = 20.0;

  /// Accuracy in metres at or above which the ring is empty.
  static const startAccuracyMetres = 100.0;

  /// How long to wait for a good fix before offering "Save anyway" (UserFlows: 60 seconds).
  static const saveAnywayAfter = Duration(seconds: 60);

  /// Latest accuracy in metres, or null with no fix yet.
  final double? accuracyMetres;

  /// Called when the farmer taps "Save anyway".
  final VoidCallback onSaveAnyway;

  /// Creates the state holding the "Save anyway" timer. Returns it; throws nothing.
  @override
  ConsumerState<GpsRing> createState() => _GpsRingState();
}

class _GpsRingState extends ConsumerState<GpsRing> {
  late final Timer _timer;
  bool _offerSaveAnyway = false;

  /// Starts the "Save anyway" timer. Side effect: a one-shot timer. Throws nothing.
  @override
  void initState() {
    super.initState();
    _timer = Timer(GpsRing.saveAnywayAfter, () => setState(() => _offerSaveAnyway = true));
  }

  /// Cancels the timer. Throws nothing.
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Builds ring, accuracy, sentence and (after the wait, while still weak) the "Save anyway" button.
  /// [context] supplies theme, tokens and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final accuracy = widget.accuracyMetres;
    final good = accuracy != null && accuracy <= GpsRing.goodAccuracyMetres;
    final progress = accuracy == null
        ? 0.0
        : ((GpsRing.startAccuracyMetres - accuracy) / (GpsRing.startAccuracyMetres - GpsRing.goodAccuracyMetres)).clamp(
            0.0,
            1.0,
          );
    final promptId = good ? 'gpsFound' : 'gpsHold';
    final sentence = good ? l10n.gpsFound : l10n.gpsHold;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The ring is decoration for screen readers: the accuracy text and the prompt bar carry its meaning.
        ExcludeSemantics(
          child: Center(
            child: SizedBox.square(
              dimension: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    color: good ? tokens.done.color : theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                  Icon(
                    good ? tokens.done.icon : Icons.my_location,
                    size: 64,
                    color: good ? tokens.done.color : theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.gap),
        if (accuracy != null)
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.gpsAccuracy(accuracy.round()),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: tokens.gap),
        // Keyed by prompt so the bar is rebuilt, and speaks again, when the ring turns green.
        VoicePromptBar(key: ValueKey(promptId), promptId: promptId, text: sentence),
        if (_offerSaveAnyway && !good) ...[
          SizedBox(height: tokens.gap),
          FarmerButton(
            icon: Icons.save_alt,
            label: l10n.saveAnyway,
            onPressed: widget.onSaveAnyway,
            onSpeak: () => playPrompt(ref, context, 'saveAnyway'),
          ),
        ],
      ],
    );
  }
}
