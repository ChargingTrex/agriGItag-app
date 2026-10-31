// O03b Consent: the recorded consent message plays by itself (clip `onboardConsentMessage`) and is shown as text
//   under the farmer's one big "I agree".
// Requirement: UserFlows §Onboarding a farmer step 2 ("plays a short recorded message in Tamil ... The farmer taps a
//   large 'I agree' button; the consent is saved with time and the officer's name"), FR41, CLAUDE.md §6; the
//   consent entry itself is written by OnboardingNotifier.save (kind `consent`, data_collection, witness from token).
// Callers: onboarding_wizard.dart (OnboardingStep.consent).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// A handshake picture, the farmer's 64 dp "I agree" (after agreeing and coming back: a tick and Next), and the
/// spoken consent [message] below it.
class ConsentStep extends ConsumerWidget {
  /// Creates the step. [message] is the localised consent text, the words of the `onboardConsentMessage` clip.
  const ConsentStep({super.key, required this.message});

  /// Localised consent text (version [consentTextVersion]).
  final String message;

  /// Builds the step. [context] supplies theme, tokens and strings; [ref] reads and edits the draft.
  /// Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final agreed = ref.watch(onboardingProvider.select((d) => d.requireValue.consentGivenAt != null));
    return stepColumn(context, [
      ExcludeSemantics(
        child: Icon(
          agreed ? tokens.done.icon : Icons.handshake_outlined,
          size: 96,
          color: agreed ? tokens.done.color : null,
        ),
      ),
      if (agreed)
        const NextButton()
      else
        FarmerButton(
          icon: Icons.thumb_up_alt_outlined,
          label: l10n.onboardAgree,
          onPressed: () =>
              ref.read(onboardingProvider.notifier).agree(DateTime.now(), Localizations.localeOf(context).languageCode),
          onSpeak: () => playPrompt(ref, context, 'onboardAgree'),
          prominent: true,
        ),
      VoicePromptBar(promptId: 'onboardConsentMessage', text: message),
    ]);
  }
}
