// One sign-in step: a spoken prompt, one sentence (problem or notice), the typed digits and a large digit keypad, the
//   step's action button and the language button. Shared by the phone, OTP and PIN screens; also maps sign-in
//   failures to one sentence.
// Requirement: FR1, UserFlows §Log in once, §Design rules ("Tap, never type": a number pad, never a free-text box;
//   "Big targets" 64 dp keys; "Language first" one-button switch), §When things go wrong (one short sentence, never an
//   error code); D-024 error codes (docs/api/conventions.md "Authentication").
// Callers: phone_screen.dart, otp_screen.dart, pin_screen.dart; test/widget/auth_screens_test.dart and goldens.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/session.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';

/// Returns the one sentence a sign-in [failure] shows, in [l10n]'s language.
///
/// Waits are rounded up to whole minutes ([now] defaults to the clock; `locked_until` is an ISO-8601 time).
/// Unknown codes get a generic "try again"; the code itself is never shown. Throws nothing.
String authMessage(AppLocalizations l10n, AuthFailure failure, {DateTime? now}) {
  int minutes(num seconds) => max(1, (seconds / 60).ceil());
  final d = failure.details;
  return switch (failure.code) {
    'otp_invalid' => l10n.errorOtpInvalid,
    'otp_expired' => l10n.errorOtpExpired,
    'otp_locked' => l10n.errorOtpLocked,
    'pin_invalid' => l10n.errorPinInvalid((d['attempts_left'] as num?)?.toInt() ?? 0),
    'pin_locked' => l10n.errorPinLocked(
      minutes(DateTime.tryParse('${d['locked_until']}')?.difference(now ?? DateTime.now()).inSeconds ?? 300),
    ),
    'rate_limited' => l10n.errorRateLimited(minutes((d['retry_after_s'] as num?) ?? 60)),
    'device_in_use' => l10n.errorDeviceInUse,
    'unauthorized' => l10n.errorSignInExpired,
    'validation_error' => l10n.errorPhoneInvalid,
    'network' => l10n.errorNetwork,
    'portal_only' => l10n.errorPortalOnly,
    _ => l10n.errorUnknown,
  };
}

/// The layout every sign-in step shares.
///
/// The digits come only from the on-screen keypad (no system keyboard, no text field): [value] is shown as [length]
/// slots, as dots when [obscure].
class AuthStep extends ConsumerWidget {
  /// Creates the step.
  ///
  /// [prompt] says what to enter and [promptId] is its ARB key (the voice clip id); [message] is one localised sentence (a problem, or a notice) or null; [prefix] is
  /// shown before the digits (`+91`); [value] holds the digits typed so far, at most [length]; [obscure] hides them;
  /// [onChanged] receives the new digits after each key (null while a request runs); [action] is the step's button.
  const AuthStep({
    super.key,
    required this.prompt,
    required this.promptId,
    required this.value,
    required this.length,
    required this.onChanged,
    this.message,
    this.prefix,
    this.obscure = false,
    this.action,
  });

  /// What to enter, e.g. "Enter mobile number".
  final String prompt;

  /// ARB key of [prompt]; the recorded clip `assets/audio/<lang>/<promptId>.ogg` (D-016).
  final String promptId;

  /// One sentence: what went wrong or why the user is here; null shows nothing.
  final String? message;

  /// Fixed text before the digits, e.g. the country code.
  final String? prefix;

  /// Digits typed so far.
  final String value;

  /// Number of digits the step needs.
  final int length;

  /// Whether to show dots instead of the digits (PIN).
  final bool obscure;

  /// Receives the new digits; null disables the keypad.
  final ValueChanged<String>? onChanged;

  /// The step's single button, or null when the step submits by itself on the last digit.
  final Widget? action;

  /// Builds the step. [context] supplies theme, tokens and strings; [ref] switches the language. Returns the widget;
  /// throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionProvider.select((s) => s.locale));
    final slots = List.generate(length, (i) => i < value.length ? (obscure ? '●' : value[i]) : '–').join(' ');
    return Scaffold(
      // No implied back arrow (48 dp, below the farmer minimum): each step has its own 56 dp+ buttons and the
      // system back gesture still returns to the previous step.
      appBar: AppBar(title: Text(l10n.signIn), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Keyed by prompt: a new prompt (PIN chosen → repeat it) is spoken again.
              VoicePromptBar(key: ValueKey(promptId), promptId: promptId, text: prompt),
              if (message != null) ...[
                SizedBox(height: tokens.gap),
                Row(
                  children: [
                    Icon(tokens.attention.icon, color: tokens.attention.color),
                    SizedBox(width: tokens.gap / 2),
                    Expanded(
                      child: Semantics(liveRegion: true, child: Text(message!, style: theme.textTheme.titleMedium)),
                    ),
                  ],
                ),
              ],
              SizedBox(height: tokens.gap),
              Semantics(
                label: obscure ? '${value.length} / $length' : null,
                excludeSemantics: obscure,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(prefix == null ? slots : '$prefix  $slots', style: theme.textTheme.displaySmall),
                ),
              ),
              _DigitKeys(value: value, length: length, onChanged: onChanged, deleteLabel: l10n.authDelete),
              if (action != null) ...[SizedBox(height: tokens.gap), action!],
              SizedBox(height: tokens.gap),
              FarmerButton(
                icon: Icons.translate,
                label: l10n.switchLanguage,
                onPressed: () => ref.read(sessionProvider.notifier).setLocale(locale == tamil ? english : tamil),
                onSpeak: () => playPrompt(ref, context, 'switchLanguage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3 x 4 grid of 64 dp digit keys with a delete key; appends to or trims [value], up to [length] digits.
///
/// shortcut: own keypad because M05's NumberPad drops a leading zero (PIN 0123 becomes 123), groups a 10-digit
/// phone Indian-style (98,76,54,3210) and cannot mask a PIN; swap to NumberPad when it gets fixed-length and
/// obscure modes.
class _DigitKeys extends StatelessWidget {
  /// Creates the keys. [value] is the current digits; [length] the most digits; [onChanged] receives the new digits
  /// (null disables every key); [deleteLabel] is the spoken name of the delete key.
  const _DigitKeys({required this.value, required this.length, required this.onChanged, required this.deleteLabel});

  final String value;
  final int length;
  final ValueChanged<String>? onChanged;
  final String deleteLabel;

  /// Builds the grid. [context] supplies theme and tokens. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final change = onChanged;
    Widget key(String face, String? next, {String? label}) => Expanded(
      child: Semantics(
        label: label,
        button: true,
        child: FilledButton.tonal(
          onPressed: change == null || next == null ? null : () => change(next),
          style: FilledButton.styleFrom(minimumSize: Size.fromHeight(tokens.farmerTarget), padding: EdgeInsets.zero),
          child: face == 'del'
              ? const Icon(Icons.backspace_outlined, size: 32)
              : Text(face, style: theme.textTheme.headlineMedium),
        ),
      ),
    );
    Widget digit(String d) => key(d, value.length < length ? value + d : null);
    Widget row(List<Widget> keys) => Padding(
      padding: EdgeInsets.only(top: tokens.gap),
      child: Row(
        children: [
          keys[0],
          SizedBox(width: tokens.gap),
          keys[1],
          SizedBox(width: tokens.gap),
          keys[2],
        ],
      ),
    );
    return Column(
      children: [
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        row([
          const Expanded(child: SizedBox()),
          digit('0'),
          key('del', value.isEmpty ? null : value.substring(0, value.length - 1), label: deleteLabel),
        ]),
      ],
    );
  }
}
