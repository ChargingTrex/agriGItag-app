// Field rules of one event form, read from the tenant's field configuration (D-017): which fields show, which are
// required, and their en/ta labels.
// Requirement: D-017 (YAML field configuration: a disabled field is not shown, a required field blocks the confirm
//   tick, labels come from the YAML en/ta keys), PLAN §7.2 note under M13 (`/config/fields` drives M07 forms),
//   mobile-design.md §4.
// Callers: EventLogNotifier.fieldRules (event_log_controller.dart) and the event screens.

import 'dart:convert';

/// The enabled fields of one entity as served by `/v1/config/fields` (bundle part `fields`).
///
/// DECISION D-017: forms follow the tenant's field list instead of hard-coded requiredness.
///   ADV: an FPO switches a field off or makes it required without an app release.
///   COMPROMISE: only fields this app has a widget for can be captured; a field the YAML requires but the app cannot
///     capture is ignored here (it would block the tick forever) and is left to the server's `field_required` check.
class FieldRules {
  /// Creates rules from [fields] (the server's `FieldSpec` objects), or null before the first config pull.
  const FieldRules(this.fields);

  /// Parses the stored FieldConfig [json]: a list of field objects, or an object with a `fields` list; null (not
  /// pulled yet) gives rules that show every field and require none.
  ///
  /// Throws: [FormatException] or [TypeError] when the stored JSON has another shape.
  factory FieldRules.parse(String? json) {
    if (json == null) return const FieldRules(null);
    final raw = jsonDecode(json);
    final list = raw is Map<String, dynamic> ? raw['fields'] : raw;
    return FieldRules((list as List<dynamic>).cast<Map<String, dynamic>>());
  }

  /// Enabled field objects (disabled ones are absent on the wire), or null when no configuration is stored yet.
  final List<Map<String, dynamic>>? fields;

  /// The field object called [name], or null when it is disabled (or unknown). Throws nothing.
  Map<String, dynamic>? _field(String name) => fields?.where((f) => f['name'] == name).firstOrNull;

  /// Whether [name] is shown and sent: true before the first config pull. Throws nothing.
  bool enabled(String name) => fields == null || _field(name) != null;

  /// Whether [name] must have a value before the tick works. Throws nothing.
  bool required(String name) => _field(name)?['required'] == true;

  /// The YAML label of [name] in [languageCode] (`ta`/`en`), or null to fall back to the ARB string.
  /// Throws nothing.
  String? label(String name, String languageCode) =>
      ((_field(name)?['label'] as Map<String, dynamic>?)?[languageCode]) as String?;

  /// The fields of [captured] that are required and absent from [payload]. Returns an empty list when the tick may
  /// work. Throws nothing.
  List<String> missing(List<String> captured, Map<String, Object?> payload) => [
    for (final f in captured)
      if (required(f) && payload[f] == null) f,
  ];
}
