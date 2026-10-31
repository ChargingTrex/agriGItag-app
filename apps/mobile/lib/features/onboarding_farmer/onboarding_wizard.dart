// O03 onboarding wizard screen: the shell around the step on screen (app bar with step counter and cloud, the
//   step's spoken prompt, the step body) and the Next button the steps share.
// Requirement: UserFlows §Onboarding a farmer (the officer drives the screens; the farmer listens, agrees and stands
//   in the field), §Design rules (one job per screen, voice before words, big targets, works with no signal),
//   mobile-design.md §4 Officer O03a-i, PLAN §7.2 M09; every control >= 56 dp (farmer taps, and officer-only controls held to the same size).
// Callers: app_router.dart (/officer/onboard); test/features/onboarding/*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/cloud_sync_indicator.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'boundary_step.dart';
import 'consent_step.dart';
import 'crop_step.dart';
import 'handoff_step.dart';
import 'land_size_step.dart';
import 'location_step.dart';
import 'onboarding_notifier.dart';
import 'start_step.dart';
import 'water_step.dart';
import 'who_step.dart';

/// The wizard route: loads the field rules, then shows the current [OnboardingStep].
class OnboardingWizard extends ConsumerWidget {
  /// Creates the wizard.
  const OnboardingWizard({super.key});

  /// Builds the shell for the current step. [context] supplies theme and strings; [ref] watches the draft.
  /// Returns the screen; throws nothing (a broken field config shows the generic error sentence).
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final draft = ref.watch(onboardingProvider);
    final d = draft.value;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.onboardTitle)),
        body: Center(child: draft.hasError ? Text(l10n.errorUnknown) : const CircularProgressIndicator()),
      );
    }
    final notifier = ref.read(onboardingProvider.notifier);
    final (promptId, prompt, body) = _step(d, l10n);
    // The counter covers steps 1-9 as the officer sees them; the summary is not a step.
    final counted = d.steps.where((s) => s != OnboardingStep.summary).toList();
    return PopScope(
      canPop: notifier.canLeaveWizard,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.back();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: notifier.canLeaveWizard
              ? null
              : BackButton(
                  style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
                  onPressed: notifier.back,
                ),
          title: Text(l10n.onboardTitle),
          // A bar, not a "3 of 9" text: the title keeps its width at 1.5x Tamil text; screen readers get the words.
          bottom: d.step == OnboardingStep.summary
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: LinearProgressIndicator(
                    value: (counted.indexOf(d.step) + 1) / counted.length,
                    semanticsLabel: l10n.onboardStepOf(counted.indexOf(d.step) + 1, counted.length),
                  ),
                ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.gap),
              child: const CloudSyncIndicator(),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.gap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Keyed by step so each step speaks its prompt when it opens. The consent step places its own (long)
                // message under the "I agree" button, so the button never scrolls off screen.
                if (d.step != OnboardingStep.consent) ...[
                  VoicePromptBar(key: ValueKey(d.step), promptId: promptId, text: prompt),
                  SizedBox(height: tokens.gap),
                ],
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The prompt id, prompt text and body widget of [d]'s step, in [l10n]'s language. Throws nothing.
  (String, String, Widget) _step(OnboardingDraft d, AppLocalizations l10n) => switch (d.step) {
    OnboardingStep.start => ('onboardPhonePrompt', l10n.onboardPhonePrompt, const StartStep()),
    OnboardingStep.consent => (
      'onboardConsentMessage',
      l10n.onboardConsentMessage,
      ConsentStep(message: l10n.onboardConsentMessage),
    ),
    OnboardingStep.who => ('onboardWhoPrompt', l10n.onboardWhoPrompt, const WhoStep()),
    OnboardingStep.location => ('onboardLocationPrompt', l10n.onboardLocationPrompt, const LocationStep()),
    OnboardingStep.landSize => ('onboardLandPrompt', l10n.onboardLandPrompt, const LandSizeStep()),
    OnboardingStep.boundary => ('onboardBoundaryPrompt', l10n.onboardBoundaryPrompt, const BoundaryStep()),
    OnboardingStep.water => ('onboardWaterPrompt', l10n.onboardWaterPrompt, const WaterStep()),
    OnboardingStep.soil => ('onboardSoilPrompt', l10n.onboardSoilPrompt, const SoilStep()),
    OnboardingStep.crop => ('onboardCropPrompt', l10n.onboardCropPrompt, const CropStep()),
    OnboardingStep.handoff => ('onboardHandoffPrompt', l10n.onboardHandoffPrompt, const HandoffStep()),
    OnboardingStep.summary => ('onboardSummary', l10n.onboardSummary(d.name.trim(), d.plotsSaved), const SummaryStep()),
  };
}

/// The shared Next button: enabled when the current step's required fields are filled
/// ([OnboardingDraft.canLeave]); moves to the next step that applies.
class NextButton extends ConsumerWidget {
  /// Creates the button.
  const NextButton({super.key});

  /// Builds the button. [context] supplies strings; [ref] watches the draft. Returns it; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(onboardingProvider).requireValue;
    final notifier = ref.read(onboardingProvider.notifier);
    return FarmerButton(
      icon: Icons.arrow_forward,
      label: AppLocalizations.of(context).onboardNext,
      onPressed: d.canLeave(d.step) ? notifier.next : null,
      onSpeak: () => playPrompt(ref, context, 'onboardNext'),
      prominent: true,
    );
  }
}

/// A [Column] of [children] with the farmer token gap between them, stretched to full width.
///
/// Returns the widget; throws nothing.
Widget stepColumn(BuildContext context, List<Widget> children) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: Theme.of(context).extension<FarmerTokens>()!.gap,
  children: children,
);
