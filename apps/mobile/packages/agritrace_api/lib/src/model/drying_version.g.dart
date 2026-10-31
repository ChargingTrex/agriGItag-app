// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drying_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DryingVersionChangeKindEnum _$dryingVersionChangeKindEnum_create =
    const DryingVersionChangeKindEnum._('create');
const DryingVersionChangeKindEnum _$dryingVersionChangeKindEnum_correct =
    const DryingVersionChangeKindEnum._('correct');
const DryingVersionChangeKindEnum _$dryingVersionChangeKindEnum_undo =
    const DryingVersionChangeKindEnum._('undo');

DryingVersionChangeKindEnum _$dryingVersionChangeKindEnumValueOf(String name) {
  switch (name) {
    case 'create':
      return _$dryingVersionChangeKindEnum_create;
    case 'correct':
      return _$dryingVersionChangeKindEnum_correct;
    case 'undo':
      return _$dryingVersionChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DryingVersionChangeKindEnum>
    _$dryingVersionChangeKindEnumValues =
    BuiltSet<DryingVersionChangeKindEnum>(const <DryingVersionChangeKindEnum>[
  _$dryingVersionChangeKindEnum_create,
  _$dryingVersionChangeKindEnum_correct,
  _$dryingVersionChangeKindEnum_undo,
]);

const DryingVersionEventTypeEnum _$dryingVersionEventTypeEnum_drying =
    const DryingVersionEventTypeEnum._('drying');

DryingVersionEventTypeEnum _$dryingVersionEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'drying':
      return _$dryingVersionEventTypeEnum_drying;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DryingVersionEventTypeEnum> _$dryingVersionEventTypeEnumValues =
    BuiltSet<DryingVersionEventTypeEnum>(const <DryingVersionEventTypeEnum>[
  _$dryingVersionEventTypeEnum_drying,
]);

Serializer<DryingVersionChangeKindEnum>
    _$dryingVersionChangeKindEnumSerializer =
    _$DryingVersionChangeKindEnumSerializer();
Serializer<DryingVersionEventTypeEnum> _$dryingVersionEventTypeEnumSerializer =
    _$DryingVersionEventTypeEnumSerializer();

class _$DryingVersionChangeKindEnumSerializer
    implements PrimitiveSerializer<DryingVersionChangeKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
  };

  @override
  final Iterable<Type> types = const <Type>[DryingVersionChangeKindEnum];
  @override
  final String wireName = 'DryingVersionChangeKindEnum';

  @override
  Object serialize(Serializers serializers, DryingVersionChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DryingVersionChangeKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DryingVersionChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DryingVersionEventTypeEnumSerializer
    implements PrimitiveSerializer<DryingVersionEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'drying': 'drying',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'drying': 'drying',
  };

  @override
  final Iterable<Type> types = const <Type>[DryingVersionEventTypeEnum];
  @override
  final String wireName = 'DryingVersionEventTypeEnum';

  @override
  Object serialize(Serializers serializers, DryingVersionEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DryingVersionEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DryingVersionEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DryingVersion extends DryingVersion {
  @override
  final String? batchId;
  @override
  final DryingVersionChangeKindEnum? changeKind;
  @override
  final ThreeClocks clocks;
  @override
  final String eventId;
  @override
  final DryingVersionEventTypeEnum eventType;
  @override
  final GeoPoint? gps;
  @override
  final int? instanceNo;
  @override
  final String? lotId;
  @override
  final Date? occurredEndOn;
  @override
  final Date occurredOn;
  @override
  final DryingPayload payload;
  @override
  final BuiltList<PhotoIn>? photos;
  @override
  final String? plotId;
  @override
  final String? reasonCode;
  @override
  final String? reasonText;
  @override
  final EventSubject subjectType;
  @override
  final int versionNo;

  factory _$DryingVersion([void Function(DryingVersionBuilder)? updates]) =>
      (DryingVersionBuilder()..update(updates))._build();

  _$DryingVersion._(
      {this.batchId,
      this.changeKind,
      required this.clocks,
      required this.eventId,
      required this.eventType,
      this.gps,
      this.instanceNo,
      this.lotId,
      this.occurredEndOn,
      required this.occurredOn,
      required this.payload,
      this.photos,
      this.plotId,
      this.reasonCode,
      this.reasonText,
      required this.subjectType,
      required this.versionNo})
      : super._();
  @override
  DryingVersion rebuild(void Function(DryingVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DryingVersionBuilder toBuilder() => DryingVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DryingVersion &&
        batchId == other.batchId &&
        changeKind == other.changeKind &&
        clocks == other.clocks &&
        eventId == other.eventId &&
        eventType == other.eventType &&
        gps == other.gps &&
        instanceNo == other.instanceNo &&
        lotId == other.lotId &&
        occurredEndOn == other.occurredEndOn &&
        occurredOn == other.occurredOn &&
        payload == other.payload &&
        photos == other.photos &&
        plotId == other.plotId &&
        reasonCode == other.reasonCode &&
        reasonText == other.reasonText &&
        subjectType == other.subjectType &&
        versionNo == other.versionNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, changeKind.hashCode);
    _$hash = $jc(_$hash, clocks.hashCode);
    _$hash = $jc(_$hash, eventId.hashCode);
    _$hash = $jc(_$hash, eventType.hashCode);
    _$hash = $jc(_$hash, gps.hashCode);
    _$hash = $jc(_$hash, instanceNo.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, occurredEndOn.hashCode);
    _$hash = $jc(_$hash, occurredOn.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jc(_$hash, plotId.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, reasonText.hashCode);
    _$hash = $jc(_$hash, subjectType.hashCode);
    _$hash = $jc(_$hash, versionNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DryingVersion')
          ..add('batchId', batchId)
          ..add('changeKind', changeKind)
          ..add('clocks', clocks)
          ..add('eventId', eventId)
          ..add('eventType', eventType)
          ..add('gps', gps)
          ..add('instanceNo', instanceNo)
          ..add('lotId', lotId)
          ..add('occurredEndOn', occurredEndOn)
          ..add('occurredOn', occurredOn)
          ..add('payload', payload)
          ..add('photos', photos)
          ..add('plotId', plotId)
          ..add('reasonCode', reasonCode)
          ..add('reasonText', reasonText)
          ..add('subjectType', subjectType)
          ..add('versionNo', versionNo))
        .toString();
  }
}

class DryingVersionBuilder
    implements Builder<DryingVersion, DryingVersionBuilder> {
  _$DryingVersion? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  DryingVersionChangeKindEnum? _changeKind;
  DryingVersionChangeKindEnum? get changeKind => _$this._changeKind;
  set changeKind(DryingVersionChangeKindEnum? changeKind) =>
      _$this._changeKind = changeKind;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  DryingVersionEventTypeEnum? _eventType;
  DryingVersionEventTypeEnum? get eventType => _$this._eventType;
  set eventType(DryingVersionEventTypeEnum? eventType) =>
      _$this._eventType = eventType;

  GeoPointBuilder? _gps;
  GeoPointBuilder get gps => _$this._gps ??= GeoPointBuilder();
  set gps(GeoPointBuilder? gps) => _$this._gps = gps;

  int? _instanceNo;
  int? get instanceNo => _$this._instanceNo;
  set instanceNo(int? instanceNo) => _$this._instanceNo = instanceNo;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  Date? _occurredEndOn;
  Date? get occurredEndOn => _$this._occurredEndOn;
  set occurredEndOn(Date? occurredEndOn) =>
      _$this._occurredEndOn = occurredEndOn;

  Date? _occurredOn;
  Date? get occurredOn => _$this._occurredOn;
  set occurredOn(Date? occurredOn) => _$this._occurredOn = occurredOn;

  DryingPayloadBuilder? _payload;
  DryingPayloadBuilder get payload =>
      _$this._payload ??= DryingPayloadBuilder();
  set payload(DryingPayloadBuilder? payload) => _$this._payload = payload;

  ListBuilder<PhotoIn>? _photos;
  ListBuilder<PhotoIn> get photos => _$this._photos ??= ListBuilder<PhotoIn>();
  set photos(ListBuilder<PhotoIn>? photos) => _$this._photos = photos;

  String? _plotId;
  String? get plotId => _$this._plotId;
  set plotId(String? plotId) => _$this._plotId = plotId;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _reasonText;
  String? get reasonText => _$this._reasonText;
  set reasonText(String? reasonText) => _$this._reasonText = reasonText;

  EventSubject? _subjectType;
  EventSubject? get subjectType => _$this._subjectType;
  set subjectType(EventSubject? subjectType) =>
      _$this._subjectType = subjectType;

  int? _versionNo;
  int? get versionNo => _$this._versionNo;
  set versionNo(int? versionNo) => _$this._versionNo = versionNo;

  DryingVersionBuilder() {
    DryingVersion._defaults(this);
  }

  DryingVersionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _changeKind = $v.changeKind;
      _clocks = $v.clocks.toBuilder();
      _eventId = $v.eventId;
      _eventType = $v.eventType;
      _gps = $v.gps?.toBuilder();
      _instanceNo = $v.instanceNo;
      _lotId = $v.lotId;
      _occurredEndOn = $v.occurredEndOn;
      _occurredOn = $v.occurredOn;
      _payload = $v.payload.toBuilder();
      _photos = $v.photos?.toBuilder();
      _plotId = $v.plotId;
      _reasonCode = $v.reasonCode;
      _reasonText = $v.reasonText;
      _subjectType = $v.subjectType;
      _versionNo = $v.versionNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DryingVersion other) {
    _$v = other as _$DryingVersion;
  }

  @override
  void update(void Function(DryingVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DryingVersion build() => _build();

  _$DryingVersion _build() {
    _$DryingVersion _$result;
    try {
      _$result = _$v ??
          _$DryingVersion._(
            batchId: batchId,
            changeKind: changeKind,
            clocks: clocks.build(),
            eventId: BuiltValueNullFieldError.checkNotNull(
                eventId, r'DryingVersion', 'eventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'DryingVersion', 'eventType'),
            gps: _gps?.build(),
            instanceNo: instanceNo,
            lotId: lotId,
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'DryingVersion', 'occurredOn'),
            payload: payload.build(),
            photos: _photos?.build(),
            plotId: plotId,
            reasonCode: reasonCode,
            reasonText: reasonText,
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'DryingVersion', 'subjectType'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'DryingVersion', 'versionNo'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'clocks';
        clocks.build();

        _$failedField = 'gps';
        _gps?.build();

        _$failedField = 'payload';
        payload.build();
        _$failedField = 'photos';
        _photos?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DryingVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
