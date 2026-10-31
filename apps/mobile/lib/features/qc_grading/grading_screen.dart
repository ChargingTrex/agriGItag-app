// Q-grading: the grading form generated from the crop's Standards Profile (one input per required grading
//   parameter, with unit and plausible range), the instrument or "Visual" the readings come from, the live grade
//   preview (M03's port of the server grade engine) with the standard and edition, or a grey preview listing the
//   missing readings; graded weight and the declared grade compared with the computed one. Save writes one
//   `quality_reading` per reading and the `grading` event on the batch in one transaction.
// Requirement: UserFlows §Grade a batch ("The app shows only the readings this crop's standard needs ... Enter each
//   with a number pad ... The app calculates the grade and shows it in large type with the standard it used"),
//   FR42-FR50 (readings, source caps, profile, grade computation, declared vs computed, plausibility), Dataflow
//   Stage 8, PLAN §7.2 M11 ("4 readings → grade + standard edition; missing → grey"), D-006 (phone preview, server
//   authority), D-015 (profile JSON), D-017 (`event_grading` field config), D-036 (batch subject).
// Callers: batch_list_screen.dart (a batch "To grade"); test/features/qc/*.

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/models/standards.dart';
import '../../core/rules/grade_calculator.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../qc_home/qc_common.dart';
import '../qc_meter/instrument_picker.dart';
import '../qc_packing/packing_screen.dart';

/// Form field name of the graded weight (`GradingPayload.quantity`).
const _gradedKg = 'quantity';

/// The grading form for one batch.
class GradingScreen extends ConsumerStatefulWidget {
  /// Creates the form for [batch]. Throws nothing.
  const GradingScreen({super.key, required this.batch});

  /// The batch being graded.
  final QcBatch batch;

  /// Creates the state holding the typed readings, the source, the declared grade and the entry ids. Returns it;
  /// throws nothing.
  @override
  ConsumerState<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends ConsumerState<GradingScreen> {
  // D-005: one id per parameter and one for the event, made once, so a retry writes the same entries.
  final _ids = <String, String>{};
  final _gradingId = const Uuid().v7();
  final _values = <String, String>{};
  String? _selected;
  // FR42: each reading keeps its own source (instrument id or visual), e.g. a meter for moisture, visual counts
  // for broken pods.
  final _sources = <String, String>{};
  String? _declared;
  bool _saved = false;
  bool _saving = false;
  bool _failed = false;

  /// Builds the form once the profile, field config and instruments are loaded. [context] supplies tokens and
  /// strings. Returns the screen; throws nothing (a load error shows the generic sentence).
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final standards = ref.watch(qcStandardsProvider(widget.batch.cropId));
    final config = ref.watch(qcFieldRulesProvider('event_grading'));
    final meters = ref.watch(qcInstrumentsProvider);
    final Widget body;
    if (standards.hasError || config.hasError || meters.hasError) {
      body = CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown));
    } else if (!standards.hasValue || !config.hasValue || !meters.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (standards.value == null) {
      body = CheckLine(check: (glyph: tokens.todo, text: l10n.qcNoStandards));
    } else {
      body = _form(context, standards.value!, config.value, meters.value!);
    }
    return qcScaffold(context, l10n.qcBatchLine(widget.batch.code, widget.batch.totalKg ?? '–'), body);
  }

  /// Reading source of parameter [code]: `visual` when "Visual" was picked for it, else `instrument` (also the
  /// preview's assumption before a source is picked). Throws nothing.
  String _kindOf(String code) => _sources[code] == visualSource ? visualSource : 'instrument';

  /// The form for [rules], field [config] and [meters]. [context] supplies tokens, locale and strings. Returns the
  /// widget; throws nothing.
  Widget _form(BuildContext context, StandardsRules rules, Map<String, bool>? config, List<Instrument> meters) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final locale = Localizations.localeOf(context);
    // "Only the readings this crop's standard needs": required grading parameters, in profile order.
    final params = rules.parameters.where((p) => p.role == 'grading' && p.required).toList();
    final valid = <Reading>[];
    final problems = <String, QcCheck>{};
    for (final p in params) {
      final value = parseTyped(_values[p.code]);
      if (value == null) continue;
      // Before a source is picked the preview assumes a meter; the source check runs once one is picked.
      final reading = Reading(
        parameterCode: p.code,
        value: value,
        unit: p.unit,
        stage: 'grading',
        source: _kindOf(p.code),
      );
      final violation = checkPlausibility(
        rules,
        reading,
      ).where((v) => _sources[p.code] != null || v.code != 'source_not_allowed').firstOrNull;
      if (violation == null) {
        valid.add(reading);
      } else {
        problems[p.code] = (
          glyph: tokens.attention,
          text: violation.code == 'implausible_value'
              ? l10n.qcOutOfRange('${p.plausible?.min ?? ''}', '${p.plausible?.max ?? ''}', p.unit)
              : l10n.qcSourceNotAllowed,
        );
      }
    }
    final result = compute(rules, valid);
    final fields = [
      for (final p in params)
        QcField(
          name: p.code,
          label: parameterLabel(p, locale),
          unit: p.unit,
          hint: p.plausible == null
              ? null
              : l10n.qcRange('${p.plausible!.min ?? ''}', '${p.plausible!.max ?? ''}', p.unit),
          check: problems[p.code],
        ),
      if (fieldShown(config, _gradedKg)) QcField(name: _gradedKg, label: l10n.qcGradedWeight, unit: l10n.unitKg),
    ];
    final declaredShown = fieldShown(config, 'declared_grade');
    final gradedKg = parseTyped(_values[_gradedKg]);
    final anyReading = params.any((p) => parseTyped(_values[p.code]) != null);
    final noSource = params.any((p) => parseTyped(_values[p.code]) != null && _sources[p.code] == null);
    final selected = _selected ?? fields.firstOrNull?.name ?? '';
    final selectedParam = params.where((p) => p.code == selected).firstOrNull;
    String? blocker;
    if (fieldRequired(config, _gradedKg) && gradedKg == null) {
      blocker = l10n.qcFillRequired(l10n.qcGradedWeight);
    } else if (declaredShown && fieldRequired(config, 'declared_grade') && _declared == null) {
      blocker = l10n.qcFillRequired(l10n.qcDeclaredGrade);
    } else if (problems.isNotEmpty) {
      blocker = problems.values.first.text;
    } else if (noSource) {
      blocker = l10n.qcPickMeter;
    } else if (!anyReading && gradedKg == null && _declared == null && params.isNotEmpty) {
      blocker = l10n.qcFillRequired(parameterLabel(params.first, locale));
    }
    final declaredAbove =
        _declared != null && declaredVsComputed(rules, _declared!, result.grade) == 'declared_above_computed';
    return QcStepBody(
      promptId: 'qcGradingPrompt',
      prompt: l10n.qcGradingPrompt,
      saved: _saved,
      nextLabel: l10n.qcPack,
      nextPromptId: 'qcPack',
      onNext: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => PackingScreen(batch: widget.batch, gradedKg: gradedKg?.toString() ?? widget.batch.gradedKg),
        ),
      ),
      blocker: blocker == null ? null : (glyph: tokens.todo, text: blocker),
      onSave: _saving ? null : () => _save(rules, valid, gradedKg),
      children: [
        QcNumberForm(
          fields: fields,
          values: _values,
          selected: selected,
          onSelect: (name) => setState(() => _selected = name),
          onChanged: (name, v) => setState(() => _values[name] = v),
        ),
        // The source of the selected reading, offered as the profile allows it (FR44: e.g. no visual moisture).
        if (selectedParam != null) ...[
          SizedBox(height: tokens.gap),
          InstrumentPicker(
            instruments: !selectedParam.sourcesAllowed.contains('instrument')
                ? const []
                : [
                    for (final m in meters)
                      if (selectedParam.code != 'moisture' || m.kind == 'moisture_meter') m,
                  ],
            selected: _sources[selectedParam.code],
            today: DateTime.now(),
            allowVisual: selectedParam.sourcesAllowed.contains(visualSource),
            onSelected: (id) => setState(() => _sources[selectedParam.code] = id),
          ),
        ],
        SizedBox(height: tokens.gap),
        _preview(context, rules, result),
        if (declaredShown) ...[
          SizedBox(height: tokens.gap),
          Text(l10n.qcDeclaredGrade, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.gap / 2),
          PictureCardGrid<String>(
            selected: _declared,
            onSelected: (g) => setState(() => _declared = g),
            choices: [
              for (final g in [...rules.grades, rules.failGrade])
                PictureChoice(value: g, picture: const Icon(Icons.workspace_premium, size: 40), label: g),
            ],
          ),
          if (declaredAbove)
            CheckLine(check: (glyph: tokens.todo, text: l10n.qcDeclaredAbove(_declared!, result.grade!))),
        ],
        if (_failed) CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown)),
      ],
    );
  }

  /// The grade preview: the computed grade in large type with the standard and edition and a green tick, or, while
  /// a required reading is missing, a grey card listing the missing readings. [rules] give the standard and labels;
  /// [result] is M03's `compute`. [context] supplies theme and strings. Returns the card; throws nothing.
  Widget _preview(BuildContext context, StandardsRules rules, GradeResult result) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final grade = result.grade;
    final locale = Localizations.localeOf(context);
    final missing = [for (final code in result.missingRequired) parameterLabel(rules.parameter(code)!, locale)];
    return Card.outlined(
      key: const ValueKey('qcGradePreview'),
      margin: EdgeInsets.zero,
      color: grade == null ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: grade == null
            ? CheckLine(check: (glyph: pendingGlyph, text: l10n.qcGradeMissing(missing.join(', '))))
            : MergeSemantics(
                child: Row(
                  children: [
                    Icon(tokens.done.icon, color: tokens.done.color, size: 40),
                    SizedBox(width: tokens.gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.qcGrade(grade), style: theme.textTheme.headlineMedium),
                          Text(
                            l10n.qcStandardEdition(rules.standardName, rules.standardEdition),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Saves one `quality_reading` per [valid] reading and the `grading` event (graded weight [gradedKg], declared
  /// grade) on the batch in one transaction. [rules] give each parameter's method. Returns when saved or failed;
  /// throws nothing (a failure shows the generic sentence and keeps the form). Side effects: Entries and Outbox rows.
  Future<void> _save(StandardsRules rules, List<Reading> valid, Decimal? gradedKg) async {
    setState(() => _saving = true);
    final batchId = widget.batch.id;
    final now = DateTime.now();
    try {
      await saveQcEntries(ref.read(appDatabaseProvider), [
        for (final r in valid)
          (
            id: _ids.putIfAbsent(r.parameterCode, const Uuid().v7),
            type: 'quality_reading',
            lotId: null,
            farmerId: '',
            payload: readingPayload(
              batchId: batchId,
              stage: 'grading',
              code: r.parameterCode,
              value: r.value,
              unit: r.unit,
              methodRef: rules.parameter(r.parameterCode)?.methodRef,
              source: _kindOf(r.parameterCode),
              instrumentId: _kindOf(r.parameterCode) == visualSource ? null : _sources[r.parameterCode],
              now: now,
            ),
          ),
        (
          id: _gradingId,
          type: 'grading',
          lotId: null,
          farmerId: '',
          payload: {
            // Lifted onto the event version as its subject by the outbox (M02 `_versionKeys`).
            'batch_id': batchId,
            if (gradedKg != null) 'quantity': quantity(gradedKg, 'kg'),
            'declared_grade': ?_declared,
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
