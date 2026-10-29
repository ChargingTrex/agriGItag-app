// FarmerButton: the full-width farmer action button (icon + short word + speaker).
// Requirement: UserFlows §Design rules "Big targets" (>= 56 dp, full width) and "Pictures and voice before
//   words" (icon, short word, speaker icon that plays a recorded prompt); mobile-design.md §6 (Semantics on
//   icon-only controls); plan §7.2 M00/M05 (golden at 56/64 dp).
// Callers: PlaceholderScreen (core/router); every farmer screen from M05 on; test/widget/farmer_button_test.dart.

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';

/// A full-width button with an icon, a label of at most two words and a speaker button beside it.
///
/// Height is [FarmerTokens.minTarget] (56 dp), or [FarmerTokens.farmerTarget] (64 dp) when [prominent].
/// The control grows taller, never shorter, when the user's text scale is larger.
class FarmerButton extends StatelessWidget {
  /// Creates the button.
  ///
  /// [icon] is the picture that carries the meaning; [label] is the localised word(s), at most two words
  /// (asserted in debug builds); [onPressed] runs the action, null disables it; [onSpeak] plays the recorded
  /// voice prompt for this button, null disables the speaker; [prominent] picks the 64 dp main-action size.
  const FarmerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.onSpeak,
    this.prominent = false,
  });

  /// Picture for the action.
  final IconData icon;

  /// Localised label, at most two words.
  final String label;

  /// Action callback; null renders the button disabled.
  final VoidCallback? onPressed;

  /// Plays the voice prompt; null renders the speaker disabled.
  final VoidCallback? onSpeak;

  /// True for the screen's main action (64 dp instead of 56 dp).
  final bool prominent;

  /// Builds the row of action button and speaker button.
  ///
  /// [context] must have a theme with [FarmerTokens] and [AppLocalizations]. Returns the widget.
  /// Throws an [AssertionError] in debug builds when [label] has more than two words.
  @override
  Widget build(BuildContext context) {
    assert(label.trim().split(RegExp(r'\s+')).length <= 2, 'FarmerButton label "$label" exceeds two words');
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final height = prominent ? tokens.farmerTarget : tokens.minTarget;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 28),
            label: Text(label),
            style: FilledButton.styleFrom(minimumSize: Size.fromHeight(height), textStyle: theme.textTheme.titleMedium),
          ),
        ),
        SizedBox(width: tokens.gap / 2),
        // The speaker has no text, so it gets a spoken label; MergeSemantics keeps label and tap action
        // on one node for TalkBack / VoiceOver.
        MergeSemantics(
          child: Semantics(
            label: AppLocalizations.of(context).playVoice,
            child: IconButton.filledTonal(
              onPressed: onSpeak,
              icon: const Icon(Icons.volume_up, size: 28),
              style: IconButton.styleFrom(minimumSize: Size.square(height)),
            ),
          ),
        ),
      ],
    );
  }
}
