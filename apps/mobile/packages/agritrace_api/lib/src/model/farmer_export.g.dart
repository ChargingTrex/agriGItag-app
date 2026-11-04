// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_export.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerExport extends FarmerExport {
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> assistSessions;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> auditLog;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> batchShares;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> consents;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> devices;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> eventVersions;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> evidencePhotos;
  @override
  final BuiltMap<String, JsonObject?> farmer;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> idDocuments;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> intakes;
  @override
  final DateTime linksExpireAt;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> lots;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> notifications;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> plots;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>?> qualityReadings;
  @override
  final BuiltMap<String, JsonObject?>? user;

  factory _$FarmerExport([void Function(FarmerExportBuilder)? updates]) =>
      (FarmerExportBuilder()..update(updates))._build();

  _$FarmerExport._(
      {required this.assistSessions,
      required this.auditLog,
      required this.batchShares,
      required this.consents,
      required this.devices,
      required this.eventVersions,
      required this.evidencePhotos,
      required this.farmer,
      required this.idDocuments,
      required this.intakes,
      required this.linksExpireAt,
      required this.lots,
      required this.notifications,
      required this.plots,
      required this.qualityReadings,
      this.user})
      : super._();
  @override
  FarmerExport rebuild(void Function(FarmerExportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerExportBuilder toBuilder() => FarmerExportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerExport &&
        assistSessions == other.assistSessions &&
        auditLog == other.auditLog &&
        batchShares == other.batchShares &&
        consents == other.consents &&
        devices == other.devices &&
        eventVersions == other.eventVersions &&
        evidencePhotos == other.evidencePhotos &&
        farmer == other.farmer &&
        idDocuments == other.idDocuments &&
        intakes == other.intakes &&
        linksExpireAt == other.linksExpireAt &&
        lots == other.lots &&
        notifications == other.notifications &&
        plots == other.plots &&
        qualityReadings == other.qualityReadings &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assistSessions.hashCode);
    _$hash = $jc(_$hash, auditLog.hashCode);
    _$hash = $jc(_$hash, batchShares.hashCode);
    _$hash = $jc(_$hash, consents.hashCode);
    _$hash = $jc(_$hash, devices.hashCode);
    _$hash = $jc(_$hash, eventVersions.hashCode);
    _$hash = $jc(_$hash, evidencePhotos.hashCode);
    _$hash = $jc(_$hash, farmer.hashCode);
    _$hash = $jc(_$hash, idDocuments.hashCode);
    _$hash = $jc(_$hash, intakes.hashCode);
    _$hash = $jc(_$hash, linksExpireAt.hashCode);
    _$hash = $jc(_$hash, lots.hashCode);
    _$hash = $jc(_$hash, notifications.hashCode);
    _$hash = $jc(_$hash, plots.hashCode);
    _$hash = $jc(_$hash, qualityReadings.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerExport')
          ..add('assistSessions', assistSessions)
          ..add('auditLog', auditLog)
          ..add('batchShares', batchShares)
          ..add('consents', consents)
          ..add('devices', devices)
          ..add('eventVersions', eventVersions)
          ..add('evidencePhotos', evidencePhotos)
          ..add('farmer', farmer)
          ..add('idDocuments', idDocuments)
          ..add('intakes', intakes)
          ..add('linksExpireAt', linksExpireAt)
          ..add('lots', lots)
          ..add('notifications', notifications)
          ..add('plots', plots)
          ..add('qualityReadings', qualityReadings)
          ..add('user', user))
        .toString();
  }
}

class FarmerExportBuilder
    implements Builder<FarmerExport, FarmerExportBuilder> {
  _$FarmerExport? _$v;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _assistSessions;
  ListBuilder<BuiltMap<String, JsonObject?>?> get assistSessions =>
      _$this._assistSessions ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set assistSessions(
          ListBuilder<BuiltMap<String, JsonObject?>?>? assistSessions) =>
      _$this._assistSessions = assistSessions;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _auditLog;
  ListBuilder<BuiltMap<String, JsonObject?>?> get auditLog =>
      _$this._auditLog ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set auditLog(ListBuilder<BuiltMap<String, JsonObject?>?>? auditLog) =>
      _$this._auditLog = auditLog;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _batchShares;
  ListBuilder<BuiltMap<String, JsonObject?>?> get batchShares =>
      _$this._batchShares ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set batchShares(ListBuilder<BuiltMap<String, JsonObject?>?>? batchShares) =>
      _$this._batchShares = batchShares;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _consents;
  ListBuilder<BuiltMap<String, JsonObject?>?> get consents =>
      _$this._consents ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set consents(ListBuilder<BuiltMap<String, JsonObject?>?>? consents) =>
      _$this._consents = consents;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _devices;
  ListBuilder<BuiltMap<String, JsonObject?>?> get devices =>
      _$this._devices ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set devices(ListBuilder<BuiltMap<String, JsonObject?>?>? devices) =>
      _$this._devices = devices;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _eventVersions;
  ListBuilder<BuiltMap<String, JsonObject?>?> get eventVersions =>
      _$this._eventVersions ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set eventVersions(
          ListBuilder<BuiltMap<String, JsonObject?>?>? eventVersions) =>
      _$this._eventVersions = eventVersions;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _evidencePhotos;
  ListBuilder<BuiltMap<String, JsonObject?>?> get evidencePhotos =>
      _$this._evidencePhotos ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set evidencePhotos(
          ListBuilder<BuiltMap<String, JsonObject?>?>? evidencePhotos) =>
      _$this._evidencePhotos = evidencePhotos;

  MapBuilder<String, JsonObject?>? _farmer;
  MapBuilder<String, JsonObject?> get farmer =>
      _$this._farmer ??= MapBuilder<String, JsonObject?>();
  set farmer(MapBuilder<String, JsonObject?>? farmer) =>
      _$this._farmer = farmer;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _idDocuments;
  ListBuilder<BuiltMap<String, JsonObject?>?> get idDocuments =>
      _$this._idDocuments ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set idDocuments(ListBuilder<BuiltMap<String, JsonObject?>?>? idDocuments) =>
      _$this._idDocuments = idDocuments;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _intakes;
  ListBuilder<BuiltMap<String, JsonObject?>?> get intakes =>
      _$this._intakes ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set intakes(ListBuilder<BuiltMap<String, JsonObject?>?>? intakes) =>
      _$this._intakes = intakes;

  DateTime? _linksExpireAt;
  DateTime? get linksExpireAt => _$this._linksExpireAt;
  set linksExpireAt(DateTime? linksExpireAt) =>
      _$this._linksExpireAt = linksExpireAt;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _lots;
  ListBuilder<BuiltMap<String, JsonObject?>?> get lots =>
      _$this._lots ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set lots(ListBuilder<BuiltMap<String, JsonObject?>?>? lots) =>
      _$this._lots = lots;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _notifications;
  ListBuilder<BuiltMap<String, JsonObject?>?> get notifications =>
      _$this._notifications ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set notifications(
          ListBuilder<BuiltMap<String, JsonObject?>?>? notifications) =>
      _$this._notifications = notifications;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _plots;
  ListBuilder<BuiltMap<String, JsonObject?>?> get plots =>
      _$this._plots ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set plots(ListBuilder<BuiltMap<String, JsonObject?>?>? plots) =>
      _$this._plots = plots;

  ListBuilder<BuiltMap<String, JsonObject?>?>? _qualityReadings;
  ListBuilder<BuiltMap<String, JsonObject?>?> get qualityReadings =>
      _$this._qualityReadings ??= ListBuilder<BuiltMap<String, JsonObject?>?>();
  set qualityReadings(
          ListBuilder<BuiltMap<String, JsonObject?>?>? qualityReadings) =>
      _$this._qualityReadings = qualityReadings;

  MapBuilder<String, JsonObject?>? _user;
  MapBuilder<String, JsonObject?> get user =>
      _$this._user ??= MapBuilder<String, JsonObject?>();
  set user(MapBuilder<String, JsonObject?>? user) => _$this._user = user;

  FarmerExportBuilder() {
    FarmerExport._defaults(this);
  }

  FarmerExportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assistSessions = $v.assistSessions.toBuilder();
      _auditLog = $v.auditLog.toBuilder();
      _batchShares = $v.batchShares.toBuilder();
      _consents = $v.consents.toBuilder();
      _devices = $v.devices.toBuilder();
      _eventVersions = $v.eventVersions.toBuilder();
      _evidencePhotos = $v.evidencePhotos.toBuilder();
      _farmer = $v.farmer.toBuilder();
      _idDocuments = $v.idDocuments.toBuilder();
      _intakes = $v.intakes.toBuilder();
      _linksExpireAt = $v.linksExpireAt;
      _lots = $v.lots.toBuilder();
      _notifications = $v.notifications.toBuilder();
      _plots = $v.plots.toBuilder();
      _qualityReadings = $v.qualityReadings.toBuilder();
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerExport other) {
    _$v = other as _$FarmerExport;
  }

  @override
  void update(void Function(FarmerExportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerExport build() => _build();

  _$FarmerExport _build() {
    _$FarmerExport _$result;
    try {
      _$result = _$v ??
          _$FarmerExport._(
            assistSessions: assistSessions.build(),
            auditLog: auditLog.build(),
            batchShares: batchShares.build(),
            consents: consents.build(),
            devices: devices.build(),
            eventVersions: eventVersions.build(),
            evidencePhotos: evidencePhotos.build(),
            farmer: farmer.build(),
            idDocuments: idDocuments.build(),
            intakes: intakes.build(),
            linksExpireAt: BuiltValueNullFieldError.checkNotNull(
                linksExpireAt, r'FarmerExport', 'linksExpireAt'),
            lots: lots.build(),
            notifications: notifications.build(),
            plots: plots.build(),
            qualityReadings: qualityReadings.build(),
            user: _user?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'assistSessions';
        assistSessions.build();
        _$failedField = 'auditLog';
        auditLog.build();
        _$failedField = 'batchShares';
        batchShares.build();
        _$failedField = 'consents';
        consents.build();
        _$failedField = 'devices';
        devices.build();
        _$failedField = 'eventVersions';
        eventVersions.build();
        _$failedField = 'evidencePhotos';
        evidencePhotos.build();
        _$failedField = 'farmer';
        farmer.build();
        _$failedField = 'idDocuments';
        idDocuments.build();
        _$failedField = 'intakes';
        intakes.build();

        _$failedField = 'lots';
        lots.build();
        _$failedField = 'notifications';
        notifications.build();
        _$failedField = 'plots';
        plots.build();
        _$failedField = 'qualityReadings';
        qualityReadings.build();
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FarmerExport', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
