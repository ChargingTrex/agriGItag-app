// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta = const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rootIdMeta = const VerificationMeta('rootId');
  @override
  late final GeneratedColumn<String> rootId = GeneratedColumn<String>(
    'root_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersedesEntryIdMeta = const VerificationMeta('supersedesEntryId');
  @override
  late final GeneratedColumn<String> supersedesEntryId = GeneratedColumn<String>(
    'supersedes_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instanceNoMeta = const VerificationMeta('instanceNo');
  @override
  late final GeneratedColumn<int> instanceNo = GeneratedColumn<int>(
    'instance_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta('deviceTime');
  @override
  late final GeneratedColumn<DateTime> deviceTime = GeneratedColumn<DateTime>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gpsTimeMeta = const VerificationMeta('gpsTime');
  @override
  late final GeneratedColumn<DateTime> gpsTime = GeneratedColumn<DateTime>(
    'gps_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverReceivedAtMeta = const VerificationMeta('serverReceivedAt');
  @override
  late final GeneratedColumn<DateTime> serverReceivedAt = GeneratedColumn<DateTime>(
    'server_received_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta('accuracyM');
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocationStatus, String> locationStatus = GeneratedColumn<String>(
    'location_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocationStatus>($EntriesTable.$converterlocationStatus);
  static const VerificationMeta _enteredByUserIdMeta = const VerificationMeta('enteredByUserId');
  @override
  late final GeneratedColumn<String> enteredByUserId = GeneratedColumn<String>(
    'entered_by_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assistModeMeta = const VerificationMeta('assistMode');
  @override
  late final GeneratedColumn<bool> assistMode = GeneratedColumn<bool>(
    'assist_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("assist_mode" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enteredRemotelyMeta = const VerificationMeta('enteredRemotely');
  @override
  late final GeneratedColumn<bool> enteredRemotely = GeneratedColumn<bool>(
    'entered_remotely',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("entered_remotely" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reasonCodeMeta = const VerificationMeta('reasonCode');
  @override
  late final GeneratedColumn<String> reasonCode = GeneratedColumn<String>(
    'reason_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntryStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<EntryStatus>($EntriesTable.$converterstatus);
  static const VerificationMeta _undoDeadlineMeta = const VerificationMeta('undoDeadline');
  @override
  late final GeneratedColumn<DateTime> undoDeadline = GeneratedColumn<DateTime>(
    'undo_deadline',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entryId,
    rootId,
    version,
    supersedesEntryId,
    entryType,
    lotId,
    plotId,
    farmerId,
    instanceNo,
    payloadJson,
    deviceTime,
    gpsTime,
    serverReceivedAt,
    lat,
    lng,
    accuracyM,
    locationStatus,
    enteredByUserId,
    assistMode,
    enteredRemotely,
    reasonCode,
    status,
    undoDeadline,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta, entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('root_id')) {
      context.handle(_rootIdMeta, rootId.isAcceptableOrUnknown(data['root_id']!, _rootIdMeta));
    } else if (isInserting) {
      context.missing(_rootIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta, version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('supersedes_entry_id')) {
      context.handle(
        _supersedesEntryIdMeta,
        supersedesEntryId.isAcceptableOrUnknown(data['supersedes_entry_id']!, _supersedesEntryIdMeta),
      );
    }
    if (data.containsKey('entry_type')) {
      context.handle(_entryTypeMeta, entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(_lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(_plotIdMeta, plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta));
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('instance_no')) {
      context.handle(_instanceNoMeta, instanceNo.isAcceptableOrUnknown(data['instance_no']!, _instanceNoMeta));
    } else if (isInserting) {
      context.missing(_instanceNoMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(_payloadJsonMeta, payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('device_time')) {
      context.handle(_deviceTimeMeta, deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta));
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('gps_time')) {
      context.handle(_gpsTimeMeta, gpsTime.isAcceptableOrUnknown(data['gps_time']!, _gpsTimeMeta));
    }
    if (data.containsKey('server_received_at')) {
      context.handle(
        _serverReceivedAtMeta,
        serverReceivedAt.isAcceptableOrUnknown(data['server_received_at']!, _serverReceivedAtMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(_accuracyMMeta, accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta));
    }
    if (data.containsKey('entered_by_user_id')) {
      context.handle(
        _enteredByUserIdMeta,
        enteredByUserId.isAcceptableOrUnknown(data['entered_by_user_id']!, _enteredByUserIdMeta),
      );
    } else if (isInserting) {
      context.missing(_enteredByUserIdMeta);
    }
    if (data.containsKey('assist_mode')) {
      context.handle(_assistModeMeta, assistMode.isAcceptableOrUnknown(data['assist_mode']!, _assistModeMeta));
    }
    if (data.containsKey('entered_remotely')) {
      context.handle(
        _enteredRemotelyMeta,
        enteredRemotely.isAcceptableOrUnknown(data['entered_remotely']!, _enteredRemotelyMeta),
      );
    }
    if (data.containsKey('reason_code')) {
      context.handle(_reasonCodeMeta, reasonCode.isAcceptableOrUnknown(data['reason_code']!, _reasonCodeMeta));
    }
    if (data.containsKey('undo_deadline')) {
      context.handle(_undoDeadlineMeta, undoDeadline.isAcceptableOrUnknown(data['undo_deadline']!, _undoDeadlineMeta));
    } else if (isInserting) {
      context.missing(_undoDeadlineMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      entryId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      rootId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}root_id'])!,
      version: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      supersedesEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_entry_id'],
      ),
      entryType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_type'])!,
      lotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lot_id']),
      plotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plot_id']),
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      instanceNo: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}instance_no'])!,
      payloadJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      deviceTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}device_time'])!,
      gpsTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}gps_time']),
      serverReceivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}server_received_at'],
      ),
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      accuracyM: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}accuracy_m']),
      locationStatus: $EntriesTable.$converterlocationStatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}location_status'])!,
      ),
      enteredByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entered_by_user_id'],
      )!,
      assistMode: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}assist_mode'])!,
      enteredRemotely: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}entered_remotely'],
      )!,
      reasonCode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}reason_code']),
      status: $EntriesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      undoDeadline: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}undo_deadline'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocationStatus, String, String> $converterlocationStatus =
      const EnumNameConverter<LocationStatus>(LocationStatus.values);
  static JsonTypeConverter2<EntryStatus, String, String> $converterstatus = const EnumNameConverter<EntryStatus>(
    EntryStatus.values,
  );
}

class Entry extends DataClass implements Insertable<Entry> {
  /// Entry id (UUIDv7) generated on the phone; also the push `client_id` and idempotency key.
  ///
  /// DECISION D-005: client-generated UUIDv7 as primary and idempotency key.
  ///   ADV: the id exists offline, a retried push is deduplicated by the server, and v7 sorts by creation time.
  ///   COMPROMISE: a foreign-owned id is rejected server-side (`client_id_conflict`) instead of being impossible.
  final String entryId;

  /// Entry id of version 1 of this event; shared by every version (the server's `event_id`).
  final String rootId;

  /// Version number within [rootId], starting at 1 (the server's `version_no`).
  final int version;

  /// Entry id of the version this row replaces; null for version 1.
  final String? supersedesEntryId;

  /// Event type (`harvest`, `drying`, ..., or `undo`); selects the payload schema (D-014).
  final String entryType;

  /// Lot the event belongs to; null for plot-level events.
  final String? lotId;

  /// Plot the event belongs to; null when not tied to a plot.
  final String? plotId;

  /// Farmer the event is about (the farmer themselves, or the one an officer assists).
  final String farmerId;

  /// Repetition number of this event type on the lot (second picking = 2).
  final int instanceNo;

  /// Event payload as JSON; quantities carry units (`{"value": 195, "unit": "kg"}`).
  final String payloadJson;

  /// Phone clock at save time (may be wrong; compared with [serverReceivedAt]).
  final DateTime deviceTime;

  /// GPS satellite time at save; null without a fix.
  final DateTime? gpsTime;

  /// Server receive time from the push acknowledgement; null until confirmed.
  final DateTime? serverReceivedAt;

  /// Latitude in decimal degrees (WGS 84); null without a fix.
  final double? lat;

  /// Longitude in decimal degrees (WGS 84); null without a fix.
  final double? lng;

  /// GPS accuracy radius in metres; null without a fix.
  final double? accuracyM;

  /// Quality of the GPS fix.
  final LocationStatus locationStatus;

  /// User who entered it (the farmer, or the officer in assist mode). The server takes it from the token.
  ///
  /// DECISION D-029: this column is the entry's owner on a shared phone; schema v2 adds no separate
  ///   `ownerUserId` here (only on Outbox, filled from this column).
  ///   ADV: one source of truth, already covered by the append-only trigger, no Entries table rebuild.
  ///   COMPROMISE: "owner" and "author" can never differ; true today because only the signed-in user saves.
  final String enteredByUserId;

  /// True when an officer entered it for the farmer (CLAUDE.md §6: assist mode is recorded on every entry).
  final bool assistMode;

  /// True when entered away from the farm (e.g. by phone call), so location checks do not apply.
  final bool enteredRemotely;

  /// Reason code for a correction or undo; null for version 1.
  final String? reasonCode;

  /// Sync state; the only fact-free column besides [serverReceivedAt] that may change after save.
  final EntryStatus status;

  /// Last moment the farmer may undo this entry (save time + 24 h).
  final DateTime undoDeadline;

  /// When the row was written on the phone.
  final DateTime createdAt;
  const Entry({
    required this.entryId,
    required this.rootId,
    required this.version,
    this.supersedesEntryId,
    required this.entryType,
    this.lotId,
    this.plotId,
    required this.farmerId,
    required this.instanceNo,
    required this.payloadJson,
    required this.deviceTime,
    this.gpsTime,
    this.serverReceivedAt,
    this.lat,
    this.lng,
    this.accuracyM,
    required this.locationStatus,
    required this.enteredByUserId,
    required this.assistMode,
    required this.enteredRemotely,
    this.reasonCode,
    required this.status,
    required this.undoDeadline,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['root_id'] = Variable<String>(rootId);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || supersedesEntryId != null) {
      map['supersedes_entry_id'] = Variable<String>(supersedesEntryId);
    }
    map['entry_type'] = Variable<String>(entryType);
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    if (!nullToAbsent || plotId != null) {
      map['plot_id'] = Variable<String>(plotId);
    }
    map['farmer_id'] = Variable<String>(farmerId);
    map['instance_no'] = Variable<int>(instanceNo);
    map['payload_json'] = Variable<String>(payloadJson);
    map['device_time'] = Variable<DateTime>(deviceTime);
    if (!nullToAbsent || gpsTime != null) {
      map['gps_time'] = Variable<DateTime>(gpsTime);
    }
    if (!nullToAbsent || serverReceivedAt != null) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    {
      map['location_status'] = Variable<String>($EntriesTable.$converterlocationStatus.toSql(locationStatus));
    }
    map['entered_by_user_id'] = Variable<String>(enteredByUserId);
    map['assist_mode'] = Variable<bool>(assistMode);
    map['entered_remotely'] = Variable<bool>(enteredRemotely);
    if (!nullToAbsent || reasonCode != null) {
      map['reason_code'] = Variable<String>(reasonCode);
    }
    {
      map['status'] = Variable<String>($EntriesTable.$converterstatus.toSql(status));
    }
    map['undo_deadline'] = Variable<DateTime>(undoDeadline);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      entryId: Value(entryId),
      rootId: Value(rootId),
      version: Value(version),
      supersedesEntryId: supersedesEntryId == null && nullToAbsent ? const Value.absent() : Value(supersedesEntryId),
      entryType: Value(entryType),
      lotId: lotId == null && nullToAbsent ? const Value.absent() : Value(lotId),
      plotId: plotId == null && nullToAbsent ? const Value.absent() : Value(plotId),
      farmerId: Value(farmerId),
      instanceNo: Value(instanceNo),
      payloadJson: Value(payloadJson),
      deviceTime: Value(deviceTime),
      gpsTime: gpsTime == null && nullToAbsent ? const Value.absent() : Value(gpsTime),
      serverReceivedAt: serverReceivedAt == null && nullToAbsent ? const Value.absent() : Value(serverReceivedAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent ? const Value.absent() : Value(accuracyM),
      locationStatus: Value(locationStatus),
      enteredByUserId: Value(enteredByUserId),
      assistMode: Value(assistMode),
      enteredRemotely: Value(enteredRemotely),
      reasonCode: reasonCode == null && nullToAbsent ? const Value.absent() : Value(reasonCode),
      status: Value(status),
      undoDeadline: Value(undoDeadline),
      createdAt: Value(createdAt),
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      entryId: serializer.fromJson<String>(json['entryId']),
      rootId: serializer.fromJson<String>(json['rootId']),
      version: serializer.fromJson<int>(json['version']),
      supersedesEntryId: serializer.fromJson<String?>(json['supersedesEntryId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      plotId: serializer.fromJson<String?>(json['plotId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      instanceNo: serializer.fromJson<int>(json['instanceNo']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      deviceTime: serializer.fromJson<DateTime>(json['deviceTime']),
      gpsTime: serializer.fromJson<DateTime?>(json['gpsTime']),
      serverReceivedAt: serializer.fromJson<DateTime?>(json['serverReceivedAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      locationStatus: $EntriesTable.$converterlocationStatus.fromJson(
        serializer.fromJson<String>(json['locationStatus']),
      ),
      enteredByUserId: serializer.fromJson<String>(json['enteredByUserId']),
      assistMode: serializer.fromJson<bool>(json['assistMode']),
      enteredRemotely: serializer.fromJson<bool>(json['enteredRemotely']),
      reasonCode: serializer.fromJson<String?>(json['reasonCode']),
      status: $EntriesTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      undoDeadline: serializer.fromJson<DateTime>(json['undoDeadline']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'rootId': serializer.toJson<String>(rootId),
      'version': serializer.toJson<int>(version),
      'supersedesEntryId': serializer.toJson<String?>(supersedesEntryId),
      'entryType': serializer.toJson<String>(entryType),
      'lotId': serializer.toJson<String?>(lotId),
      'plotId': serializer.toJson<String?>(plotId),
      'farmerId': serializer.toJson<String>(farmerId),
      'instanceNo': serializer.toJson<int>(instanceNo),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'deviceTime': serializer.toJson<DateTime>(deviceTime),
      'gpsTime': serializer.toJson<DateTime?>(gpsTime),
      'serverReceivedAt': serializer.toJson<DateTime?>(serverReceivedAt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'locationStatus': serializer.toJson<String>($EntriesTable.$converterlocationStatus.toJson(locationStatus)),
      'enteredByUserId': serializer.toJson<String>(enteredByUserId),
      'assistMode': serializer.toJson<bool>(assistMode),
      'enteredRemotely': serializer.toJson<bool>(enteredRemotely),
      'reasonCode': serializer.toJson<String?>(reasonCode),
      'status': serializer.toJson<String>($EntriesTable.$converterstatus.toJson(status)),
      'undoDeadline': serializer.toJson<DateTime>(undoDeadline),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Entry copyWith({
    String? entryId,
    String? rootId,
    int? version,
    Value<String?> supersedesEntryId = const Value.absent(),
    String? entryType,
    Value<String?> lotId = const Value.absent(),
    Value<String?> plotId = const Value.absent(),
    String? farmerId,
    int? instanceNo,
    String? payloadJson,
    DateTime? deviceTime,
    Value<DateTime?> gpsTime = const Value.absent(),
    Value<DateTime?> serverReceivedAt = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    LocationStatus? locationStatus,
    String? enteredByUserId,
    bool? assistMode,
    bool? enteredRemotely,
    Value<String?> reasonCode = const Value.absent(),
    EntryStatus? status,
    DateTime? undoDeadline,
    DateTime? createdAt,
  }) => Entry(
    entryId: entryId ?? this.entryId,
    rootId: rootId ?? this.rootId,
    version: version ?? this.version,
    supersedesEntryId: supersedesEntryId.present ? supersedesEntryId.value : this.supersedesEntryId,
    entryType: entryType ?? this.entryType,
    lotId: lotId.present ? lotId.value : this.lotId,
    plotId: plotId.present ? plotId.value : this.plotId,
    farmerId: farmerId ?? this.farmerId,
    instanceNo: instanceNo ?? this.instanceNo,
    payloadJson: payloadJson ?? this.payloadJson,
    deviceTime: deviceTime ?? this.deviceTime,
    gpsTime: gpsTime.present ? gpsTime.value : this.gpsTime,
    serverReceivedAt: serverReceivedAt.present ? serverReceivedAt.value : this.serverReceivedAt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    locationStatus: locationStatus ?? this.locationStatus,
    enteredByUserId: enteredByUserId ?? this.enteredByUserId,
    assistMode: assistMode ?? this.assistMode,
    enteredRemotely: enteredRemotely ?? this.enteredRemotely,
    reasonCode: reasonCode.present ? reasonCode.value : this.reasonCode,
    status: status ?? this.status,
    undoDeadline: undoDeadline ?? this.undoDeadline,
    createdAt: createdAt ?? this.createdAt,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      rootId: data.rootId.present ? data.rootId.value : this.rootId,
      version: data.version.present ? data.version.value : this.version,
      supersedesEntryId: data.supersedesEntryId.present ? data.supersedesEntryId.value : this.supersedesEntryId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      instanceNo: data.instanceNo.present ? data.instanceNo.value : this.instanceNo,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      deviceTime: data.deviceTime.present ? data.deviceTime.value : this.deviceTime,
      gpsTime: data.gpsTime.present ? data.gpsTime.value : this.gpsTime,
      serverReceivedAt: data.serverReceivedAt.present ? data.serverReceivedAt.value : this.serverReceivedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      locationStatus: data.locationStatus.present ? data.locationStatus.value : this.locationStatus,
      enteredByUserId: data.enteredByUserId.present ? data.enteredByUserId.value : this.enteredByUserId,
      assistMode: data.assistMode.present ? data.assistMode.value : this.assistMode,
      enteredRemotely: data.enteredRemotely.present ? data.enteredRemotely.value : this.enteredRemotely,
      reasonCode: data.reasonCode.present ? data.reasonCode.value : this.reasonCode,
      status: data.status.present ? data.status.value : this.status,
      undoDeadline: data.undoDeadline.present ? data.undoDeadline.value : this.undoDeadline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('entryId: $entryId, ')
          ..write('rootId: $rootId, ')
          ..write('version: $version, ')
          ..write('supersedesEntryId: $supersedesEntryId, ')
          ..write('entryType: $entryType, ')
          ..write('lotId: $lotId, ')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('instanceNo: $instanceNo, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('gpsTime: $gpsTime, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('locationStatus: $locationStatus, ')
          ..write('enteredByUserId: $enteredByUserId, ')
          ..write('assistMode: $assistMode, ')
          ..write('enteredRemotely: $enteredRemotely, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('status: $status, ')
          ..write('undoDeadline: $undoDeadline, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    entryId,
    rootId,
    version,
    supersedesEntryId,
    entryType,
    lotId,
    plotId,
    farmerId,
    instanceNo,
    payloadJson,
    deviceTime,
    gpsTime,
    serverReceivedAt,
    lat,
    lng,
    accuracyM,
    locationStatus,
    enteredByUserId,
    assistMode,
    enteredRemotely,
    reasonCode,
    status,
    undoDeadline,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.entryId == this.entryId &&
          other.rootId == this.rootId &&
          other.version == this.version &&
          other.supersedesEntryId == this.supersedesEntryId &&
          other.entryType == this.entryType &&
          other.lotId == this.lotId &&
          other.plotId == this.plotId &&
          other.farmerId == this.farmerId &&
          other.instanceNo == this.instanceNo &&
          other.payloadJson == this.payloadJson &&
          other.deviceTime == this.deviceTime &&
          other.gpsTime == this.gpsTime &&
          other.serverReceivedAt == this.serverReceivedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.locationStatus == this.locationStatus &&
          other.enteredByUserId == this.enteredByUserId &&
          other.assistMode == this.assistMode &&
          other.enteredRemotely == this.enteredRemotely &&
          other.reasonCode == this.reasonCode &&
          other.status == this.status &&
          other.undoDeadline == this.undoDeadline &&
          other.createdAt == this.createdAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> entryId;
  final Value<String> rootId;
  final Value<int> version;
  final Value<String?> supersedesEntryId;
  final Value<String> entryType;
  final Value<String?> lotId;
  final Value<String?> plotId;
  final Value<String> farmerId;
  final Value<int> instanceNo;
  final Value<String> payloadJson;
  final Value<DateTime> deviceTime;
  final Value<DateTime?> gpsTime;
  final Value<DateTime?> serverReceivedAt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<LocationStatus> locationStatus;
  final Value<String> enteredByUserId;
  final Value<bool> assistMode;
  final Value<bool> enteredRemotely;
  final Value<String?> reasonCode;
  final Value<EntryStatus> status;
  final Value<DateTime> undoDeadline;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.entryId = const Value.absent(),
    this.rootId = const Value.absent(),
    this.version = const Value.absent(),
    this.supersedesEntryId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.lotId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.instanceNo = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.gpsTime = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.locationStatus = const Value.absent(),
    this.enteredByUserId = const Value.absent(),
    this.assistMode = const Value.absent(),
    this.enteredRemotely = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.status = const Value.absent(),
    this.undoDeadline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String entryId,
    required String rootId,
    required int version,
    this.supersedesEntryId = const Value.absent(),
    required String entryType,
    this.lotId = const Value.absent(),
    this.plotId = const Value.absent(),
    required String farmerId,
    required int instanceNo,
    required String payloadJson,
    required DateTime deviceTime,
    this.gpsTime = const Value.absent(),
    this.serverReceivedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    required LocationStatus locationStatus,
    required String enteredByUserId,
    this.assistMode = const Value.absent(),
    this.enteredRemotely = const Value.absent(),
    this.reasonCode = const Value.absent(),
    required EntryStatus status,
    required DateTime undoDeadline,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId),
       rootId = Value(rootId),
       version = Value(version),
       entryType = Value(entryType),
       farmerId = Value(farmerId),
       instanceNo = Value(instanceNo),
       payloadJson = Value(payloadJson),
       deviceTime = Value(deviceTime),
       locationStatus = Value(locationStatus),
       enteredByUserId = Value(enteredByUserId),
       status = Value(status),
       undoDeadline = Value(undoDeadline),
       createdAt = Value(createdAt);
  static Insertable<Entry> custom({
    Expression<String>? entryId,
    Expression<String>? rootId,
    Expression<int>? version,
    Expression<String>? supersedesEntryId,
    Expression<String>? entryType,
    Expression<String>? lotId,
    Expression<String>? plotId,
    Expression<String>? farmerId,
    Expression<int>? instanceNo,
    Expression<String>? payloadJson,
    Expression<DateTime>? deviceTime,
    Expression<DateTime>? gpsTime,
    Expression<DateTime>? serverReceivedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<String>? locationStatus,
    Expression<String>? enteredByUserId,
    Expression<bool>? assistMode,
    Expression<bool>? enteredRemotely,
    Expression<String>? reasonCode,
    Expression<String>? status,
    Expression<DateTime>? undoDeadline,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (rootId != null) 'root_id': rootId,
      if (version != null) 'version': version,
      if (supersedesEntryId != null) 'supersedes_entry_id': supersedesEntryId,
      if (entryType != null) 'entry_type': entryType,
      if (lotId != null) 'lot_id': lotId,
      if (plotId != null) 'plot_id': plotId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (instanceNo != null) 'instance_no': instanceNo,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (deviceTime != null) 'device_time': deviceTime,
      if (gpsTime != null) 'gps_time': gpsTime,
      if (serverReceivedAt != null) 'server_received_at': serverReceivedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (locationStatus != null) 'location_status': locationStatus,
      if (enteredByUserId != null) 'entered_by_user_id': enteredByUserId,
      if (assistMode != null) 'assist_mode': assistMode,
      if (enteredRemotely != null) 'entered_remotely': enteredRemotely,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (status != null) 'status': status,
      if (undoDeadline != null) 'undo_deadline': undoDeadline,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? entryId,
    Value<String>? rootId,
    Value<int>? version,
    Value<String?>? supersedesEntryId,
    Value<String>? entryType,
    Value<String?>? lotId,
    Value<String?>? plotId,
    Value<String>? farmerId,
    Value<int>? instanceNo,
    Value<String>? payloadJson,
    Value<DateTime>? deviceTime,
    Value<DateTime?>? gpsTime,
    Value<DateTime?>? serverReceivedAt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<LocationStatus>? locationStatus,
    Value<String>? enteredByUserId,
    Value<bool>? assistMode,
    Value<bool>? enteredRemotely,
    Value<String?>? reasonCode,
    Value<EntryStatus>? status,
    Value<DateTime>? undoDeadline,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      entryId: entryId ?? this.entryId,
      rootId: rootId ?? this.rootId,
      version: version ?? this.version,
      supersedesEntryId: supersedesEntryId ?? this.supersedesEntryId,
      entryType: entryType ?? this.entryType,
      lotId: lotId ?? this.lotId,
      plotId: plotId ?? this.plotId,
      farmerId: farmerId ?? this.farmerId,
      instanceNo: instanceNo ?? this.instanceNo,
      payloadJson: payloadJson ?? this.payloadJson,
      deviceTime: deviceTime ?? this.deviceTime,
      gpsTime: gpsTime ?? this.gpsTime,
      serverReceivedAt: serverReceivedAt ?? this.serverReceivedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      locationStatus: locationStatus ?? this.locationStatus,
      enteredByUserId: enteredByUserId ?? this.enteredByUserId,
      assistMode: assistMode ?? this.assistMode,
      enteredRemotely: enteredRemotely ?? this.enteredRemotely,
      reasonCode: reasonCode ?? this.reasonCode,
      status: status ?? this.status,
      undoDeadline: undoDeadline ?? this.undoDeadline,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (rootId.present) {
      map['root_id'] = Variable<String>(rootId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (supersedesEntryId.present) {
      map['supersedes_entry_id'] = Variable<String>(supersedesEntryId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (instanceNo.present) {
      map['instance_no'] = Variable<int>(instanceNo.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<DateTime>(deviceTime.value);
    }
    if (gpsTime.present) {
      map['gps_time'] = Variable<DateTime>(gpsTime.value);
    }
    if (serverReceivedAt.present) {
      map['server_received_at'] = Variable<DateTime>(serverReceivedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (locationStatus.present) {
      map['location_status'] = Variable<String>($EntriesTable.$converterlocationStatus.toSql(locationStatus.value));
    }
    if (enteredByUserId.present) {
      map['entered_by_user_id'] = Variable<String>(enteredByUserId.value);
    }
    if (assistMode.present) {
      map['assist_mode'] = Variable<bool>(assistMode.value);
    }
    if (enteredRemotely.present) {
      map['entered_remotely'] = Variable<bool>(enteredRemotely.value);
    }
    if (reasonCode.present) {
      map['reason_code'] = Variable<String>(reasonCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($EntriesTable.$converterstatus.toSql(status.value));
    }
    if (undoDeadline.present) {
      map['undo_deadline'] = Variable<DateTime>(undoDeadline.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('entryId: $entryId, ')
          ..write('rootId: $rootId, ')
          ..write('version: $version, ')
          ..write('supersedesEntryId: $supersedesEntryId, ')
          ..write('entryType: $entryType, ')
          ..write('lotId: $lotId, ')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('instanceNo: $instanceNo, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('gpsTime: $gpsTime, ')
          ..write('serverReceivedAt: $serverReceivedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('locationStatus: $locationStatus, ')
          ..write('enteredByUserId: $enteredByUserId, ')
          ..write('assistMode: $assistMode, ')
          ..write('enteredRemotely: $enteredRemotely, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('status: $status, ')
          ..write('undoDeadline: $undoDeadline, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaTable extends Media with TableInfo<$MediaTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaIdMeta = const VerificationMeta('mediaId');
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES entries (entry_id)'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta('capturedAt');
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMMeta = const VerificationMeta('accuracyM');
  @override
  late final GeneratedColumn<double> accuracyM = GeneratedColumn<double>(
    'accuracy_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadUrlMeta = const VerificationMeta('uploadUrl');
  @override
  late final GeneratedColumn<String> uploadUrl = GeneratedColumn<String>(
    'upload_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadUrlExpiresAtMeta = const VerificationMeta('uploadUrlExpiresAt');
  @override
  late final GeneratedColumn<DateTime> uploadUrlExpiresAt = GeneratedColumn<DateTime>(
    'upload_url_expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UploadStatus, String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<UploadStatus>($MediaTable.$converteruploadStatus);
  static const VerificationMeta _objectKeyMeta = const VerificationMeta('objectKey');
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta('thumbPath');
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purgedAtMeta = const VerificationMeta('purgedAt');
  @override
  late final GeneratedColumn<DateTime> purgedAt = GeneratedColumn<DateTime>(
    'purged_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaId,
    entryId,
    kind,
    localPath,
    bytes,
    sha256,
    width,
    height,
    capturedAt,
    lat,
    lng,
    accuracyM,
    uploadUrl,
    uploadUrlExpiresAt,
    uploadStatus,
    objectKey,
    thumbPath,
    purgedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(Insertable<MediaFile> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_id')) {
      context.handle(_mediaIdMeta, mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta));
    } else if (isInserting) {
      context.missing(_mediaIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta, entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta, localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(_bytesMeta, bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta));
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(_sha256Meta, sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta));
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('width')) {
      context.handle(_widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta, height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(_capturedAtMeta, capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta));
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(_lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('accuracy_m')) {
      context.handle(_accuracyMMeta, accuracyM.isAcceptableOrUnknown(data['accuracy_m']!, _accuracyMMeta));
    }
    if (data.containsKey('upload_url')) {
      context.handle(_uploadUrlMeta, uploadUrl.isAcceptableOrUnknown(data['upload_url']!, _uploadUrlMeta));
    }
    if (data.containsKey('upload_url_expires_at')) {
      context.handle(
        _uploadUrlExpiresAtMeta,
        uploadUrlExpiresAt.isAcceptableOrUnknown(data['upload_url_expires_at']!, _uploadUrlExpiresAtMeta),
      );
    }
    if (data.containsKey('object_key')) {
      context.handle(_objectKeyMeta, objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta));
    }
    if (data.containsKey('thumb_path')) {
      context.handle(_thumbPathMeta, thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta));
    } else if (isInserting) {
      context.missing(_thumbPathMeta);
    }
    if (data.containsKey('purged_at')) {
      context.handle(_purgedAtMeta, purgedAt.isAcceptableOrUnknown(data['purged_at']!, _purgedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaId};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      mediaId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}media_id'])!,
      entryId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      localPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      bytes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}bytes'])!,
      sha256: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sha256'])!,
      width: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      capturedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}captured_at'])!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lng']),
      accuracyM: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}accuracy_m']),
      uploadUrl: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}upload_url']),
      uploadUrlExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upload_url_expires_at'],
      ),
      uploadStatus: $MediaTable.$converteruploadStatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}upload_status'])!,
      ),
      objectKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}object_key']),
      thumbPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}thumb_path'])!,
      purgedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}purged_at']),
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UploadStatus, String, String> $converteruploadStatus =
      const EnumNameConverter<UploadStatus>(UploadStatus.values);
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  /// Media id (UUIDv7) generated on the phone; the photo `client_id` in the push.
  ///
  /// DECISION D-005: client-generated UUIDv7, so a retried upload or confirm is idempotent.
  ///   ADV: the photo has a permanent id before any network call.
  ///   COMPROMISE: same as for entries; the server rejects a foreign-owned id.
  final String mediaId;

  /// Entry this file belongs to.
  final String entryId;

  /// Media kind (`photo`, `voice`).
  final String kind;

  /// Local path of the full-size file; the file is deleted after upload (see [purgedAt]).
  final String localPath;

  /// Size of the full-size file in bytes.
  final int bytes;

  /// SHA-256 of the full-size file, lowercase hex; the server checks it on upload.
  final String sha256;

  /// Image width in pixels (0 for audio).
  final int width;

  /// Image height in pixels (0 for audio).
  final int height;

  /// When the photo was taken (EXIF DateTimeOriginal or capture time).
  final DateTime capturedAt;

  /// Latitude at capture in decimal degrees; null without a fix.
  final double? lat;

  /// Longitude at capture in decimal degrees; null without a fix.
  final double? lng;

  /// GPS accuracy at capture in metres; null without a fix.
  final double? accuracyM;

  /// Presigned PUT URL from the push acknowledgement; null until the entry is confirmed.
  final String? uploadUrl;

  /// When [uploadUrl] expires (15 min after issue, D-011).
  final DateTime? uploadUrlExpiresAt;

  /// Upload state.
  final UploadStatus uploadStatus;

  /// Object key in the evidence bucket once uploaded.
  final String? objectKey;

  /// Local path of the ~10 KB thumbnail kept after the full-size file is purged.
  final String thumbPath;

  /// When the full-size file was deleted from the phone; null while it still exists.
  final DateTime? purgedAt;
  const MediaFile({
    required this.mediaId,
    required this.entryId,
    required this.kind,
    required this.localPath,
    required this.bytes,
    required this.sha256,
    required this.width,
    required this.height,
    required this.capturedAt,
    this.lat,
    this.lng,
    this.accuracyM,
    this.uploadUrl,
    this.uploadUrlExpiresAt,
    required this.uploadStatus,
    this.objectKey,
    required this.thumbPath,
    this.purgedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_id'] = Variable<String>(mediaId);
    map['entry_id'] = Variable<String>(entryId);
    map['kind'] = Variable<String>(kind);
    map['local_path'] = Variable<String>(localPath);
    map['bytes'] = Variable<int>(bytes);
    map['sha256'] = Variable<String>(sha256);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || accuracyM != null) {
      map['accuracy_m'] = Variable<double>(accuracyM);
    }
    if (!nullToAbsent || uploadUrl != null) {
      map['upload_url'] = Variable<String>(uploadUrl);
    }
    if (!nullToAbsent || uploadUrlExpiresAt != null) {
      map['upload_url_expires_at'] = Variable<DateTime>(uploadUrlExpiresAt);
    }
    {
      map['upload_status'] = Variable<String>($MediaTable.$converteruploadStatus.toSql(uploadStatus));
    }
    if (!nullToAbsent || objectKey != null) {
      map['object_key'] = Variable<String>(objectKey);
    }
    map['thumb_path'] = Variable<String>(thumbPath);
    if (!nullToAbsent || purgedAt != null) {
      map['purged_at'] = Variable<DateTime>(purgedAt);
    }
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      mediaId: Value(mediaId),
      entryId: Value(entryId),
      kind: Value(kind),
      localPath: Value(localPath),
      bytes: Value(bytes),
      sha256: Value(sha256),
      width: Value(width),
      height: Value(height),
      capturedAt: Value(capturedAt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      accuracyM: accuracyM == null && nullToAbsent ? const Value.absent() : Value(accuracyM),
      uploadUrl: uploadUrl == null && nullToAbsent ? const Value.absent() : Value(uploadUrl),
      uploadUrlExpiresAt: uploadUrlExpiresAt == null && nullToAbsent ? const Value.absent() : Value(uploadUrlExpiresAt),
      uploadStatus: Value(uploadStatus),
      objectKey: objectKey == null && nullToAbsent ? const Value.absent() : Value(objectKey),
      thumbPath: Value(thumbPath),
      purgedAt: purgedAt == null && nullToAbsent ? const Value.absent() : Value(purgedAt),
    );
  }

  factory MediaFile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      mediaId: serializer.fromJson<String>(json['mediaId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      kind: serializer.fromJson<String>(json['kind']),
      localPath: serializer.fromJson<String>(json['localPath']),
      bytes: serializer.fromJson<int>(json['bytes']),
      sha256: serializer.fromJson<String>(json['sha256']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      accuracyM: serializer.fromJson<double?>(json['accuracyM']),
      uploadUrl: serializer.fromJson<String?>(json['uploadUrl']),
      uploadUrlExpiresAt: serializer.fromJson<DateTime?>(json['uploadUrlExpiresAt']),
      uploadStatus: $MediaTable.$converteruploadStatus.fromJson(serializer.fromJson<String>(json['uploadStatus'])),
      objectKey: serializer.fromJson<String?>(json['objectKey']),
      thumbPath: serializer.fromJson<String>(json['thumbPath']),
      purgedAt: serializer.fromJson<DateTime?>(json['purgedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaId': serializer.toJson<String>(mediaId),
      'entryId': serializer.toJson<String>(entryId),
      'kind': serializer.toJson<String>(kind),
      'localPath': serializer.toJson<String>(localPath),
      'bytes': serializer.toJson<int>(bytes),
      'sha256': serializer.toJson<String>(sha256),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'accuracyM': serializer.toJson<double?>(accuracyM),
      'uploadUrl': serializer.toJson<String?>(uploadUrl),
      'uploadUrlExpiresAt': serializer.toJson<DateTime?>(uploadUrlExpiresAt),
      'uploadStatus': serializer.toJson<String>($MediaTable.$converteruploadStatus.toJson(uploadStatus)),
      'objectKey': serializer.toJson<String?>(objectKey),
      'thumbPath': serializer.toJson<String>(thumbPath),
      'purgedAt': serializer.toJson<DateTime?>(purgedAt),
    };
  }

  MediaFile copyWith({
    String? mediaId,
    String? entryId,
    String? kind,
    String? localPath,
    int? bytes,
    String? sha256,
    int? width,
    int? height,
    DateTime? capturedAt,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> accuracyM = const Value.absent(),
    Value<String?> uploadUrl = const Value.absent(),
    Value<DateTime?> uploadUrlExpiresAt = const Value.absent(),
    UploadStatus? uploadStatus,
    Value<String?> objectKey = const Value.absent(),
    String? thumbPath,
    Value<DateTime?> purgedAt = const Value.absent(),
  }) => MediaFile(
    mediaId: mediaId ?? this.mediaId,
    entryId: entryId ?? this.entryId,
    kind: kind ?? this.kind,
    localPath: localPath ?? this.localPath,
    bytes: bytes ?? this.bytes,
    sha256: sha256 ?? this.sha256,
    width: width ?? this.width,
    height: height ?? this.height,
    capturedAt: capturedAt ?? this.capturedAt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    accuracyM: accuracyM.present ? accuracyM.value : this.accuracyM,
    uploadUrl: uploadUrl.present ? uploadUrl.value : this.uploadUrl,
    uploadUrlExpiresAt: uploadUrlExpiresAt.present ? uploadUrlExpiresAt.value : this.uploadUrlExpiresAt,
    uploadStatus: uploadStatus ?? this.uploadStatus,
    objectKey: objectKey.present ? objectKey.value : this.objectKey,
    thumbPath: thumbPath ?? this.thumbPath,
    purgedAt: purgedAt.present ? purgedAt.value : this.purgedAt,
  );
  MediaFile copyWithCompanion(MediaCompanion data) {
    return MediaFile(
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      kind: data.kind.present ? data.kind.value : this.kind,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      capturedAt: data.capturedAt.present ? data.capturedAt.value : this.capturedAt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      accuracyM: data.accuracyM.present ? data.accuracyM.value : this.accuracyM,
      uploadUrl: data.uploadUrl.present ? data.uploadUrl.value : this.uploadUrl,
      uploadUrlExpiresAt: data.uploadUrlExpiresAt.present ? data.uploadUrlExpiresAt.value : this.uploadUrlExpiresAt,
      uploadStatus: data.uploadStatus.present ? data.uploadStatus.value : this.uploadStatus,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      purgedAt: data.purgedAt.present ? data.purgedAt.value : this.purgedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('mediaId: $mediaId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('localPath: $localPath, ')
          ..write('bytes: $bytes, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('uploadUrl: $uploadUrl, ')
          ..write('uploadUrlExpiresAt: $uploadUrlExpiresAt, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('objectKey: $objectKey, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('purgedAt: $purgedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaId,
    entryId,
    kind,
    localPath,
    bytes,
    sha256,
    width,
    height,
    capturedAt,
    lat,
    lng,
    accuracyM,
    uploadUrl,
    uploadUrlExpiresAt,
    uploadStatus,
    objectKey,
    thumbPath,
    purgedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.mediaId == this.mediaId &&
          other.entryId == this.entryId &&
          other.kind == this.kind &&
          other.localPath == this.localPath &&
          other.bytes == this.bytes &&
          other.sha256 == this.sha256 &&
          other.width == this.width &&
          other.height == this.height &&
          other.capturedAt == this.capturedAt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.accuracyM == this.accuracyM &&
          other.uploadUrl == this.uploadUrl &&
          other.uploadUrlExpiresAt == this.uploadUrlExpiresAt &&
          other.uploadStatus == this.uploadStatus &&
          other.objectKey == this.objectKey &&
          other.thumbPath == this.thumbPath &&
          other.purgedAt == this.purgedAt);
}

class MediaCompanion extends UpdateCompanion<MediaFile> {
  final Value<String> mediaId;
  final Value<String> entryId;
  final Value<String> kind;
  final Value<String> localPath;
  final Value<int> bytes;
  final Value<String> sha256;
  final Value<int> width;
  final Value<int> height;
  final Value<DateTime> capturedAt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> accuracyM;
  final Value<String?> uploadUrl;
  final Value<DateTime?> uploadUrlExpiresAt;
  final Value<UploadStatus> uploadStatus;
  final Value<String?> objectKey;
  final Value<String> thumbPath;
  final Value<DateTime?> purgedAt;
  final Value<int> rowid;
  const MediaCompanion({
    this.mediaId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.kind = const Value.absent(),
    this.localPath = const Value.absent(),
    this.bytes = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.uploadUrl = const Value.absent(),
    this.uploadUrlExpiresAt = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.purgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaCompanion.insert({
    required String mediaId,
    required String entryId,
    required String kind,
    required String localPath,
    required int bytes,
    required String sha256,
    required int width,
    required int height,
    required DateTime capturedAt,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.accuracyM = const Value.absent(),
    this.uploadUrl = const Value.absent(),
    this.uploadUrlExpiresAt = const Value.absent(),
    required UploadStatus uploadStatus,
    this.objectKey = const Value.absent(),
    required String thumbPath,
    this.purgedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : mediaId = Value(mediaId),
       entryId = Value(entryId),
       kind = Value(kind),
       localPath = Value(localPath),
       bytes = Value(bytes),
       sha256 = Value(sha256),
       width = Value(width),
       height = Value(height),
       capturedAt = Value(capturedAt),
       uploadStatus = Value(uploadStatus),
       thumbPath = Value(thumbPath);
  static Insertable<MediaFile> custom({
    Expression<String>? mediaId,
    Expression<String>? entryId,
    Expression<String>? kind,
    Expression<String>? localPath,
    Expression<int>? bytes,
    Expression<String>? sha256,
    Expression<int>? width,
    Expression<int>? height,
    Expression<DateTime>? capturedAt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? accuracyM,
    Expression<String>? uploadUrl,
    Expression<DateTime>? uploadUrlExpiresAt,
    Expression<String>? uploadStatus,
    Expression<String>? objectKey,
    Expression<String>? thumbPath,
    Expression<DateTime>? purgedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaId != null) 'media_id': mediaId,
      if (entryId != null) 'entry_id': entryId,
      if (kind != null) 'kind': kind,
      if (localPath != null) 'local_path': localPath,
      if (bytes != null) 'bytes': bytes,
      if (sha256 != null) 'sha256': sha256,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
      if (uploadUrl != null) 'upload_url': uploadUrl,
      if (uploadUrlExpiresAt != null) 'upload_url_expires_at': uploadUrlExpiresAt,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (objectKey != null) 'object_key': objectKey,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (purgedAt != null) 'purged_at': purgedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaCompanion copyWith({
    Value<String>? mediaId,
    Value<String>? entryId,
    Value<String>? kind,
    Value<String>? localPath,
    Value<int>? bytes,
    Value<String>? sha256,
    Value<int>? width,
    Value<int>? height,
    Value<DateTime>? capturedAt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? accuracyM,
    Value<String?>? uploadUrl,
    Value<DateTime?>? uploadUrlExpiresAt,
    Value<UploadStatus>? uploadStatus,
    Value<String?>? objectKey,
    Value<String>? thumbPath,
    Value<DateTime?>? purgedAt,
    Value<int>? rowid,
  }) {
    return MediaCompanion(
      mediaId: mediaId ?? this.mediaId,
      entryId: entryId ?? this.entryId,
      kind: kind ?? this.kind,
      localPath: localPath ?? this.localPath,
      bytes: bytes ?? this.bytes,
      sha256: sha256 ?? this.sha256,
      width: width ?? this.width,
      height: height ?? this.height,
      capturedAt: capturedAt ?? this.capturedAt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracyM: accuracyM ?? this.accuracyM,
      uploadUrl: uploadUrl ?? this.uploadUrl,
      uploadUrlExpiresAt: uploadUrlExpiresAt ?? this.uploadUrlExpiresAt,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      objectKey: objectKey ?? this.objectKey,
      thumbPath: thumbPath ?? this.thumbPath,
      purgedAt: purgedAt ?? this.purgedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (accuracyM.present) {
      map['accuracy_m'] = Variable<double>(accuracyM.value);
    }
    if (uploadUrl.present) {
      map['upload_url'] = Variable<String>(uploadUrl.value);
    }
    if (uploadUrlExpiresAt.present) {
      map['upload_url_expires_at'] = Variable<DateTime>(uploadUrlExpiresAt.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>($MediaTable.$converteruploadStatus.toSql(uploadStatus.value));
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (purgedAt.present) {
      map['purged_at'] = Variable<DateTime>(purgedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('mediaId: $mediaId, ')
          ..write('entryId: $entryId, ')
          ..write('kind: $kind, ')
          ..write('localPath: $localPath, ')
          ..write('bytes: $bytes, ')
          ..write('sha256: $sha256, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('accuracyM: $accuracyM, ')
          ..write('uploadUrl: $uploadUrl, ')
          ..write('uploadUrlExpiresAt: $uploadUrlExpiresAt, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('objectKey: $objectKey, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('purgedAt: $purgedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionTableTable extends SessionTable with TableInfo<$SessionTableTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Role, String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Role>($SessionTableTable.$converterrole);
  static const VerificationMeta _fpoIdMeta = const VerificationMeta('fpoId');
  @override
  late final GeneratedColumn<String> fpoId = GeneratedColumn<String>(
    'fpo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta('refreshToken');
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ta'),
  );
  static const VerificationMeta _wifiOnlyPhotosMeta = const VerificationMeta('wifiOnlyPhotos');
  @override
  late final GeneratedColumn<bool> wifiOnlyPhotos = GeneratedColumn<bool>(
    'wifi_only_photos',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("wifi_only_photos" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    role,
    fpoId,
    deviceId,
    accessToken,
    refreshToken,
    pinHash,
    locale,
    wifiOnlyPhotos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session';
  @override
  VerificationContext validateIntegrity(Insertable<SessionRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('fpo_id')) {
      context.handle(_fpoIdMeta, fpoId.isAcceptableOrUnknown(data['fpo_id']!, _fpoIdMeta));
    } else if (isInserting) {
      context.missing(_fpoIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta, deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('access_token')) {
      context.handle(_accessTokenMeta, accessToken.isAcceptableOrUnknown(data['access_token']!, _accessTokenMeta));
    } else if (isInserting) {
      context.missing(_accessTokenMeta);
    }
    if (data.containsKey('refresh_token')) {
      context.handle(_refreshTokenMeta, refreshToken.isAcceptableOrUnknown(data['refresh_token']!, _refreshTokenMeta));
    } else if (isInserting) {
      context.missing(_refreshTokenMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta, pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    }
    if (data.containsKey('wifi_only_photos')) {
      context.handle(
        _wifiOnlyPhotosMeta,
        wifiOnlyPhotos.isAcceptableOrUnknown(data['wifi_only_photos']!, _wifiOnlyPhotosMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      role: $SessionTableTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      ),
      fpoId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}fpo_id'])!,
      deviceId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      accessToken: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}access_token'])!,
      refreshToken: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}refresh_token'])!,
      pinHash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pin_hash']),
      locale: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      wifiOnlyPhotos: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}wifi_only_photos'])!,
    );
  }

  @override
  $SessionTableTable createAlias(String alias) {
    return $SessionTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Role, String, String> $converterrole = const EnumNameConverter<Role>(Role.values);
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  /// Always 1: there is at most one signed-in user per phone.
  final int id;

  /// Server user id (UUID).
  final String userId;

  /// Role of the signed-in user, stored as the Dart enum name (`farmer`, `fieldOfficer`, `qc`).
  final Role role;

  /// FPO the user belongs to (UUID); every API call is scoped to it.
  final String fpoId;

  /// Stable id of this install (UUID, also kept in the keystore), sent in `POST /v1/auth/otp/verify`.
  final String deviceId;

  /// Unused since M06 (D-027): always `''`; the access token is in the keystore. Dropped at the next schema bump.
  final String accessToken;

  /// Unused since M06 (D-027): always `''`; the refresh token is in the keystore. Dropped at the next schema bump.
  final String refreshToken;

  /// Unused (always null): the office PIN is checked by the server only (D-024). Dropped at the next schema bump.
  final String? pinHash;

  /// UI language code, `ta` (default) or `en` (D-016).
  final String locale;

  /// When true, photos wait for Wi-Fi before uploading (Arch §Offline-first "When it syncs").
  final bool wifiOnlyPhotos;
  const SessionRow({
    required this.id,
    required this.userId,
    required this.role,
    required this.fpoId,
    required this.deviceId,
    required this.accessToken,
    required this.refreshToken,
    this.pinHash,
    required this.locale,
    required this.wifiOnlyPhotos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    {
      map['role'] = Variable<String>($SessionTableTable.$converterrole.toSql(role));
    }
    map['fpo_id'] = Variable<String>(fpoId);
    map['device_id'] = Variable<String>(deviceId);
    map['access_token'] = Variable<String>(accessToken);
    map['refresh_token'] = Variable<String>(refreshToken);
    if (!nullToAbsent || pinHash != null) {
      map['pin_hash'] = Variable<String>(pinHash);
    }
    map['locale'] = Variable<String>(locale);
    map['wifi_only_photos'] = Variable<bool>(wifiOnlyPhotos);
    return map;
  }

  SessionTableCompanion toCompanion(bool nullToAbsent) {
    return SessionTableCompanion(
      id: Value(id),
      userId: Value(userId),
      role: Value(role),
      fpoId: Value(fpoId),
      deviceId: Value(deviceId),
      accessToken: Value(accessToken),
      refreshToken: Value(refreshToken),
      pinHash: pinHash == null && nullToAbsent ? const Value.absent() : Value(pinHash),
      locale: Value(locale),
      wifiOnlyPhotos: Value(wifiOnlyPhotos),
    );
  }

  factory SessionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      role: $SessionTableTable.$converterrole.fromJson(serializer.fromJson<String>(json['role'])),
      fpoId: serializer.fromJson<String>(json['fpoId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
      refreshToken: serializer.fromJson<String>(json['refreshToken']),
      pinHash: serializer.fromJson<String?>(json['pinHash']),
      locale: serializer.fromJson<String>(json['locale']),
      wifiOnlyPhotos: serializer.fromJson<bool>(json['wifiOnlyPhotos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>($SessionTableTable.$converterrole.toJson(role)),
      'fpoId': serializer.toJson<String>(fpoId),
      'deviceId': serializer.toJson<String>(deviceId),
      'accessToken': serializer.toJson<String>(accessToken),
      'refreshToken': serializer.toJson<String>(refreshToken),
      'pinHash': serializer.toJson<String?>(pinHash),
      'locale': serializer.toJson<String>(locale),
      'wifiOnlyPhotos': serializer.toJson<bool>(wifiOnlyPhotos),
    };
  }

  SessionRow copyWith({
    int? id,
    String? userId,
    Role? role,
    String? fpoId,
    String? deviceId,
    String? accessToken,
    String? refreshToken,
    Value<String?> pinHash = const Value.absent(),
    String? locale,
    bool? wifiOnlyPhotos,
  }) => SessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    fpoId: fpoId ?? this.fpoId,
    deviceId: deviceId ?? this.deviceId,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    pinHash: pinHash.present ? pinHash.value : this.pinHash,
    locale: locale ?? this.locale,
    wifiOnlyPhotos: wifiOnlyPhotos ?? this.wifiOnlyPhotos,
  );
  SessionRow copyWithCompanion(SessionTableCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      fpoId: data.fpoId.present ? data.fpoId.value : this.fpoId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      accessToken: data.accessToken.present ? data.accessToken.value : this.accessToken,
      refreshToken: data.refreshToken.present ? data.refreshToken.value : this.refreshToken,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      locale: data.locale.present ? data.locale.value : this.locale,
      wifiOnlyPhotos: data.wifiOnlyPhotos.present ? data.wifiOnlyPhotos.value : this.wifiOnlyPhotos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('fpoId: $fpoId, ')
          ..write('deviceId: $deviceId, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('pinHash: $pinHash, ')
          ..write('locale: $locale, ')
          ..write('wifiOnlyPhotos: $wifiOnlyPhotos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, role, fpoId, deviceId, accessToken, refreshToken, pinHash, locale, wifiOnlyPhotos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.fpoId == this.fpoId &&
          other.deviceId == this.deviceId &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.pinHash == this.pinHash &&
          other.locale == this.locale &&
          other.wifiOnlyPhotos == this.wifiOnlyPhotos);
}

class SessionTableCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<String> userId;
  final Value<Role> role;
  final Value<String> fpoId;
  final Value<String> deviceId;
  final Value<String> accessToken;
  final Value<String> refreshToken;
  final Value<String?> pinHash;
  final Value<String> locale;
  final Value<bool> wifiOnlyPhotos;
  const SessionTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.fpoId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.locale = const Value.absent(),
    this.wifiOnlyPhotos = const Value.absent(),
  });
  SessionTableCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required Role role,
    required String fpoId,
    required String deviceId,
    required String accessToken,
    required String refreshToken,
    this.pinHash = const Value.absent(),
    this.locale = const Value.absent(),
    this.wifiOnlyPhotos = const Value.absent(),
  }) : userId = Value(userId),
       role = Value(role),
       fpoId = Value(fpoId),
       deviceId = Value(deviceId),
       accessToken = Value(accessToken),
       refreshToken = Value(refreshToken);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? fpoId,
    Expression<String>? deviceId,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<String>? pinHash,
    Expression<String>? locale,
    Expression<bool>? wifiOnlyPhotos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (fpoId != null) 'fpo_id': fpoId,
      if (deviceId != null) 'device_id': deviceId,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (pinHash != null) 'pin_hash': pinHash,
      if (locale != null) 'locale': locale,
      if (wifiOnlyPhotos != null) 'wifi_only_photos': wifiOnlyPhotos,
    });
  }

  SessionTableCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<Role>? role,
    Value<String>? fpoId,
    Value<String>? deviceId,
    Value<String>? accessToken,
    Value<String>? refreshToken,
    Value<String?>? pinHash,
    Value<String>? locale,
    Value<bool>? wifiOnlyPhotos,
  }) {
    return SessionTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      fpoId: fpoId ?? this.fpoId,
      deviceId: deviceId ?? this.deviceId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      pinHash: pinHash ?? this.pinHash,
      locale: locale ?? this.locale,
      wifiOnlyPhotos: wifiOnlyPhotos ?? this.wifiOnlyPhotos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>($SessionTableTable.$converterrole.toSql(role.value));
    }
    if (fpoId.present) {
      map['fpo_id'] = Variable<String>(fpoId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (wifiOnlyPhotos.present) {
      map['wifi_only_photos'] = Variable<bool>(wifiOnlyPhotos.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('fpoId: $fpoId, ')
          ..write('deviceId: $deviceId, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('pinHash: $pinHash, ')
          ..write('locale: $locale, ')
          ..write('wifiOnlyPhotos: $wifiOnlyPhotos')
          ..write(')'))
        .toString();
  }
}

class $FarmersTable extends Farmers with TableInfo<$FarmersTable, Farmer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fpoIdMeta = const VerificationMeta('fpoId');
  @override
  late final GeneratedColumn<String> fpoId = GeneratedColumn<String>(
    'fpo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageMeta = const VerificationMeta('village');
  @override
  late final GeneratedColumn<String> village = GeneratedColumn<String>(
    'village',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasSmartphoneMeta = const VerificationMeta('hasSmartphone');
  @override
  late final GeneratedColumn<bool> hasSmartphone = GeneratedColumn<bool>(
    'has_smartphone',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_smartphone" IN (0, 1))'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    farmerId,
    fpoId,
    name,
    village,
    photoPath,
    hasSmartphone,
    language,
    status,
    json,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farmers';
  @override
  VerificationContext validateIntegrity(Insertable<Farmer> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('fpo_id')) {
      context.handle(_fpoIdMeta, fpoId.isAcceptableOrUnknown(data['fpo_id']!, _fpoIdMeta));
    } else if (isInserting) {
      context.missing(_fpoIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('village')) {
      context.handle(_villageMeta, village.isAcceptableOrUnknown(data['village']!, _villageMeta));
    } else if (isInserting) {
      context.missing(_villageMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta, photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('has_smartphone')) {
      context.handle(
        _hasSmartphoneMeta,
        hasSmartphone.isAcceptableOrUnknown(data['has_smartphone']!, _hasSmartphoneMeta),
      );
    } else if (isInserting) {
      context.missing(_hasSmartphoneMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta, language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('json')) {
      context.handle(_jsonMeta, json.isAcceptableOrUnknown(data['json']!, _jsonMeta));
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {farmerId};
  @override
  Farmer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Farmer(
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      fpoId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}fpo_id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      village: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}village'])!,
      photoPath: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      hasSmartphone: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}has_smartphone'])!,
      language: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      json: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}json'])!,
    );
  }

  @override
  $FarmersTable createAlias(String alias) {
    return $FarmersTable(attachedDatabase, alias);
  }
}

class Farmer extends DataClass implements Insertable<Farmer> {
  /// Server farmer id (UUID).
  final String farmerId;

  /// FPO the farmer belongs to (UUID).
  final String fpoId;

  /// Display name.
  final String name;

  /// Village name, for officer lists.
  final String village;

  /// Local path of the farmer's photo; null until downloaded or taken.
  final String? photoPath;

  /// Whether the farmer has their own smartphone (false → officer assist mode is the usual path).
  final bool hasSmartphone;

  /// Preferred language code (`ta`, `en`, ...).
  final String language;

  /// Server status of the farmer record (e.g. `active`).
  final String status;

  /// Remaining profile fields as JSON; which ones exist is decided by FieldConfig (D-017).
  final String json;
  const Farmer({
    required this.farmerId,
    required this.fpoId,
    required this.name,
    required this.village,
    this.photoPath,
    required this.hasSmartphone,
    required this.language,
    required this.status,
    required this.json,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['farmer_id'] = Variable<String>(farmerId);
    map['fpo_id'] = Variable<String>(fpoId);
    map['name'] = Variable<String>(name);
    map['village'] = Variable<String>(village);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['has_smartphone'] = Variable<bool>(hasSmartphone);
    map['language'] = Variable<String>(language);
    map['status'] = Variable<String>(status);
    map['json'] = Variable<String>(json);
    return map;
  }

  FarmersCompanion toCompanion(bool nullToAbsent) {
    return FarmersCompanion(
      farmerId: Value(farmerId),
      fpoId: Value(fpoId),
      name: Value(name),
      village: Value(village),
      photoPath: photoPath == null && nullToAbsent ? const Value.absent() : Value(photoPath),
      hasSmartphone: Value(hasSmartphone),
      language: Value(language),
      status: Value(status),
      json: Value(json),
    );
  }

  factory Farmer.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Farmer(
      farmerId: serializer.fromJson<String>(json['farmerId']),
      fpoId: serializer.fromJson<String>(json['fpoId']),
      name: serializer.fromJson<String>(json['name']),
      village: serializer.fromJson<String>(json['village']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      hasSmartphone: serializer.fromJson<bool>(json['hasSmartphone']),
      language: serializer.fromJson<String>(json['language']),
      status: serializer.fromJson<String>(json['status']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'farmerId': serializer.toJson<String>(farmerId),
      'fpoId': serializer.toJson<String>(fpoId),
      'name': serializer.toJson<String>(name),
      'village': serializer.toJson<String>(village),
      'photoPath': serializer.toJson<String?>(photoPath),
      'hasSmartphone': serializer.toJson<bool>(hasSmartphone),
      'language': serializer.toJson<String>(language),
      'status': serializer.toJson<String>(status),
      'json': serializer.toJson<String>(json),
    };
  }

  Farmer copyWith({
    String? farmerId,
    String? fpoId,
    String? name,
    String? village,
    Value<String?> photoPath = const Value.absent(),
    bool? hasSmartphone,
    String? language,
    String? status,
    String? json,
  }) => Farmer(
    farmerId: farmerId ?? this.farmerId,
    fpoId: fpoId ?? this.fpoId,
    name: name ?? this.name,
    village: village ?? this.village,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    hasSmartphone: hasSmartphone ?? this.hasSmartphone,
    language: language ?? this.language,
    status: status ?? this.status,
    json: json ?? this.json,
  );
  Farmer copyWithCompanion(FarmersCompanion data) {
    return Farmer(
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      fpoId: data.fpoId.present ? data.fpoId.value : this.fpoId,
      name: data.name.present ? data.name.value : this.name,
      village: data.village.present ? data.village.value : this.village,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      hasSmartphone: data.hasSmartphone.present ? data.hasSmartphone.value : this.hasSmartphone,
      language: data.language.present ? data.language.value : this.language,
      status: data.status.present ? data.status.value : this.status,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Farmer(')
          ..write('farmerId: $farmerId, ')
          ..write('fpoId: $fpoId, ')
          ..write('name: $name, ')
          ..write('village: $village, ')
          ..write('photoPath: $photoPath, ')
          ..write('hasSmartphone: $hasSmartphone, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(farmerId, fpoId, name, village, photoPath, hasSmartphone, language, status, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Farmer &&
          other.farmerId == this.farmerId &&
          other.fpoId == this.fpoId &&
          other.name == this.name &&
          other.village == this.village &&
          other.photoPath == this.photoPath &&
          other.hasSmartphone == this.hasSmartphone &&
          other.language == this.language &&
          other.status == this.status &&
          other.json == this.json);
}

class FarmersCompanion extends UpdateCompanion<Farmer> {
  final Value<String> farmerId;
  final Value<String> fpoId;
  final Value<String> name;
  final Value<String> village;
  final Value<String?> photoPath;
  final Value<bool> hasSmartphone;
  final Value<String> language;
  final Value<String> status;
  final Value<String> json;
  final Value<int> rowid;
  const FarmersCompanion({
    this.farmerId = const Value.absent(),
    this.fpoId = const Value.absent(),
    this.name = const Value.absent(),
    this.village = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.hasSmartphone = const Value.absent(),
    this.language = const Value.absent(),
    this.status = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmersCompanion.insert({
    required String farmerId,
    required String fpoId,
    required String name,
    required String village,
    this.photoPath = const Value.absent(),
    required bool hasSmartphone,
    required String language,
    required String status,
    required String json,
    this.rowid = const Value.absent(),
  }) : farmerId = Value(farmerId),
       fpoId = Value(fpoId),
       name = Value(name),
       village = Value(village),
       hasSmartphone = Value(hasSmartphone),
       language = Value(language),
       status = Value(status),
       json = Value(json);
  static Insertable<Farmer> custom({
    Expression<String>? farmerId,
    Expression<String>? fpoId,
    Expression<String>? name,
    Expression<String>? village,
    Expression<String>? photoPath,
    Expression<bool>? hasSmartphone,
    Expression<String>? language,
    Expression<String>? status,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (farmerId != null) 'farmer_id': farmerId,
      if (fpoId != null) 'fpo_id': fpoId,
      if (name != null) 'name': name,
      if (village != null) 'village': village,
      if (photoPath != null) 'photo_path': photoPath,
      if (hasSmartphone != null) 'has_smartphone': hasSmartphone,
      if (language != null) 'language': language,
      if (status != null) 'status': status,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmersCompanion copyWith({
    Value<String>? farmerId,
    Value<String>? fpoId,
    Value<String>? name,
    Value<String>? village,
    Value<String?>? photoPath,
    Value<bool>? hasSmartphone,
    Value<String>? language,
    Value<String>? status,
    Value<String>? json,
    Value<int>? rowid,
  }) {
    return FarmersCompanion(
      farmerId: farmerId ?? this.farmerId,
      fpoId: fpoId ?? this.fpoId,
      name: name ?? this.name,
      village: village ?? this.village,
      photoPath: photoPath ?? this.photoPath,
      hasSmartphone: hasSmartphone ?? this.hasSmartphone,
      language: language ?? this.language,
      status: status ?? this.status,
      json: json ?? this.json,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (fpoId.present) {
      map['fpo_id'] = Variable<String>(fpoId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (village.present) {
      map['village'] = Variable<String>(village.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (hasSmartphone.present) {
      map['has_smartphone'] = Variable<bool>(hasSmartphone.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmersCompanion(')
          ..write('farmerId: $farmerId, ')
          ..write('fpoId: $fpoId, ')
          ..write('name: $name, ')
          ..write('village: $village, ')
          ..write('photoPath: $photoPath, ')
          ..write('hasSmartphone: $hasSmartphone, ')
          ..write('language: $language, ')
          ..write('status: $status, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotsTable extends Plots with TableInfo<$PlotsTable, Plot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinLatMeta = const VerificationMeta('pinLat');
  @override
  late final GeneratedColumn<double> pinLat = GeneratedColumn<double>(
    'pin_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinLngMeta = const VerificationMeta('pinLng');
  @override
  late final GeneratedColumn<double> pinLng = GeneratedColumn<double>(
    'pin_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinAccuracyMMeta = const VerificationMeta('pinAccuracyM');
  @override
  late final GeneratedColumn<double> pinAccuracyM = GeneratedColumn<double>(
    'pin_accuracy_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinMethodMeta = const VerificationMeta('pinMethod');
  @override
  late final GeneratedColumn<String> pinMethod = GeneratedColumn<String>(
    'pin_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _declaredAreaMeta = const VerificationMeta('declaredArea');
  @override
  late final GeneratedColumn<double> declaredArea = GeneratedColumn<double>(
    'declared_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaUnitMeta = const VerificationMeta('areaUnit');
  @override
  late final GeneratedColumn<String> areaUnit = GeneratedColumn<String>(
    'area_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surveyNoLocalOnlyMeta = const VerificationMeta('surveyNoLocalOnly');
  @override
  late final GeneratedColumn<String> surveyNoLocalOnly = GeneratedColumn<String>(
    'survey_no_local_only',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boundaryGeoJsonMeta = const VerificationMeta('boundaryGeoJson');
  @override
  late final GeneratedColumn<String> boundaryGeoJson = GeneratedColumn<String>(
    'boundary_geo_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giStatusMeta = const VerificationMeta('giStatus');
  @override
  late final GeneratedColumn<String> giStatus = GeneratedColumn<String>(
    'gi_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("locked" IN (0, 1))'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    plotId,
    farmerId,
    pinLat,
    pinLng,
    pinAccuracyM,
    pinMethod,
    declaredArea,
    areaUnit,
    surveyNoLocalOnly,
    boundaryGeoJson,
    giStatus,
    locked,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plots';
  @override
  VerificationContext validateIntegrity(Insertable<Plot> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plot_id')) {
      context.handle(_plotIdMeta, plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta));
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('pin_lat')) {
      context.handle(_pinLatMeta, pinLat.isAcceptableOrUnknown(data['pin_lat']!, _pinLatMeta));
    } else if (isInserting) {
      context.missing(_pinLatMeta);
    }
    if (data.containsKey('pin_lng')) {
      context.handle(_pinLngMeta, pinLng.isAcceptableOrUnknown(data['pin_lng']!, _pinLngMeta));
    } else if (isInserting) {
      context.missing(_pinLngMeta);
    }
    if (data.containsKey('pin_accuracy_m')) {
      context.handle(_pinAccuracyMMeta, pinAccuracyM.isAcceptableOrUnknown(data['pin_accuracy_m']!, _pinAccuracyMMeta));
    } else if (isInserting) {
      context.missing(_pinAccuracyMMeta);
    }
    if (data.containsKey('pin_method')) {
      context.handle(_pinMethodMeta, pinMethod.isAcceptableOrUnknown(data['pin_method']!, _pinMethodMeta));
    } else if (isInserting) {
      context.missing(_pinMethodMeta);
    }
    if (data.containsKey('declared_area')) {
      context.handle(_declaredAreaMeta, declaredArea.isAcceptableOrUnknown(data['declared_area']!, _declaredAreaMeta));
    } else if (isInserting) {
      context.missing(_declaredAreaMeta);
    }
    if (data.containsKey('area_unit')) {
      context.handle(_areaUnitMeta, areaUnit.isAcceptableOrUnknown(data['area_unit']!, _areaUnitMeta));
    } else if (isInserting) {
      context.missing(_areaUnitMeta);
    }
    if (data.containsKey('survey_no_local_only')) {
      context.handle(
        _surveyNoLocalOnlyMeta,
        surveyNoLocalOnly.isAcceptableOrUnknown(data['survey_no_local_only']!, _surveyNoLocalOnlyMeta),
      );
    }
    if (data.containsKey('boundary_geo_json')) {
      context.handle(
        _boundaryGeoJsonMeta,
        boundaryGeoJson.isAcceptableOrUnknown(data['boundary_geo_json']!, _boundaryGeoJsonMeta),
      );
    }
    if (data.containsKey('gi_status')) {
      context.handle(_giStatusMeta, giStatus.isAcceptableOrUnknown(data['gi_status']!, _giStatusMeta));
    } else if (isInserting) {
      context.missing(_giStatusMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(_lockedMeta, locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta));
    } else if (isInserting) {
      context.missing(_lockedMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta, version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {plotId};
  @override
  Plot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plot(
      plotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plot_id'])!,
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      pinLat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pin_lat'])!,
      pinLng: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pin_lng'])!,
      pinAccuracyM: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pin_accuracy_m'])!,
      pinMethod: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}pin_method'])!,
      declaredArea: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}declared_area'])!,
      areaUnit: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}area_unit'])!,
      surveyNoLocalOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}survey_no_local_only'],
      ),
      boundaryGeoJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boundary_geo_json'],
      ),
      giStatus: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}gi_status'])!,
      locked: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}locked'])!,
      version: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $PlotsTable createAlias(String alias) {
    return $PlotsTable(attachedDatabase, alias);
  }
}

class Plot extends DataClass implements Insertable<Plot> {
  /// Server plot id (UUID).
  final String plotId;

  /// Owner farmer id.
  final String farmerId;

  /// Pin latitude in decimal degrees (WGS 84).
  final double pinLat;

  /// Pin longitude in decimal degrees (WGS 84).
  final double pinLng;

  /// Pin accuracy radius in metres.
  final double pinAccuracyM;

  /// How the pin was set (e.g. `gps`, `map_tap`).
  final String pinMethod;

  /// Area the farmer declared, in [areaUnit].
  final double declaredArea;

  /// Unit of [declaredArea]: `acre` or `cent`.
  final String areaUnit;

  /// Land-record survey number; kept on the phone only and never shown publicly (CLAUDE.md §6).
  final String? surveyNoLocalOnly;

  /// Walked boundary as GeoJSON Polygon; null when only a pin exists.
  final String? boundaryGeoJson;

  /// GI-region status of the plot (server value, e.g. `inside`, `outside`, `unknown`).
  final String giStatus;

  /// True when the plot is locked against edits (it has events or a sale).
  final bool locked;

  /// Server version of the plot record, for stale-write detection.
  final int version;
  const Plot({
    required this.plotId,
    required this.farmerId,
    required this.pinLat,
    required this.pinLng,
    required this.pinAccuracyM,
    required this.pinMethod,
    required this.declaredArea,
    required this.areaUnit,
    this.surveyNoLocalOnly,
    this.boundaryGeoJson,
    required this.giStatus,
    required this.locked,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plot_id'] = Variable<String>(plotId);
    map['farmer_id'] = Variable<String>(farmerId);
    map['pin_lat'] = Variable<double>(pinLat);
    map['pin_lng'] = Variable<double>(pinLng);
    map['pin_accuracy_m'] = Variable<double>(pinAccuracyM);
    map['pin_method'] = Variable<String>(pinMethod);
    map['declared_area'] = Variable<double>(declaredArea);
    map['area_unit'] = Variable<String>(areaUnit);
    if (!nullToAbsent || surveyNoLocalOnly != null) {
      map['survey_no_local_only'] = Variable<String>(surveyNoLocalOnly);
    }
    if (!nullToAbsent || boundaryGeoJson != null) {
      map['boundary_geo_json'] = Variable<String>(boundaryGeoJson);
    }
    map['gi_status'] = Variable<String>(giStatus);
    map['locked'] = Variable<bool>(locked);
    map['version'] = Variable<int>(version);
    return map;
  }

  PlotsCompanion toCompanion(bool nullToAbsent) {
    return PlotsCompanion(
      plotId: Value(plotId),
      farmerId: Value(farmerId),
      pinLat: Value(pinLat),
      pinLng: Value(pinLng),
      pinAccuracyM: Value(pinAccuracyM),
      pinMethod: Value(pinMethod),
      declaredArea: Value(declaredArea),
      areaUnit: Value(areaUnit),
      surveyNoLocalOnly: surveyNoLocalOnly == null && nullToAbsent ? const Value.absent() : Value(surveyNoLocalOnly),
      boundaryGeoJson: boundaryGeoJson == null && nullToAbsent ? const Value.absent() : Value(boundaryGeoJson),
      giStatus: Value(giStatus),
      locked: Value(locked),
      version: Value(version),
    );
  }

  factory Plot.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plot(
      plotId: serializer.fromJson<String>(json['plotId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      pinLat: serializer.fromJson<double>(json['pinLat']),
      pinLng: serializer.fromJson<double>(json['pinLng']),
      pinAccuracyM: serializer.fromJson<double>(json['pinAccuracyM']),
      pinMethod: serializer.fromJson<String>(json['pinMethod']),
      declaredArea: serializer.fromJson<double>(json['declaredArea']),
      areaUnit: serializer.fromJson<String>(json['areaUnit']),
      surveyNoLocalOnly: serializer.fromJson<String?>(json['surveyNoLocalOnly']),
      boundaryGeoJson: serializer.fromJson<String?>(json['boundaryGeoJson']),
      giStatus: serializer.fromJson<String>(json['giStatus']),
      locked: serializer.fromJson<bool>(json['locked']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'plotId': serializer.toJson<String>(plotId),
      'farmerId': serializer.toJson<String>(farmerId),
      'pinLat': serializer.toJson<double>(pinLat),
      'pinLng': serializer.toJson<double>(pinLng),
      'pinAccuracyM': serializer.toJson<double>(pinAccuracyM),
      'pinMethod': serializer.toJson<String>(pinMethod),
      'declaredArea': serializer.toJson<double>(declaredArea),
      'areaUnit': serializer.toJson<String>(areaUnit),
      'surveyNoLocalOnly': serializer.toJson<String?>(surveyNoLocalOnly),
      'boundaryGeoJson': serializer.toJson<String?>(boundaryGeoJson),
      'giStatus': serializer.toJson<String>(giStatus),
      'locked': serializer.toJson<bool>(locked),
      'version': serializer.toJson<int>(version),
    };
  }

  Plot copyWith({
    String? plotId,
    String? farmerId,
    double? pinLat,
    double? pinLng,
    double? pinAccuracyM,
    String? pinMethod,
    double? declaredArea,
    String? areaUnit,
    Value<String?> surveyNoLocalOnly = const Value.absent(),
    Value<String?> boundaryGeoJson = const Value.absent(),
    String? giStatus,
    bool? locked,
    int? version,
  }) => Plot(
    plotId: plotId ?? this.plotId,
    farmerId: farmerId ?? this.farmerId,
    pinLat: pinLat ?? this.pinLat,
    pinLng: pinLng ?? this.pinLng,
    pinAccuracyM: pinAccuracyM ?? this.pinAccuracyM,
    pinMethod: pinMethod ?? this.pinMethod,
    declaredArea: declaredArea ?? this.declaredArea,
    areaUnit: areaUnit ?? this.areaUnit,
    surveyNoLocalOnly: surveyNoLocalOnly.present ? surveyNoLocalOnly.value : this.surveyNoLocalOnly,
    boundaryGeoJson: boundaryGeoJson.present ? boundaryGeoJson.value : this.boundaryGeoJson,
    giStatus: giStatus ?? this.giStatus,
    locked: locked ?? this.locked,
    version: version ?? this.version,
  );
  Plot copyWithCompanion(PlotsCompanion data) {
    return Plot(
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      pinLat: data.pinLat.present ? data.pinLat.value : this.pinLat,
      pinLng: data.pinLng.present ? data.pinLng.value : this.pinLng,
      pinAccuracyM: data.pinAccuracyM.present ? data.pinAccuracyM.value : this.pinAccuracyM,
      pinMethod: data.pinMethod.present ? data.pinMethod.value : this.pinMethod,
      declaredArea: data.declaredArea.present ? data.declaredArea.value : this.declaredArea,
      areaUnit: data.areaUnit.present ? data.areaUnit.value : this.areaUnit,
      surveyNoLocalOnly: data.surveyNoLocalOnly.present ? data.surveyNoLocalOnly.value : this.surveyNoLocalOnly,
      boundaryGeoJson: data.boundaryGeoJson.present ? data.boundaryGeoJson.value : this.boundaryGeoJson,
      giStatus: data.giStatus.present ? data.giStatus.value : this.giStatus,
      locked: data.locked.present ? data.locked.value : this.locked,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plot(')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinAccuracyM: $pinAccuracyM, ')
          ..write('pinMethod: $pinMethod, ')
          ..write('declaredArea: $declaredArea, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('surveyNoLocalOnly: $surveyNoLocalOnly, ')
          ..write('boundaryGeoJson: $boundaryGeoJson, ')
          ..write('giStatus: $giStatus, ')
          ..write('locked: $locked, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    plotId,
    farmerId,
    pinLat,
    pinLng,
    pinAccuracyM,
    pinMethod,
    declaredArea,
    areaUnit,
    surveyNoLocalOnly,
    boundaryGeoJson,
    giStatus,
    locked,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plot &&
          other.plotId == this.plotId &&
          other.farmerId == this.farmerId &&
          other.pinLat == this.pinLat &&
          other.pinLng == this.pinLng &&
          other.pinAccuracyM == this.pinAccuracyM &&
          other.pinMethod == this.pinMethod &&
          other.declaredArea == this.declaredArea &&
          other.areaUnit == this.areaUnit &&
          other.surveyNoLocalOnly == this.surveyNoLocalOnly &&
          other.boundaryGeoJson == this.boundaryGeoJson &&
          other.giStatus == this.giStatus &&
          other.locked == this.locked &&
          other.version == this.version);
}

class PlotsCompanion extends UpdateCompanion<Plot> {
  final Value<String> plotId;
  final Value<String> farmerId;
  final Value<double> pinLat;
  final Value<double> pinLng;
  final Value<double> pinAccuracyM;
  final Value<String> pinMethod;
  final Value<double> declaredArea;
  final Value<String> areaUnit;
  final Value<String?> surveyNoLocalOnly;
  final Value<String?> boundaryGeoJson;
  final Value<String> giStatus;
  final Value<bool> locked;
  final Value<int> version;
  final Value<int> rowid;
  const PlotsCompanion({
    this.plotId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.pinLat = const Value.absent(),
    this.pinLng = const Value.absent(),
    this.pinAccuracyM = const Value.absent(),
    this.pinMethod = const Value.absent(),
    this.declaredArea = const Value.absent(),
    this.areaUnit = const Value.absent(),
    this.surveyNoLocalOnly = const Value.absent(),
    this.boundaryGeoJson = const Value.absent(),
    this.giStatus = const Value.absent(),
    this.locked = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotsCompanion.insert({
    required String plotId,
    required String farmerId,
    required double pinLat,
    required double pinLng,
    required double pinAccuracyM,
    required String pinMethod,
    required double declaredArea,
    required String areaUnit,
    this.surveyNoLocalOnly = const Value.absent(),
    this.boundaryGeoJson = const Value.absent(),
    required String giStatus,
    required bool locked,
    required int version,
    this.rowid = const Value.absent(),
  }) : plotId = Value(plotId),
       farmerId = Value(farmerId),
       pinLat = Value(pinLat),
       pinLng = Value(pinLng),
       pinAccuracyM = Value(pinAccuracyM),
       pinMethod = Value(pinMethod),
       declaredArea = Value(declaredArea),
       areaUnit = Value(areaUnit),
       giStatus = Value(giStatus),
       locked = Value(locked),
       version = Value(version);
  static Insertable<Plot> custom({
    Expression<String>? plotId,
    Expression<String>? farmerId,
    Expression<double>? pinLat,
    Expression<double>? pinLng,
    Expression<double>? pinAccuracyM,
    Expression<String>? pinMethod,
    Expression<double>? declaredArea,
    Expression<String>? areaUnit,
    Expression<String>? surveyNoLocalOnly,
    Expression<String>? boundaryGeoJson,
    Expression<String>? giStatus,
    Expression<bool>? locked,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (plotId != null) 'plot_id': plotId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (pinLat != null) 'pin_lat': pinLat,
      if (pinLng != null) 'pin_lng': pinLng,
      if (pinAccuracyM != null) 'pin_accuracy_m': pinAccuracyM,
      if (pinMethod != null) 'pin_method': pinMethod,
      if (declaredArea != null) 'declared_area': declaredArea,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (surveyNoLocalOnly != null) 'survey_no_local_only': surveyNoLocalOnly,
      if (boundaryGeoJson != null) 'boundary_geo_json': boundaryGeoJson,
      if (giStatus != null) 'gi_status': giStatus,
      if (locked != null) 'locked': locked,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotsCompanion copyWith({
    Value<String>? plotId,
    Value<String>? farmerId,
    Value<double>? pinLat,
    Value<double>? pinLng,
    Value<double>? pinAccuracyM,
    Value<String>? pinMethod,
    Value<double>? declaredArea,
    Value<String>? areaUnit,
    Value<String?>? surveyNoLocalOnly,
    Value<String?>? boundaryGeoJson,
    Value<String>? giStatus,
    Value<bool>? locked,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return PlotsCompanion(
      plotId: plotId ?? this.plotId,
      farmerId: farmerId ?? this.farmerId,
      pinLat: pinLat ?? this.pinLat,
      pinLng: pinLng ?? this.pinLng,
      pinAccuracyM: pinAccuracyM ?? this.pinAccuracyM,
      pinMethod: pinMethod ?? this.pinMethod,
      declaredArea: declaredArea ?? this.declaredArea,
      areaUnit: areaUnit ?? this.areaUnit,
      surveyNoLocalOnly: surveyNoLocalOnly ?? this.surveyNoLocalOnly,
      boundaryGeoJson: boundaryGeoJson ?? this.boundaryGeoJson,
      giStatus: giStatus ?? this.giStatus,
      locked: locked ?? this.locked,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (pinLat.present) {
      map['pin_lat'] = Variable<double>(pinLat.value);
    }
    if (pinLng.present) {
      map['pin_lng'] = Variable<double>(pinLng.value);
    }
    if (pinAccuracyM.present) {
      map['pin_accuracy_m'] = Variable<double>(pinAccuracyM.value);
    }
    if (pinMethod.present) {
      map['pin_method'] = Variable<String>(pinMethod.value);
    }
    if (declaredArea.present) {
      map['declared_area'] = Variable<double>(declaredArea.value);
    }
    if (areaUnit.present) {
      map['area_unit'] = Variable<String>(areaUnit.value);
    }
    if (surveyNoLocalOnly.present) {
      map['survey_no_local_only'] = Variable<String>(surveyNoLocalOnly.value);
    }
    if (boundaryGeoJson.present) {
      map['boundary_geo_json'] = Variable<String>(boundaryGeoJson.value);
    }
    if (giStatus.present) {
      map['gi_status'] = Variable<String>(giStatus.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlotsCompanion(')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('pinLat: $pinLat, ')
          ..write('pinLng: $pinLng, ')
          ..write('pinAccuracyM: $pinAccuracyM, ')
          ..write('pinMethod: $pinMethod, ')
          ..write('declaredArea: $declaredArea, ')
          ..write('areaUnit: $areaUnit, ')
          ..write('surveyNoLocalOnly: $surveyNoLocalOnly, ')
          ..write('boundaryGeoJson: $boundaryGeoJson, ')
          ..write('giStatus: $giStatus, ')
          ..write('locked: $locked, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LotsTable extends Lots with TableInfo<$LotsTable, Lot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
    'crop_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgHarvestedMeta = const VerificationMeta('kgHarvested');
  @override
  late final GeneratedColumn<double> kgHarvested = GeneratedColumn<double>(
    'kg_harvested',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kgPackedMeta = const VerificationMeta('kgPacked');
  @override
  late final GeneratedColumn<double> kgPacked = GeneratedColumn<double>(
    'kg_packed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastMoistureMeta = const VerificationMeta('lastMoisture');
  @override
  late final GeneratedColumn<double> lastMoisture = GeneratedColumn<double>(
    'last_moisture',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qrPayloadMeta = const VerificationMeta('qrPayload');
  @override
  late final GeneratedColumn<String> qrPayload = GeneratedColumn<String>(
    'qr_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    lotId,
    plotId,
    farmerId,
    cropId,
    season,
    status,
    kgHarvested,
    kgPacked,
    lastMoisture,
    qrPayload,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lots';
  @override
  VerificationContext validateIntegrity(Insertable<Lot> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lot_id')) {
      context.handle(_lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('plot_id')) {
      context.handle(_plotIdMeta, plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta));
    } else if (isInserting) {
      context.missing(_plotIdMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(_cropIdMeta, cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta));
    } else if (isInserting) {
      context.missing(_cropIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(_seasonMeta, season.isAcceptableOrUnknown(data['season']!, _seasonMeta));
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('kg_harvested')) {
      context.handle(_kgHarvestedMeta, kgHarvested.isAcceptableOrUnknown(data['kg_harvested']!, _kgHarvestedMeta));
    }
    if (data.containsKey('kg_packed')) {
      context.handle(_kgPackedMeta, kgPacked.isAcceptableOrUnknown(data['kg_packed']!, _kgPackedMeta));
    }
    if (data.containsKey('last_moisture')) {
      context.handle(_lastMoistureMeta, lastMoisture.isAcceptableOrUnknown(data['last_moisture']!, _lastMoistureMeta));
    }
    if (data.containsKey('qr_payload')) {
      context.handle(_qrPayloadMeta, qrPayload.isAcceptableOrUnknown(data['qr_payload']!, _qrPayloadMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lotId};
  @override
  Lot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lot(
      lotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lot_id'])!,
      plotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plot_id'])!,
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      cropId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}crop_id'])!,
      season: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}season'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      kgHarvested: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kg_harvested'])!,
      kgPacked: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kg_packed'])!,
      lastMoisture: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}last_moisture']),
      qrPayload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}qr_payload']),
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LotsTable createAlias(String alias) {
    return $LotsTable(attachedDatabase, alias);
  }
}

class Lot extends DataClass implements Insertable<Lot> {
  /// Server lot id (UUID).
  final String lotId;

  /// Plot the lot grows on.
  final String plotId;

  /// Owner farmer id.
  final String farmerId;

  /// Crop id (e.g. Samba Vathal chilli).
  final String cropId;

  /// Season label (e.g. `2026-rabi`).
  final String season;

  /// Server lot status (`open`, `drying`, `ready_for_sale`, ...).
  final String status;

  /// Harvested quantity in kilograms.
  final double kgHarvested;

  /// Packed quantity in kilograms.
  final double kgPacked;

  /// Last moisture reading in percent (wet basis); null until measured.
  final double? lastMoisture;

  /// Payload of the lot's QR label; null until printed.
  final String? qrPayload;

  /// When the server last changed the lot.
  final DateTime updatedAt;
  const Lot({
    required this.lotId,
    required this.plotId,
    required this.farmerId,
    required this.cropId,
    required this.season,
    required this.status,
    required this.kgHarvested,
    required this.kgPacked,
    this.lastMoisture,
    this.qrPayload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lot_id'] = Variable<String>(lotId);
    map['plot_id'] = Variable<String>(plotId);
    map['farmer_id'] = Variable<String>(farmerId);
    map['crop_id'] = Variable<String>(cropId);
    map['season'] = Variable<String>(season);
    map['status'] = Variable<String>(status);
    map['kg_harvested'] = Variable<double>(kgHarvested);
    map['kg_packed'] = Variable<double>(kgPacked);
    if (!nullToAbsent || lastMoisture != null) {
      map['last_moisture'] = Variable<double>(lastMoisture);
    }
    if (!nullToAbsent || qrPayload != null) {
      map['qr_payload'] = Variable<String>(qrPayload);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LotsCompanion toCompanion(bool nullToAbsent) {
    return LotsCompanion(
      lotId: Value(lotId),
      plotId: Value(plotId),
      farmerId: Value(farmerId),
      cropId: Value(cropId),
      season: Value(season),
      status: Value(status),
      kgHarvested: Value(kgHarvested),
      kgPacked: Value(kgPacked),
      lastMoisture: lastMoisture == null && nullToAbsent ? const Value.absent() : Value(lastMoisture),
      qrPayload: qrPayload == null && nullToAbsent ? const Value.absent() : Value(qrPayload),
      updatedAt: Value(updatedAt),
    );
  }

  factory Lot.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lot(
      lotId: serializer.fromJson<String>(json['lotId']),
      plotId: serializer.fromJson<String>(json['plotId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      cropId: serializer.fromJson<String>(json['cropId']),
      season: serializer.fromJson<String>(json['season']),
      status: serializer.fromJson<String>(json['status']),
      kgHarvested: serializer.fromJson<double>(json['kgHarvested']),
      kgPacked: serializer.fromJson<double>(json['kgPacked']),
      lastMoisture: serializer.fromJson<double?>(json['lastMoisture']),
      qrPayload: serializer.fromJson<String?>(json['qrPayload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lotId': serializer.toJson<String>(lotId),
      'plotId': serializer.toJson<String>(plotId),
      'farmerId': serializer.toJson<String>(farmerId),
      'cropId': serializer.toJson<String>(cropId),
      'season': serializer.toJson<String>(season),
      'status': serializer.toJson<String>(status),
      'kgHarvested': serializer.toJson<double>(kgHarvested),
      'kgPacked': serializer.toJson<double>(kgPacked),
      'lastMoisture': serializer.toJson<double?>(lastMoisture),
      'qrPayload': serializer.toJson<String?>(qrPayload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Lot copyWith({
    String? lotId,
    String? plotId,
    String? farmerId,
    String? cropId,
    String? season,
    String? status,
    double? kgHarvested,
    double? kgPacked,
    Value<double?> lastMoisture = const Value.absent(),
    Value<String?> qrPayload = const Value.absent(),
    DateTime? updatedAt,
  }) => Lot(
    lotId: lotId ?? this.lotId,
    plotId: plotId ?? this.plotId,
    farmerId: farmerId ?? this.farmerId,
    cropId: cropId ?? this.cropId,
    season: season ?? this.season,
    status: status ?? this.status,
    kgHarvested: kgHarvested ?? this.kgHarvested,
    kgPacked: kgPacked ?? this.kgPacked,
    lastMoisture: lastMoisture.present ? lastMoisture.value : this.lastMoisture,
    qrPayload: qrPayload.present ? qrPayload.value : this.qrPayload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Lot copyWithCompanion(LotsCompanion data) {
    return Lot(
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      season: data.season.present ? data.season.value : this.season,
      status: data.status.present ? data.status.value : this.status,
      kgHarvested: data.kgHarvested.present ? data.kgHarvested.value : this.kgHarvested,
      kgPacked: data.kgPacked.present ? data.kgPacked.value : this.kgPacked,
      lastMoisture: data.lastMoisture.present ? data.lastMoisture.value : this.lastMoisture,
      qrPayload: data.qrPayload.present ? data.qrPayload.value : this.qrPayload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lot(')
          ..write('lotId: $lotId, ')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('cropId: $cropId, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('kgHarvested: $kgHarvested, ')
          ..write('kgPacked: $kgPacked, ')
          ..write('lastMoisture: $lastMoisture, ')
          ..write('qrPayload: $qrPayload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    lotId,
    plotId,
    farmerId,
    cropId,
    season,
    status,
    kgHarvested,
    kgPacked,
    lastMoisture,
    qrPayload,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lot &&
          other.lotId == this.lotId &&
          other.plotId == this.plotId &&
          other.farmerId == this.farmerId &&
          other.cropId == this.cropId &&
          other.season == this.season &&
          other.status == this.status &&
          other.kgHarvested == this.kgHarvested &&
          other.kgPacked == this.kgPacked &&
          other.lastMoisture == this.lastMoisture &&
          other.qrPayload == this.qrPayload &&
          other.updatedAt == this.updatedAt);
}

class LotsCompanion extends UpdateCompanion<Lot> {
  final Value<String> lotId;
  final Value<String> plotId;
  final Value<String> farmerId;
  final Value<String> cropId;
  final Value<String> season;
  final Value<String> status;
  final Value<double> kgHarvested;
  final Value<double> kgPacked;
  final Value<double?> lastMoisture;
  final Value<String?> qrPayload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LotsCompanion({
    this.lotId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.cropId = const Value.absent(),
    this.season = const Value.absent(),
    this.status = const Value.absent(),
    this.kgHarvested = const Value.absent(),
    this.kgPacked = const Value.absent(),
    this.lastMoisture = const Value.absent(),
    this.qrPayload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LotsCompanion.insert({
    required String lotId,
    required String plotId,
    required String farmerId,
    required String cropId,
    required String season,
    required String status,
    this.kgHarvested = const Value.absent(),
    this.kgPacked = const Value.absent(),
    this.lastMoisture = const Value.absent(),
    this.qrPayload = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : lotId = Value(lotId),
       plotId = Value(plotId),
       farmerId = Value(farmerId),
       cropId = Value(cropId),
       season = Value(season),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<Lot> custom({
    Expression<String>? lotId,
    Expression<String>? plotId,
    Expression<String>? farmerId,
    Expression<String>? cropId,
    Expression<String>? season,
    Expression<String>? status,
    Expression<double>? kgHarvested,
    Expression<double>? kgPacked,
    Expression<double>? lastMoisture,
    Expression<String>? qrPayload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lotId != null) 'lot_id': lotId,
      if (plotId != null) 'plot_id': plotId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (cropId != null) 'crop_id': cropId,
      if (season != null) 'season': season,
      if (status != null) 'status': status,
      if (kgHarvested != null) 'kg_harvested': kgHarvested,
      if (kgPacked != null) 'kg_packed': kgPacked,
      if (lastMoisture != null) 'last_moisture': lastMoisture,
      if (qrPayload != null) 'qr_payload': qrPayload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LotsCompanion copyWith({
    Value<String>? lotId,
    Value<String>? plotId,
    Value<String>? farmerId,
    Value<String>? cropId,
    Value<String>? season,
    Value<String>? status,
    Value<double>? kgHarvested,
    Value<double>? kgPacked,
    Value<double?>? lastMoisture,
    Value<String?>? qrPayload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LotsCompanion(
      lotId: lotId ?? this.lotId,
      plotId: plotId ?? this.plotId,
      farmerId: farmerId ?? this.farmerId,
      cropId: cropId ?? this.cropId,
      season: season ?? this.season,
      status: status ?? this.status,
      kgHarvested: kgHarvested ?? this.kgHarvested,
      kgPacked: kgPacked ?? this.kgPacked,
      lastMoisture: lastMoisture ?? this.lastMoisture,
      qrPayload: qrPayload ?? this.qrPayload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (kgHarvested.present) {
      map['kg_harvested'] = Variable<double>(kgHarvested.value);
    }
    if (kgPacked.present) {
      map['kg_packed'] = Variable<double>(kgPacked.value);
    }
    if (lastMoisture.present) {
      map['last_moisture'] = Variable<double>(lastMoisture.value);
    }
    if (qrPayload.present) {
      map['qr_payload'] = Variable<String>(qrPayload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotsCompanion(')
          ..write('lotId: $lotId, ')
          ..write('plotId: $plotId, ')
          ..write('farmerId: $farmerId, ')
          ..write('cropId: $cropId, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('kgHarvested: $kgHarvested, ')
          ..write('kgPacked: $kgPacked, ')
          ..write('lastMoisture: $lastMoisture, ')
          ..write('qrPayload: $qrPayload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxKind, String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<OutboxKind>($OutboxTable.$converterkind);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
    'ref_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt = GeneratedColumn<DateTime>(
    'next_attempt_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OutboxStatus, String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('waiting'),
  ).withConverter<OutboxStatus>($OutboxTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    kind,
    refId,
    ownerUserId,
    idempotencyKey,
    priority,
    attempts,
    nextAttemptAt,
    lastError,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxItem> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(_refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    } else if (isInserting) {
      context.missing(_refIdMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(_ownerUserIdMeta, ownerUserId.isAcceptableOrUnknown(data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(data['idempotency_key']!, _idempotencyKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta, priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta, attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(data['next_attempt_at']!, _nextAttemptAtMeta),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta, lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItem(
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      kind: $OutboxTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      ),
      refId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}ref_id'])!,
      ownerUserId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}owner_user_id'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      priority: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      attempts: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      status: $OutboxTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OutboxKind, String, String> $converterkind = const EnumNameConverter<OutboxKind>(
    OutboxKind.values,
  );
  static JsonTypeConverter2<OutboxStatus, String, String> $converterstatus = const EnumNameConverter<OutboxStatus>(
    OutboxStatus.values,
  );
}

class OutboxItem extends DataClass implements Insertable<OutboxItem> {
  /// Queue position; autoincrement, so a lower number was enqueued earlier.
  final int seq;

  /// Whether [refId] is an entry or a media file.
  final OutboxKind kind;

  /// `Entries.entryId` or `Media.mediaId` of the row to send.
  final String refId;

  /// User who created the row: the entry's `enteredByUserId` (for media, its entry's). Schema v2.
  ///
  /// DECISION D-029: the outbox is per user on a shared phone; sync sends and counts only the signed-in user's rows.
  ///   ADV: sign-out keeps unsent rows without letting the next user's token send them; a simple filter to test.
  ///   COMPROMISE: rows of a user who never signs in again stay (counted as stranded for the officer, M10).
  final String ownerUserId;

  /// Idempotency key sent with the request; the client UUID of the entry or media (D-005).
  final String idempotencyKey;

  /// 0 for entries, 1 for media: small facts go first (Arch §Offline-first "Small first, photos second").
  final int priority;

  /// Number of send attempts so far.
  final int attempts;

  /// Earliest time of the next attempt while waiting; the attempt start time while sending.
  final DateTime nextAttemptAt;

  /// Last error code or message; null after a clean send.
  final String? lastError;

  /// Life-cycle state.
  final OutboxStatus status;

  /// When the row was enqueued.
  final DateTime createdAt;
  const OutboxItem({
    required this.seq,
    required this.kind,
    required this.refId,
    required this.ownerUserId,
    required this.idempotencyKey,
    required this.priority,
    required this.attempts,
    required this.nextAttemptAt,
    this.lastError,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    {
      map['kind'] = Variable<String>($OutboxTable.$converterkind.toSql(kind));
    }
    map['ref_id'] = Variable<String>(refId);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['priority'] = Variable<int>(priority);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    {
      map['status'] = Variable<String>($OutboxTable.$converterstatus.toSql(status));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      kind: Value(kind),
      refId: Value(refId),
      ownerUserId: Value(ownerUserId),
      idempotencyKey: Value(idempotencyKey),
      priority: Value(priority),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      lastError: lastError == null && nullToAbsent ? const Value.absent() : Value(lastError),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxItem.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItem(
      seq: serializer.fromJson<int>(json['seq']),
      kind: $OutboxTable.$converterkind.fromJson(serializer.fromJson<String>(json['kind'])),
      refId: serializer.fromJson<String>(json['refId']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      priority: serializer.fromJson<int>(json['priority']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      status: $OutboxTable.$converterstatus.fromJson(serializer.fromJson<String>(json['status'])),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'kind': serializer.toJson<String>($OutboxTable.$converterkind.toJson(kind)),
      'refId': serializer.toJson<String>(refId),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'priority': serializer.toJson<int>(priority),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'status': serializer.toJson<String>($OutboxTable.$converterstatus.toJson(status)),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxItem copyWith({
    int? seq,
    OutboxKind? kind,
    String? refId,
    String? ownerUserId,
    String? idempotencyKey,
    int? priority,
    int? attempts,
    DateTime? nextAttemptAt,
    Value<String?> lastError = const Value.absent(),
    OutboxStatus? status,
    DateTime? createdAt,
  }) => OutboxItem(
    seq: seq ?? this.seq,
    kind: kind ?? this.kind,
    refId: refId ?? this.refId,
    ownerUserId: ownerUserId ?? this.ownerUserId,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    priority: priority ?? this.priority,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxItem copyWithCompanion(OutboxCompanion data) {
    return OutboxItem(
      seq: data.seq.present ? data.seq.value : this.seq,
      kind: data.kind.present ? data.kind.value : this.kind,
      refId: data.refId.present ? data.refId.value : this.refId,
      ownerUserId: data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      idempotencyKey: data.idempotencyKey.present ? data.idempotencyKey.value : this.idempotencyKey,
      priority: data.priority.present ? data.priority.value : this.priority,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present ? data.nextAttemptAt.value : this.nextAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItem(')
          ..write('seq: $seq, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    kind,
    refId,
    ownerUserId,
    idempotencyKey,
    priority,
    attempts,
    nextAttemptAt,
    lastError,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItem &&
          other.seq == this.seq &&
          other.kind == this.kind &&
          other.refId == this.refId &&
          other.ownerUserId == this.ownerUserId &&
          other.idempotencyKey == this.idempotencyKey &&
          other.priority == this.priority &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastError == this.lastError &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxItem> {
  final Value<int> seq;
  final Value<OutboxKind> kind;
  final Value<String> refId;
  final Value<String> ownerUserId;
  final Value<String> idempotencyKey;
  final Value<int> priority;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<String?> lastError;
  final Value<OutboxStatus> status;
  final Value<DateTime> createdAt;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.kind = const Value.absent(),
    this.refId = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required OutboxKind kind,
    required String refId,
    required String ownerUserId,
    required String idempotencyKey,
    required int priority,
    this.attempts = const Value.absent(),
    required DateTime nextAttemptAt,
    this.lastError = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
  }) : kind = Value(kind),
       refId = Value(refId),
       ownerUserId = Value(ownerUserId),
       idempotencyKey = Value(idempotencyKey),
       priority = Value(priority),
       nextAttemptAt = Value(nextAttemptAt),
       createdAt = Value(createdAt);
  static Insertable<OutboxItem> custom({
    Expression<int>? seq,
    Expression<String>? kind,
    Expression<String>? refId,
    Expression<String>? ownerUserId,
    Expression<String>? idempotencyKey,
    Expression<int>? priority,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastError,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (kind != null) 'kind': kind,
      if (refId != null) 'ref_id': refId,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (priority != null) 'priority': priority,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<OutboxKind>? kind,
    Value<String>? refId,
    Value<String>? ownerUserId,
    Value<String>? idempotencyKey,
    Value<int>? priority,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<String?>? lastError,
    Value<OutboxStatus>? status,
    Value<DateTime>? createdAt,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      kind: kind ?? this.kind,
      refId: refId ?? this.refId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      priority: priority ?? this.priority,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastError: lastError ?? this.lastError,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>($OutboxTable.$converterkind.toSql(kind.value));
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (status.present) {
      map['status'] = Variable<String>($OutboxTable.$converterstatus.toSql(status.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('kind: $kind, ')
          ..write('refId: $refId, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RefBundlesTable extends RefBundles with TableInfo<$RefBundlesTable, RefBundle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefBundlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bundleTypeMeta = const VerificationMeta('bundleType');
  @override
  late final GeneratedColumn<String> bundleType = GeneratedColumn<String>(
    'bundle_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyJsonMeta = const VerificationMeta('bodyJson');
  @override
  late final GeneratedColumn<String> bodyJson = GeneratedColumn<String>(
    'body_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetDirMeta = const VerificationMeta('assetDir');
  @override
  late final GeneratedColumn<String> assetDir = GeneratedColumn<String>(
    'asset_dir',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [bundleType, version, etag, fetchedAt, bodyJson, assetDir];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ref_bundles';
  @override
  VerificationContext validateIntegrity(Insertable<RefBundle> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bundle_type')) {
      context.handle(_bundleTypeMeta, bundleType.isAcceptableOrUnknown(data['bundle_type']!, _bundleTypeMeta));
    } else if (isInserting) {
      context.missing(_bundleTypeMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta, version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(_etagMeta, etag.isAcceptableOrUnknown(data['etag']!, _etagMeta));
    } else if (isInserting) {
      context.missing(_etagMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta, fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('body_json')) {
      context.handle(_bodyJsonMeta, bodyJson.isAcceptableOrUnknown(data['body_json']!, _bodyJsonMeta));
    } else if (isInserting) {
      context.missing(_bodyJsonMeta);
    }
    if (data.containsKey('asset_dir')) {
      context.handle(_assetDirMeta, assetDir.isAcceptableOrUnknown(data['asset_dir']!, _assetDirMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bundleType};
  @override
  RefBundle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefBundle(
      bundleType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bundle_type'])!,
      version: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      etag: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}etag'])!,
      fetchedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      bodyJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body_json'])!,
      assetDir: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}asset_dir']),
    );
  }

  @override
  $RefBundlesTable createAlias(String alias) {
    return $RefBundlesTable(attachedDatabase, alias);
  }
}

class RefBundle extends DataClass implements Insertable<RefBundle> {
  /// Bundle part name (`crops`, `standards`, `gi_region`, `fields`, ...).
  final String bundleType;

  /// Server version of the part; `GET /v1/sync/reference?since=` compares against it.
  final int version;

  /// HTTP ETag of the part, sent back as `If-None-Match`.
  final String etag;

  /// When the part was last downloaded.
  final DateTime fetchedAt;

  /// The part's JSON body.
  final String bodyJson;

  /// Directory of unpacked assets (images, voice clips); null for JSON-only parts.
  final String? assetDir;
  const RefBundle({
    required this.bundleType,
    required this.version,
    required this.etag,
    required this.fetchedAt,
    required this.bodyJson,
    this.assetDir,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bundle_type'] = Variable<String>(bundleType);
    map['version'] = Variable<int>(version);
    map['etag'] = Variable<String>(etag);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['body_json'] = Variable<String>(bodyJson);
    if (!nullToAbsent || assetDir != null) {
      map['asset_dir'] = Variable<String>(assetDir);
    }
    return map;
  }

  RefBundlesCompanion toCompanion(bool nullToAbsent) {
    return RefBundlesCompanion(
      bundleType: Value(bundleType),
      version: Value(version),
      etag: Value(etag),
      fetchedAt: Value(fetchedAt),
      bodyJson: Value(bodyJson),
      assetDir: assetDir == null && nullToAbsent ? const Value.absent() : Value(assetDir),
    );
  }

  factory RefBundle.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefBundle(
      bundleType: serializer.fromJson<String>(json['bundleType']),
      version: serializer.fromJson<int>(json['version']),
      etag: serializer.fromJson<String>(json['etag']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      bodyJson: serializer.fromJson<String>(json['bodyJson']),
      assetDir: serializer.fromJson<String?>(json['assetDir']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bundleType': serializer.toJson<String>(bundleType),
      'version': serializer.toJson<int>(version),
      'etag': serializer.toJson<String>(etag),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'bodyJson': serializer.toJson<String>(bodyJson),
      'assetDir': serializer.toJson<String?>(assetDir),
    };
  }

  RefBundle copyWith({
    String? bundleType,
    int? version,
    String? etag,
    DateTime? fetchedAt,
    String? bodyJson,
    Value<String?> assetDir = const Value.absent(),
  }) => RefBundle(
    bundleType: bundleType ?? this.bundleType,
    version: version ?? this.version,
    etag: etag ?? this.etag,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    bodyJson: bodyJson ?? this.bodyJson,
    assetDir: assetDir.present ? assetDir.value : this.assetDir,
  );
  RefBundle copyWithCompanion(RefBundlesCompanion data) {
    return RefBundle(
      bundleType: data.bundleType.present ? data.bundleType.value : this.bundleType,
      version: data.version.present ? data.version.value : this.version,
      etag: data.etag.present ? data.etag.value : this.etag,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      assetDir: data.assetDir.present ? data.assetDir.value : this.assetDir,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefBundle(')
          ..write('bundleType: $bundleType, ')
          ..write('version: $version, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('assetDir: $assetDir')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bundleType, version, etag, fetchedAt, bodyJson, assetDir);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefBundle &&
          other.bundleType == this.bundleType &&
          other.version == this.version &&
          other.etag == this.etag &&
          other.fetchedAt == this.fetchedAt &&
          other.bodyJson == this.bodyJson &&
          other.assetDir == this.assetDir);
}

class RefBundlesCompanion extends UpdateCompanion<RefBundle> {
  final Value<String> bundleType;
  final Value<int> version;
  final Value<String> etag;
  final Value<DateTime> fetchedAt;
  final Value<String> bodyJson;
  final Value<String?> assetDir;
  final Value<int> rowid;
  const RefBundlesCompanion({
    this.bundleType = const Value.absent(),
    this.version = const Value.absent(),
    this.etag = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.assetDir = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefBundlesCompanion.insert({
    required String bundleType,
    required int version,
    required String etag,
    required DateTime fetchedAt,
    required String bodyJson,
    this.assetDir = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bundleType = Value(bundleType),
       version = Value(version),
       etag = Value(etag),
       fetchedAt = Value(fetchedAt),
       bodyJson = Value(bodyJson);
  static Insertable<RefBundle> custom({
    Expression<String>? bundleType,
    Expression<int>? version,
    Expression<String>? etag,
    Expression<DateTime>? fetchedAt,
    Expression<String>? bodyJson,
    Expression<String>? assetDir,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bundleType != null) 'bundle_type': bundleType,
      if (version != null) 'version': version,
      if (etag != null) 'etag': etag,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (bodyJson != null) 'body_json': bodyJson,
      if (assetDir != null) 'asset_dir': assetDir,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefBundlesCompanion copyWith({
    Value<String>? bundleType,
    Value<int>? version,
    Value<String>? etag,
    Value<DateTime>? fetchedAt,
    Value<String>? bodyJson,
    Value<String?>? assetDir,
    Value<int>? rowid,
  }) {
    return RefBundlesCompanion(
      bundleType: bundleType ?? this.bundleType,
      version: version ?? this.version,
      etag: etag ?? this.etag,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      bodyJson: bodyJson ?? this.bodyJson,
      assetDir: assetDir ?? this.assetDir,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bundleType.present) {
      map['bundle_type'] = Variable<String>(bundleType.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(bodyJson.value);
    }
    if (assetDir.present) {
      map['asset_dir'] = Variable<String>(assetDir.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefBundlesCompanion(')
          ..write('bundleType: $bundleType, ')
          ..write('version: $version, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('assetDir: $assetDir, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState with TableInfo<$SyncStateTable, SyncStateEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncStateEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateEntry(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateEntry extends DataClass implements Insertable<SyncStateEntry> {
  /// Key name.
  final String key;

  /// Value as text (numbers and times serialised by the caller).
  final String value;
  const SyncStateEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(key: Value(key), value: Value(value));
  }

  factory SyncStateEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SyncStateEntry copyWith({String? key, String? value}) =>
      SyncStateEntry(key: key ?? this.key, value: value ?? this.value);
  SyncStateEntry copyWithCompanion(SyncStateCompanion data) {
    return SyncStateEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SyncStateEntry && other.key == this.key && other.value == this.value);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SyncStateEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SyncStateCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetricsTable extends SyncMetrics with TableInfo<$SyncMetricsTable, SyncMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ackedAtMeta = const VerificationMeta('ackedAt');
  @override
  late final GeneratedColumn<DateTime> ackedAt = GeneratedColumn<DateTime>(
    'acked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUploadMsMeta = const VerificationMeta('photoUploadMs');
  @override
  late final GeneratedColumn<int> photoUploadMs = GeneratedColumn<int>(
    'photo_upload_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failuresMeta = const VerificationMeta('failures');
  @override
  late final GeneratedColumn<int> failures = GeneratedColumn<int>(
    'failures',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _networkTypeMeta = const VerificationMeta('networkType');
  @override
  late final GeneratedColumn<String> networkType = GeneratedColumn<String>(
    'network_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shippedMeta = const VerificationMeta('shipped');
  @override
  late final GeneratedColumn<bool> shipped = GeneratedColumn<bool>(
    'shipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("shipped" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, savedAt, ackedAt, photoUploadMs, failures, networkType, shipped];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metrics';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetric> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta, entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta, savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('acked_at')) {
      context.handle(_ackedAtMeta, ackedAt.isAcceptableOrUnknown(data['acked_at']!, _ackedAtMeta));
    }
    if (data.containsKey('photo_upload_ms')) {
      context.handle(
        _photoUploadMsMeta,
        photoUploadMs.isAcceptableOrUnknown(data['photo_upload_ms']!, _photoUploadMsMeta),
      );
    }
    if (data.containsKey('failures')) {
      context.handle(_failuresMeta, failures.isAcceptableOrUnknown(data['failures']!, _failuresMeta));
    }
    if (data.containsKey('network_type')) {
      context.handle(_networkTypeMeta, networkType.isAcceptableOrUnknown(data['network_type']!, _networkTypeMeta));
    } else if (isInserting) {
      context.missing(_networkTypeMeta);
    }
    if (data.containsKey('shipped')) {
      context.handle(_shippedMeta, shipped.isAcceptableOrUnknown(data['shipped']!, _shippedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetric(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entryId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      savedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!,
      ackedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}acked_at']),
      photoUploadMs: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}photo_upload_ms']),
      failures: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}failures'])!,
      networkType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}network_type'])!,
      shipped: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}shipped'])!,
    );
  }

  @override
  $SyncMetricsTable createAlias(String alias) {
    return $SyncMetricsTable(attachedDatabase, alias);
  }
}

class SyncMetric extends DataClass implements Insertable<SyncMetric> {
  /// Local row id.
  final int id;

  /// Entry the metric is about.
  final String entryId;

  /// When the entry was saved on the phone.
  final DateTime savedAt;

  /// When the server acknowledged it; null until then.
  final DateTime? ackedAt;

  /// Total photo upload time in milliseconds; null without photos or before upload.
  final int? photoUploadMs;

  /// Failed send attempts before success.
  final int failures;

  /// Network type at send (`wifi`, `lte`, `3g`, `2g`, `none`).
  final String networkType;

  /// True once the metric was included in an accepted push.
  final bool shipped;
  const SyncMetric({
    required this.id,
    required this.entryId,
    required this.savedAt,
    this.ackedAt,
    this.photoUploadMs,
    required this.failures,
    required this.networkType,
    required this.shipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<String>(entryId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    if (!nullToAbsent || ackedAt != null) {
      map['acked_at'] = Variable<DateTime>(ackedAt);
    }
    if (!nullToAbsent || photoUploadMs != null) {
      map['photo_upload_ms'] = Variable<int>(photoUploadMs);
    }
    map['failures'] = Variable<int>(failures);
    map['network_type'] = Variable<String>(networkType);
    map['shipped'] = Variable<bool>(shipped);
    return map;
  }

  SyncMetricsCompanion toCompanion(bool nullToAbsent) {
    return SyncMetricsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      savedAt: Value(savedAt),
      ackedAt: ackedAt == null && nullToAbsent ? const Value.absent() : Value(ackedAt),
      photoUploadMs: photoUploadMs == null && nullToAbsent ? const Value.absent() : Value(photoUploadMs),
      failures: Value(failures),
      networkType: Value(networkType),
      shipped: Value(shipped),
    );
  }

  factory SyncMetric.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetric(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<String>(json['entryId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      ackedAt: serializer.fromJson<DateTime?>(json['ackedAt']),
      photoUploadMs: serializer.fromJson<int?>(json['photoUploadMs']),
      failures: serializer.fromJson<int>(json['failures']),
      networkType: serializer.fromJson<String>(json['networkType']),
      shipped: serializer.fromJson<bool>(json['shipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<String>(entryId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'ackedAt': serializer.toJson<DateTime?>(ackedAt),
      'photoUploadMs': serializer.toJson<int?>(photoUploadMs),
      'failures': serializer.toJson<int>(failures),
      'networkType': serializer.toJson<String>(networkType),
      'shipped': serializer.toJson<bool>(shipped),
    };
  }

  SyncMetric copyWith({
    int? id,
    String? entryId,
    DateTime? savedAt,
    Value<DateTime?> ackedAt = const Value.absent(),
    Value<int?> photoUploadMs = const Value.absent(),
    int? failures,
    String? networkType,
    bool? shipped,
  }) => SyncMetric(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    savedAt: savedAt ?? this.savedAt,
    ackedAt: ackedAt.present ? ackedAt.value : this.ackedAt,
    photoUploadMs: photoUploadMs.present ? photoUploadMs.value : this.photoUploadMs,
    failures: failures ?? this.failures,
    networkType: networkType ?? this.networkType,
    shipped: shipped ?? this.shipped,
  );
  SyncMetric copyWithCompanion(SyncMetricsCompanion data) {
    return SyncMetric(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      ackedAt: data.ackedAt.present ? data.ackedAt.value : this.ackedAt,
      photoUploadMs: data.photoUploadMs.present ? data.photoUploadMs.value : this.photoUploadMs,
      failures: data.failures.present ? data.failures.value : this.failures,
      networkType: data.networkType.present ? data.networkType.value : this.networkType,
      shipped: data.shipped.present ? data.shipped.value : this.shipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetric(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('savedAt: $savedAt, ')
          ..write('ackedAt: $ackedAt, ')
          ..write('photoUploadMs: $photoUploadMs, ')
          ..write('failures: $failures, ')
          ..write('networkType: $networkType, ')
          ..write('shipped: $shipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entryId, savedAt, ackedAt, photoUploadMs, failures, networkType, shipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetric &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.savedAt == this.savedAt &&
          other.ackedAt == this.ackedAt &&
          other.photoUploadMs == this.photoUploadMs &&
          other.failures == this.failures &&
          other.networkType == this.networkType &&
          other.shipped == this.shipped);
}

class SyncMetricsCompanion extends UpdateCompanion<SyncMetric> {
  final Value<int> id;
  final Value<String> entryId;
  final Value<DateTime> savedAt;
  final Value<DateTime?> ackedAt;
  final Value<int?> photoUploadMs;
  final Value<int> failures;
  final Value<String> networkType;
  final Value<bool> shipped;
  const SyncMetricsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.ackedAt = const Value.absent(),
    this.photoUploadMs = const Value.absent(),
    this.failures = const Value.absent(),
    this.networkType = const Value.absent(),
    this.shipped = const Value.absent(),
  });
  SyncMetricsCompanion.insert({
    this.id = const Value.absent(),
    required String entryId,
    required DateTime savedAt,
    this.ackedAt = const Value.absent(),
    this.photoUploadMs = const Value.absent(),
    this.failures = const Value.absent(),
    required String networkType,
    this.shipped = const Value.absent(),
  }) : entryId = Value(entryId),
       savedAt = Value(savedAt),
       networkType = Value(networkType);
  static Insertable<SyncMetric> custom({
    Expression<int>? id,
    Expression<String>? entryId,
    Expression<DateTime>? savedAt,
    Expression<DateTime>? ackedAt,
    Expression<int>? photoUploadMs,
    Expression<int>? failures,
    Expression<String>? networkType,
    Expression<bool>? shipped,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (savedAt != null) 'saved_at': savedAt,
      if (ackedAt != null) 'acked_at': ackedAt,
      if (photoUploadMs != null) 'photo_upload_ms': photoUploadMs,
      if (failures != null) 'failures': failures,
      if (networkType != null) 'network_type': networkType,
      if (shipped != null) 'shipped': shipped,
    });
  }

  SyncMetricsCompanion copyWith({
    Value<int>? id,
    Value<String>? entryId,
    Value<DateTime>? savedAt,
    Value<DateTime?>? ackedAt,
    Value<int?>? photoUploadMs,
    Value<int>? failures,
    Value<String>? networkType,
    Value<bool>? shipped,
  }) {
    return SyncMetricsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      savedAt: savedAt ?? this.savedAt,
      ackedAt: ackedAt ?? this.ackedAt,
      photoUploadMs: photoUploadMs ?? this.photoUploadMs,
      failures: failures ?? this.failures,
      networkType: networkType ?? this.networkType,
      shipped: shipped ?? this.shipped,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (ackedAt.present) {
      map['acked_at'] = Variable<DateTime>(ackedAt.value);
    }
    if (photoUploadMs.present) {
      map['photo_upload_ms'] = Variable<int>(photoUploadMs.value);
    }
    if (failures.present) {
      map['failures'] = Variable<int>(failures.value);
    }
    if (networkType.present) {
      map['network_type'] = Variable<String>(networkType.value);
    }
    if (shipped.present) {
      map['shipped'] = Variable<bool>(shipped.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetricsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('savedAt: $savedAt, ')
          ..write('ackedAt: $ackedAt, ')
          ..write('photoUploadMs: $photoUploadMs, ')
          ..write('failures: $failures, ')
          ..write('networkType: $networkType, ')
          ..write('shipped: $shipped')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, FarmTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<String> lotId = GeneratedColumn<String>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta('promptId');
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("done" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, farmerId, lotId, eventType, dueDate, promptId, source, done];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<FarmTask> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(_lotIdMeta, lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta, eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(_promptIdMeta, promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta));
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('done')) {
      context.handle(_doneMeta, done.isAcceptableOrUnknown(data['done']!, _doneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  FarmTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmTask(
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}task_id'])!,
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      lotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lot_id']),
      eventType: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      dueDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      promptId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}prompt_id'])!,
      source: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      done: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}done'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class FarmTask extends DataClass implements Insertable<FarmTask> {
  /// Task id (UUID).
  final String taskId;

  /// Farmer the task is for.
  final String farmerId;

  /// Lot the task is about; null for farmer-level tasks.
  final String? lotId;

  /// Event type to log (`harvest`, `drying`, ...).
  final String eventType;

  /// Day the task is due.
  final DateTime dueDate;

  /// Voice prompt id played with the task (D-016).
  final String promptId;

  /// Where the task came from (`schedule`, `officer`, ...).
  final String source;

  /// True once the farmer logged the event.
  final bool done;
  const FarmTask({
    required this.taskId,
    required this.farmerId,
    this.lotId,
    required this.eventType,
    required this.dueDate,
    required this.promptId,
    required this.source,
    required this.done,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['farmer_id'] = Variable<String>(farmerId);
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<String>(lotId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['prompt_id'] = Variable<String>(promptId);
    map['source'] = Variable<String>(source);
    map['done'] = Variable<bool>(done);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      taskId: Value(taskId),
      farmerId: Value(farmerId),
      lotId: lotId == null && nullToAbsent ? const Value.absent() : Value(lotId),
      eventType: Value(eventType),
      dueDate: Value(dueDate),
      promptId: Value(promptId),
      source: Value(source),
      done: Value(done),
    );
  }

  factory FarmTask.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmTask(
      taskId: serializer.fromJson<String>(json['taskId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      lotId: serializer.fromJson<String?>(json['lotId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      promptId: serializer.fromJson<String>(json['promptId']),
      source: serializer.fromJson<String>(json['source']),
      done: serializer.fromJson<bool>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'farmerId': serializer.toJson<String>(farmerId),
      'lotId': serializer.toJson<String?>(lotId),
      'eventType': serializer.toJson<String>(eventType),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'promptId': serializer.toJson<String>(promptId),
      'source': serializer.toJson<String>(source),
      'done': serializer.toJson<bool>(done),
    };
  }

  FarmTask copyWith({
    String? taskId,
    String? farmerId,
    Value<String?> lotId = const Value.absent(),
    String? eventType,
    DateTime? dueDate,
    String? promptId,
    String? source,
    bool? done,
  }) => FarmTask(
    taskId: taskId ?? this.taskId,
    farmerId: farmerId ?? this.farmerId,
    lotId: lotId.present ? lotId.value : this.lotId,
    eventType: eventType ?? this.eventType,
    dueDate: dueDate ?? this.dueDate,
    promptId: promptId ?? this.promptId,
    source: source ?? this.source,
    done: done ?? this.done,
  );
  FarmTask copyWithCompanion(TasksCompanion data) {
    return FarmTask(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      source: data.source.present ? data.source.value : this.source,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmTask(')
          ..write('taskId: $taskId, ')
          ..write('farmerId: $farmerId, ')
          ..write('lotId: $lotId, ')
          ..write('eventType: $eventType, ')
          ..write('dueDate: $dueDate, ')
          ..write('promptId: $promptId, ')
          ..write('source: $source, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, farmerId, lotId, eventType, dueDate, promptId, source, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmTask &&
          other.taskId == this.taskId &&
          other.farmerId == this.farmerId &&
          other.lotId == this.lotId &&
          other.eventType == this.eventType &&
          other.dueDate == this.dueDate &&
          other.promptId == this.promptId &&
          other.source == this.source &&
          other.done == this.done);
}

class TasksCompanion extends UpdateCompanion<FarmTask> {
  final Value<String> taskId;
  final Value<String> farmerId;
  final Value<String?> lotId;
  final Value<String> eventType;
  final Value<DateTime> dueDate;
  final Value<String> promptId;
  final Value<String> source;
  final Value<bool> done;
  final Value<int> rowid;
  const TasksCompanion({
    this.taskId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.promptId = const Value.absent(),
    this.source = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String taskId,
    required String farmerId,
    this.lotId = const Value.absent(),
    required String eventType,
    required DateTime dueDate,
    required String promptId,
    required String source,
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       farmerId = Value(farmerId),
       eventType = Value(eventType),
       dueDate = Value(dueDate),
       promptId = Value(promptId),
       source = Value(source);
  static Insertable<FarmTask> custom({
    Expression<String>? taskId,
    Expression<String>? farmerId,
    Expression<String>? lotId,
    Expression<String>? eventType,
    Expression<DateTime>? dueDate,
    Expression<String>? promptId,
    Expression<String>? source,
    Expression<bool>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (lotId != null) 'lot_id': lotId,
      if (eventType != null) 'event_type': eventType,
      if (dueDate != null) 'due_date': dueDate,
      if (promptId != null) 'prompt_id': promptId,
      if (source != null) 'source': source,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? taskId,
    Value<String>? farmerId,
    Value<String?>? lotId,
    Value<String>? eventType,
    Value<DateTime>? dueDate,
    Value<String>? promptId,
    Value<String>? source,
    Value<bool>? done,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      taskId: taskId ?? this.taskId,
      farmerId: farmerId ?? this.farmerId,
      lotId: lotId ?? this.lotId,
      eventType: eventType ?? this.eventType,
      dueDate: dueDate ?? this.dueDate,
      promptId: promptId ?? this.promptId,
      source: source ?? this.source,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<String>(lotId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('taskId: $taskId, ')
          ..write('farmerId: $farmerId, ')
          ..write('lotId: $lotId, ')
          ..write('eventType: $eventType, ')
          ..write('dueDate: $dueDate, ')
          ..write('promptId: $promptId, ')
          ..write('source: $source, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlagsTable extends Flags with TableInfo<$FlagsTable, Flag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flagIdMeta = const VerificationMeta('flagId');
  @override
  late final GeneratedColumn<String> flagId = GeneratedColumn<String>(
    'flag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farmerIdMeta = const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
    'farmer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plotIdMeta = const VerificationMeta('plotId');
  @override
  late final GeneratedColumn<String> plotId = GeneratedColumn<String>(
    'plot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailJsonMeta = const VerificationMeta('detailJson');
  @override
  late final GeneratedColumn<String> detailJson = GeneratedColumn<String>(
    'detail_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedReasonMeta = const VerificationMeta('resolvedReason');
  @override
  late final GeneratedColumn<String> resolvedReason = GeneratedColumn<String>(
    'resolved_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    flagId,
    farmerId,
    entryId,
    plotId,
    type,
    severity,
    status,
    detailJson,
    resolvedReason,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flags';
  @override
  VerificationContext validateIntegrity(Insertable<Flag> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flag_id')) {
      context.handle(_flagIdMeta, flagId.isAcceptableOrUnknown(data['flag_id']!, _flagIdMeta));
    } else if (isInserting) {
      context.missing(_flagIdMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta, farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta, entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    }
    if (data.containsKey('plot_id')) {
      context.handle(_plotIdMeta, plotId.isAcceptableOrUnknown(data['plot_id']!, _plotIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta, severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('detail_json')) {
      context.handle(_detailJsonMeta, detailJson.isAcceptableOrUnknown(data['detail_json']!, _detailJsonMeta));
    } else if (isInserting) {
      context.missing(_detailJsonMeta);
    }
    if (data.containsKey('resolved_reason')) {
      context.handle(
        _resolvedReasonMeta,
        resolvedReason.isAcceptableOrUnknown(data['resolved_reason']!, _resolvedReasonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flagId};
  @override
  Flag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flag(
      flagId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}flag_id'])!,
      farmerId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      entryId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entry_id']),
      plotId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}plot_id']),
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      severity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      status: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      detailJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}detail_json'])!,
      resolvedReason: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}resolved_reason']),
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FlagsTable createAlias(String alias) {
    return $FlagsTable(attachedDatabase, alias);
  }
}

class Flag extends DataClass implements Insertable<Flag> {
  /// Server flag id (UUID).
  final String flagId;

  /// Farmer the flag concerns.
  final String farmerId;

  /// Entry that raised it; null for plot- or lot-level flags.
  final String? entryId;

  /// Plot that raised it; null when not plot-related.
  final String? plotId;

  /// Rule code (`gi_region_outside`, `yield_over_ceiling`, ...).
  final String type;

  /// Severity: `info`, `warn` or `hold`.
  final String severity;

  /// Status: `open`, `cleared`, `fixed` or `escalated`.
  final String status;

  /// Rule details as JSON (measured value, limit, units).
  final String detailJson;

  /// Resolution reason code; null while open.
  final String? resolvedReason;

  /// When the server last changed the flag.
  final DateTime updatedAt;
  const Flag({
    required this.flagId,
    required this.farmerId,
    this.entryId,
    this.plotId,
    required this.type,
    required this.severity,
    required this.status,
    required this.detailJson,
    this.resolvedReason,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flag_id'] = Variable<String>(flagId);
    map['farmer_id'] = Variable<String>(farmerId);
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    if (!nullToAbsent || plotId != null) {
      map['plot_id'] = Variable<String>(plotId);
    }
    map['type'] = Variable<String>(type);
    map['severity'] = Variable<String>(severity);
    map['status'] = Variable<String>(status);
    map['detail_json'] = Variable<String>(detailJson);
    if (!nullToAbsent || resolvedReason != null) {
      map['resolved_reason'] = Variable<String>(resolvedReason);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FlagsCompanion toCompanion(bool nullToAbsent) {
    return FlagsCompanion(
      flagId: Value(flagId),
      farmerId: Value(farmerId),
      entryId: entryId == null && nullToAbsent ? const Value.absent() : Value(entryId),
      plotId: plotId == null && nullToAbsent ? const Value.absent() : Value(plotId),
      type: Value(type),
      severity: Value(severity),
      status: Value(status),
      detailJson: Value(detailJson),
      resolvedReason: resolvedReason == null && nullToAbsent ? const Value.absent() : Value(resolvedReason),
      updatedAt: Value(updatedAt),
    );
  }

  factory Flag.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flag(
      flagId: serializer.fromJson<String>(json['flagId']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      plotId: serializer.fromJson<String?>(json['plotId']),
      type: serializer.fromJson<String>(json['type']),
      severity: serializer.fromJson<String>(json['severity']),
      status: serializer.fromJson<String>(json['status']),
      detailJson: serializer.fromJson<String>(json['detailJson']),
      resolvedReason: serializer.fromJson<String?>(json['resolvedReason']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flagId': serializer.toJson<String>(flagId),
      'farmerId': serializer.toJson<String>(farmerId),
      'entryId': serializer.toJson<String?>(entryId),
      'plotId': serializer.toJson<String?>(plotId),
      'type': serializer.toJson<String>(type),
      'severity': serializer.toJson<String>(severity),
      'status': serializer.toJson<String>(status),
      'detailJson': serializer.toJson<String>(detailJson),
      'resolvedReason': serializer.toJson<String?>(resolvedReason),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Flag copyWith({
    String? flagId,
    String? farmerId,
    Value<String?> entryId = const Value.absent(),
    Value<String?> plotId = const Value.absent(),
    String? type,
    String? severity,
    String? status,
    String? detailJson,
    Value<String?> resolvedReason = const Value.absent(),
    DateTime? updatedAt,
  }) => Flag(
    flagId: flagId ?? this.flagId,
    farmerId: farmerId ?? this.farmerId,
    entryId: entryId.present ? entryId.value : this.entryId,
    plotId: plotId.present ? plotId.value : this.plotId,
    type: type ?? this.type,
    severity: severity ?? this.severity,
    status: status ?? this.status,
    detailJson: detailJson ?? this.detailJson,
    resolvedReason: resolvedReason.present ? resolvedReason.value : this.resolvedReason,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Flag copyWithCompanion(FlagsCompanion data) {
    return Flag(
      flagId: data.flagId.present ? data.flagId.value : this.flagId,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      plotId: data.plotId.present ? data.plotId.value : this.plotId,
      type: data.type.present ? data.type.value : this.type,
      severity: data.severity.present ? data.severity.value : this.severity,
      status: data.status.present ? data.status.value : this.status,
      detailJson: data.detailJson.present ? data.detailJson.value : this.detailJson,
      resolvedReason: data.resolvedReason.present ? data.resolvedReason.value : this.resolvedReason,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flag(')
          ..write('flagId: $flagId, ')
          ..write('farmerId: $farmerId, ')
          ..write('entryId: $entryId, ')
          ..write('plotId: $plotId, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('detailJson: $detailJson, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(flagId, farmerId, entryId, plotId, type, severity, status, detailJson, resolvedReason, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flag &&
          other.flagId == this.flagId &&
          other.farmerId == this.farmerId &&
          other.entryId == this.entryId &&
          other.plotId == this.plotId &&
          other.type == this.type &&
          other.severity == this.severity &&
          other.status == this.status &&
          other.detailJson == this.detailJson &&
          other.resolvedReason == this.resolvedReason &&
          other.updatedAt == this.updatedAt);
}

class FlagsCompanion extends UpdateCompanion<Flag> {
  final Value<String> flagId;
  final Value<String> farmerId;
  final Value<String?> entryId;
  final Value<String?> plotId;
  final Value<String> type;
  final Value<String> severity;
  final Value<String> status;
  final Value<String> detailJson;
  final Value<String?> resolvedReason;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FlagsCompanion({
    this.flagId = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.plotId = const Value.absent(),
    this.type = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.detailJson = const Value.absent(),
    this.resolvedReason = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlagsCompanion.insert({
    required String flagId,
    required String farmerId,
    this.entryId = const Value.absent(),
    this.plotId = const Value.absent(),
    required String type,
    required String severity,
    required String status,
    required String detailJson,
    this.resolvedReason = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : flagId = Value(flagId),
       farmerId = Value(farmerId),
       type = Value(type),
       severity = Value(severity),
       status = Value(status),
       detailJson = Value(detailJson),
       updatedAt = Value(updatedAt);
  static Insertable<Flag> custom({
    Expression<String>? flagId,
    Expression<String>? farmerId,
    Expression<String>? entryId,
    Expression<String>? plotId,
    Expression<String>? type,
    Expression<String>? severity,
    Expression<String>? status,
    Expression<String>? detailJson,
    Expression<String>? resolvedReason,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flagId != null) 'flag_id': flagId,
      if (farmerId != null) 'farmer_id': farmerId,
      if (entryId != null) 'entry_id': entryId,
      if (plotId != null) 'plot_id': plotId,
      if (type != null) 'type': type,
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
      if (detailJson != null) 'detail_json': detailJson,
      if (resolvedReason != null) 'resolved_reason': resolvedReason,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlagsCompanion copyWith({
    Value<String>? flagId,
    Value<String>? farmerId,
    Value<String?>? entryId,
    Value<String?>? plotId,
    Value<String>? type,
    Value<String>? severity,
    Value<String>? status,
    Value<String>? detailJson,
    Value<String?>? resolvedReason,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FlagsCompanion(
      flagId: flagId ?? this.flagId,
      farmerId: farmerId ?? this.farmerId,
      entryId: entryId ?? this.entryId,
      plotId: plotId ?? this.plotId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      detailJson: detailJson ?? this.detailJson,
      resolvedReason: resolvedReason ?? this.resolvedReason,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flagId.present) {
      map['flag_id'] = Variable<String>(flagId.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (plotId.present) {
      map['plot_id'] = Variable<String>(plotId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (detailJson.present) {
      map['detail_json'] = Variable<String>(detailJson.value);
    }
    if (resolvedReason.present) {
      map['resolved_reason'] = Variable<String>(resolvedReason.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlagsCompanion(')
          ..write('flagId: $flagId, ')
          ..write('farmerId: $farmerId, ')
          ..write('entryId: $entryId, ')
          ..write('plotId: $plotId, ')
          ..write('type: $type, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('detailJson: $detailJson, ')
          ..write('resolvedReason: $resolvedReason, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstrumentsTable extends Instruments with TableInfo<$InstrumentsTable, Instrument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstrumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instrumentIdMeta = const VerificationMeta('instrumentId');
  @override
  late final GeneratedColumn<String> instrumentId = GeneratedColumn<String>(
    'instrument_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calibrationDueDateMeta = const VerificationMeta('calibrationDueDate');
  @override
  late final GeneratedColumn<DateTime> calibrationDueDate = GeneratedColumn<DateTime>(
    'calibration_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [instrumentId, kind, label, calibrationDueDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instruments';
  @override
  VerificationContext validateIntegrity(Insertable<Instrument> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instrument_id')) {
      context.handle(_instrumentIdMeta, instrumentId.isAcceptableOrUnknown(data['instrument_id']!, _instrumentIdMeta));
    } else if (isInserting) {
      context.missing(_instrumentIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('calibration_due_date')) {
      context.handle(
        _calibrationDueDateMeta,
        calibrationDueDate.isAcceptableOrUnknown(data['calibration_due_date']!, _calibrationDueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_calibrationDueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instrumentId};
  @override
  Instrument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instrument(
      instrumentId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}instrument_id'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      label: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      calibrationDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calibration_due_date'],
      )!,
    );
  }

  @override
  $InstrumentsTable createAlias(String alias) {
    return $InstrumentsTable(attachedDatabase, alias);
  }
}

class Instrument extends DataClass implements Insertable<Instrument> {
  /// Server instrument id (UUID).
  final String instrumentId;

  /// Instrument kind (`moisture_meter`, `colorimeter`, `hygrometer`, `scale`).
  final String kind;

  /// Label shown to the QC officer (make, model, serial).
  final String label;

  /// Day the calibration expires; readings after it are flagged.
  final DateTime calibrationDueDate;
  const Instrument({
    required this.instrumentId,
    required this.kind,
    required this.label,
    required this.calibrationDueDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instrument_id'] = Variable<String>(instrumentId);
    map['kind'] = Variable<String>(kind);
    map['label'] = Variable<String>(label);
    map['calibration_due_date'] = Variable<DateTime>(calibrationDueDate);
    return map;
  }

  InstrumentsCompanion toCompanion(bool nullToAbsent) {
    return InstrumentsCompanion(
      instrumentId: Value(instrumentId),
      kind: Value(kind),
      label: Value(label),
      calibrationDueDate: Value(calibrationDueDate),
    );
  }

  factory Instrument.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instrument(
      instrumentId: serializer.fromJson<String>(json['instrumentId']),
      kind: serializer.fromJson<String>(json['kind']),
      label: serializer.fromJson<String>(json['label']),
      calibrationDueDate: serializer.fromJson<DateTime>(json['calibrationDueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instrumentId': serializer.toJson<String>(instrumentId),
      'kind': serializer.toJson<String>(kind),
      'label': serializer.toJson<String>(label),
      'calibrationDueDate': serializer.toJson<DateTime>(calibrationDueDate),
    };
  }

  Instrument copyWith({String? instrumentId, String? kind, String? label, DateTime? calibrationDueDate}) => Instrument(
    instrumentId: instrumentId ?? this.instrumentId,
    kind: kind ?? this.kind,
    label: label ?? this.label,
    calibrationDueDate: calibrationDueDate ?? this.calibrationDueDate,
  );
  Instrument copyWithCompanion(InstrumentsCompanion data) {
    return Instrument(
      instrumentId: data.instrumentId.present ? data.instrumentId.value : this.instrumentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      label: data.label.present ? data.label.value : this.label,
      calibrationDueDate: data.calibrationDueDate.present ? data.calibrationDueDate.value : this.calibrationDueDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instrument(')
          ..write('instrumentId: $instrumentId, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('calibrationDueDate: $calibrationDueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(instrumentId, kind, label, calibrationDueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instrument &&
          other.instrumentId == this.instrumentId &&
          other.kind == this.kind &&
          other.label == this.label &&
          other.calibrationDueDate == this.calibrationDueDate);
}

class InstrumentsCompanion extends UpdateCompanion<Instrument> {
  final Value<String> instrumentId;
  final Value<String> kind;
  final Value<String> label;
  final Value<DateTime> calibrationDueDate;
  final Value<int> rowid;
  const InstrumentsCompanion({
    this.instrumentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.label = const Value.absent(),
    this.calibrationDueDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstrumentsCompanion.insert({
    required String instrumentId,
    required String kind,
    required String label,
    required DateTime calibrationDueDate,
    this.rowid = const Value.absent(),
  }) : instrumentId = Value(instrumentId),
       kind = Value(kind),
       label = Value(label),
       calibrationDueDate = Value(calibrationDueDate);
  static Insertable<Instrument> custom({
    Expression<String>? instrumentId,
    Expression<String>? kind,
    Expression<String>? label,
    Expression<DateTime>? calibrationDueDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instrumentId != null) 'instrument_id': instrumentId,
      if (kind != null) 'kind': kind,
      if (label != null) 'label': label,
      if (calibrationDueDate != null) 'calibration_due_date': calibrationDueDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstrumentsCompanion copyWith({
    Value<String>? instrumentId,
    Value<String>? kind,
    Value<String>? label,
    Value<DateTime>? calibrationDueDate,
    Value<int>? rowid,
  }) {
    return InstrumentsCompanion(
      instrumentId: instrumentId ?? this.instrumentId,
      kind: kind ?? this.kind,
      label: label ?? this.label,
      calibrationDueDate: calibrationDueDate ?? this.calibrationDueDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instrumentId.present) {
      map['instrument_id'] = Variable<String>(instrumentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (calibrationDueDate.present) {
      map['calibration_due_date'] = Variable<DateTime>(calibrationDueDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstrumentsCompanion(')
          ..write('instrumentId: $instrumentId, ')
          ..write('kind: $kind, ')
          ..write('label: $label, ')
          ..write('calibrationDueDate: $calibrationDueDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldConfigTable extends FieldConfig with TableInfo<$FieldConfigTable, FieldConfigEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entity, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_config';
  @override
  VerificationContext validateIntegrity(Insertable<FieldConfigEntry> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(_entityMeta, entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('json')) {
      context.handle(_jsonMeta, json.isAcceptableOrUnknown(data['json']!, _jsonMeta));
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  FieldConfigEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldConfigEntry(
      entity: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      json: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}json'])!,
    );
  }

  @override
  $FieldConfigTable createAlias(String alias) {
    return $FieldConfigTable(attachedDatabase, alias);
  }
}

class FieldConfigEntry extends DataClass implements Insertable<FieldConfigEntry> {
  /// Entity name (`farmer`, `plot`, `harvest`, ...).
  final String entity;

  /// The entity's field list as JSON (name, type, required, enabled, visibility, label keys).
  final String json;
  const FieldConfigEntry({required this.entity, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['json'] = Variable<String>(json);
    return map;
  }

  FieldConfigCompanion toCompanion(bool nullToAbsent) {
    return FieldConfigCompanion(entity: Value(entity), json: Value(json));
  }

  factory FieldConfigEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldConfigEntry(
      entity: serializer.fromJson<String>(json['entity']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'entity': serializer.toJson<String>(entity), 'json': serializer.toJson<String>(json)};
  }

  FieldConfigEntry copyWith({String? entity, String? json}) =>
      FieldConfigEntry(entity: entity ?? this.entity, json: json ?? this.json);
  FieldConfigEntry copyWithCompanion(FieldConfigCompanion data) {
    return FieldConfigEntry(
      entity: data.entity.present ? data.entity.value : this.entity,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldConfigEntry(')
          ..write('entity: $entity, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FieldConfigEntry && other.entity == this.entity && other.json == this.json);
}

class FieldConfigCompanion extends UpdateCompanion<FieldConfigEntry> {
  final Value<String> entity;
  final Value<String> json;
  final Value<int> rowid;
  const FieldConfigCompanion({
    this.entity = const Value.absent(),
    this.json = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldConfigCompanion.insert({required String entity, required String json, this.rowid = const Value.absent()})
    : entity = Value(entity),
      json = Value(json);
  static Insertable<FieldConfigEntry> custom({
    Expression<String>? entity,
    Expression<String>? json,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (json != null) 'json': json,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldConfigCompanion copyWith({Value<String>? entity, Value<String>? json, Value<int>? rowid}) {
    return FieldConfigCompanion(entity: entity ?? this.entity, json: json ?? this.json, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldConfigCompanion(')
          ..write('entity: $entity, ')
          ..write('json: $json, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final Trigger entriesFactsImmutable = Trigger(
    'CREATE TRIGGER entries_facts_immutable BEFORE UPDATE OF entry_id, root_id, version, supersedes_entry_id, entry_type, lot_id, plot_id, farmer_id, instance_no, payload_json, device_time, gps_time, lat, lng, accuracy_m, location_status, entered_by_user_id, assist_mode, entered_remotely, reason_code, undo_deadline, created_at ON entries BEGIN SELECT RAISE (ABORT, \'entries are append-only: save a new version instead\');END',
    'entries_facts_immutable',
  );
  late final Trigger entriesNoDelete = Trigger(
    'CREATE TRIGGER entries_no_delete BEFORE DELETE ON entries BEGIN SELECT RAISE (ABORT, \'entries are append-only: they are never deleted\');END',
    'entries_no_delete',
  );
  late final $MediaTable media = $MediaTable(this);
  late final Index entriesLotStatus = Index(
    'entries_lot_status',
    'CREATE INDEX entries_lot_status ON entries (lot_id, status)',
  );
  late final Index entriesRootVersion = Index(
    'entries_root_version',
    'CREATE UNIQUE INDEX entries_root_version ON entries (root_id, version)',
  );
  late final Index mediaEntry = Index('media_entry', 'CREATE INDEX media_entry ON media (entry_id)');
  late final $SessionTableTable sessionTable = $SessionTableTable(this);
  late final $FarmersTable farmers = $FarmersTable(this);
  late final $PlotsTable plots = $PlotsTable(this);
  late final $LotsTable lots = $LotsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $RefBundlesTable refBundles = $RefBundlesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SyncMetricsTable syncMetrics = $SyncMetricsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $FlagsTable flags = $FlagsTable(this);
  late final $InstrumentsTable instruments = $InstrumentsTable(this);
  late final $FieldConfigTable fieldConfig = $FieldConfigTable(this);
  late final Index outboxStatusNext = Index(
    'outbox_status_next',
    'CREATE INDEX outbox_status_next ON outbox (status, next_attempt_at)',
  );
  late final EntriesDao entriesDao = EntriesDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final RefBundlesDao refBundlesDao = RefBundlesDao(this as AppDatabase);
  late final SyncStateDao syncStateDao = SyncStateDao(this as AppDatabase);
  late final SyncMetricsDao syncMetricsDao = SyncMetricsDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final FlagsDao flagsDao = FlagsDao(this as AppDatabase);
  late final FieldConfigDao fieldConfigDao = FieldConfigDao(this as AppDatabase);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entries,
    entriesFactsImmutable,
    entriesNoDelete,
    media,
    entriesLotStatus,
    entriesRootVersion,
    mediaEntry,
    sessionTable,
    farmers,
    plots,
    lots,
    outbox,
    refBundles,
    syncState,
    syncMetrics,
    tasks,
    flags,
    instruments,
    fieldConfig,
    outboxStatusNext,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('entries', limitUpdateKind: UpdateKind.update),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('entries', limitUpdateKind: UpdateKind.delete),
      result: [],
    ),
  ]);
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String entryId,
      required String rootId,
      required int version,
      Value<String?> supersedesEntryId,
      required String entryType,
      Value<String?> lotId,
      Value<String?> plotId,
      required String farmerId,
      required int instanceNo,
      required String payloadJson,
      required DateTime deviceTime,
      Value<DateTime?> gpsTime,
      Value<DateTime?> serverReceivedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      required LocationStatus locationStatus,
      required String enteredByUserId,
      Value<bool> assistMode,
      Value<bool> enteredRemotely,
      Value<String?> reasonCode,
      required EntryStatus status,
      required DateTime undoDeadline,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> entryId,
      Value<String> rootId,
      Value<int> version,
      Value<String?> supersedesEntryId,
      Value<String> entryType,
      Value<String?> lotId,
      Value<String?> plotId,
      Value<String> farmerId,
      Value<int> instanceNo,
      Value<String> payloadJson,
      Value<DateTime> deviceTime,
      Value<DateTime?> gpsTime,
      Value<DateTime?> serverReceivedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<LocationStatus> locationStatus,
      Value<String> enteredByUserId,
      Value<bool> assistMode,
      Value<bool> enteredRemotely,
      Value<String?> reasonCode,
      Value<EntryStatus> status,
      Value<DateTime> undoDeadline,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$EntriesTableReferences extends BaseReferences<_$AppDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaTable, List<MediaFile>> _mediaRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.media, aliasName: $_aliasNameGenerator(db.entries.entryId, db.media.entryId));

  $$MediaTableProcessedTableManager get mediaRefs {
    final manager = $$MediaTableTableManager(
      $_db,
      $_db.media,
    ).filter((f) => f.entryId.entryId.sqlEquals($_itemColumn<String>('entry_id')!));

    final cache = $_typedResult.readTableOrNull(_mediaRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EntriesTableFilterComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supersedesEntryId =>
      $composableBuilder(column: $table.supersedesEntryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get instanceNo =>
      $composableBuilder(column: $table.instanceNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deviceTime =>
      $composableBuilder(column: $table.deviceTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get gpsTime =>
      $composableBuilder(column: $table.gpsTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get serverReceivedAt =>
      $composableBuilder(column: $table.serverReceivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<LocationStatus, LocationStatus, String> get locationStatus =>
      $composableBuilder(column: $table.locationStatus, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get enteredByUserId =>
      $composableBuilder(column: $table.enteredByUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get assistMode =>
      $composableBuilder(column: $table.assistMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enteredRemotely =>
      $composableBuilder(column: $table.enteredRemotely, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reasonCode =>
      $composableBuilder(column: $table.reasonCode, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<EntryStatus, EntryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get undoDeadline =>
      $composableBuilder(column: $table.undoDeadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> mediaRefs(Expression<bool> Function($$MediaTableFilterComposer f) f) {
    final $$MediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.entryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MediaTableFilterComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableOrderingComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rootId =>
      $composableBuilder(column: $table.rootId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supersedesEntryId =>
      $composableBuilder(column: $table.supersedesEntryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get instanceNo =>
      $composableBuilder(column: $table.instanceNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deviceTime =>
      $composableBuilder(column: $table.deviceTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get gpsTime =>
      $composableBuilder(column: $table.gpsTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get serverReceivedAt =>
      $composableBuilder(column: $table.serverReceivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationStatus =>
      $composableBuilder(column: $table.locationStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get enteredByUserId =>
      $composableBuilder(column: $table.enteredByUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get assistMode =>
      $composableBuilder(column: $table.assistMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enteredRemotely =>
      $composableBuilder(column: $table.enteredRemotely, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reasonCode =>
      $composableBuilder(column: $table.reasonCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get undoDeadline =>
      $composableBuilder(column: $table.undoDeadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$EntriesTableAnnotationComposer extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId => $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get rootId => $composableBuilder(column: $table.rootId, builder: (column) => column);

  GeneratedColumn<int> get version => $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get supersedesEntryId =>
      $composableBuilder(column: $table.supersedesEntryId, builder: (column) => column);

  GeneratedColumn<String> get entryType => $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get lotId => $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get plotId => $composableBuilder(column: $table.plotId, builder: (column) => column);

  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<int> get instanceNo => $composableBuilder(column: $table.instanceNo, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get deviceTime =>
      $composableBuilder(column: $table.deviceTime, builder: (column) => column);

  GeneratedColumn<DateTime> get gpsTime => $composableBuilder(column: $table.gpsTime, builder: (column) => column);

  GeneratedColumn<DateTime> get serverReceivedAt =>
      $composableBuilder(column: $table.serverReceivedAt, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM => $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocationStatus, String> get locationStatus =>
      $composableBuilder(column: $table.locationStatus, builder: (column) => column);

  GeneratedColumn<String> get enteredByUserId =>
      $composableBuilder(column: $table.enteredByUserId, builder: (column) => column);

  GeneratedColumn<bool> get assistMode => $composableBuilder(column: $table.assistMode, builder: (column) => column);

  GeneratedColumn<bool> get enteredRemotely =>
      $composableBuilder(column: $table.enteredRemotely, builder: (column) => column);

  GeneratedColumn<String> get reasonCode => $composableBuilder(column: $table.reasonCode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EntryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get undoDeadline =>
      $composableBuilder(column: $table.undoDeadline, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> mediaRefs<T extends Object>(Expression<T> Function($$MediaTableAnnotationComposer a) f) {
    final $$MediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.media,
      getReferencedColumn: (t) => t.entryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MediaTableAnnotationComposer(
            $db: $db,
            $table: $db.media,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool mediaRefs})
        > {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entryId = const Value.absent(),
                Value<String> rootId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> supersedesEntryId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String?> plotId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<int> instanceNo = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> deviceTime = const Value.absent(),
                Value<DateTime?> gpsTime = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<LocationStatus> locationStatus = const Value.absent(),
                Value<String> enteredByUserId = const Value.absent(),
                Value<bool> assistMode = const Value.absent(),
                Value<bool> enteredRemotely = const Value.absent(),
                Value<String?> reasonCode = const Value.absent(),
                Value<EntryStatus> status = const Value.absent(),
                Value<DateTime> undoDeadline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                entryId: entryId,
                rootId: rootId,
                version: version,
                supersedesEntryId: supersedesEntryId,
                entryType: entryType,
                lotId: lotId,
                plotId: plotId,
                farmerId: farmerId,
                instanceNo: instanceNo,
                payloadJson: payloadJson,
                deviceTime: deviceTime,
                gpsTime: gpsTime,
                serverReceivedAt: serverReceivedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                locationStatus: locationStatus,
                enteredByUserId: enteredByUserId,
                assistMode: assistMode,
                enteredRemotely: enteredRemotely,
                reasonCode: reasonCode,
                status: status,
                undoDeadline: undoDeadline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entryId,
                required String rootId,
                required int version,
                Value<String?> supersedesEntryId = const Value.absent(),
                required String entryType,
                Value<String?> lotId = const Value.absent(),
                Value<String?> plotId = const Value.absent(),
                required String farmerId,
                required int instanceNo,
                required String payloadJson,
                required DateTime deviceTime,
                Value<DateTime?> gpsTime = const Value.absent(),
                Value<DateTime?> serverReceivedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                required LocationStatus locationStatus,
                required String enteredByUserId,
                Value<bool> assistMode = const Value.absent(),
                Value<bool> enteredRemotely = const Value.absent(),
                Value<String?> reasonCode = const Value.absent(),
                required EntryStatus status,
                required DateTime undoDeadline,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                entryId: entryId,
                rootId: rootId,
                version: version,
                supersedesEntryId: supersedesEntryId,
                entryType: entryType,
                lotId: lotId,
                plotId: plotId,
                farmerId: farmerId,
                instanceNo: instanceNo,
                payloadJson: payloadJson,
                deviceTime: deviceTime,
                gpsTime: gpsTime,
                serverReceivedAt: serverReceivedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                locationStatus: locationStatus,
                enteredByUserId: enteredByUserId,
                assistMode: assistMode,
                enteredRemotely: enteredRemotely,
                reasonCode: reasonCode,
                status: status,
                undoDeadline: undoDeadline,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$EntriesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({mediaRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaRefs) db.media],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaRefs)
                    await $_getPrefetchedData<Entry, $EntriesTable, MediaFile>(
                      currentTable: table,
                      referencedTable: $$EntriesTableReferences._mediaRefsTable(db),
                      managerFromTypedResult: (p0) => $$EntriesTableReferences(db, table, p0).mediaRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.entryId == item.entryId),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool mediaRefs})
    >;
typedef $$MediaTableCreateCompanionBuilder =
    MediaCompanion Function({
      required String mediaId,
      required String entryId,
      required String kind,
      required String localPath,
      required int bytes,
      required String sha256,
      required int width,
      required int height,
      required DateTime capturedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<String?> uploadUrl,
      Value<DateTime?> uploadUrlExpiresAt,
      required UploadStatus uploadStatus,
      Value<String?> objectKey,
      required String thumbPath,
      Value<DateTime?> purgedAt,
      Value<int> rowid,
    });
typedef $$MediaTableUpdateCompanionBuilder =
    MediaCompanion Function({
      Value<String> mediaId,
      Value<String> entryId,
      Value<String> kind,
      Value<String> localPath,
      Value<int> bytes,
      Value<String> sha256,
      Value<int> width,
      Value<int> height,
      Value<DateTime> capturedAt,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> accuracyM,
      Value<String?> uploadUrl,
      Value<DateTime?> uploadUrlExpiresAt,
      Value<UploadStatus> uploadStatus,
      Value<String?> objectKey,
      Value<String> thumbPath,
      Value<DateTime?> purgedAt,
      Value<int> rowid,
    });

final class $$MediaTableReferences extends BaseReferences<_$AppDatabase, $MediaTable, MediaFile> {
  $$MediaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EntriesTable _entryIdTable(_$AppDatabase db) =>
      db.entries.createAlias($_aliasNameGenerator(db.media.entryId, db.entries.entryId));

  $$EntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<String>('entry_id')!;

    final manager = $$EntriesTableTableManager($_db, $_db.entries).filter((f) => f.entryId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytes => $composableBuilder(column: $table.bytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get width => $composableBuilder(column: $table.width, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get capturedAt =>
      $composableBuilder(column: $table.capturedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uploadUrl =>
      $composableBuilder(column: $table.uploadUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadUrlExpiresAt =>
      $composableBuilder(column: $table.uploadUrlExpiresAt, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<UploadStatus, UploadStatus, String> get uploadStatus =>
      $composableBuilder(column: $table.uploadStatus, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get purgedAt =>
      $composableBuilder(column: $table.purgedAt, builder: (column) => ColumnFilters(column));

  $$EntriesTableFilterComposer get entryId {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.entryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaTableOrderingComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get capturedAt =>
      $composableBuilder(column: $table.capturedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracyM =>
      $composableBuilder(column: $table.accuracyM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadUrl =>
      $composableBuilder(column: $table.uploadUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadUrlExpiresAt =>
      $composableBuilder(column: $table.uploadUrlExpiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uploadStatus =>
      $composableBuilder(column: $table.uploadStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get purgedAt =>
      $composableBuilder(column: $table.purgedAt, builder: (column) => ColumnOrderings(column));

  $$EntriesTableOrderingComposer get entryId {
    final $$EntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.entryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EntriesTableOrderingComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaTableAnnotationComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mediaId => $composableBuilder(column: $table.mediaId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get localPath => $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<int> get bytes => $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get sha256 => $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<int> get width => $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height => $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt =>
      $composableBuilder(column: $table.capturedAt, builder: (column) => column);

  GeneratedColumn<double> get lat => $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng => $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get accuracyM => $composableBuilder(column: $table.accuracyM, builder: (column) => column);

  GeneratedColumn<String> get uploadUrl => $composableBuilder(column: $table.uploadUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadUrlExpiresAt =>
      $composableBuilder(column: $table.uploadUrlExpiresAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UploadStatus, String> get uploadStatus =>
      $composableBuilder(column: $table.uploadStatus, builder: (column) => column);

  GeneratedColumn<String> get objectKey => $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<String> get thumbPath => $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<DateTime> get purgedAt => $composableBuilder(column: $table.purgedAt, builder: (column) => column);

  $$EntriesTableAnnotationComposer get entryId {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.entryId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTable,
          MediaFile,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (MediaFile, $$MediaTableReferences),
          MediaFile,
          PrefetchHooks Function({bool entryId})
        > {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> mediaId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<String?> uploadUrl = const Value.absent(),
                Value<DateTime?> uploadUrlExpiresAt = const Value.absent(),
                Value<UploadStatus> uploadStatus = const Value.absent(),
                Value<String?> objectKey = const Value.absent(),
                Value<String> thumbPath = const Value.absent(),
                Value<DateTime?> purgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion(
                mediaId: mediaId,
                entryId: entryId,
                kind: kind,
                localPath: localPath,
                bytes: bytes,
                sha256: sha256,
                width: width,
                height: height,
                capturedAt: capturedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                uploadUrl: uploadUrl,
                uploadUrlExpiresAt: uploadUrlExpiresAt,
                uploadStatus: uploadStatus,
                objectKey: objectKey,
                thumbPath: thumbPath,
                purgedAt: purgedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mediaId,
                required String entryId,
                required String kind,
                required String localPath,
                required int bytes,
                required String sha256,
                required int width,
                required int height,
                required DateTime capturedAt,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> accuracyM = const Value.absent(),
                Value<String?> uploadUrl = const Value.absent(),
                Value<DateTime?> uploadUrlExpiresAt = const Value.absent(),
                required UploadStatus uploadStatus,
                Value<String?> objectKey = const Value.absent(),
                required String thumbPath,
                Value<DateTime?> purgedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaCompanion.insert(
                mediaId: mediaId,
                entryId: entryId,
                kind: kind,
                localPath: localPath,
                bytes: bytes,
                sha256: sha256,
                width: width,
                height: height,
                capturedAt: capturedAt,
                lat: lat,
                lng: lng,
                accuracyM: accuracyM,
                uploadUrl: uploadUrl,
                uploadUrlExpiresAt: uploadUrlExpiresAt,
                uploadStatus: uploadStatus,
                objectKey: objectKey,
                thumbPath: thumbPath,
                purgedAt: purgedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$MediaTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.entryId,
                                referencedTable: $$MediaTableReferences._entryIdTable(db),
                                referencedColumn: $$MediaTableReferences._entryIdTable(db).entryId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTable,
      MediaFile,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaFile, $$MediaTableReferences),
      MediaFile,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$SessionTableTableCreateCompanionBuilder =
    SessionTableCompanion Function({
      Value<int> id,
      required String userId,
      required Role role,
      required String fpoId,
      required String deviceId,
      required String accessToken,
      required String refreshToken,
      Value<String?> pinHash,
      Value<String> locale,
      Value<bool> wifiOnlyPhotos,
    });
typedef $$SessionTableTableUpdateCompanionBuilder =
    SessionTableCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<Role> role,
      Value<String> fpoId,
      Value<String> deviceId,
      Value<String> accessToken,
      Value<String> refreshToken,
      Value<String?> pinHash,
      Value<String> locale,
      Value<bool> wifiOnlyPhotos,
    });

class $$SessionTableTableFilterComposer extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Role, Role, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get fpoId =>
      $composableBuilder(column: $table.fpoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wifiOnlyPhotos =>
      $composableBuilder(column: $table.wifiOnlyPhotos, builder: (column) => ColumnFilters(column));
}

class $$SessionTableTableOrderingComposer extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fpoId =>
      $composableBuilder(column: $table.fpoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get wifiOnlyPhotos =>
      $composableBuilder(column: $table.wifiOnlyPhotos, builder: (column) => ColumnOrderings(column));
}

class $$SessionTableTableAnnotationComposer extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId => $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Role, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fpoId => $composableBuilder(column: $table.fpoId, builder: (column) => column);

  GeneratedColumn<String> get deviceId => $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => column);

  GeneratedColumn<String> get pinHash => $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get locale => $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<bool> get wifiOnlyPhotos =>
      $composableBuilder(column: $table.wifiOnlyPhotos, builder: (column) => column);
}

class $$SessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionTableTable,
          SessionRow,
          $$SessionTableTableFilterComposer,
          $$SessionTableTableOrderingComposer,
          $$SessionTableTableAnnotationComposer,
          $$SessionTableTableCreateCompanionBuilder,
          $$SessionTableTableUpdateCompanionBuilder,
          (SessionRow, BaseReferences<_$AppDatabase, $SessionTableTable, SessionRow>),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionTableTableTableManager(_$AppDatabase db, $SessionTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SessionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SessionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<Role> role = const Value.absent(),
                Value<String> fpoId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
                Value<String> refreshToken = const Value.absent(),
                Value<String?> pinHash = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> wifiOnlyPhotos = const Value.absent(),
              }) => SessionTableCompanion(
                id: id,
                userId: userId,
                role: role,
                fpoId: fpoId,
                deviceId: deviceId,
                accessToken: accessToken,
                refreshToken: refreshToken,
                pinHash: pinHash,
                locale: locale,
                wifiOnlyPhotos: wifiOnlyPhotos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required Role role,
                required String fpoId,
                required String deviceId,
                required String accessToken,
                required String refreshToken,
                Value<String?> pinHash = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<bool> wifiOnlyPhotos = const Value.absent(),
              }) => SessionTableCompanion.insert(
                id: id,
                userId: userId,
                role: role,
                fpoId: fpoId,
                deviceId: deviceId,
                accessToken: accessToken,
                refreshToken: refreshToken,
                pinHash: pinHash,
                locale: locale,
                wifiOnlyPhotos: wifiOnlyPhotos,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionTableTable,
      SessionRow,
      $$SessionTableTableFilterComposer,
      $$SessionTableTableOrderingComposer,
      $$SessionTableTableAnnotationComposer,
      $$SessionTableTableCreateCompanionBuilder,
      $$SessionTableTableUpdateCompanionBuilder,
      (SessionRow, BaseReferences<_$AppDatabase, $SessionTableTable, SessionRow>),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$FarmersTableCreateCompanionBuilder =
    FarmersCompanion Function({
      required String farmerId,
      required String fpoId,
      required String name,
      required String village,
      Value<String?> photoPath,
      required bool hasSmartphone,
      required String language,
      required String status,
      required String json,
      Value<int> rowid,
    });
typedef $$FarmersTableUpdateCompanionBuilder =
    FarmersCompanion Function({
      Value<String> farmerId,
      Value<String> fpoId,
      Value<String> name,
      Value<String> village,
      Value<String?> photoPath,
      Value<bool> hasSmartphone,
      Value<String> language,
      Value<String> status,
      Value<String> json,
      Value<int> rowid,
    });

class $$FarmersTableFilterComposer extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fpoId =>
      $composableBuilder(column: $table.fpoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasSmartphone =>
      $composableBuilder(column: $table.hasSmartphone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get json => $composableBuilder(column: $table.json, builder: (column) => ColumnFilters(column));
}

class $$FarmersTableOrderingComposer extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fpoId =>
      $composableBuilder(column: $table.fpoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get village =>
      $composableBuilder(column: $table.village, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasSmartphone =>
      $composableBuilder(column: $table.hasSmartphone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => ColumnOrderings(column));
}

class $$FarmersTableAnnotationComposer extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get fpoId => $composableBuilder(column: $table.fpoId, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get village => $composableBuilder(column: $table.village, builder: (column) => column);

  GeneratedColumn<String> get photoPath => $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<bool> get hasSmartphone =>
      $composableBuilder(column: $table.hasSmartphone, builder: (column) => column);

  GeneratedColumn<String> get language => $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get json => $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$FarmersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FarmersTable,
          Farmer,
          $$FarmersTableFilterComposer,
          $$FarmersTableOrderingComposer,
          $$FarmersTableAnnotationComposer,
          $$FarmersTableCreateCompanionBuilder,
          $$FarmersTableUpdateCompanionBuilder,
          (Farmer, BaseReferences<_$AppDatabase, $FarmersTable, Farmer>),
          Farmer,
          PrefetchHooks Function()
        > {
  $$FarmersTableTableManager(_$AppDatabase db, $FarmersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FarmersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FarmersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FarmersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> farmerId = const Value.absent(),
                Value<String> fpoId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> village = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<bool> hasSmartphone = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion(
                farmerId: farmerId,
                fpoId: fpoId,
                name: name,
                village: village,
                photoPath: photoPath,
                hasSmartphone: hasSmartphone,
                language: language,
                status: status,
                json: json,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String farmerId,
                required String fpoId,
                required String name,
                required String village,
                Value<String?> photoPath = const Value.absent(),
                required bool hasSmartphone,
                required String language,
                required String status,
                required String json,
                Value<int> rowid = const Value.absent(),
              }) => FarmersCompanion.insert(
                farmerId: farmerId,
                fpoId: fpoId,
                name: name,
                village: village,
                photoPath: photoPath,
                hasSmartphone: hasSmartphone,
                language: language,
                status: status,
                json: json,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FarmersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FarmersTable,
      Farmer,
      $$FarmersTableFilterComposer,
      $$FarmersTableOrderingComposer,
      $$FarmersTableAnnotationComposer,
      $$FarmersTableCreateCompanionBuilder,
      $$FarmersTableUpdateCompanionBuilder,
      (Farmer, BaseReferences<_$AppDatabase, $FarmersTable, Farmer>),
      Farmer,
      PrefetchHooks Function()
    >;
typedef $$PlotsTableCreateCompanionBuilder =
    PlotsCompanion Function({
      required String plotId,
      required String farmerId,
      required double pinLat,
      required double pinLng,
      required double pinAccuracyM,
      required String pinMethod,
      required double declaredArea,
      required String areaUnit,
      Value<String?> surveyNoLocalOnly,
      Value<String?> boundaryGeoJson,
      required String giStatus,
      required bool locked,
      required int version,
      Value<int> rowid,
    });
typedef $$PlotsTableUpdateCompanionBuilder =
    PlotsCompanion Function({
      Value<String> plotId,
      Value<String> farmerId,
      Value<double> pinLat,
      Value<double> pinLng,
      Value<double> pinAccuracyM,
      Value<String> pinMethod,
      Value<double> declaredArea,
      Value<String> areaUnit,
      Value<String?> surveyNoLocalOnly,
      Value<String?> boundaryGeoJson,
      Value<String> giStatus,
      Value<bool> locked,
      Value<int> version,
      Value<int> rowid,
    });

class $$PlotsTableFilterComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pinLat =>
      $composableBuilder(column: $table.pinLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pinLng =>
      $composableBuilder(column: $table.pinLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pinAccuracyM =>
      $composableBuilder(column: $table.pinAccuracyM, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinMethod =>
      $composableBuilder(column: $table.pinMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get declaredArea =>
      $composableBuilder(column: $table.declaredArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get surveyNoLocalOnly =>
      $composableBuilder(column: $table.surveyNoLocalOnly, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundaryGeoJson =>
      $composableBuilder(column: $table.boundaryGeoJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get giStatus =>
      $composableBuilder(column: $table.giStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$PlotsTableOrderingComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pinLat =>
      $composableBuilder(column: $table.pinLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pinLng =>
      $composableBuilder(column: $table.pinLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pinAccuracyM =>
      $composableBuilder(column: $table.pinAccuracyM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinMethod =>
      $composableBuilder(column: $table.pinMethod, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get declaredArea =>
      $composableBuilder(column: $table.declaredArea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaUnit =>
      $composableBuilder(column: $table.areaUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get surveyNoLocalOnly =>
      $composableBuilder(column: $table.surveyNoLocalOnly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundaryGeoJson =>
      $composableBuilder(column: $table.boundaryGeoJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get giStatus =>
      $composableBuilder(column: $table.giStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$PlotsTableAnnotationComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get plotId => $composableBuilder(column: $table.plotId, builder: (column) => column);

  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<double> get pinLat => $composableBuilder(column: $table.pinLat, builder: (column) => column);

  GeneratedColumn<double> get pinLng => $composableBuilder(column: $table.pinLng, builder: (column) => column);

  GeneratedColumn<double> get pinAccuracyM =>
      $composableBuilder(column: $table.pinAccuracyM, builder: (column) => column);

  GeneratedColumn<String> get pinMethod => $composableBuilder(column: $table.pinMethod, builder: (column) => column);

  GeneratedColumn<double> get declaredArea =>
      $composableBuilder(column: $table.declaredArea, builder: (column) => column);

  GeneratedColumn<String> get areaUnit => $composableBuilder(column: $table.areaUnit, builder: (column) => column);

  GeneratedColumn<String> get surveyNoLocalOnly =>
      $composableBuilder(column: $table.surveyNoLocalOnly, builder: (column) => column);

  GeneratedColumn<String> get boundaryGeoJson =>
      $composableBuilder(column: $table.boundaryGeoJson, builder: (column) => column);

  GeneratedColumn<String> get giStatus => $composableBuilder(column: $table.giStatus, builder: (column) => column);

  GeneratedColumn<bool> get locked => $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<int> get version => $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$PlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotsTable,
          Plot,
          $$PlotsTableFilterComposer,
          $$PlotsTableOrderingComposer,
          $$PlotsTableAnnotationComposer,
          $$PlotsTableCreateCompanionBuilder,
          $$PlotsTableUpdateCompanionBuilder,
          (Plot, BaseReferences<_$AppDatabase, $PlotsTable, Plot>),
          Plot,
          PrefetchHooks Function()
        > {
  $$PlotsTableTableManager(_$AppDatabase db, $PlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$PlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> plotId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<double> pinLat = const Value.absent(),
                Value<double> pinLng = const Value.absent(),
                Value<double> pinAccuracyM = const Value.absent(),
                Value<String> pinMethod = const Value.absent(),
                Value<double> declaredArea = const Value.absent(),
                Value<String> areaUnit = const Value.absent(),
                Value<String?> surveyNoLocalOnly = const Value.absent(),
                Value<String?> boundaryGeoJson = const Value.absent(),
                Value<String> giStatus = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotsCompanion(
                plotId: plotId,
                farmerId: farmerId,
                pinLat: pinLat,
                pinLng: pinLng,
                pinAccuracyM: pinAccuracyM,
                pinMethod: pinMethod,
                declaredArea: declaredArea,
                areaUnit: areaUnit,
                surveyNoLocalOnly: surveyNoLocalOnly,
                boundaryGeoJson: boundaryGeoJson,
                giStatus: giStatus,
                locked: locked,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String plotId,
                required String farmerId,
                required double pinLat,
                required double pinLng,
                required double pinAccuracyM,
                required String pinMethod,
                required double declaredArea,
                required String areaUnit,
                Value<String?> surveyNoLocalOnly = const Value.absent(),
                Value<String?> boundaryGeoJson = const Value.absent(),
                required String giStatus,
                required bool locked,
                required int version,
                Value<int> rowid = const Value.absent(),
              }) => PlotsCompanion.insert(
                plotId: plotId,
                farmerId: farmerId,
                pinLat: pinLat,
                pinLng: pinLng,
                pinAccuracyM: pinAccuracyM,
                pinMethod: pinMethod,
                declaredArea: declaredArea,
                areaUnit: areaUnit,
                surveyNoLocalOnly: surveyNoLocalOnly,
                boundaryGeoJson: boundaryGeoJson,
                giStatus: giStatus,
                locked: locked,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotsTable,
      Plot,
      $$PlotsTableFilterComposer,
      $$PlotsTableOrderingComposer,
      $$PlotsTableAnnotationComposer,
      $$PlotsTableCreateCompanionBuilder,
      $$PlotsTableUpdateCompanionBuilder,
      (Plot, BaseReferences<_$AppDatabase, $PlotsTable, Plot>),
      Plot,
      PrefetchHooks Function()
    >;
typedef $$LotsTableCreateCompanionBuilder =
    LotsCompanion Function({
      required String lotId,
      required String plotId,
      required String farmerId,
      required String cropId,
      required String season,
      required String status,
      Value<double> kgHarvested,
      Value<double> kgPacked,
      Value<double?> lastMoisture,
      Value<String?> qrPayload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LotsTableUpdateCompanionBuilder =
    LotsCompanion Function({
      Value<String> lotId,
      Value<String> plotId,
      Value<String> farmerId,
      Value<String> cropId,
      Value<String> season,
      Value<String> status,
      Value<double> kgHarvested,
      Value<double> kgPacked,
      Value<double?> lastMoisture,
      Value<String?> qrPayload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LotsTableFilterComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kgHarvested =>
      $composableBuilder(column: $table.kgHarvested, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kgPacked =>
      $composableBuilder(column: $table.kgPacked, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lastMoisture =>
      $composableBuilder(column: $table.lastMoisture, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qrPayload =>
      $composableBuilder(column: $table.qrPayload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LotsTableOrderingComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kgHarvested =>
      $composableBuilder(column: $table.kgHarvested, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kgPacked =>
      $composableBuilder(column: $table.kgPacked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lastMoisture =>
      $composableBuilder(column: $table.lastMoisture, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qrPayload =>
      $composableBuilder(column: $table.qrPayload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LotsTableAnnotationComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lotId => $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get plotId => $composableBuilder(column: $table.plotId, builder: (column) => column);

  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get cropId => $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<String> get season => $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get kgHarvested =>
      $composableBuilder(column: $table.kgHarvested, builder: (column) => column);

  GeneratedColumn<double> get kgPacked => $composableBuilder(column: $table.kgPacked, builder: (column) => column);

  GeneratedColumn<double> get lastMoisture =>
      $composableBuilder(column: $table.lastMoisture, builder: (column) => column);

  GeneratedColumn<String> get qrPayload => $composableBuilder(column: $table.qrPayload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotsTable,
          Lot,
          $$LotsTableFilterComposer,
          $$LotsTableOrderingComposer,
          $$LotsTableAnnotationComposer,
          $$LotsTableCreateCompanionBuilder,
          $$LotsTableUpdateCompanionBuilder,
          (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
          Lot,
          PrefetchHooks Function()
        > {
  $$LotsTableTableManager(_$AppDatabase db, $LotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$LotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> lotId = const Value.absent(),
                Value<String> plotId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String> cropId = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> kgHarvested = const Value.absent(),
                Value<double> kgPacked = const Value.absent(),
                Value<double?> lastMoisture = const Value.absent(),
                Value<String?> qrPayload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion(
                lotId: lotId,
                plotId: plotId,
                farmerId: farmerId,
                cropId: cropId,
                season: season,
                status: status,
                kgHarvested: kgHarvested,
                kgPacked: kgPacked,
                lastMoisture: lastMoisture,
                qrPayload: qrPayload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String lotId,
                required String plotId,
                required String farmerId,
                required String cropId,
                required String season,
                required String status,
                Value<double> kgHarvested = const Value.absent(),
                Value<double> kgPacked = const Value.absent(),
                Value<double?> lastMoisture = const Value.absent(),
                Value<String?> qrPayload = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LotsCompanion.insert(
                lotId: lotId,
                plotId: plotId,
                farmerId: farmerId,
                cropId: cropId,
                season: season,
                status: status,
                kgHarvested: kgHarvested,
                kgPacked: kgPacked,
                lastMoisture: lastMoisture,
                qrPayload: qrPayload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotsTable,
      Lot,
      $$LotsTableFilterComposer,
      $$LotsTableOrderingComposer,
      $$LotsTableAnnotationComposer,
      $$LotsTableCreateCompanionBuilder,
      $$LotsTableUpdateCompanionBuilder,
      (Lot, BaseReferences<_$AppDatabase, $LotsTable, Lot>),
      Lot,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required OutboxKind kind,
      required String refId,
      required String ownerUserId,
      required String idempotencyKey,
      required int priority,
      Value<int> attempts,
      required DateTime nextAttemptAt,
      Value<String?> lastError,
      Value<OutboxStatus> status,
      required DateTime createdAt,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<OutboxKind> kind,
      Value<String> refId,
      Value<String> ownerUserId,
      Value<String> idempotencyKey,
      Value<int> priority,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<String?> lastError,
      Value<OutboxStatus> status,
      Value<DateTime> createdAt,
    });

class $$OutboxTableFilterComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OutboxKind, OutboxKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerUserId =>
      $composableBuilder(column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey =>
      $composableBuilder(column: $table.idempotencyKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt =>
      $composableBuilder(column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OutboxStatus, OutboxStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerUserId =>
      $composableBuilder(column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey =>
      $composableBuilder(column: $table.idempotencyKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt =>
      $composableBuilder(column: $table.nextAttemptAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq => $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get refId => $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId =>
      $composableBuilder(column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey =>
      $composableBuilder(column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<int> get priority => $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attempts => $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt =>
      $composableBuilder(column: $table.nextAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get lastError => $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OutboxStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxItem,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxItem, BaseReferences<_$AppDatabase, $OutboxTable, OutboxItem>),
          OutboxItem,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<OutboxKind> kind = const Value.absent(),
                Value<String> refId = const Value.absent(),
                Value<String> ownerUserId = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                kind: kind,
                refId: refId,
                ownerUserId: ownerUserId,
                idempotencyKey: idempotencyKey,
                priority: priority,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                status: status,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required OutboxKind kind,
                required String refId,
                required String ownerUserId,
                required String idempotencyKey,
                required int priority,
                Value<int> attempts = const Value.absent(),
                required DateTime nextAttemptAt,
                Value<String?> lastError = const Value.absent(),
                Value<OutboxStatus> status = const Value.absent(),
                required DateTime createdAt,
              }) => OutboxCompanion.insert(
                seq: seq,
                kind: kind,
                refId: refId,
                ownerUserId: ownerUserId,
                idempotencyKey: idempotencyKey,
                priority: priority,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                lastError: lastError,
                status: status,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxItem,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxItem, BaseReferences<_$AppDatabase, $OutboxTable, OutboxItem>),
      OutboxItem,
      PrefetchHooks Function()
    >;
typedef $$RefBundlesTableCreateCompanionBuilder =
    RefBundlesCompanion Function({
      required String bundleType,
      required int version,
      required String etag,
      required DateTime fetchedAt,
      required String bodyJson,
      Value<String?> assetDir,
      Value<int> rowid,
    });
typedef $$RefBundlesTableUpdateCompanionBuilder =
    RefBundlesCompanion Function({
      Value<String> bundleType,
      Value<int> version,
      Value<String> etag,
      Value<DateTime> fetchedAt,
      Value<String> bodyJson,
      Value<String?> assetDir,
      Value<int> rowid,
    });

class $$RefBundlesTableFilterComposer extends Composer<_$AppDatabase, $RefBundlesTable> {
  $$RefBundlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bundleType =>
      $composableBuilder(column: $table.bundleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get etag => $composableBuilder(column: $table.etag, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetDir =>
      $composableBuilder(column: $table.assetDir, builder: (column) => ColumnFilters(column));
}

class $$RefBundlesTableOrderingComposer extends Composer<_$AppDatabase, $RefBundlesTable> {
  $$RefBundlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bundleType =>
      $composableBuilder(column: $table.bundleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetDir =>
      $composableBuilder(column: $table.assetDir, builder: (column) => ColumnOrderings(column));
}

class $$RefBundlesTableAnnotationComposer extends Composer<_$AppDatabase, $RefBundlesTable> {
  $$RefBundlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bundleType => $composableBuilder(column: $table.bundleType, builder: (column) => column);

  GeneratedColumn<int> get version => $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get etag => $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt => $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<String> get bodyJson => $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<String> get assetDir => $composableBuilder(column: $table.assetDir, builder: (column) => column);
}

class $$RefBundlesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefBundlesTable,
          RefBundle,
          $$RefBundlesTableFilterComposer,
          $$RefBundlesTableOrderingComposer,
          $$RefBundlesTableAnnotationComposer,
          $$RefBundlesTableCreateCompanionBuilder,
          $$RefBundlesTableUpdateCompanionBuilder,
          (RefBundle, BaseReferences<_$AppDatabase, $RefBundlesTable, RefBundle>),
          RefBundle,
          PrefetchHooks Function()
        > {
  $$RefBundlesTableTableManager(_$AppDatabase db, $RefBundlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RefBundlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RefBundlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RefBundlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bundleType = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> etag = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<String> bodyJson = const Value.absent(),
                Value<String?> assetDir = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefBundlesCompanion(
                bundleType: bundleType,
                version: version,
                etag: etag,
                fetchedAt: fetchedAt,
                bodyJson: bodyJson,
                assetDir: assetDir,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bundleType,
                required int version,
                required String etag,
                required DateTime fetchedAt,
                required String bodyJson,
                Value<String?> assetDir = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefBundlesCompanion.insert(
                bundleType: bundleType,
                version: version,
                etag: etag,
                fetchedAt: fetchedAt,
                bodyJson: bodyJson,
                assetDir: assetDir,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefBundlesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefBundlesTable,
      RefBundle,
      $$RefBundlesTableFilterComposer,
      $$RefBundlesTableOrderingComposer,
      $$RefBundlesTableAnnotationComposer,
      $$RefBundlesTableCreateCompanionBuilder,
      $$RefBundlesTableUpdateCompanionBuilder,
      (RefBundle, BaseReferences<_$AppDatabase, $RefBundlesTable, RefBundle>),
      RefBundle,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$SyncStateTableFilterComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateEntry,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (SyncStateEntry, BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateEntry>),
          SyncStateEntry,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
                  SyncStateCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateEntry,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (SyncStateEntry, BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateEntry>),
      SyncStateEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncMetricsTableCreateCompanionBuilder =
    SyncMetricsCompanion Function({
      Value<int> id,
      required String entryId,
      required DateTime savedAt,
      Value<DateTime?> ackedAt,
      Value<int?> photoUploadMs,
      Value<int> failures,
      required String networkType,
      Value<bool> shipped,
    });
typedef $$SyncMetricsTableUpdateCompanionBuilder =
    SyncMetricsCompanion Function({
      Value<int> id,
      Value<String> entryId,
      Value<DateTime> savedAt,
      Value<DateTime?> ackedAt,
      Value<int?> photoUploadMs,
      Value<int> failures,
      Value<String> networkType,
      Value<bool> shipped,
    });

class $$SyncMetricsTableFilterComposer extends Composer<_$AppDatabase, $SyncMetricsTable> {
  $$SyncMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get ackedAt =>
      $composableBuilder(column: $table.ackedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get photoUploadMs =>
      $composableBuilder(column: $table.photoUploadMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get networkType =>
      $composableBuilder(column: $table.networkType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get shipped =>
      $composableBuilder(column: $table.shipped, builder: (column) => ColumnFilters(column));
}

class $$SyncMetricsTableOrderingComposer extends Composer<_$AppDatabase, $SyncMetricsTable> {
  $$SyncMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get ackedAt =>
      $composableBuilder(column: $table.ackedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get photoUploadMs =>
      $composableBuilder(column: $table.photoUploadMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failures =>
      $composableBuilder(column: $table.failures, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get networkType =>
      $composableBuilder(column: $table.networkType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get shipped =>
      $composableBuilder(column: $table.shipped, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetricsTableAnnotationComposer extends Composer<_$AppDatabase, $SyncMetricsTable> {
  $$SyncMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId => $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt => $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get ackedAt => $composableBuilder(column: $table.ackedAt, builder: (column) => column);

  GeneratedColumn<int> get photoUploadMs =>
      $composableBuilder(column: $table.photoUploadMs, builder: (column) => column);

  GeneratedColumn<int> get failures => $composableBuilder(column: $table.failures, builder: (column) => column);

  GeneratedColumn<String> get networkType =>
      $composableBuilder(column: $table.networkType, builder: (column) => column);

  GeneratedColumn<bool> get shipped => $composableBuilder(column: $table.shipped, builder: (column) => column);
}

class $$SyncMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetricsTable,
          SyncMetric,
          $$SyncMetricsTableFilterComposer,
          $$SyncMetricsTableOrderingComposer,
          $$SyncMetricsTableAnnotationComposer,
          $$SyncMetricsTableCreateCompanionBuilder,
          $$SyncMetricsTableUpdateCompanionBuilder,
          (SyncMetric, BaseReferences<_$AppDatabase, $SyncMetricsTable, SyncMetric>),
          SyncMetric,
          PrefetchHooks Function()
        > {
  $$SyncMetricsTableTableManager(_$AppDatabase db, $SyncMetricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SyncMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<DateTime?> ackedAt = const Value.absent(),
                Value<int?> photoUploadMs = const Value.absent(),
                Value<int> failures = const Value.absent(),
                Value<String> networkType = const Value.absent(),
                Value<bool> shipped = const Value.absent(),
              }) => SyncMetricsCompanion(
                id: id,
                entryId: entryId,
                savedAt: savedAt,
                ackedAt: ackedAt,
                photoUploadMs: photoUploadMs,
                failures: failures,
                networkType: networkType,
                shipped: shipped,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entryId,
                required DateTime savedAt,
                Value<DateTime?> ackedAt = const Value.absent(),
                Value<int?> photoUploadMs = const Value.absent(),
                Value<int> failures = const Value.absent(),
                required String networkType,
                Value<bool> shipped = const Value.absent(),
              }) => SyncMetricsCompanion.insert(
                id: id,
                entryId: entryId,
                savedAt: savedAt,
                ackedAt: ackedAt,
                photoUploadMs: photoUploadMs,
                failures: failures,
                networkType: networkType,
                shipped: shipped,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetricsTable,
      SyncMetric,
      $$SyncMetricsTableFilterComposer,
      $$SyncMetricsTableOrderingComposer,
      $$SyncMetricsTableAnnotationComposer,
      $$SyncMetricsTableCreateCompanionBuilder,
      $$SyncMetricsTableUpdateCompanionBuilder,
      (SyncMetric, BaseReferences<_$AppDatabase, $SyncMetricsTable, SyncMetric>),
      SyncMetric,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String taskId,
      required String farmerId,
      Value<String?> lotId,
      required String eventType,
      required DateTime dueDate,
      required String promptId,
      required String source,
      Value<bool> done,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> taskId,
      Value<String> farmerId,
      Value<String?> lotId,
      Value<String> eventType,
      Value<DateTime> dueDate,
      Value<String> promptId,
      Value<String> source,
      Value<bool> done,
      Value<int> rowid,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get done => $composableBuilder(column: $table.done, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId => $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get lotId => $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get eventType => $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate => $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get promptId => $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get source => $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get done => $composableBuilder(column: $table.done, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          FarmTask,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (FarmTask, BaseReferences<_$AppDatabase, $TasksTable, FarmTask>),
          FarmTask,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String?> lotId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> promptId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                taskId: taskId,
                farmerId: farmerId,
                lotId: lotId,
                eventType: eventType,
                dueDate: dueDate,
                promptId: promptId,
                source: source,
                done: done,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String farmerId,
                Value<String?> lotId = const Value.absent(),
                required String eventType,
                required DateTime dueDate,
                required String promptId,
                required String source,
                Value<bool> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                taskId: taskId,
                farmerId: farmerId,
                lotId: lotId,
                eventType: eventType,
                dueDate: dueDate,
                promptId: promptId,
                source: source,
                done: done,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      FarmTask,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (FarmTask, BaseReferences<_$AppDatabase, $TasksTable, FarmTask>),
      FarmTask,
      PrefetchHooks Function()
    >;
typedef $$FlagsTableCreateCompanionBuilder =
    FlagsCompanion Function({
      required String flagId,
      required String farmerId,
      Value<String?> entryId,
      Value<String?> plotId,
      required String type,
      required String severity,
      required String status,
      required String detailJson,
      Value<String?> resolvedReason,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FlagsTableUpdateCompanionBuilder =
    FlagsCompanion Function({
      Value<String> flagId,
      Value<String> farmerId,
      Value<String?> entryId,
      Value<String?> plotId,
      Value<String> type,
      Value<String> severity,
      Value<String> status,
      Value<String> detailJson,
      Value<String?> resolvedReason,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FlagsTableFilterComposer extends Composer<_$AppDatabase, $FlagsTable> {
  $$FlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get flagId =>
      $composableBuilder(column: $table.flagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailJson =>
      $composableBuilder(column: $table.detailJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolvedReason =>
      $composableBuilder(column: $table.resolvedReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FlagsTableOrderingComposer extends Composer<_$AppDatabase, $FlagsTable> {
  $$FlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get flagId =>
      $composableBuilder(column: $table.flagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get farmerId =>
      $composableBuilder(column: $table.farmerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plotId =>
      $composableBuilder(column: $table.plotId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailJson =>
      $composableBuilder(column: $table.detailJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolvedReason =>
      $composableBuilder(column: $table.resolvedReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FlagsTableAnnotationComposer extends Composer<_$AppDatabase, $FlagsTable> {
  $$FlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get flagId => $composableBuilder(column: $table.flagId, builder: (column) => column);

  GeneratedColumn<String> get farmerId => $composableBuilder(column: $table.farmerId, builder: (column) => column);

  GeneratedColumn<String> get entryId => $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get plotId => $composableBuilder(column: $table.plotId, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get severity => $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get status => $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get detailJson => $composableBuilder(column: $table.detailJson, builder: (column) => column);

  GeneratedColumn<String> get resolvedReason =>
      $composableBuilder(column: $table.resolvedReason, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FlagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlagsTable,
          Flag,
          $$FlagsTableFilterComposer,
          $$FlagsTableOrderingComposer,
          $$FlagsTableAnnotationComposer,
          $$FlagsTableCreateCompanionBuilder,
          $$FlagsTableUpdateCompanionBuilder,
          (Flag, BaseReferences<_$AppDatabase, $FlagsTable, Flag>),
          Flag,
          PrefetchHooks Function()
        > {
  $$FlagsTableTableManager(_$AppDatabase db, $FlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> flagId = const Value.absent(),
                Value<String> farmerId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String?> plotId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> detailJson = const Value.absent(),
                Value<String?> resolvedReason = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlagsCompanion(
                flagId: flagId,
                farmerId: farmerId,
                entryId: entryId,
                plotId: plotId,
                type: type,
                severity: severity,
                status: status,
                detailJson: detailJson,
                resolvedReason: resolvedReason,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String flagId,
                required String farmerId,
                Value<String?> entryId = const Value.absent(),
                Value<String?> plotId = const Value.absent(),
                required String type,
                required String severity,
                required String status,
                required String detailJson,
                Value<String?> resolvedReason = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FlagsCompanion.insert(
                flagId: flagId,
                farmerId: farmerId,
                entryId: entryId,
                plotId: plotId,
                type: type,
                severity: severity,
                status: status,
                detailJson: detailJson,
                resolvedReason: resolvedReason,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlagsTable,
      Flag,
      $$FlagsTableFilterComposer,
      $$FlagsTableOrderingComposer,
      $$FlagsTableAnnotationComposer,
      $$FlagsTableCreateCompanionBuilder,
      $$FlagsTableUpdateCompanionBuilder,
      (Flag, BaseReferences<_$AppDatabase, $FlagsTable, Flag>),
      Flag,
      PrefetchHooks Function()
    >;
typedef $$InstrumentsTableCreateCompanionBuilder =
    InstrumentsCompanion Function({
      required String instrumentId,
      required String kind,
      required String label,
      required DateTime calibrationDueDate,
      Value<int> rowid,
    });
typedef $$InstrumentsTableUpdateCompanionBuilder =
    InstrumentsCompanion Function({
      Value<String> instrumentId,
      Value<String> kind,
      Value<String> label,
      Value<DateTime> calibrationDueDate,
      Value<int> rowid,
    });

class $$InstrumentsTableFilterComposer extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instrumentId =>
      $composableBuilder(column: $table.instrumentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get calibrationDueDate =>
      $composableBuilder(column: $table.calibrationDueDate, builder: (column) => ColumnFilters(column));
}

class $$InstrumentsTableOrderingComposer extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instrumentId =>
      $composableBuilder(column: $table.instrumentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get calibrationDueDate =>
      $composableBuilder(column: $table.calibrationDueDate, builder: (column) => ColumnOrderings(column));
}

class $$InstrumentsTableAnnotationComposer extends Composer<_$AppDatabase, $InstrumentsTable> {
  $$InstrumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instrumentId =>
      $composableBuilder(column: $table.instrumentId, builder: (column) => column);

  GeneratedColumn<String> get kind => $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get label => $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get calibrationDueDate =>
      $composableBuilder(column: $table.calibrationDueDate, builder: (column) => column);
}

class $$InstrumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstrumentsTable,
          Instrument,
          $$InstrumentsTableFilterComposer,
          $$InstrumentsTableOrderingComposer,
          $$InstrumentsTableAnnotationComposer,
          $$InstrumentsTableCreateCompanionBuilder,
          $$InstrumentsTableUpdateCompanionBuilder,
          (Instrument, BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>),
          Instrument,
          PrefetchHooks Function()
        > {
  $$InstrumentsTableTableManager(_$AppDatabase db, $InstrumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$InstrumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$InstrumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$InstrumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instrumentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> calibrationDueDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion(
                instrumentId: instrumentId,
                kind: kind,
                label: label,
                calibrationDueDate: calibrationDueDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instrumentId,
                required String kind,
                required String label,
                required DateTime calibrationDueDate,
                Value<int> rowid = const Value.absent(),
              }) => InstrumentsCompanion.insert(
                instrumentId: instrumentId,
                kind: kind,
                label: label,
                calibrationDueDate: calibrationDueDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstrumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstrumentsTable,
      Instrument,
      $$InstrumentsTableFilterComposer,
      $$InstrumentsTableOrderingComposer,
      $$InstrumentsTableAnnotationComposer,
      $$InstrumentsTableCreateCompanionBuilder,
      $$InstrumentsTableUpdateCompanionBuilder,
      (Instrument, BaseReferences<_$AppDatabase, $InstrumentsTable, Instrument>),
      Instrument,
      PrefetchHooks Function()
    >;
typedef $$FieldConfigTableCreateCompanionBuilder =
    FieldConfigCompanion Function({required String entity, required String json, Value<int> rowid});
typedef $$FieldConfigTableUpdateCompanionBuilder =
    FieldConfigCompanion Function({Value<String> entity, Value<String> json, Value<int> rowid});

class $$FieldConfigTableFilterComposer extends Composer<_$AppDatabase, $FieldConfigTable> {
  $$FieldConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get json => $composableBuilder(column: $table.json, builder: (column) => ColumnFilters(column));
}

class $$FieldConfigTableOrderingComposer extends Composer<_$AppDatabase, $FieldConfigTable> {
  $$FieldConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => ColumnOrderings(column));
}

class $$FieldConfigTableAnnotationComposer extends Composer<_$AppDatabase, $FieldConfigTable> {
  $$FieldConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity => $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get json => $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$FieldConfigTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FieldConfigTable,
          FieldConfigEntry,
          $$FieldConfigTableFilterComposer,
          $$FieldConfigTableOrderingComposer,
          $$FieldConfigTableAnnotationComposer,
          $$FieldConfigTableCreateCompanionBuilder,
          $$FieldConfigTableUpdateCompanionBuilder,
          (FieldConfigEntry, BaseReferences<_$AppDatabase, $FieldConfigTable, FieldConfigEntry>),
          FieldConfigEntry,
          PrefetchHooks Function()
        > {
  $$FieldConfigTableTableManager(_$AppDatabase db, $FieldConfigTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FieldConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FieldConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FieldConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldConfigCompanion(entity: entity, json: json, rowid: rowid),
          createCompanionCallback:
              ({required String entity, required String json, Value<int> rowid = const Value.absent()}) =>
                  FieldConfigCompanion.insert(entity: entity, json: json, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FieldConfigTable,
      FieldConfigEntry,
      $$FieldConfigTableFilterComposer,
      $$FieldConfigTableOrderingComposer,
      $$FieldConfigTableAnnotationComposer,
      $$FieldConfigTableCreateCompanionBuilder,
      $$FieldConfigTableUpdateCompanionBuilder,
      (FieldConfigEntry, BaseReferences<_$AppDatabase, $FieldConfigTable, FieldConfigEntry>),
      FieldConfigEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntriesTableTableManager get entries => $$EntriesTableTableManager(_db, _db.entries);
  $$MediaTableTableManager get media => $$MediaTableTableManager(_db, _db.media);
  $$SessionTableTableTableManager get sessionTable => $$SessionTableTableTableManager(_db, _db.sessionTable);
  $$FarmersTableTableManager get farmers => $$FarmersTableTableManager(_db, _db.farmers);
  $$PlotsTableTableManager get plots => $$PlotsTableTableManager(_db, _db.plots);
  $$LotsTableTableManager get lots => $$LotsTableTableManager(_db, _db.lots);
  $$OutboxTableTableManager get outbox => $$OutboxTableTableManager(_db, _db.outbox);
  $$RefBundlesTableTableManager get refBundles => $$RefBundlesTableTableManager(_db, _db.refBundles);
  $$SyncStateTableTableManager get syncState => $$SyncStateTableTableManager(_db, _db.syncState);
  $$SyncMetricsTableTableManager get syncMetrics => $$SyncMetricsTableTableManager(_db, _db.syncMetrics);
  $$TasksTableTableManager get tasks => $$TasksTableTableManager(_db, _db.tasks);
  $$FlagsTableTableManager get flags => $$FlagsTableTableManager(_db, _db.flags);
  $$InstrumentsTableTableManager get instruments => $$InstrumentsTableTableManager(_db, _db.instruments);
  $$FieldConfigTableTableManager get fieldConfig => $$FieldConfigTableTableManager(_db, _db.fieldConfig);
}
