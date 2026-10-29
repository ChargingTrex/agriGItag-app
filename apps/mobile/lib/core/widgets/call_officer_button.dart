// CallFieldOfficerButton: "Call officer" — dials the farmer's field officer from any farmer screen.
// Requirement: UserFlows §Design rules "Help is a person" (a "Call my field officer" button on every screen)
//   and §Alerts, help and feature phones ("dials directly"); "Pictures and voice before words".
// Callers: ConfirmScaffold (this folder); every farmer screen from M07 on; test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/gen/app_localizations.dart';
import '../voice/voice_player.dart';
import 'farmer_button.dart';

/// Phone number of the signed-in farmer's field officer, or null when not known yet.
///
/// shortcut: always null until M06/M07 override it with the officer's number from the Drift session data;
/// while null the button shows disabled.
final fieldOfficerPhoneProvider = Provider<String?>((ref) => null);

/// Full-width [FarmerButton] that opens the phone dialer on the field officer's number (`tel:`).
class CallFieldOfficerButton extends ConsumerWidget {
  /// Creates the button; the number comes from [fieldOfficerPhoneProvider].
  const CallFieldOfficerButton({super.key});

  /// Voice prompt id (and ARB key) of the button's spoken label.
  static const promptId = 'callOfficer';

  /// Builds the button. [context] supplies strings; [ref] watches the officer's number and plays the prompt.
  /// Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phone = ref.watch(fieldOfficerPhoneProvider);
    return FarmerButton(
      icon: Icons.call,
      label: AppLocalizations.of(context).callOfficer,
      // launchUrl returns false when the device has no dialer (a tablet); nothing else to offer then.
      onPressed: phone == null ? null : () => launchUrl(Uri(scheme: 'tel', path: phone)),
      onSpeak: () => playPrompt(ref, context, promptId),
    );
  }
}
