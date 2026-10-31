// The eight farm events a farmer logs: wire names, pictures, labels, prompts and the payload fields each fills.
// Requirement: UserFlows §Each farm event (the table: the extra choice per event and what the app fills in),
//   §Logging a farm event; FR3 (each event type), FR55 (nursery split from sowing), FR56, FR57; Dataflow Stages 1–6;
//   B06 payload schemas apps/api/agritrace/modules/events/payloads/farm.py (field names), D-014.
// Callers: event_log screens and EventLogNotifier, farmer_home (task card picture), problem_report.

import '../../core/l10n/gen/app_localizations.dart';

/// One farm event type. [wireName] is the API `event_type` and the `Entries.entryType` value.
///
/// TODO(M02): use the shared enum wire-name map once M02 lands; until then this enum is the map.
enum FarmEvent {
  /// Stage 1: photo of the ploughed field; area comes from the plot.
  landPreparation('land_preparation', ['cultivated_area', 'last_ploughed_on']),

  /// Nursery bed with the seed variety (FR55).
  nursery('nursery', ['seed_variety']),

  /// Stage 2 sowing or transplanting; seed variety copied from the nursery.
  sowing('sowing', ['seed_variety']),

  /// Stage 3 fertiliser or pesticide: product and bags (FR56).
  inputApplication('input_application', ['input_id', 'quantity']),

  /// Stage 4 harvest round: bags, kilograms (FR57).
  harvest('harvest', ['quantity', 'bags']),

  /// Stage 5 drying start or end.
  drying('drying', ['phase']),

  /// Stage 6 packing: bags, kilograms; may make the lot ready for sale.
  packing('packing', ['quantity', 'bags']),

  /// Pest, disease or weather damage, with photo and voice note.
  problem('problem', ['problem_type']);

  /// Creates the event with its [wireName] and the payload [fields] this app can capture for it.
  const FarmEvent(this.wireName, this.fields);

  /// API `event_type` (snake_case), also the Entries row's `entryType` and the field-config entity suffix.
  final String wireName;

  /// Payload keys (B06) the app fills for this event; only these can block the confirm tick (D-017).
  final List<String> fields;

  /// Bundled placeholder picture of the event card.
  String get asset => 'assets/images/events/$wireName.webp';

  /// Field-configuration entity of this event (`event_harvest`, ...), as served by `/v1/config/fields`.
  String get configEntity => 'event_$wireName';

  /// The event with [wire] as its wire name, or null for an unknown name (e.g. a bad deep link). Throws nothing.
  static FarmEvent? fromWire(String? wire) => values.where((e) => e.wireName == wire).firstOrNull;

  /// The localised card label (at most two words) from [l10n]. Throws nothing.
  String label(AppLocalizations l10n) => switch (this) {
    landPreparation => l10n.eventLandPreparation,
    nursery => l10n.eventNursery,
    sowing => l10n.eventSowing,
    inputApplication => l10n.eventInputApplication,
    harvest => l10n.eventHarvest,
    drying => l10n.eventDrying,
    packing => l10n.eventPacking,
    problem => l10n.eventProblem,
  };

  /// Voice prompt id of [label] (its ARB key, e.g. `eventHarvest`). Throws nothing.
  String get promptId => 'event${name[0].toUpperCase()}${name.substring(1)}';

  /// The out-of-order question about this event as a missing earlier step ("Did you already sow?"), from [l10n].
  /// Throws nothing.
  String askedAlready(AppLocalizations l10n) => switch (this) {
    landPreparation => l10n.orderAskLandPreparation,
    nursery => l10n.orderAskNursery,
    sowing => l10n.orderAskSowing,
    inputApplication => l10n.orderAskInputApplication,
    harvest => l10n.orderAskHarvest,
    drying => l10n.orderAskDrying,
    packing => l10n.orderAskPacking,
    problem => l10n.orderAskProblem,
  };

  /// Voice prompt id of [askedAlready] (`orderAskSowing`, ...). Throws nothing.
  String get askPromptId => 'orderAsk${name[0].toUpperCase()}${name.substring(1)}';
}

/// Weight of one harvest or packing bag in kilograms (kg = bags × this).
///
/// shortcut: one bag weight for every crop and FPO; move it to the crop bundle or features.yaml (D-017) when B07
///   serves a per-crop bag weight.
const kBagKg = 50;

/// Days after "Start drying" when the local reminder task to log "Drying done" falls due.
///
/// shortcut: one value for every crop; take it from the crop calendar bundle (M12) when it carries drying spans.
const kDryingReminderDays = 7;

/// Seed varieties offered on the nursery card grid, stored as written in `seed_variety`.
///
/// shortcut: pilot chilli varieties written here; serve them from the crops bundle when B07 adds a variety list,
///   and have an agronomist confirm the names.
const kSeedVarieties = ['Samba (local)', 'K1', 'K2'];

/// Problem kinds of the problem report, as B06's `ProblemPayload.problem_type` wire values.
const kProblemTypes = ['pest', 'disease', 'weather', 'other'];
