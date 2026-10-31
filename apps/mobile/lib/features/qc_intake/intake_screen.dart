// Q-intake: the lot card (farmer, packed kg), the received weight on the number pad with the ±5 % check against the
//   packed quantity, and the intake moisture reading from a calibrated meter with the profile's moisture limit.
//   Save writes the reading and the `lot_intake` entry (receives the lot, D-040) in one transaction for the outbox.
// Requirement: UserFlows §Selling to the FPO steps 2-4 ("weighs the bags and enters the weight; ... takes an intake
//   moisture reading. Checks run on the spot: weight vs. packed quantity, ... moisture limit. A green tick means
//   accepted; an orange circle explains the problem in one line"), Dataflow Stage 7, FR42, FR43 (intake moisture),
//   FR50 (calibration, plausibility), PLAN §7.2 M11 ("230 vs 200 → orange; 11.5 → orange"), D-017 (`event_intake`
//   field config), D-006 (the phone only previews; the server re-runs every rule, B08/B09), D-040 (`lot_intake` push kind).
// Callers: scan_screen.dart (after a scan or a pick); test/features/qc/*.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/models/standards.dart';
import '../../core/rules/grade_calculator.dart';
import '../../core/rules/moisture_limit.dart';
import '../../core/theme/farmer_tokens.dart';
import '../qc_home/qc_common.dart';
import '../qc_meter/instrument_picker.dart';

/// Profile code of the moisture parameter (the one reading taken at intake).
const _moisture = 'moisture';

/// The intake check for one lot.
class IntakeScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [lot]. Throws nothing.
  const IntakeScreen({super.key, required this.lot});

  /// The scanned lot.
  final QcLot lot;

  /// Creates the state holding the typed values, the meter and the entry ids. Returns it; throws nothing.
  @override
  ConsumerState<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends ConsumerState<IntakeScreen> {
  // D-005: ids are made once per screen, so a second tap or a retry after a failed save writes the same entries.
  final _readingId = const Uuid().v7();
  final _intakeId = const Uuid().v7();
  final _values = <String, String>{};
  String _selected = 'received';
  String? _meter;
  bool _saved = false;
  bool _saving = false;
  bool _failed = false;

  /// Builds the lot card and the form once the profile, field config and meters are loaded. [context] supplies
  /// tokens and strings. Returns the screen; throws nothing (a load error shows the generic sentence).
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final standards = ref.watch(qcStandardsProvider(widget.lot.cropId));
    final config = ref.watch(qcFieldRulesProvider('event_intake'));
    final meters = ref.watch(qcInstrumentsProvider);
    final Widget body;
    if (standards.hasError || config.hasError || meters.hasError) {
      body = CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown));
    } else if (!standards.hasValue || !config.hasValue || !meters.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _form(
        context,
        standards.value,
        config.value,
        meters.value!.where((i) => i.kind == 'moisture_meter').toList(),
      );
    }
    return qcScaffold(context, l10n.qcReceiveLot, body);
  }

  /// The step body for [rules] (null: profile not downloaded, so no moisture verdict), field [config] and the
  /// moisture [meters]. [context] supplies tokens and strings. Returns the widget; throws nothing.
  Widget _form(BuildContext context, StandardsRules? rules, Map<String, bool>? config, List<Instrument> meters) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final kg = l10n.unitKg;
    final param = rules?.parameter(_moisture);
    final unit = param?.unit ?? '%';
    final received = parseTyped(_values['received']);
    final price = parseTyped(_values['price_per_kg']);
    final moisture = parseTyped(_values[_moisture]);
    final moistureProblem = moisture == null || rules == null ? null : _implausible(rules, moisture, unit, l10n);
    final fields = [
      // Always shown and required: `IntakeIn.received` is required by the server schema, not by field config.
      QcField(name: 'received', label: l10n.qcReceived, unit: kg, check: _weightCheck(received, tokens, l10n)),
      if (fieldShown(config, 'price_per_kg'))
        QcField(name: 'price_per_kg', label: l10n.qcPricePerKg, unit: l10n.unitRupeePerKg),
      if (fieldShown(config, 'moisture_reading_id'))
        QcField(
          name: _moisture,
          label: param == null ? l10n.qcMoisture : parameterLabel(param, Localizations.localeOf(context)),
          unit: unit,
          check: moistureProblem ?? _moistureCheck(rules, moisture, tokens, l10n),
        ),
    ];
    final missing = fields
        .where(
          (f) => f.name == 'received' || fieldRequired(config, f.name == _moisture ? 'moisture_reading_id' : f.name),
        )
        .where((f) => parseTyped(_values[f.name]) == null)
        .firstOrNull;
    String? blocker;
    if (missing != null) {
      blocker = l10n.qcFillRequired(missing.label);
    } else if (fields.isNotEmpty && fields.every((f) => parseTyped(_values[f.name]) == null)) {
      blocker = l10n.qcFillRequired(fields.first.label);
    } else if (moisture != null && _meter == null) {
      blocker = l10n.qcPickMeter;
    } else if (moistureProblem != null) {
      blocker = moistureProblem.text;
    }
    return QcStepBody(
      promptId: 'qcIntakePrompt',
      prompt: l10n.qcIntakePrompt,
      saved: _saved,
      nextLabel: l10n.qcDone,
      nextPromptId: 'qcDone',
      onNext: () => Navigator.of(context).popUntil((r) => r.isFirst),
      blocker: blocker == null ? null : (glyph: tokens.todo, text: blocker),
      onSave: _saving
          ? null
          : () => _save(received: received, price: price, moisture: moisture, unit: unit, methodRef: param?.methodRef),
      children: [
        _lotCard(context),
        SizedBox(height: tokens.gap),
        QcNumberForm(
          fields: fields,
          values: _values,
          selected: _selected,
          onSelect: (name) => setState(() => _selected = name),
          onChanged: (name, v) => setState(() => _values[name] = v),
        ),
        if (fieldShown(config, 'moisture_reading_id')) ...[
          SizedBox(height: tokens.gap),
          InstrumentPicker(
            instruments: meters,
            selected: _meter,
            today: DateTime.now(),
            onSelected: (id) => setState(() => _meter = id),
          ),
        ],
        if (_failed) CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown)),
      ],
    );
  }

  /// The lot card: lot, farmer and packed weight. [context] supplies theme and strings. Returns it; throws nothing.
  Widget _lotCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lot = widget.lot;
    final theme = Theme.of(context);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          Flexible(
            child: Text(value, style: theme.textTheme.titleMedium, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            row(l10n.qcLot, shortId(lot.lotId)),
            row(l10n.qcFarmer, lot.farmerName ?? shortId(lot.farmerId)),
            row(l10n.qcPacked, '${kgText(lot.packedKg)} ${l10n.unitKg}'),
            if (lot.unverified)
              CheckLine(check: (glyph: Theme.of(context).extension<FarmerTokens>()!.todo, text: l10n.qcLotUnverified)),
          ],
        ),
      ),
    );
  }

  /// The weight check: orange when [received] differs from the packed weight by more than 5 % (UserFlows §Selling
  /// step 4; the server's `quantity_mismatch` flag decides), green within it; null before a weight is typed or when
  /// the packed weight is unknown or comes from an unverified QR. [tokens] give the glyphs, [l10n] the sentence.
  /// Throws nothing.
  QcCheck? _weightCheck(Decimal? received, FarmerTokens tokens, AppLocalizations l10n) {
    final packedKg = widget.lot.packedKg;
    // An unverified card shows the QR's own packed weight, which anyone can forge (D-035): no check against it.
    if (received == null || packedKg <= 0 || widget.lot.unverified) return null;
    final packed = toDecimal(packedKg);
    // Exact: |r − p| × 100 > p × 5, so 210 vs 200 (exactly 5 %) stays green.
    final off = (received - packed).abs() * Decimal.fromInt(100) > packed * Decimal.fromInt(5);
    return off
        ? (glyph: tokens.todo, text: l10n.qcWeightMismatch(kgText(received.toDouble()), kgText(packedKg)))
        : (glyph: tokens.done, text: l10n.qcWeightOk);
  }

  /// The moisture verdict under [rules]' `ready_for_sale` gate (M03 `moistureVerdict`): orange above the limit,
  /// green within; null without a value, a profile or a gate. [tokens] give the glyphs, [l10n] the sentence.
  /// Throws nothing.
  QcCheck? _moistureCheck(StandardsRules? rules, Decimal? moisture, FarmerTokens tokens, AppLocalizations l10n) {
    final limit = rules?.lotGates['ready_for_sale']?.max;
    if (rules == null || moisture == null || limit == null) return null;
    return moistureVerdict(rules, moisture.toString()) == MoistureVerdict.continueDrying
        ? (glyph: tokens.todo, text: l10n.qcMoistureHigh(moisture.toString(), limit.toString()))
        : (glyph: tokens.done, text: l10n.qcMoistureOk(limit.toString()));
  }

  /// The plausibility problem of a [moisture] reading in [unit] under [rules] (FR50), as a blocking check, or null.
  /// [l10n] gives the sentence. Throws nothing.
  QcCheck? _implausible(StandardsRules rules, Decimal moisture, String unit, AppLocalizations l10n) {
    final reading = Reading(
      parameterCode: _moisture,
      value: moisture,
      unit: unit,
      stage: 'intake',
      source: 'instrument',
    );
    final range = rules.parameter(_moisture)?.plausible;
    final bad = checkPlausibility(rules, reading).any((v) => v.code == 'implausible_value');
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    return bad && range != null
        ? (glyph: tokens.attention, text: l10n.qcOutOfRange('${range.min ?? ''}', '${range.max ?? ''}', unit))
        : null;
  }

  /// Saves the moisture reading (when typed) and the `lot_intake` entry in one transaction (`saveQcEntries`).
  ///
  /// [received] kg (never null: Save stays disabled without it), [price] ₹/kg and [moisture] in [unit] are the
  /// typed values (null = left out of the payload);
  /// [methodRef] is the profile's moisture method. Returns when saved or failed; throws nothing (a failure shows the
  /// generic sentence and keeps the form for a retry). Side effects: Entries and Outbox rows.
  Future<void> _save({
    required Decimal? received,
    required Decimal? price,
    required Decimal? moisture,
    required String unit,
    required String? methodRef,
  }) async {
    setState(() => _saving = true);
    final lot = widget.lot;
    final now = DateTime.now();
    final reading = moisture == null
        ? null
        : (
            id: _readingId,
            type: 'quality_reading',
            lotId: lot.lotId,
            farmerId: lot.farmerId,
            payload: readingPayload(
              lotId: lot.lotId,
              stage: 'intake',
              code: _moisture,
              value: moisture,
              unit: unit,
              methodRef: methodRef,
              source: 'instrument',
              instrumentId: _meter,
              now: now,
            ),
          );
    try {
      await saveQcEntries(ref.read(appDatabaseProvider), [
        ?reading,
        (
          id: _intakeId,
          // DECISION D-040: the phone receives the lot with push kind `lot_intake` (`IntakeIn` without client_id),
          //   not an `intake` event version, which only lands on the lot timeline and receives nothing.
          //   ADV: one intake record (`lot_intakes`): shares, reconciliation, pull and the page see this weight.
          //   COMPROMISE: no `processor_id` is sent (the QC user has none in context); the server uses the FPO's
          //   only processor and answers `field_required` when an FPO has several, until a processor picker exists.
          type: 'lot_intake',
          lotId: lot.lotId,
          farmerId: lot.farmerId,
          payload: {
            'lot_id': lot.lotId,
            'sale_date': now.toIso8601String().substring(0, 10),
            'received': quantity(received!, 'kg'),
            if (price != null) 'price_per_kg': price.toString(),
            'intake_moisture_reading_id': ?reading?.id,
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
