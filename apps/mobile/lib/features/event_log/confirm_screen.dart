// F07 Confirm: the photo, the entry read aloud ("Harvest, 6 bags, today. Correct?"), a big tick or Retake — the
// third tap. The tick saves exactly once however often it is tapped.
// Requirement: UserFlows §Logging a farm event ("the confirm screen reads the entry aloud ... and offers only a big
//   tick or Retake"), §Design rules "Mistakes are easy to undo" (confirm shows the photo before saving), §Each farm
//   event (problem: photo plus a 30-second voice note); FR3; D-005 (one save per tap burst), D-017 (a required field
//   without a value disables the tick).
// Callers: app_router.dart route `/log/:eventType/confirm` and its assist copy (pushed by CameraStep).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/widgets/confirm_scaffold.dart';
import '../problem_report/voice_note_button.dart';
import 'event_log_controller.dart';
import 'extra_choice.dart';
import 'farm_event.dart';
import 'farmer_sheet.dart';

/// The confirm screen of the current draft.
class ConfirmScreen extends ConsumerWidget {
  /// Creates the screen.
  const ConfirmScreen({super.key});

  /// Builds the M05 ConfirmScaffold for the draft. [context] supplies strings; [ref] reads the draft. Returns the
  /// screen (an empty box when the draft has no photo; the route guard never lets that show). Throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(eventLogProvider);
    final n = ref.read(eventLogProvider.notifier);
    final photo = d.photo;
    if (photo == null || d.event == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final (summary, promptId) = confirmSummary(l10n, d, Localizations.localeOf(context).languageCode);
    return ConfirmScaffold(
      title: d.event!.label(l10n),
      summary: summary,
      promptId: promptId,
      preview: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              // DECISION D-002: decode the confirm preview at 720 px wide, not the stored 1600 px.
              //   ADV: about a fifth of the memory of a full decode on 2 GB Android Go phones; looks the same on screen.
              //   COMPROMISE: zooming into the preview is not possible (the farmer only checks it is the right photo).
              cacheWidth: 720,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black12, child: Icon(Icons.image, size: 96)),
            ),
          ),
          if (d.event == FarmEvent.problem) ...[const SizedBox(height: 8), const VoiceNoteButton()],
        ],
      ),
      // Off while a required field is empty (D-017) or the voice note is still recording.
      onConfirm: n.missingRequired.isEmpty && !d.recording ? () => _confirm(context, ref) : null,
      onRetake: () {
        n.discardPhoto();
        context.pop();
      },
      showCloud: true,
    );
  }

  /// Saves (idempotent, so a double tap writes one entry) and opens the saved screen; a storage failure opens the
  /// "Phone is full" sheet. [context] navigates; [ref] reads the notifier. Throws nothing.
  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(eventLogProvider.notifier).save();
      if (context.mounted) context.go(farmerPath(ref, '/home/saved'));
    } on Exception {
      // SqliteException (disk full, I/O) or FileSystemException: nothing was written; the farmer can retry.
      if (!context.mounted) return;
      await showFarmerSheet(
        context,
        icon: Icons.sd_card_alert,
        sentence: l10n.phoneFull,
        promptId: 'phoneFull',
        actionIcon: Icons.cloud_upload,
        actionLabel: l10n.sendNow,
        actionPromptId: 'sendNow',
        onAction: ref.read(afterSaveProvider),
      );
    }
  }
}

/// The spoken summary of draft [d] and its prompt id: event, the choice or bags, "today", "Correct?" ([l10n]
/// strings; product names in [languageCode]). Returns (sentence, promptId); throws nothing.
(String, String) confirmSummary(AppLocalizations l10n, EventDraft d, String languageCode) {
  final event = d.event!;
  final name = event == FarmEvent.drying
      ? (d.dryingPhase == 'end' ? l10n.dryingDone : l10n.dryingStart)
      : event.label(l10n);
  final input = d.input;
  final choice = switch (event) {
    FarmEvent.nursery => d.seedVariety,
    FarmEvent.sowing => d.nurseryVariety,
    FarmEvent.problem => d.problemType == null ? null : problemLabel(l10n, d.problemType!),
    _ => null,
  };
  return switch (event) {
    FarmEvent.harvest || FarmEvent.packing => (l10n.confirmBags(name, d.bags), 'confirmBags'),
    FarmEvent.inputApplication when input != null => (
      l10n.confirmProduct(name, languageCode == 'ta' ? input.nameLocal ?? input.nameEn : input.nameEn, d.bags),
      'confirmProduct',
    ),
    FarmEvent.inputApplication => (l10n.confirmBags(name, d.bags), 'confirmBags'),
    _ when choice != null => (l10n.confirmChoice(name, choice), 'confirmChoice'),
    _ => (l10n.confirmPlain(name), 'confirmPlain'),
  };
}
