// Q-packing: final (retail) packing of a graded batch: packed weight on the number pad, capped by the graded weight
//   (blocked with the reason above it), plus pack size, pack count and average price when the FPO captures them.
//   Save writes the `final_packing` event on the batch for the outbox.
// Requirement: Dataflow Stage 9 / §4 gate "final packing ≤ graded kg", FR58 (quantities with units), PLAN §7.2 M11
//   (final packing), D-017 (`event_final_packing` field config), D-033 (the server's `packed_above_graded` gate
//   decides; the phone only previews), D-036 (batch subject).
// Callers: grading_screen.dart ("Pack" after saving), batch_list_screen.dart (a batch "To pack"); test/features/qc/*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../qc_home/qc_common.dart';

/// The final packing screen for one batch.
class PackingScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [batch]; [gradedKg] is the graded weight in kg as decimal text (the admin-approved one,
  /// or the one just entered on the grading form), null when unknown. Throws nothing.
  const PackingScreen({super.key, required this.batch, required this.gradedKg});

  /// The batch being packed.
  final QcBatch batch;

  /// Graded weight in kg (decimal text), the ceiling for the packed weight; null when unknown.
  final String? gradedKg;

  /// Creates the state holding the typed values and the entry id. Returns it; throws nothing.
  @override
  ConsumerState<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends ConsumerState<PackingScreen> {
  // D-005: made once, so a retry writes the same entry.
  final _packingId = const Uuid().v7();
  final _values = <String, String>{};
  String _selected = 'quantity';
  bool _saved = false;
  bool _saving = false;
  bool _failed = false;

  /// Builds the form once the field config is loaded. [context] supplies tokens and strings. Returns the screen;
  /// throws nothing (a load error shows the generic sentence).
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final config = ref.watch(qcFieldRulesProvider('event_final_packing'));
    return qcScaffold(
      context,
      l10n.qcBatchLine(widget.batch.code, widget.batch.totalKg ?? '–'),
      config.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown)),
        data: (rules) => _form(context, rules),
      ),
    );
  }

  /// The form under field [config]. [context] supplies tokens and strings. Returns the widget; throws nothing.
  Widget _form(BuildContext context, Map<String, bool>? config) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final ceiling = parseTyped(widget.gradedKg);
    final packed = parseTyped(_values['quantity']);
    final above = packed != null && ceiling != null && packed > ceiling;
    final aboveText = above ? l10n.qcPackAboveGraded(kgText(packed.toDouble()), kgText(ceiling.toDouble())) : null;
    final fields = [
      if (fieldShown(config, 'quantity'))
        QcField(
          name: 'quantity',
          label: l10n.qcPackedWeight,
          unit: l10n.unitKg,
          check: aboveText == null ? null : (glyph: tokens.attention, text: aboveText),
        ),
      if (fieldShown(config, 'pack_size'))
        QcField(name: 'pack_size', label: l10n.qcPackSize, unit: l10n.unitGram, decimal: false),
      if (fieldShown(config, 'packs')) QcField(name: 'packs', label: l10n.qcPacks, decimal: false),
      if (fieldShown(config, 'avg_sale_price_per_kg'))
        QcField(name: 'avg_sale_price_per_kg', label: l10n.qcAvgPrice, unit: l10n.unitRupeePerKg),
    ];
    final missing = fields
        .where((f) => fieldRequired(config, f.name) && parseTyped(_values[f.name]) == null)
        .firstOrNull;
    String? blocker;
    if (missing != null) {
      blocker = l10n.qcFillRequired(missing.label);
    } else if (fields.isNotEmpty && fields.every((f) => parseTyped(_values[f.name]) == null)) {
      blocker = l10n.qcFillRequired(fields.first.label);
    } else if (packed != null && ceiling == null) {
      blocker = l10n.qcGradedUnknown;
    } else if (aboveText != null) {
      blocker = aboveText;
    }
    return QcStepBody(
      promptId: 'qcPackingPrompt',
      prompt: l10n.qcPackingPrompt,
      saved: _saved,
      nextLabel: l10n.qcDone,
      nextPromptId: 'qcDone',
      onNext: () => Navigator.of(context).popUntil((r) => r.isFirst),
      blocker: blocker == null ? null : (glyph: tokens.todo, text: blocker),
      onSave: _saving ? null : _save,
      children: [
        if (ceiling != null)
          Text(l10n.qcGradedCeiling(kgText(ceiling.toDouble())), style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: tokens.gap),
        QcNumberForm(
          fields: fields,
          values: _values,
          selected: _selected,
          onSelect: (name) => setState(() => _selected = name),
          onChanged: (name, v) => setState(() => _values[name] = v),
        ),
        if (_failed) CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown)),
      ],
    );
  }

  /// Saves the `final_packing` event with the typed values (left-out fields are not in the payload). Returns when
  /// saved or failed; throws nothing (a failure shows the generic sentence and keeps the form). Side effects: one
  /// Entries row and its Outbox row.
  Future<void> _save() async {
    setState(() => _saving = true);
    final packed = parseTyped(_values['quantity']);
    final size = parseTyped(_values['pack_size']);
    final packs = parseTyped(_values['packs']);
    final price = parseTyped(_values['avg_sale_price_per_kg']);
    final now = DateTime.now();
    try {
      await saveQcEntries(ref.read(appDatabaseProvider), [
        (
          id: _packingId,
          type: 'final_packing',
          lotId: null,
          farmerId: '',
          payload: {
            // Lifted onto the event version as its subject by the outbox (M02 `_versionKeys`).
            'batch_id': widget.batch.id,
            if (packed != null) 'quantity': quantity(packed, 'kg'),
            if (size != null) 'pack_size': quantity(size, 'g'),
            if (packs != null) 'packs': packs.toBigInt().toInt(),
            if (price != null) 'avg_sale_price_per_kg': price.toString(),
          },
        ),
      ], now);
      if (mounted) setState(() => _saved = true);
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
