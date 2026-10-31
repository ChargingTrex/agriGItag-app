// O03i Farmer's phone handoff (a QR the farmer's phone scans to open sign-in with the number filled in, and the
//   60-second voice tour), and the farmer summary after saving ("Another plot", "Done").
// Requirement: UserFlows §Onboarding a farmer step 9 ("the farmer scans a QR, signs in with the same SMS code, and
//   plays the 60-second voice tour"), PLAN §1 "Multiple farm lands per farmer" and §7.2 note ("Add another plot"),
//   CLAUDE.md §6 (the QR carries the phone number only: no token, no OTP, no farmer id).
// Callers: onboarding_wizard.dart (OnboardingStep.handoff, OnboardingStep.summary).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// The sign-in link in the handoff QR for [phone] (E.164): `agritrace://auth?phone=%2B91...`. Throws nothing.
///
/// TODO(M08): register the `agritrace` scheme (Android intent filter, iOS URL type) and prefill PhoneScreen from
///   `phone`; until then the farmer types the number shown under the code.
String signInLink(String phone) => Uri(scheme: 'agritrace', host: 'auth', queryParameters: {'phone': phone}).toString();

/// QR + number, "Voice tour", Next to the summary.
class HandoffStep extends ConsumerWidget {
  /// Creates the step.
  const HandoffStep({super.key});

  /// Builds the step. [context] supplies theme and strings; [ref] reads the draft. Returns the widget; throws
  /// nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final phone = ref.watch(onboardingProvider.select((d) => d.requireValue.phone))!;
    return stepColumn(context, [
      Center(
        child: QrImageView(
          data: signInLink(phone),
          size: 220,
          backgroundColor: Colors.white,
          semanticsLabel: l10n.onboardQrLabel(phone),
        ),
      ),
      Text(phone, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
      FarmerButton(
        icon: Icons.record_voice_over,
        label: l10n.onboardVoiceTour,
        onPressed: () => playPrompt(ref, context, 'onboardTour'),
        onSpeak: () => playPrompt(ref, context, 'onboardVoiceTour'),
      ),
      const NextButton(),
    ]);
  }
}

/// "Another plot" (steps 4-8 again for this farmer) and "Done" (back to the officer home).
class SummaryStep extends ConsumerWidget {
  /// Creates the step.
  const SummaryStep({super.key});

  /// Builds the two buttons; the summary sentence is the wizard's prompt bar. [context] supplies strings; [ref]
  /// drives the notifier. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return stepColumn(context, [
      FarmerButton(
        icon: Icons.add_location_alt,
        label: l10n.onboardAnotherPlot,
        onPressed: ref.read(onboardingProvider.notifier).addAnotherPlot,
        onSpeak: () => playPrompt(ref, context, 'onboardAnotherPlot'),
      ),
      FarmerButton(
        icon: Icons.done,
        label: l10n.onboardDone,
        onPressed: () => context.go('/officer'),
        onSpeak: () => playPrompt(ref, context, 'onboardDone'),
        prominent: true,
      ),
    ]);
  }
}
