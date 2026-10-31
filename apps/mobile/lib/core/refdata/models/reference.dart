// Typed reference data the preview rules read: crops with their event schema, the input master, plots,
// the GI region outline with its buffer, and the crop calendar.
// Requirement: FR22, FR55 (per-crop mandatory events and date order, nursery vs main-field tracks), FR56 (input
//   master with categories), FR27–FR32, FR67 (GI outline + tolerance buffer), FR68 (declared area), M12
//   (calendar reminders), backend-design.md §3 (bundle parts), D-016 (reference data travels as bundles).
// Callers: bundle_repository.dart (parses the bundle parts), lib/core/rules/*.dart, test/rules/*.
//
// Bundle shapes below are the phone's expectation of B07's parts (B07 is not merged yet); see the report
// docs/agents/reports/M03.md "Contract for B07".

/// A WGS 84 position as GeoJSON orders it: longitude first, then latitude, in decimal degrees.
typedef LonLat = (double lon, double lat);

/// Per-crop event rules (FR22, FR55): which events are mandatory and the date order inside each track.
class EventSchema {
  /// Creates a schema with [mandatory] event types and ordered [tracks].
  const EventSchema({this.mandatory = const [], this.tracks = const {}});

  /// Parses `{"mandatory": [type], "tracks": {"nursery": [type], "main_field": [type]}}` from [j].
  ///
  /// Throws: [TypeError] when a key has the wrong JSON type.
  factory EventSchema.fromJson(Map<String, dynamic> j) => EventSchema(
    mandatory: (j['mandatory'] as List<dynamic>?)?.cast<String>() ?? const [],
    tracks: (j['tracks'] as Map<String, dynamic>? ?? const {}).map(
      (name, steps) => MapEntry(name, (steps as List<dynamic>).cast<String>()),
    ),
  );

  /// Event types a lot needs before it is complete (e.g. `drying` for dry chilli).
  final List<String> mandatory;

  /// Track name → event types in required date order. An event type may sit in several tracks (`sowing` ends
  /// the nursery track and follows land preparation on the main field); tracks are not ordered against each other.
  final Map<String, List<String>> tracks;
}

/// A crop from the `crops` bundle part.
class Crop {
  /// Creates a crop.
  const Crop({
    required this.id,
    required this.code,
    required this.nameEn,
    this.nameLocal,
    required this.eventSchema,
    this.giTagId,
  });

  /// Parses one crop object [j]. Throws: [TypeError] when a key is missing or has the wrong JSON type.
  factory Crop.fromJson(Map<String, dynamic> j) => Crop(
    id: j['id'] as String,
    code: j['code'] as String,
    nameEn: j['name_en'] as String,
    nameLocal: j['name_local'] as String?,
    eventSchema: EventSchema.fromJson(j['event_schema'] as Map<String, dynamic>? ?? const {}),
    giTagId: j['gi_tag_id'] as String?,
  );

  /// Server crop id (UUID).
  final String id;

  /// Stable crop code.
  final String code;

  /// English name.
  final String nameEn;

  /// Name in the local script (Tamil for the pilot).
  final String? nameLocal;

  /// Mandatory events and date-order tracks.
  final EventSchema eventSchema;

  /// GI tag the crop is sold under (server `CropOut.gi_tag_id`), or null for a crop without one; the onboarding
  /// wizard (M09) sends it as the plot's `gi_tag_id`.
  final String? giTagId;
}

/// One row of the input master (FR56).
class InputItem {
  /// Creates an input master row.
  const InputItem({
    required this.id,
    required this.nameEn,
    this.nameLocal,
    this.manufacturer,
    required this.category,
    required this.unit,
  });

  /// Parses one input object [j]. Throws: [TypeError] when a key is missing or has the wrong JSON type.
  factory InputItem.fromJson(Map<String, dynamic> j) => InputItem(
    id: j['id'] as String,
    nameEn: j['name_en'] as String,
    nameLocal: j['name_local'] as String?,
    manufacturer: j['manufacturer'] as String?,
    category: j['category'] as String,
    unit: j['unit'] as String,
  );

  /// Server input id (UUID).
  final String id;

  /// English name, e.g. `Organic Fertilizer Gold`.
  final String nameEn;

  /// Local-script name.
  final String? nameLocal;

  /// Maker, e.g. `Amul`.
  final String? manufacturer;

  /// `chemical_fertilizer`, `organic_fertilizer`, `bio_fertilizer`, `chemical_pesticide` or `bio_pesticide`.
  final String category;

  /// Unit the input is measured in, e.g. `kg`.
  final String unit;
}

/// A plot from the `plots` bundle part: the pin and declared area the preview rules need.
class RefPlot {
  /// Creates a plot.
  const RefPlot({
    required this.id,
    required this.farmerId,
    required this.lat,
    required this.lon,
    required this.declaredArea,
    required this.areaUnit,
  });

  /// Parses `{"id", "farmer_id", "pin": {"lat", "lon"}, "declared_area", "area_unit"}` from [j].
  ///
  /// Throws: [TypeError] when a key is missing or has the wrong JSON type.
  factory RefPlot.fromJson(Map<String, dynamic> j) {
    final pin = j['pin'] as Map<String, dynamic>;
    return RefPlot(
      id: j['id'] as String,
      farmerId: j['farmer_id'] as String,
      lat: (pin['lat'] as num).toDouble(),
      lon: (pin['lon'] as num).toDouble(),
      declaredArea: j['declared_area'] as num,
      areaUnit: j['area_unit'] as String,
    );
  }

  /// Server plot id (UUID).
  final String id;

  /// Owner farmer id.
  final String farmerId;

  /// Pin latitude, decimal degrees.
  final double lat;

  /// Pin longitude, decimal degrees.
  final double lon;

  /// Declared area in [areaUnit]; kept as the JSON number so the yield check reads it exactly.
  final num declaredArea;

  /// `acre` or `cent` (100 cents = 1 acre).
  final String areaUnit;
}

/// The GI production area outline with its GPS-drift buffer (FR27, FR32; `gi_region` bundle part).
class GiRegion {
  /// Creates a region from [polygons] (each a list of rings, outer ring first) and [bufferM] metres.
  const GiRegion({required this.polygons, required this.bufferM});

  /// Parses the bundle part `{"geometry": <GeoJSON Polygon|MultiPolygon>, "tolerance_buffer_m": n}` from [j], or
  /// a GeoJSON FeatureCollection whose first feature carries `tolerance_buffer_m` in its properties.
  ///
  /// Throws: [FormatException] for another geometry type; [TypeError] on a missing key or wrong JSON type.
  factory GiRegion.fromJson(Map<String, dynamic> j) {
    final feature = j['type'] == 'FeatureCollection'
        ? (j['features'] as List<dynamic>).first as Map<String, dynamic>
        : null;
    final geometry = (feature ?? j)['geometry'] as Map<String, dynamic>;
    final buffer = (feature?['properties'] as Map<String, dynamic>? ?? j)['tolerance_buffer_m'] as num;
    final coords = geometry['coordinates'] as List<dynamic>;
    final polygons = switch (geometry['type']) {
      'MultiPolygon' => coords,
      'Polygon' => [coords],
      final t => throw FormatException('gi_region geometry must be Polygon or MultiPolygon, got $t'),
    };
    return GiRegion(
      polygons: [
        for (final polygon in polygons)
          [
            for (final ring in polygon as List<dynamic>)
              [
                for (final p in (ring as List<dynamic>).cast<List<dynamic>>())
                  ((p[0] as num).toDouble(), (p[1] as num).toDouble()),
              ],
          ],
      ],
      bufferM: buffer.toDouble(),
    );
  }

  /// Polygons → rings (outer first, then holes) → positions.
  final List<List<List<LonLat>>> polygons;

  /// Distance outside the outline still treated as near the edge, in metres.
  final double bufferM;
}

/// One crop-calendar reminder from the `calendar` bundle part (M12 local reminders).
class CalendarEntry {
  /// Creates a reminder for [eventType] due on [dueOn] spoken with [promptId].
  const CalendarEntry({required this.eventType, required this.dueOn, required this.promptId, this.lotId});

  /// Parses `{"event_type", "due_on": "YYYY-MM-DD", "prompt_id", "lot_id"?}` from [j].
  ///
  /// Throws: [TypeError] on a missing key, [FormatException] when `due_on` is not an ISO date.
  factory CalendarEntry.fromJson(Map<String, dynamic> j) => CalendarEntry(
    eventType: j['event_type'] as String,
    dueOn: DateTime.parse(j['due_on'] as String),
    promptId: j['prompt_id'] as String,
    lotId: j['lot_id'] as String?,
  );

  /// Event type the reminder is for, e.g. `harvest`.
  final String eventType;

  /// Due date (local calendar day).
  final DateTime dueOn;

  /// Voice prompt id to play.
  final String promptId;

  /// Lot the reminder is about, when it is lot-specific.
  final String? lotId;
}
