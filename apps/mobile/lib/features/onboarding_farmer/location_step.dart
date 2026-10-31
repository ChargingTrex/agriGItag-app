// O03d Location: the farmer taps "I am standing in my field"; the GPS ring fills as the fix improves and the pin
//   saves by itself once it is green (<= 20 m). After 60 s a weak fix can be saved anyway. No map, no typing.
// Requirement: UserFlows §Onboarding a farmer step 4, §When things go wrong (Weak GPS: filling circle, "Save
//   anyway" after 60 s, saved with its accuracy and flagged), FR64 (live-GPS pin with accuracy, time and device),
//   Arch §Offline-first "Three clocks" (Clocks.stamp in OnboardingNotifier.savePin).
// Callers: onboarding_wizard.dart (OnboardingStep.location).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capture/capture_constants.dart';
import '../../core/capture/gps_fix.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/gps_ring.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// "In field" button, then the ring; once the pin is saved, its accuracy with a tick and Next.
class LocationStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const LocationStep({super.key});

  /// Creates the state holding the GPS subscription. Returns it; throws nothing.
  @override
  ConsumerState<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<LocationStep> {
  StreamSubscription<LocationFix>? _sub;
  LocationFix? _latest, _best;
  bool _noFix = false;

  /// Stops listening to the GPS. Throws nothing.
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Starts listening to fixes; the first one at or below 20 m is saved as the pin. Side effect: GPS on.
  /// Throws nothing (provider errors end the stream; the ring then offers "Save anyway").
  void _start() {
    _sub = ref.read(gpsFixProvider).fixes().listen((fix) {
      if (_best == null || fix.accuracyM < _best!.accuracyM) _best = fix;
      setState(() => _latest = fix);
      if (fix.accuracyM <= kGpsGoodAccuracyM) _save(fix, lowAccuracy: false);
    }, onError: (Object _) {});
    setState(() {});
  }

  /// Saves [fix] as the pin and stops the GPS; [lowAccuracy] marks "Save anyway". Throws nothing.
  void _save(LocationFix fix, {required bool lowAccuracy}) {
    _sub?.cancel();
    _sub = null;
    ref.read(onboardingProvider.notifier).savePin(fix, lowAccuracy: lowAccuracy);
  }

  /// Builds the step for its three states (not started, waiting for a fix, saved). [context] supplies tokens and
  /// strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final pin = ref.watch(onboardingProvider.select((d) => d.requireValue.pin));
    if (pin != null) {
      return stepColumn(context, [
        MergeSemantics(
          child: Row(
            children: [
              Icon(tokens.done.icon, color: tokens.done.color, size: 48),
              SizedBox(width: tokens.gap),
              Expanded(
                child: Text(l10n.onboardPinSaved(pin.accuracyM.round()), style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
        ),
        const NextButton(),
      ]);
    }
    if (_sub == null) {
      return FarmerButton(
        icon: Icons.my_location,
        label: l10n.onboardInField,
        onPressed: _start,
        onSpeak: () => playPrompt(ref, context, 'onboardInField'),
        prominent: true,
      );
    }
    return stepColumn(context, [
      GpsRing(
        accuracyMetres: _latest?.accuracyM,
        onSaveAnyway: () {
          final best = _best;
          best == null ? setState(() => _noFix = true) : _save(best, lowAccuracy: true);
        },
      ),
      if (_noFix) Text(l10n.onboardNoFixYet, style: Theme.of(context).textTheme.titleMedium),
    ]);
  }
}
