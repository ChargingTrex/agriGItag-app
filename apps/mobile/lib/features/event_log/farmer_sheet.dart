// F16: how every problem in a farmer flow reaches the farmer — one picture, one sentence read aloud, one button that
// fixes it, shown as a bottom sheet over the M05 ErrorSheet. Never an error code.
// Requirement: UserFlows §When things go wrong (photo not clear, phone full, ...), §Design rules "Pictures and voice
//   before words"; plan §7.2 M07 (F16 error sheets).
// Callers: CameraStep, ConfirmScreen, SavedScreen, EventFlowScreen (event_log), VoiceNoteButton (problem_report).

import 'package:flutter/material.dart';

import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/error_sheet.dart';

/// Shows the one-button sheet: [icon] pictures the problem, [sentence] / [promptId] is the spoken line, the button is
/// [actionIcon] + [actionLabel] (≤ 2 words) / [actionPromptId]. The button closes the sheet, then runs [onAction].
///
/// [context] must sit under the app theme. Returns when the sheet is closed (by the button or a swipe). Throws
/// nothing. Side effect: pushes a modal route.
Future<void> showFarmerSheet(
  BuildContext context, {
  required IconData icon,
  required String sentence,
  required String promptId,
  required IconData actionIcon,
  required String actionLabel,
  required String actionPromptId,
  VoidCallback? onAction,
}) => showModalBottomSheet<void>(
  context: context,
  // Scrollable: at 1.5x text on a small phone the sheet can be taller than the default half screen.
  isScrollControlled: true,
  builder: (sheet) => SingleChildScrollView(
    child: ErrorSheet(
      picture: Icon(icon, size: 96, color: Theme.of(sheet).extension<FarmerTokens>()!.attention.color),
      sentence: sentence,
      promptId: promptId,
      actionIcon: actionIcon,
      actionLabel: actionLabel,
      actionPromptId: actionPromptId,
      onAction: () {
        Navigator.of(sheet).pop();
        onAction?.call();
      },
    ),
  ),
);
