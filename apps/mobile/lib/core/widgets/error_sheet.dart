// ErrorSheet: how every problem reaches a farmer — one picture, one sentence read aloud, one button that
//   fixes it. Never an error code.
// Requirement: UserFlows §When things go wrong ("The app never shows an error code; every problem appears as
//   one picture, one short sentence read aloud, and one button that fixes it"), e.g. "Photo is not clear.
//   Take again?" with a big camera button; "Phone is full. Send your entries now?".
// Callers: capture quality check (M04/M07), low storage (M13); shown with showModalBottomSheet;
//   test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';
import 'farmer_button.dart';
import 'voice_prompt_bar.dart';

/// Bottom-sheet body: [picture], the spoken [sentence] and a single 64 dp full-width action.
///
/// Show it with `showModalBottomSheet(context: context, builder: (_) => ErrorSheet(...))`.
class ErrorSheet extends ConsumerWidget {
  /// Creates the sheet.
  ///
  /// [picture] shows the problem (e.g. a 96 dp icon); [sentence] is the localised sentence and [promptId] its
  /// recorded clip; [actionIcon], [actionLabel] (at most two words) and [actionPromptId] describe the one
  /// button; [onAction] fixes the problem.
  const ErrorSheet({
    super.key,
    required this.picture,
    required this.sentence,
    required this.promptId,
    required this.actionIcon,
    required this.actionLabel,
    required this.actionPromptId,
    required this.onAction,
  });

  /// Picture of the problem.
  final Widget picture;

  /// Localised one-sentence description, read aloud on open.
  final String sentence;

  /// Voice prompt id of [sentence].
  final String promptId;

  /// Icon of the fixing action.
  final IconData actionIcon;

  /// Localised label of the fixing action, at most two words.
  final String actionLabel;

  /// Voice prompt id of [actionLabel].
  final String actionPromptId;

  /// Fixes the problem (e.g. reopens the camera).
  final VoidCallback onAction;

  /// Builds the sheet. [context] supplies tokens; [ref] plays the button prompt. Returns the widget;
  /// throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: picture),
            SizedBox(height: tokens.gap),
            VoicePromptBar(promptId: promptId, text: sentence),
            SizedBox(height: tokens.gap),
            FarmerButton(
              icon: actionIcon,
              label: actionLabel,
              onPressed: onAction,
              onSpeak: () => playPrompt(ref, context, actionPromptId),
              prominent: true,
            ),
          ],
        ),
      ),
    );
  }
}
