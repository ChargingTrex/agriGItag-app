// O03a Start: the officer types the farmer's mobile number on the large digit keypad.
// Requirement: UserFlows §Onboarding a farmer step 1 ("enters the farmer's mobile number"), §Design rules "Tap,
//   never type" (keypad, no keyboard), FR1, D-017 (`farmer.phone` disabled skips this step; required blocks Next).
// Callers: onboarding_wizard.dart (OnboardingStep.start).
//
// The SMS code that proves the number is checked at step 9, when the farmer signs in on their own phone with it:
// the API sends no SMS to a number without an account, and verifying the code on the officer's phone would sign the
// officer out (D-024). See TODO.md (M09) for the server route that would allow the check here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../auth/auth_step.dart' show DigitKeys;
import '../auth/phone_screen.dart' show countryCode;
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// The number as `+91  98765 –––––` slots above M06's digit keypad, and Next.
class StartStep extends ConsumerWidget {
  /// Creates the step.
  const StartStep({super.key});

  /// Builds the read-out, keypad and Next. [context] supplies theme and strings; [ref] edits the draft.
  /// Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digits = ref.watch(onboardingProvider.select((d) => d.requireValue.phoneDigits));
    final slots = List.generate(10, (i) => i < digits.length ? digits[i] : '–').join(' ');
    return stepColumn(context, [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('$countryCode  $slots', style: Theme.of(context).textTheme.displaySmall),
      ),
      DigitKeys(
        value: digits,
        length: 10,
        onChanged: (v) => ref.read(onboardingProvider.notifier).edit((d) => d.phoneDigits = v),
        deleteLabel: AppLocalizations.of(context).authDelete,
      ),
      const NextButton(),
    ]);
  }
}
