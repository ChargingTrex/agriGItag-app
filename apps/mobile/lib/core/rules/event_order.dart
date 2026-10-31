// Event date-order preview: before a farm event is saved, lists the earlier steps of its crop's tracks that are
// not yet recorded on or before its date, so the app can ask "Did you already sow?".
// Requirement: FR55 (nursery split from the main field, date-order rules per crop), FR22, PRD §12 "Nursery before
//   ploughing" (normal, no flag); D-006 (phone preview, server re-runs B08 `event_order`).
// Callers: farmer event screens (M07 out-of-order prompt); test/rules/preview_rules_test.dart.

import '../refdata/models/reference.dart';

/// A farm event already recorded on the lot: its [type] and the calendar day it happened [on].
typedef DatedEvent = ({String type, DateTime on});

/// Earlier steps the farmer should be asked about before saving an event of [newType] dated [on].
///
/// For every track of [schema] containing [newType], each step listed before it must have an event in [recorded]
/// dated on or before [on]; the steps without one are returned once each, in track order (an `order_gap`).
/// Tracks are independent, so a nursery dated before land preparation is no gap. Returns an empty list when the
/// order is fine or [newType] is in no track. Throws nothing.
List<String> orderGaps(EventSchema schema, List<DatedEvent> recorded, String newType, DateTime on) => {
  for (final steps in schema.tracks.values)
    if (steps.contains(newType))
      for (final step in steps.sublist(0, steps.indexOf(newType)))
        if (!recorded.any((e) => e.type == step && !e.on.isAfter(on))) step,
}.toList();
