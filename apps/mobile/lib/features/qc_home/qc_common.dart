// What the QC screens share: the scanned lot and listed batch, the "tiles + one number pad" form, the check line,
//   field rules from FieldConfig, the reading payload and the one-transaction save into the outbox.
// Requirement: UserFlows §Selling to the FPO (steps 2-4: lot, farmer, packed quantity; weight; moisture; checks with a
//   green tick or an orange circle and one line), §Grade a batch (number pad entry), §Design rules ("Tap, never type",
//   "Colour plus shape"); FR42 (reading record), FR50; D-017 (FieldConfig: disabled fields hidden, required block
//   Save); D-005 (client UUIDv7), D-014 (append-only Entries); CLAUDE.md §5.6 (quantities carry units).
// Callers: qc_intake (scan_screen, intake_screen), qc_grading (batch_list_screen, grading_screen), qc_packing
//   (packing_screen), qc_meter (instrument_picker); test/features/qc/*.

import 'dart:convert';

import 'package:agritrace_api/agritrace_api.dart' show InstrumentKind, standardSerializers;
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_client.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/bundle_repository.dart';
import '../../core/refdata/models/standards.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/theme/status_glyphs.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/number_pad.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../onboarding_farmer/onboarding_notifier.dart' show FieldRules;

/// A lot the QC officer scanned or picked: what the lot card shows and the intake entries need.
class QcLot {
  /// Creates the lot. [lotId] is the server lot id; [farmerId] its farmer; [farmerName] the name when the farmer is
  /// on this phone; [packedKg] the farmer's packed quantity in kg; [cropId] the crop, null when only the QR knew the
  /// lot; [unverified] marks a lot known only from the farmer's QR (its farmer and packed weight are not checked).
  /// Throws nothing.
  const QcLot({
    required this.lotId,
    required this.farmerId,
    this.farmerName,
    required this.packedKg,
    this.cropId,
    this.unverified = false,
  });

  /// True when the lot is not on this phone and the card shows the QR's own farmer and packed weight.
  final bool unverified;

  /// Server lot id (UUID).
  final String lotId;

  /// Farmer who owns the lot.
  final String farmerId;

  /// Farmer's name from the local Farmers table; null when the farmer was never stored on this phone.
  final String? farmerName;

  /// Quantity the farmer packed, in kg (0 when unknown).
  final double packedKg;

  /// Crop of the lot; null when the lot is known only from its QR (the single bundled crop is used then).
  final String? cropId;
}

/// A batch from `GET /v1/batches` that waits for grading (`created`) or final packing (`graded`).
class QcBatch {
  /// Creates the batch. [id] and [code] identify it; [cropId] selects the standards profile; [status] is the server
  /// batch status; [totalKg] the received total and [gradedKg] the approved graded weight, both in kg as decimal text
  /// (null when unknown). Throws nothing.
  const QcBatch({
    required this.id,
    required this.code,
    required this.cropId,
    required this.status,
    this.totalKg,
    this.gradedKg,
  });

  /// Batch id (UUID); the subject of the grading readings and events.
  final String id;

  /// 12-character batch code printed on the batch QR.
  final String code;

  /// Crop of every lot in the batch.
  final String cropId;

  /// `created` (to grade) or `graded` (to pack).
  final String status;

  /// Sum of the lots' intake weights in kg (decimal text), or null.
  final String? totalKg;

  /// Graded weight in kg approved by the FPO admin (decimal text), or null before approval.
  final String? gradedKg;
}

/// A check shown under a field: the status glyph (shape and colour) and one sentence.
typedef QcCheck = ({StatusGlyph glyph, String text});

/// Grey glyph of a preview that cannot be computed yet (missing readings); shape differs from tick and circle.
const pendingGlyph = StatusGlyph(icon: Icons.hourglass_empty, color: Color(0xFF616161));

/// One numeric field of a QC form.
class QcField {
  /// Creates the field. [name] is the payload key or parameter code; [label] the localised label; [unit] the
  /// localised unit (null for a count); [decimal] allows a point; [hint] is a second line (e.g. the range); [check]
  /// the line shown under the tile. Throws nothing.
  const QcField({required this.name, required this.label, this.unit, this.decimal = true, this.hint, this.check});

  /// Payload key (`received`, `quantity`, ...) or profile parameter code (`moisture`).
  final String name;

  /// Localised label.
  final String label;

  /// Localised unit shown after the value; null for a count.
  final String? unit;

  /// Whether the number pad shows the point key.
  final bool decimal;

  /// Second line under the label, e.g. "Range 0 to 100 %".
  final String? hint;

  /// Check sentence shown under the tile, or null.
  final QcCheck? check;
}

/// The QC form: one selectable tile per field and a single [NumberPad] that edits the selected tile.
///
/// One pad instead of one per field keeps a 4-reading grading form on one phone screen of scrolling (a pad is about
/// 350 dp tall).
class QcNumberForm extends StatelessWidget {
  /// Creates the form. [fields] are shown in order; [values] holds the raw typed text per field name; [selected] is
  /// the field the pad edits; [onSelect] receives a tapped field's name; [onChanged] receives the field name and its
  /// new raw text. Throws nothing.
  const QcNumberForm({
    super.key,
    required this.fields,
    required this.values,
    required this.selected,
    required this.onSelect,
    required this.onChanged,
  });

  /// Fields in display order.
  final List<QcField> fields;

  /// Raw typed text per field name (missing = empty).
  final Map<String, String> values;

  /// Name of the field the pad edits.
  final String selected;

  /// Called with the name of a tapped tile.
  final ValueChanged<String> onSelect;

  /// Called with the edited field's name and new raw text.
  final void Function(String name, String value) onChanged;

  /// Builds the tiles and the pad. [context] supplies theme and tokens. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final current = fields.where((f) => f.name == selected).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final f in fields) ...[
          _tile(context, f, tokens),
          if (f.check != null) CheckLine(check: f.check!),
          SizedBox(height: tokens.gap / 2),
        ],
        if (current != null)
          NumberPad(
            // Keyed by field so the pad's read-out never shows the previous field's value for a frame.
            key: ValueKey(current.name),
            value: values[current.name] ?? '',
            allowDecimal: current.decimal,
            unit: current.unit,
            onChanged: (v) => onChanged(current.name, v),
          ),
      ],
    );
  }

  /// One selectable tile for [f]: label, hint and the typed value with its unit. [context] supplies the theme;
  /// [tokens] the sizes. Returns the widget; throws nothing.
  Widget _tile(BuildContext context, QcField f, FarmerTokens tokens) {
    final theme = Theme.of(context);
    final isSelected = f.name == selected;
    final raw = values[f.name] ?? '';
    return Semantics(
      // Keyed by field name so tests find a tile in either language.
      key: ValueKey('qcTile-${f.name}'),
      selected: isSelected,
      button: true,
      child: Card.outlined(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => onSelect(f.name),
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.minTarget),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.gap, vertical: tokens.gap / 2),
              // A Wrap, not a Row: at 1.5x Tamil the value moves under the label instead of squeezing it letter by letter.
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: tokens.gap,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.label, style: theme.textTheme.titleMedium),
                      if (f.hint != null) Text(f.hint!, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  Text(raw.isEmpty ? '–' : [raw, ?f.unit].join(' '), style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One check: the glyph (shape + colour, never colour alone) and its sentence, read as one node.
class CheckLine extends StatelessWidget {
  /// Creates the line for [check]. Throws nothing.
  const CheckLine({super.key, required this.check});

  /// Glyph and sentence.
  final QcCheck check;

  /// Builds the row. [context] supplies the theme. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(check.glyph.icon, color: check.glyph.color, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(check.text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    ),
  );
}

/// The screen body every QC step shares: spoken prompt, content, and the Save button with the reason it is
/// disabled; after saving, the "Saved" sentence and one next button.
class QcStepBody extends ConsumerWidget {
  /// Creates the body. [promptId] / [prompt] are the spoken prompt; [children] the form; [blocker] the sentence why
  /// Save is disabled (null enables it); [onSave] saves; [saved] switches to the saved state, where [nextLabel],
  /// [nextPromptId] and [onNext] make the one button. Throws nothing.
  const QcStepBody({
    super.key,
    required this.promptId,
    required this.prompt,
    required this.children,
    required this.blocker,
    required this.onSave,
    required this.saved,
    required this.nextLabel,
    required this.nextPromptId,
    required this.onNext,
  });

  /// Voice prompt id of [prompt].
  final String promptId;

  /// Localised prompt shown and spoken when the step opens.
  final String prompt;

  /// The step's form.
  final List<Widget> children;

  /// Why Save is disabled; null when it is enabled.
  final QcCheck? blocker;

  /// Saves the step; called once (the screen flips to [saved] or shows the error).
  final VoidCallback? onSave;

  /// True after the save: the form is replaced by the confirmation.
  final bool saved;

  /// Localised label of the button shown after saving.
  final String nextLabel;

  /// Voice prompt id of [nextLabel].
  final String nextPromptId;

  /// Runs after saving (back to the QC home, or on to packing).
  final VoidCallback onNext;

  /// Builds the column. [context] supplies tokens and strings; [ref] plays the button prompts. Returns the widget;
  /// throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final gap = SizedBox(height: tokens.gap);
    if (saved) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VoicePromptBar(key: const ValueKey('qcSaved'), promptId: 'qcSaved', text: l10n.qcSaved),
          gap,
          FarmerButton(
            icon: Icons.arrow_forward,
            label: nextLabel,
            onPressed: onNext,
            onSpeak: () => playPrompt(ref, context, nextPromptId),
            prominent: true,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VoicePromptBar(promptId: promptId, text: prompt),
        gap,
        ...children,
        gap,
        if (blocker != null) CheckLine(check: blocker!),
        FarmerButton(
          icon: Icons.save,
          label: l10n.qcSave,
          onPressed: blocker == null ? onSave : null,
          onSpeak: () => playPrompt(ref, context, 'qcSave'),
          prominent: true,
        ),
      ],
    );
  }
}

/// The QC screens' scaffold: app bar with [title] and a 56 dp back button, scrolling [body]. Returns the widget;
/// throws nothing.
Widget qcScaffold(BuildContext context, String title, Widget body) {
  final tokens = Theme.of(context).extension<FarmerTokens>()!;
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      // 56 dp: the default back arrow is 48 dp (UserFlows §Design rules "Big targets").
      leading: Navigator.of(context).canPop()
          ? BackButton(style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)))
          : null,
      title: Text(title),
    ),
    body: SafeArea(
      child: SingleChildScrollView(padding: EdgeInsets.all(tokens.gap), child: body),
    ),
  );
}

/// Parses the raw text of a [NumberPad] ("230", "11.5", "12.") as an exact decimal; null when empty.
///
/// Returns the value. Throws nothing (the pad only produces digits and one point).
Decimal? parseTyped(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return Decimal.tryParse(raw.endsWith('.') ? raw.substring(0, raw.length - 1) : raw);
}

/// A quantity with its unit as the API expects it (`Quantity`, FR58): `{value: "230", unit: "kg"}`.
///
/// [value] is sent as decimal text, which the server's `Decimal` reads exactly. Returns the map; throws nothing.
Map<String, Object> quantity(Decimal value, String unit) => {'value': value.toString(), 'unit': unit};

/// [kg] for display in en_IN grouping without a trailing ".0" ("1,200", "11.5"). Returns the text; throws nothing.
String kgText(num kg) => NumberFormat('#,##,##0.###', 'en_IN').format(kg);

/// The first 8 characters of an id, upper case, for cards where the full UUID would not fit. Throws nothing.
String shortId(String id) => (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();

/// [d] as the farmer UI writes dates ("14 Feb", CLAUDE.md §5.6) in [locale]. Returns the text; throws nothing.
String dayText(DateTime d, Locale locale) => DateFormat('d MMM', locale.toString()).format(d);

/// The profile label of [p] in [locale]: Tamil name, English name, or the code with spaces. Returns it.
String parameterLabel(Parameter p, Locale locale) =>
    (locale.languageCode == 'ta' ? p.nameLocal : null) ?? p.nameEn ?? p.code.replaceAll('_', ' ');

/// The FieldConfig rules of an entity (`event_intake`, `event_grading`, `event_final_packing`) from the phone's store.
///
/// Yields enabled field → required, or null when the configuration was never pulled (every field shown, none
/// required). Fails with [FormatException] or [TypeError] for a malformed stored config.
final qcFieldRulesProvider = FutureProvider.autoDispose.family<Map<String, bool>?, String>(
  (ref, entity) async => FieldRules.parse(await ref.read(appDatabaseProvider).fieldConfigDao.get(entity)),
);

/// Whether [field] is shown under [rules] (null = never pulled = shown). Returns the flag; throws nothing.
bool fieldShown(Map<String, bool>? rules, String field) => rules == null || rules.containsKey(field);

/// Whether [field] must be filled before Save under [rules]. Returns the flag; throws nothing.
bool fieldRequired(Map<String, bool>? rules, String field) => rules?[field] ?? false;

/// The Standards Profile of crop [cropId] from the reference bundle, or of the only bundled crop when [cropId] is
/// null; null when not downloaded. Throws [FormatException] or [TypeError] for a malformed bundle.
final qcStandardsProvider = FutureProvider.autoDispose.family<StandardsRules?, String?>((ref, cropId) async {
  final repo = BundleRepository(ref.read(appDatabaseProvider).refBundlesDao);
  // shortcut: a lot known only from its QR has no crop; the pilot bundles one crop. Upgrade when M08's QR carries it.
  final id = cropId ?? (await repo.crops()).firstOrNull?.id;
  return id == null ? null : repo.standards(id);
});

/// Fetches the FPO's active instruments from the API as rows of the local Instruments table; tests replace it.
typedef InstrumentFetcher = Future<List<InstrumentsCompanion>> Function();

/// `GET /v1/instruments?active=true`, every page, through the generated client (D-003). A meter without a
/// calibration due date is left out: the server refuses its readings (FR50). Throws [DioException] without signal or
/// on an API error.
final qcInstrumentFetcherProvider = Provider<InstrumentFetcher>(
  (ref) => () async {
    final api = ref.read(apiClientProvider).api.getQualityApi();
    final rows = <InstrumentsCompanion>[];
    String? cursor;
    do {
      final page = (await api.listInstrumentsV1InstrumentsGet(active: true, cursor: cursor)).data!;
      for (final i in page.items) {
        final due = i.calibrationDueOn;
        if (due == null) continue;
        rows.add(
          InstrumentsCompanion.insert(
            instrumentId: i.id,
            kind: standardSerializers.serializeWith(InstrumentKind.serializer, i.kind)! as String,
            label: '${i.makeModel} ${i.serialNo}',
            calibrationDueDate: due.toDateTime(),
          ),
        );
      }
      cursor = page.hasMore ? page.nextCursor : null;
    } while (cursor != null);
    return rows;
  },
);

/// Instruments registered for the FPO: refreshed from the API when there is signal, else the rows cached on the
/// phone by the last online visit.
///
/// DECISION D-036: the QC screens mirror `GET /v1/instruments` into the Instruments table themselves, the same online
///   way as the batch list, until a reference-bundle part and an M02 mirror serve instruments.
///   ADV: meters (with calibration due dates) reach a real phone now; offline the cached rows still work.
///   COMPROMISE: the cache is refreshed only when a QC screen opens online; a meter registered or recalibrated while
///   the phone stays offline is missing or shows the old due date (the server re-checks every reading).
/// Throws what Drift throws on a broken database; any [DioException] falls back to the cache.
final qcInstrumentsProvider = FutureProvider.autoDispose<List<Instrument>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  try {
    final rows = await ref.read(qcInstrumentFetcherProvider)();
    // Replaced whole, so a meter the FPO deactivated disappears; the table is a cache, not a record (not append-only).
    await db.transaction(() async {
      await db.delete(db.instruments).go();
      await db.batch((b) => b.insertAll(db.instruments, rows));
    });
  } on DioException {
    // No signal or an API error: keep using the cached rows.
  }
  return (db.select(db.instruments)..orderBy([(i) => OrderingTerm(expression: i.label)])).get();
});

/// A reading payload as the server's `QualityReadingIn` without `client_id` (the entry id is sent as it, M02).
///
/// Exactly one of [lotId] and [batchId]; [stage] is `intake` or `grading`; [code], [value] and [unit] the measurement;
/// [methodRef] the profile's method; [source] `instrument` or `visual`; [instrumentId] the meter (null for visual);
/// [now] the measuring time (also the device time). Returns the map; throws nothing.
Map<String, Object?> readingPayload({
  String? lotId,
  String? batchId,
  required String stage,
  required String code,
  required Decimal value,
  required String unit,
  String? methodRef,
  required String source,
  String? instrumentId,
  required DateTime now,
}) => {
  'lot_id': ?lotId,
  'batch_id': ?batchId,
  'stage': stage,
  'parameter_code': code,
  'measurement': quantity(value, unit),
  'method_ref': ?methodRef,
  'source': source,
  'instrument_id': ?instrumentId,
  'measured_at': now.toUtc().toIso8601String(),
  'device_time': now.toUtc().toIso8601String(),
};

/// One entry a QC step writes: id (UUIDv7 made when the screen opened), type (an event type or `quality_reading`),
/// lot (null for a batch), farmer (`''` for a batch) and payload.
typedef QcEntry = ({String id, String type, String? lotId, String farmerId, Map<String, Object?> payload});

/// Writes [entries] in one transaction through `EntriesDao.save`, so the outbox pushes them in order (M02).
///
/// [db] is the store; [now] the save time (device clock; there is no GPS fix at the processing unit, so the GPS
/// clock is null and the server adds its own). Every entry is entered by the signed-in QC user. Returns when
/// written. Throws [StateError] when nobody is signed in and `SqliteException` when a write fails (nothing is
/// written then). Side effects: Entries and Outbox rows; the pending-send count emits.
Future<void> saveQcEntries(AppDatabase db, List<QcEntry> entries, DateTime now) async {
  final user = await db.sessionDao.read();
  if (user == null) throw StateError('no signed-in user');
  await db.transaction(() async {
    for (final e in entries) {
      await db.entriesDao.save(
        EntriesCompanion.insert(
          entryId: e.id,
          rootId: e.id,
          version: 1,
          entryType: e.type,
          lotId: Value(e.lotId),
          // shortcut: Entries.farmerId is NOT NULL and a batch has many farmers, so batch entries carry ''; make the
          //   column nullable in schema v3 (M13) if a local query ever needs batch entries by farmer.
          farmerId: e.farmerId,
          instanceNo: 1,
          payloadJson: jsonEncode(e.payload),
          deviceTime: now,
          locationStatus: LocationStatus.none,
          enteredByUserId: user.userId,
          status: EntryStatus.saved,
          // QC records are not farmer events: nothing to undo; a wrong one is corrected by a new version (D-033 for
          // intakes), so the undo window closes at once, as for the M09 registrations.
          undoDeadline: now,
          createdAt: now,
        ),
        const [],
      );
    }
  });
}
