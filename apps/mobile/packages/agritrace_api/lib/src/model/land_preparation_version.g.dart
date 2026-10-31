// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'land_preparation_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LandPreparationVersionChangeKindEnum
    _$landPreparationVersionChangeKindEnum_create =
    const LandPreparationVersionChangeKindEnum._('create');
const LandPreparationVersionChangeKindEnum
    _$landPreparationVersionChangeKindEnum_correct =
    const LandPreparationVersionChangeKindEnum._('correct');
const LandPreparationVersionChangeKindEnum
    _$landPreparationVersionChangeKindEnum_undo =
    const LandPreparationVersionChangeKindEnum._('undo');

LandPreparationVersionChangeKindEnum
    _$landPreparationVersionChangeKindEnumValueOf(String name) {
  switch (name) {
    case 'create':
      return _$landPreparationVersionChangeKindEnum_create;
    case 'correct':
      return _$landPreparationVersionChangeKindEnum_correct;
    case 'undo':
      return _$landPreparationVersionChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LandPreparationVersionChangeKindEnum>
    _$landPreparationVersionChangeKindEnumValues = BuiltSet<
        LandPreparationVersionChangeKindEnum>(const <LandPreparationVersionChangeKindEnum>[
  _$landPreparationVersionChangeKindEnum_create,
  _$landPreparationVersionChangeKindEnum_correct,
  _$landPreparationVersionChangeKindEnum_undo,
]);

const LandPreparationVersionEventTypeEnum
    _$landPreparationVersionEventTypeEnum_landPreparation =
    const LandPreparationVersionEventTypeEnum._('landPreparation');

LandPreparationVersionEventTypeEnum
    _$landPreparationVersionEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'landPreparation':
      return _$landPreparationVersionEventTypeEnum_landPreparation;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LandPreparationVersionEventTypeEnum>
    _$landPreparationVersionEventTypeEnumValues = BuiltSet<
        LandPreparationVersionEventTypeEnum>(const <LandPreparationVersionEventTypeEnum>[
  _$landPreparationVersionEventTypeEnum_landPreparation,
]);

Serializer<LandPreparationVersionChangeKindEnum>
    _$landPreparationVersionChangeKindEnumSerializer =
    _$LandPreparationVersionChangeKindEnumSerializer();
Serializer<LandPreparationVersionEventTypeEnum>
    _$landPreparationVersionEventTypeEnumSerializer =
    _$LandPreparationVersionEventTypeEnumSerializer();

class _$LandPreparationVersionChangeKindEnumSerializer
    implements PrimitiveSerializer<LandPreparationVersionChangeKindEnum> {
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
  final Iterable<Type> types = const <Type>[
    LandPreparationVersionChangeKindEnum
  ];
  @override
  final String wireName = 'LandPreparationVersionChangeKindEnum';

  @override
  Object serialize(
          Serializers serializers, LandPreparationVersionChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LandPreparationVersionChangeKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LandPreparationVersionChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LandPreparationVersionEventTypeEnumSerializer
    implements PrimitiveSerializer<LandPreparationVersionEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'landPreparation': 'land_preparation',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'land_preparation': 'landPreparation',
  };

  @override
  final Iterable<Type> types = const <Type>[
    LandPreparationVersionEventTypeEnum
  ];
  @override
  final String wireName = 'LandPreparationVersionEventTypeEnum';

  @override
  Object serialize(
          Serializers serializers, LandPreparationVersionEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LandPreparationVersionEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LandPreparationVersionEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LandPreparationVersion extends LandPreparationVersion {
  @override
  final String? batchId;
  @override
  final LandPreparationVersionChangeKindEnum? changeKind;
  @override
  final ThreeClocks clocks;
  @override
  final String eventId;
  @override
  final LandPreparationVersionEventTypeEnum eventType;
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
  final LandPreparationPayload payload;
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

  factory _$LandPreparationVersion(
          [void Function(LandPreparationVersionBuilder)? updates]) =>
      (LandPreparationVersionBuilder()..update(updates))._build();

  _$LandPreparationVersion._(
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
  LandPreparationVersion rebuild(
          void Function(LandPreparationVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LandPreparationVersionBuilder toBuilder() =>
      LandPreparationVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LandPreparationVersion &&
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
    return (newBuiltValueToStringHelper(r'LandPreparationVersion')
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

class LandPreparationVersionBuilder
    implements Builder<LandPreparationVersion, LandPreparationVersionBuilder> {
  _$LandPreparationVersion? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  LandPreparationVersionChangeKindEnum? _changeKind;
  LandPreparationVersionChangeKindEnum? get changeKind => _$this._changeKind;
  set changeKind(LandPreparationVersionChangeKindEnum? changeKind) =>
      _$this._changeKind = changeKind;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  LandPreparationVersionEventTypeEnum? _eventType;
  LandPreparationVersionEventTypeEnum? get eventType => _$this._eventType;
  set eventType(LandPreparationVersionEventTypeEnum? eventType) =>
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

  LandPreparationPayloadBuilder? _payload;
  LandPreparationPayloadBuilder get payload =>
      _$this._payload ??= LandPreparationPayloadBuilder();
  set payload(LandPreparationPayloadBuilder? payload) =>
      _$this._payload = payload;

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

  LandPreparationVersionBuilder() {
    LandPreparationVersion._defaults(this);
  }

  LandPreparationVersionBuilder get _$this {
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
  void replace(LandPreparationVersion other) {
    _$v = other as _$LandPreparationVersion;
  }

  @override
  void update(void Function(LandPreparationVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LandPreparationVersion build() => _build();

  _$LandPreparationVersion _build() {
    _$LandPreparationVersion _$result;
    try {
      _$result = _$v ??
          _$LandPreparationVersion._(
            batchId: batchId,
            changeKind: changeKind,
            clocks: clocks.build(),
            eventId: BuiltValueNullFieldError.checkNotNull(
                eventId, r'LandPreparationVersion', 'eventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'LandPreparationVersion', 'eventType'),
            gps: _gps?.build(),
            instanceNo: instanceNo,
            lotId: lotId,
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'LandPreparationVersion', 'occurredOn'),
            payload: payload.build(),
            photos: _photos?.build(),
            plotId: plotId,
            reasonCode: reasonCode,
            reasonText: reasonText,
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'LandPreparationVersion', 'subjectType'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'LandPreparationVersion', 'versionNo'),
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
            r'LandPreparationVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
