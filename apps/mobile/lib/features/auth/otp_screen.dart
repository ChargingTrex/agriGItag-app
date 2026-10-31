// F01 sign-in, step 2: the 6-digit SMS code, read from the SMS on Android or typed on the keypad; submits on the
//   sixth digit. Handles `device_in_use` with a sign-out sheet.
// Requirement: FR1, UserFlows §Onboarding a farmer step 1 ("The farmer gets an SMS code, which the app reads
//   automatically") and step 9, §Who uses what (shared family phones), §When things go wrong (one sentence, one
//   button); D-024 (`otp_invalid`, `otp_expired`, `otp_locked`, `device_in_use`, `pin_required`).
// Callers: app_router.dart (/auth/otp with the phone as `extra`); widget tests.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/session.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/error_sheet.dart';
import '../../core/widgets/farmer_button.dart';
import 'auth_step.dart';

/// Waits for the sign-in SMS and returns its 6-digit code, or null when none was read (cancelled, not Android).
///
/// DECISION D-028: Android's SMS User Consent API (smart_auth) instead of the SMS Retriever API.
///   ADV: works with any SMS text, so the notifications template (B04) need not carry the app's signing hash, which
///   differs between debug and release keys; no SMS permission.
///   COMPROMISE: Android shows a one-tap "Allow" sheet instead of a silent read; iOS gets no auto-read, because
///   iOS one-time-code autofill needs a system-keyboard text field, which the farmer rules forbid.
final smsCodeProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    final result = await SmartAuth.instance.getSmsWithUserConsentApi(matcher: r'\d{6}');
    return result.hasData ? result.data!.code : null;
  },
);

/// The OTP step for [phone].
class OtpScreen extends ConsumerStatefulWidget {
  /// Creates the screen. [phone] is the E.164 number the code was sent to.
  const OtpScreen({super.key, required this.phone});

  /// Number the code was sent to, e.g. `+919876543210`.
  final String phone;

  /// Creates the state holding the typed code. Returns it; throws nothing.
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';
  AuthFailure? _error;
  bool _busy = false;

  /// Starts listening for the SMS. Side effect: Android shows the consent sheet when the SMS arrives.
  @override
  void initState() {
    super.initState();
    _listen();
  }

  /// Stops the SMS listener. Side effect: platform call on Android; errors are ignored by the plugin.
  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.android) SmartAuth.instance.removeUserConsentApiListener();
    super.dispose();
  }

  /// Fills in and submits the code read from the SMS, if any. Returns when done; throws nothing.
  Future<void> _listen() async {
    final code = await ref.read(smsCodeProvider)();
    if (mounted && code != null && !_busy) _onChanged(code);
  }

  /// Takes the new [code] digits and submits on the sixth. Returns nothing; throws nothing.
  void _onChanged(String code) {
    setState(() {
      _code = code;
      _error = null;
    });
    if (code.length == 6) _verify();
  }

  /// Verifies the code: a farmer is signed in (the router opens /home), an office user goes to the PIN step.
  /// Returns when done; throws nothing (failures become the sentence or the device sheet).
  /// Side effects: network call, stored session, navigation.
  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      final step = await ref.read(sessionProvider.notifier).verifyOtp(widget.phone, _code);
      if (step != null && mounted) await context.push('/auth/pin', extra: step);
    } on Exception catch (e) {
      final failure = AuthFailure.from(e);
      if (!mounted) return;
      if (failure.code == 'device_in_use') {
        await _deviceInUse();
      } else {
        setState(() {
          _error = failure;
          _code = '';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Shows "This phone is signed in as someone else. Sign out first." with a sign-out button that forgets the old
  /// device binding and retries the same code. Returns when the sheet closes; throws nothing.
  Future<void> _deviceInUse() async {
    final l10n = AppLocalizations.of(context);
    final signOut = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheet) => ErrorSheet(
        picture: const Icon(Icons.phonelink_lock, size: 96),
        sentence: l10n.errorDeviceInUse,
        promptId: 'errorDeviceInUse',
        actionIcon: Icons.logout,
        actionLabel: l10n.signOut,
        actionPromptId: 'signOut',
        onAction: () => Navigator.of(sheet).pop(true),
      ),
    );
    if (!mounted) return;
    if (signOut != true) return setState(() => _code = '');
    await ref.read(sessionProvider.notifier).forgetDevice();
    if (mounted) await _verify();
  }

  /// Asks for a new code. Returns when done; throws nothing (failures become the sentence).
  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _code = '';
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).requestOtp(widget.phone);
      _listen();
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
    return AuthStep(
      prompt: l10n.authOtpTitle,
      promptId: 'authOtpTitle',
      message: _error == null ? null : authMessage(l10n, _error!),
      value: _code,
      length: 6,
      onChanged: _busy ? null : _onChanged,
      action: FarmerButton(
        icon: Icons.refresh,
        label: l10n.authResend,
        onPressed: _busy ? null : _resend,
        onSpeak: () => playPrompt(ref, context, 'authResend'),
      ),
    );
  }
}
