// Dart enum names (camelCase, also how Drift stores them on disk) to the server's snake_case wire values, and back.
// Requirement: backend-design.md §3 (push `kind` values), D-023 (server enums are snake_case strings), M01 review
//   P3-6 ("camelCase enum names on disk, M02 maps them"); PLAN §13 A2–A4 (the push envelope).
// Callers: outbox_processor.dart (entry kind, change kind, event types), test/sync/contract_test.dart (checks every
//   value against packages/openapi/openapi.json, and the D-031/D-032 kinds against backend-design.md §3 until B15).

/// Event types the server accepts in an `event_version` (`EventType`); an entry of one of these types (or `undo`)
/// is pushed as an event version.
const eventTypes = {
  'land_preparation',
  'nursery',
  'sowing',
  'input_application',
  'harvest',
  'drying',
  'packing',
  'problem',
  'intake',
  'grading',
  'final_packing',
};

/// Kind of a push entry (`SyncEntry.kind` on the server). An entry whose `entryType` is one of [eventTypes] (or
/// `undo`) is an `eventVersion`; one whose `entryType` equals another kind's wire name is sent as that kind with its
/// payload as `data`; any other type cannot be sent.
enum SyncKind {
  /// A farm or processing event version (`EventVersionIn`).
  eventVersion,

  /// A farmer registered offline by an officer, `data` = `FarmerIn`, id = client id (D-031).
  farmer,

  /// An assist session started offline, `data` = farmer, start time and GPS, id = client id (D-032).
  assistSession,

  /// A quality reading (QC, moisture, ...).
  qualityReading,

  /// A new or corrected plot.
  plot,

  /// A consent given or revoked.
  consent,

  /// An officer's flag resolution (rejected by the pilot server with `not_implemented_pilot`).
  flagResolution,
}

/// How an event version came about (`change_kind` on the server).
enum ChangeKind {
  /// Version 1.
  create,

  /// A correction (officer or admin).
  correct,

  /// A farmer's undo within 24 h.
  undo,
}

/// The server's snake_case name of [value]: `eventVersion` → `event_version`. Returns the name; throws nothing.
String wireName(Enum value) => value.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// The value of [values] whose [wireName] is [wire], or null when none matches (an unknown server value).
/// Throws nothing.
T? fromWire<T extends Enum>(Iterable<T> values, String? wire) {
  for (final v in values) {
    if (wireName(v) == wire) return v;
  }
  return null;
}
