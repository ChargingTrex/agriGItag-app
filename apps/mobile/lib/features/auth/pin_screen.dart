// Officer and QC sign-in, step 3: the 4-digit PIN after the OTP; on first sign-in the user chooses it (twice).
// Requirement: FR1, Arch §Security and privacy (PIN for office roles), D-024 (`pin_required` with `pin_set`;
//   `pin_invalid` with `attempts_left`; 5th wrong PIN → `pin_locked` for 5 minutes with `locked_until`; the pin
//   token lives 5 minutes).
// Callers: app_router.dart (/auth/pin with the PinRequiredOut as `extra`); widget tests and goldens.

import 'package:agritrace_api/agritrace_api.dart' show PinRequiredOut;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/session.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import 'auth_step.dart';

/// The PIN step for the OTP result [step].
class PinScreen extends ConsumerStatefulWidget {
  /// Creates the screen. [step] carries the pin token and whether the user already has a PIN.
  const PinScreen({super.key, required this.step});

  /// The `pin_required` answer of OTP verify.
  final PinRequiredOut step;

  /// Creates the state holding the typed PIN. Returns it; throws nothing.
  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';
  String? _first; // first entry while choosing a new PIN
  String? _message;
  bool _busy = false, _expired = false;

  /// Takes the new [pin] digits; on the fourth digit confirms or submits. Returns nothing; throws nothing.
  void _onChanged(String pin) {
    final first = _first;
    final choosing = !widget.step.pinSet && pin.length == 4;
    setState(() {
      _message = null;
      _pin = choosing ? '' : pin;
      if (choosing) {
        // The first entry is kept; the second is used up whether or not it matches.
        _first = first == null ? pin : null;
        if (first != null && first != pin) _message = AppLocalizations.of(context).authPinMismatch;
      }
    });
    // Submit an existing PIN on its 4th digit, or a new PIN once both entries match.
    if (pin.length == 4 && (widget.step.pinSet || first == pin)) _submit(pin);
  }

  /// Sends [pin]; success signs in (the router opens the role's home). Returns when done; throws nothing (failures
  /// become the sentence). Side effects: network call, stored session.
  Future<void> _submit(String pin) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).verifyPin(widget.step.pinToken, pin);
    } on Exception catch (e) {
      final failure = AuthFailure.from(e);
      if (mounted) {
        setState(() {
          _message = authMessage(l10n, failure);
          _expired = failure.code == 'unauthorized';
          _pin = '';
          _first = null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Builds the step. [context] supplies strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthStep(
      prompt: widget.step.pinSet ? l10n.authPinTitle : (_first == null ? l10n.authPinChoose : l10n.authPinRepeat),
      promptId: widget.step.pinSet ? 'authPinTitle' : (_first == null ? 'authPinChoose' : 'authPinRepeat'),
      message: _message,
      value: _pin,
      length: 4,
      obscure: true,
      onChanged: _busy || _expired ? null : _onChanged,
      // The 5-minute pin token ran out: the only way on is a new code.
      action: _expired
          ? FarmerButton(
              icon: Icons.restart_alt,
              label: l10n.authStartAgain,
              onPressed: () => context.go('/auth'),
              onSpeak: () => playPrompt(ref, context, 'authStartAgain'),
              prominent: true,
            )
          : null,
    );
  }
}
