// Moisture reading (assist mode): the officer picks the farmer's lot and a moisture meter, types the meter's value on
//   the number pad and saves it as a `quality_reading` entry. A meter whose calibration date has passed is blocked
//   with one sentence.
// Requirement: UserFlows §Who uses what (the field officer "carries the moisture meter"), §Each farm event (Drying:
//   "moisture reading added by the field officer's meter"), §Design rules ("Tap, never type": number pad); PRD FR42–
//   FR44 (instrument source with an in-date calibration), Dataflow Stage 5 (lot ready only at or under the moisture
//   limit); quality `QualityReadingIn` (stage `drying_end`, `parameter_code` moisture, unit %, `instrument_id`) and its
//   `instrument_calibration_expired` check (judged on the measuring day); D-005, D-032 (`assist_session_id`).
// Callers: app_router.dart route `/assist/:farmerId/moisture` (assisted farmer home "Moisture" button).

import 'dart:convert';

import 'package:agritrace_api/agritrace_api.dart' show InstrumentKind;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators, Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/api/api_client.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/number_pad.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../event_log/choose_event_screen.dart' show farmerAppBar;
import '../event_log/event_log_controller.dart';
import '../officer_assist/assist_controller.dart';
import '../officer_home/officer_button.dart';
import '../onboarding_farmer/onboarding_notifier.dart' show assistSessionKey;

/// Entry type of a reading; M02 sends it as push kind `quality_reading` with the payload as `data` (QualityReadingIn
/// without `client_id`: the entry id is the reading id).
const qualityReadingEntryType = 'quality_reading';

/// `Instruments.kind` of a moisture meter (server `InstrumentKind.moisture_meter`).
const _moistureMeter = 'moisture_meter';

/// Whether a meter calibrated until [due] may not be used on [now]'s day: the server refuses a reading measured after
/// the due day (`instrument_calibration_expired`), so the due day itself still counts. Returns the answer; throws
/// nothing.
bool calibrationExpired(DateTime due, DateTime now) =>
    DateTime(now.year, now.month, now.day).isAfter(DateTime(due.year, due.month, due.day));

/// The FPO's moisture meters from the Instruments table, refreshed from `GET /v1/instruments` first when there is
/// signal.
///
/// shortcut: the sync pull has no instrument entity, so this screen fetches them itself (one page, 50 meters); move it
///   into M02's pull when M11's QC screens need instruments too.
final moistureMetersProvider = FutureProvider.autoDispose<List<Instrument>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  try {
    final page = await ref.read(apiClientProvider).api.getQualityApi().listInstrumentsV1InstrumentsGet(active: true);
    final items = page.data!.items;
    await db.batch((b) {
      // Meters deactivated (or removed) on the server stop being choices: the server refuses their readings.
      b.deleteWhere(
        db.instruments,
        (i) => i.kind.equals(_moistureMeter) & i.instrumentId.isNotIn([for (final m in items) m.id]),
      );
      for (final i in items) {
        final due = i.calibrationDueOn;
        // No due date: the server refuses every reading with it, so it never becomes a choice.
        if (due == null || i.kind != InstrumentKind.moistureMeter) continue;
        b.insertAllOnConflictUpdate(db.instruments, [
          InstrumentsCompanion.insert(
            instrumentId: i.id,
            kind: _moistureMeter,
            label: '${i.makeModel} ${i.serialNo}',
            calibrationDueDate: due.toDateTime(),
          ),
        ]);
      }
    });
  } on DioException {
    // No signal: the meters stored last time are used.
  }
  return (db.select(db.instruments)..where((i) => i.kind.equals(_moistureMeter))).get();
});

/// The moisture reading screen for the assisted farmer.
class MoistureScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const MoistureScreen({super.key});

  /// Creates the state holding lot, meter and value. Returns it; throws nothing.
  @override
  ConsumerState<MoistureScreen> createState() => _MoistureScreenState();
}

class _MoistureScreenState extends ConsumerState<MoistureScreen> {
  late final Future<List<Lot>> _lots = ref.read(eventLogProvider.notifier).activeLots();
  Lot? _lot;
  Instrument? _meter;
  String _value = '';
  bool _saving = false;

  /// Saves the reading as a `quality_reading` entry and the lot's last moisture, in one transaction, then returns to
  /// the farmer home with "Saved.". [lot] is the measured lot and [meter] the in-date meter. Throws nothing; a failed
  /// write keeps the screen. Side effects: Entries, Outbox and Lots rows; a send kick.
  Future<void> _save(Lot lot, Instrument meter) async {
    setState(() => _saving = true);
    final db = ref.read(appDatabaseProvider);
    final assist = ref.read(assistProvider);
    final now = ref.read(clockProvider)();
    try {
      final officer = await db.sessionDao.read() ?? (throw StateError('signed out'));
      final id = const Uuid().v7();
      await db.transaction(() async {
        await db.entriesDao.save(
          EntriesCompanion.insert(
            entryId: id,
            rootId: id,
            version: 1,
            entryType: qualityReadingEntryType,
            lotId: Value(lot.lotId),
            plotId: Value(lot.plotId),
            farmerId: lot.farmerId,
            instanceNo: 1,
            payloadJson: jsonEncode({
              'lot_id': lot.lotId,
              'stage': 'drying_end',
              'parameter_code': 'moisture',
              // Text, not a double: the server reads it as an exact Decimal (D-006).
              'measurement': {'value': _value, 'unit': '%'},
              'source': 'instrument',
              'instrument_id': meter.instrumentId,
              'measured_at': now.toUtc().toIso8601String(),
              'device_time': now.toUtc().toIso8601String(),
              assistSessionKey: ?assist?.sessionId,
            }),
            deviceTime: now,
            locationStatus: LocationStatus.none,
            enteredByUserId: officer.userId,
            assistMode: Value(assist != null),
            status: EntryStatus.saved,
            // A reading is corrected by a new reading, not undone.
            undoDeadline: now,
            createdAt: now,
          ),
          const [],
        );
        // The packing readiness preview (EventLogNotifier) reads this; the server's lot status replaces it on pull.
        await (db.update(
          db.lots,
        )..where((l) => l.lotId.equals(lot.lotId))).write(LotsCompanion(lastMoisture: Value(double.parse(_value))));
      });
      ref.read(afterSaveProvider)();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final saved = AppLocalizations.of(context).savedOnline;
      context.go(farmerPath(ref, '/home'));
      messenger.showSnackBar(SnackBar(content: Text(saved)));
    } on Exception {
      // SqliteException or StateError (signed out meanwhile): nothing was written.
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Builds lot cards (more than one lot), meter cards, then either the expired sentence or the number pad and Save.
  /// [context] supplies theme, strings and the locale (dates read "14 Feb"). Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final text = Theme.of(context).textTheme;
    final gap = SizedBox(height: tokens.gap);
    final now = ref.read(clockProvider)();
    final dayMonth = DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag());
    final meters = ref.watch(moistureMetersProvider).value;
    return Scaffold(
      appBar: farmerAppBar(context, l10n.moistureTitle),
      body: FutureBuilder<List<Lot>>(
        future: _lots,
        builder: (context, snapshot) {
          final lots = snapshot.data;
          if (lots == null || meters == null) return const SizedBox.shrink();
          if (lots.isEmpty) return Padding(padding: EdgeInsets.all(tokens.gap), child: Text(l10n.moistureNoLot));
          final lot = _lot ?? (lots.length == 1 ? lots.single : null);
          final meter = _meter;
          final expired = meter != null && calibrationExpired(meter.calibrationDueDate, now);
          final value = double.tryParse(_value);
          return ListView(
            padding: EdgeInsets.all(tokens.gap),
            children: [
              if (lots.length > 1) ...[
                Text(l10n.choosePlotPrompt, style: text.titleMedium),
                gap,
                PictureCardGrid<Lot>(
                  selected: lot,
                  onSelected: (l) => setState(() => _lot = l),
                  choices: [
                    for (final (i, l) in lots.indexed)
                      PictureChoice(
                        value: l,
                        picture: const Icon(Icons.grass, size: 56),
                        label: l10n.plotNumber(i + 1),
                      ),
                  ],
                ),
                gap,
              ],
              Text(l10n.moistureMeterPrompt, style: text.titleMedium),
              gap,
              if (meters.isEmpty)
                Text(l10n.moistureNoMeter, style: text.bodyLarge)
              else
                PictureCardGrid<Instrument>(
                  selected: meter,
                  onSelected: (m) => setState(() => _meter = m),
                  choices: [
                    for (final m in meters)
                      PictureChoice(
                        value: m,
                        picture: const Icon(Icons.speed, size: 56),
                        label: l10n.moistureMeterCard(m.label, dayMonth.format(m.calibrationDueDate)),
                      ),
                  ],
                ),
              gap,
              if (expired)
                // Blocked, not warned: the server would refuse the reading anyway (FR44 calibration in date).
                Row(
                  children: [
                    Icon(tokens.attention.icon, color: tokens.attention.color, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.moistureCalibrationExpired(dayMonth.format(meter.calibrationDueDate)),
                        style: text.titleMedium,
                      ),
                    ),
                  ],
                )
              else if (meter != null) ...[
                Text(l10n.moistureValuePrompt, style: text.titleMedium),
                NumberPad(
                  value: _value,
                  onChanged: (v) => setState(() => _value = v),
                  allowDecimal: true,
                  maxDigits: 3,
                  unit: '%',
                ),
                gap,
                OfficerButton(
                  icon: Icons.save,
                  label: l10n.onboardSave,
                  // 0–100 %: the server refuses anything else as `implausible_value`.
                  onPressed: lot != null && value != null && value <= 100 && !_saving ? () => _save(lot, meter) : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
