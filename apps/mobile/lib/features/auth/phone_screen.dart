// F01 sign-in, step 1: the mobile number, typed on the on-screen keypad, then "Get code".
// Requirement: FR1 (phone + OTP), UserFlows §Log in once, §Onboarding a farmer steps 1 and 9 (the officer types the
//   number), §When things go wrong "Phone lost or changed" (same number, same SMS code on the new phone); D-024
//   (`otp/request` → 204, `rate_limited` with `retry_after_s`).
// Callers: app_router.dart (/auth, and /auth/otp or /auth/pin without their step data); widget tests and goldens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/session.dart';
import '../../core/widgets/farmer_button.dart';
import 'auth_step.dart';

/// Indian mobile numbers: `+91` and 10 digits (the pilot FPOs are in Tamil Nadu).
const countryCode = '+91';

/// The phone-number step. Shows why the user was signed out when the server ended the session.
class PhoneScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const PhoneScreen({super.key});

  /// Creates the state holding the typed digits. Returns it; throws nothing.
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  String _digits = '';
  AuthFailure? _error;
  bool _busy = false;

  /// Requests the code and opens the OTP step. Returns when done; throws nothing (failures become the sentence).
  /// Side effects: network call; navigation to /auth/otp on success.
  Future<void> _submit() async {
    final phone = '$countryCode$_digits';
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).requestOtp(phone);
      if (mounted) await context.push('/auth/otp', extra: phone);
    } on Exception catch (e) {
      if (mounted) setState(() => _error = AuthFailure.from(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Builds the step. [context] supplies strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ended = ref.watch(sessionProvider.select((s) => s.sessionEnded));
    return AuthStep(
      prompt: l10n.authPhoneTitle,
      message: _error != null ? authMessage(l10n, _error!) : (ended ? l10n.sessionEnded : null),
      prefix: countryCode,
      value: _digits,
      length: 10,
      onChanged: _busy
          ? null
          : (v) => setState(() {
              _digits = v;
              _error = null;
            }),
      action: FarmerButton(
        icon: Icons.sms_outlined,
        label: l10n.authGetCode,
        onPressed: _digits.length == 10 && !_busy ? _submit : null,
        // shortcut: no voice clip yet, so the speaker slot is disabled; M05 wires the prompt player.
        onSpeak: null,
        prominent: true,
      ),
    );
  }
}
