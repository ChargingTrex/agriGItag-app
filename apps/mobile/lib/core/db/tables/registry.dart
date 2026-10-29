// Drift tables for the registry data a phone keeps offline: farmers, their plots and their lots.
// Requirement: mobile-design.md §2 (Farmers, Plots, Lots); Arch §Offline-first "Reference data travels to the
//   phone" (plots for the GI-region check); backend-design.md §2 registry and lots_batches (server owners).
// Callers: database.dart (table list); M02 pull_service.dart writes them; farmer/officer features read them.

import 'package:drift/drift.dart';

/// Farmers visible on this phone: the signed-in farmer, or every farmer of the officer's FPO.
@DataClassName('Farmer')
class Farmers extends Table {
  /// Server farmer id (UUID).
  TextColumn get farmerId => text()();

  /// FPO the farmer belongs to (UUID).
  TextColumn get fpoId => text()();

  /// Display name.
  TextColumn get name => text()();

  /// Village name, for officer lists.
  TextColumn get village => text()();

  /// Local path of the farmer's photo; null until downloaded or taken.
  TextColumn get photoPath => text().nullable()();

  /// Whether the farmer has their own smartphone (false → officer assist mode is the usual path).
  BoolColumn get hasSmartphone => boolean()();

  /// Preferred language code (`ta`, `en`, ...).
  TextColumn get language => text()();

  /// Server status of the farmer record (e.g. `active`).
  TextColumn get status => text()();

  /// Remaining profile fields as JSON; which ones exist is decided by FieldConfig (D-017).
  TextColumn get json => text()();

  /// Primary key: [farmerId].
  @override
  Set<Column<Object>> get primaryKey => {farmerId};
}

/// Plots (fields) of the farmers above, with the pin used by the GI-region preview check.
@DataClassName('Plot')
class Plots extends Table {
  /// Server plot id (UUID).
  TextColumn get plotId => text()();

  /// Owner farmer id.
  TextColumn get farmerId => text()();

  /// Pin latitude in decimal degrees (WGS 84).
  RealColumn get pinLat => real()();

  /// Pin longitude in decimal degrees (WGS 84).
  RealColumn get pinLng => real()();

  /// Pin accuracy radius in metres.
  RealColumn get pinAccuracyM => real()();

  /// How the pin was set (e.g. `gps`, `map_tap`).
  TextColumn get pinMethod => text()();

  /// Area the farmer declared, in [areaUnit].
  RealColumn get declaredArea => real()();

  /// Unit of [declaredArea]: `acre` or `cent`.
  TextColumn get areaUnit => text()();

  /// Land-record survey number; kept on the phone only and never shown publicly (CLAUDE.md §6).
  TextColumn get surveyNoLocalOnly => text().nullable()();

  /// Walked boundary as GeoJSON Polygon; null when only a pin exists.
  TextColumn get boundaryGeoJson => text().nullable()();

  /// GI-region status of the plot (server value, e.g. `inside`, `outside`, `unknown`).
  TextColumn get giStatus => text()();

  /// True when the plot is locked against edits (it has events or a sale).
  BoolColumn get locked => boolean()();

  /// Server version of the plot record, for stale-write detection.
  IntColumn get version => integer()();

  /// Primary key: [plotId].
  @override
  Set<Column<Object>> get primaryKey => {plotId};
}

/// Lots: one crop on one plot in one season, the unit farm events are logged against.
@DataClassName('Lot')
class Lots extends Table {
  /// Server lot id (UUID).
  TextColumn get lotId => text()();

  /// Plot the lot grows on.
  TextColumn get plotId => text()();

  /// Owner farmer id.
  TextColumn get farmerId => text()();

  /// Crop id (e.g. Samba Vathal chilli).
  TextColumn get cropId => text()();

  /// Season label (e.g. `2026-rabi`).
  TextColumn get season => text()();

  /// Server lot status (`open`, `drying`, `ready_for_sale`, ...).
  TextColumn get status => text()();

  /// Harvested quantity in kilograms.
  RealColumn get kgHarvested => real().withDefault(const Constant(0))();

  /// Packed quantity in kilograms.
  RealColumn get kgPacked => real().withDefault(const Constant(0))();

  /// Last moisture reading in percent (wet basis); null until measured.
  RealColumn get lastMoisture => real().nullable()();

  /// Payload of the lot's QR label; null until printed.
  TextColumn get qrPayload => text().nullable()();

  /// When the server last changed the lot.
  DateTimeColumn get updatedAt => dateTime()();

  /// Primary key: [lotId].
  @override
  Set<Column<Object>> get primaryKey => {lotId};
}
