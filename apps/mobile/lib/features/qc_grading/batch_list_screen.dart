// Q-batches: the FPO's batches waiting for grading (`created`) or final packing (`graded`), loaded from the API; a
//   tap opens the grading form or the packing screen.
// Requirement: UserFlows §FPO admin and QC flows ("Create a batch (FPO admin, web portal) ... a batch ID and QR are
//   generated"; "Grade a batch (QC officer, mobile app)"), Dataflow Stages 8-9 (grading and final packing are batch
//   events), PLAN §7.2 M11, D-036 (batches come from the API; readings and events are still saved offline).
// Callers: qc_home/qc_home_screen.dart ("Grade batch"); test/features/qc/*.

import 'package:agritrace_api/agritrace_api.dart' show BatchStatus;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../qc_home/qc_common.dart';
import '../qc_packing/packing_screen.dart';
import 'grading_screen.dart';

/// Batches to grade or pack, from `GET /v1/batches` through the generated client (D-003).
///
/// DECISION D-036: the phone keeps no batch table; the batch list is read online, while the grading readings and the
///   grading / final-packing events are saved offline through the outbox like every other entry.
///   ADV: grading lands on the batch the grade engine reads (readings with `batch_id`), with no new Drift table,
///   migration or pull entity; batches are created on the portal, so a QC officer grading one has just been online.
///   COMPROMISE: with no signal the list cannot open (one sentence and "Try again"); the first 50 batches of each
///   status only (`shortcut:` follow the cursor when an FPO has more waiting).
/// Fails with [DioException] (no signal, or an API error) and passes on any other error of the call.
final qcBatchesProvider = FutureProvider.autoDispose<List<QcBatch>>((ref) async {
  final api = ref.read(apiClientProvider).api.getLotsBatchesApi();
  // The server filters by status, so batches to grade are never hidden behind page 1 of all batches.
  final pages = [
    for (final status in [BatchStatus.created, BatchStatus.graded])
      (await api.listBatchesV1BatchesGet(status: status)).data!,
  ];
  return [
    for (final page in pages)
      for (final b in page.items)
        QcBatch(
          id: b.id,
          code: b.code,
          cropId: b.cropId,
          status: b.status.name,
          totalKg: b.totalReceived?.value,
          gradedKg: b.graded?.value,
        ),
  ];
});

/// The batch list screen.
class BatchListScreen extends ConsumerWidget {
  /// Creates the screen.
  const BatchListScreen({super.key});

  /// Builds the prompt and the list, the offline sentence with "Try again", or a spinner. [context] supplies tokens
  /// and strings; [ref] watches the batches. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final batches = ref.watch(qcBatchesProvider);
    return qcScaffold(
      context,
      l10n.qcGradeBatch,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VoicePromptBar(promptId: 'qcBatchesPrompt', text: l10n.qcBatchesPrompt),
          SizedBox(height: tokens.gap),
          ...batches.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [
              CheckLine(
                check: (
                  glyph: tokens.todo,
                  text: e is DioException && e.response == null ? l10n.qcBatchesOffline : l10n.errorUnknown,
                ),
              ),
              FarmerButton(
                icon: Icons.refresh,
                label: l10n.qcRetry,
                onPressed: () => ref.invalidate(qcBatchesProvider),
                onSpeak: () => playPrompt(ref, context, 'qcRetry'),
              ),
            ],
            data: (list) => list.isEmpty
                ? [CheckLine(check: (glyph: tokens.done, text: l10n.qcNoBatches))]
                : [for (final b in list) _card(context, b, l10n)],
          ),
        ],
      ),
    );
  }

  /// One batch card: code and weight, "To grade" or "To pack"; a tap opens the matching screen. [context] pushes
  /// the route; [l10n] gives the strings. Returns the widget; throws nothing.
  Widget _card(BuildContext context, QcBatch b, AppLocalizations l10n) {
    final toPack = b.status == BatchStatus.graded.name;
    return Card.outlined(
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(toPack ? Icons.inventory : Icons.grading, size: 32),
        title: Text(l10n.qcBatchLine(b.code, b.totalKg ?? '–')),
        subtitle: Text(toPack ? l10n.qcToPack : l10n.qcToGrade),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => toPack ? PackingScreen(batch: b, gradedKg: b.gradedKg) : GradingScreen(batch: b),
          ),
        ),
      ),
    );
  }
}
