// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IntakeVersionChangeKindEnum _$intakeVersionChangeKindEnum_create =
    const IntakeVersionChangeKindEnum._('create');
const IntakeVersionChangeKindEnum _$intakeVersionChangeKindEnum_correct =
    const IntakeVersionChangeKindEnum._('correct');
const IntakeVersionChangeKindEnum _$intakeVersionChangeKindEnum_undo =
    const IntakeVersionChangeKindEnum._('undo');

IntakeVersionChangeKindEnum _$intakeVersionChangeKindEnumValueOf(String name) {
  switch (name) {
    case 'create':
      return _$intakeVersionChangeKindEnum_create;
    case 'correct':
      return _$intakeVersionChangeKindEnum_correct;
    case 'undo':
      return _$intakeVersionChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IntakeVersionChangeKindEnum>
    _$intakeVersionChangeKindEnumValues =
    BuiltSet<IntakeVersionChangeKindEnum>(const <IntakeVersionChangeKindEnum>[
  _$intakeVersionChangeKindEnum_create,
  _$intakeVersionChangeKindEnum_correct,
  _$intakeVersionChangeKindEnum_undo,
]);

const IntakeVersionEventTypeEnum _$intakeVersionEventTypeEnum_intake =
    const IntakeVersionEventTypeEnum._('intake');

IntakeVersionEventTypeEnum _$intakeVersionEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'intake':
      return _$intakeVersionEventTypeEnum_intake;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IntakeVersionEventTypeEnum> _$intakeVersionEventTypeEnumValues =
    BuiltSet<IntakeVersionEventTypeEnum>(const <IntakeVersionEventTypeEnum>[
  _$intakeVersionEventTypeEnum_intake,
]);

Serializer<IntakeVersionChangeKindEnum>
    _$intakeVersionChangeKindEnumSerializer =
    _$IntakeVersionChangeKindEnumSerializer();
Serializer<IntakeVersionEventTypeEnum> _$intakeVersionEventTypeEnumSerializer =
    _$IntakeVersionEventTypeEnumSerializer();

class _$IntakeVersionChangeKindEnumSerializer
    implements PrimitiveSerializer<IntakeVersionChangeKindEnum> {
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
  final Iterable<Type> types = const <Type>[IntakeVersionChangeKindEnum];
  @override
  final String wireName = 'IntakeVersionChangeKindEnum';

  @override
  Object serialize(Serializers serializers, IntakeVersionChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IntakeVersionChangeKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IntakeVersionChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IntakeVersionEventTypeEnumSerializer
    implements PrimitiveSerializer<IntakeVersionEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'intake': 'intake',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'intake': 'intake',
  };

  @override
  final Iterable<Type> types = const <Type>[IntakeVersionEventTypeEnum];
  @override
  final String wireName = 'IntakeVersionEventTypeEnum';

  @override
  Object serialize(Serializers serializers, IntakeVersionEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IntakeVersionEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IntakeVersionEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IntakeVersion extends IntakeVersion {
  @override
  final String? batchId;
  @override
  final IntakeVersionChangeKindEnum? changeKind;
  @override
  final ThreeClocks clocks;
  @override
  final String eventId;
  @override
  final IntakeVersionEventTypeEnum eventType;
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
  final IntakePayload payload;
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

  factory _$IntakeVersion([void Function(IntakeVersionBuilder)? updates]) =>
      (IntakeVersionBuilder()..update(updates))._build();

  _$IntakeVersion._(
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
  IntakeVersion rebuild(void Function(IntakeVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IntakeVersionBuilder toBuilder() => IntakeVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IntakeVersion &&
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
    return (newBuiltValueToStringHelper(r'IntakeVersion')
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

class IntakeVersionBuilder
    implements Builder<IntakeVersion, IntakeVersionBuilder> {
  _$IntakeVersion? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  IntakeVersionChangeKindEnum? _changeKind;
  IntakeVersionChangeKindEnum? get changeKind => _$this._changeKind;
  set changeKind(IntakeVersionChangeKindEnum? changeKind) =>
      _$this._changeKind = changeKind;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  IntakeVersionEventTypeEnum? _eventType;
  IntakeVersionEventTypeEnum? get eventType => _$this._eventType;
  set eventType(IntakeVersionEventTypeEnum? eventType) =>
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

  IntakePayloadBuilder? _payload;
  IntakePayloadBuilder get payload =>
      _$this._payload ??= IntakePayloadBuilder();
  set payload(IntakePayloadBuilder? payload) => _$this._payload = payload;

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

  IntakeVersionBuilder() {
    IntakeVersion._defaults(this);
  }

  IntakeVersionBuilder get _$this {
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
  void replace(IntakeVersion other) {
    _$v = other as _$IntakeVersion;
  }

  @override
  void update(void Function(IntakeVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IntakeVersion build() => _build();

  _$IntakeVersion _build() {
    _$IntakeVersion _$result;
    try {
      _$result = _$v ??
          _$IntakeVersion._(
            batchId: batchId,
            changeKind: changeKind,
            clocks: clocks.build(),
            eventId: BuiltValueNullFieldError.checkNotNull(
                eventId, r'IntakeVersion', 'eventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'IntakeVersion', 'eventType'),
            gps: _gps?.build(),
            instanceNo: instanceNo,
            lotId: lotId,
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'IntakeVersion', 'occurredOn'),
            payload: payload.build(),
            photos: _photos?.build(),
            plotId: plotId,
            reasonCode: reasonCode,
            reasonText: reasonText,
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'IntakeVersion', 'subjectType'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'IntakeVersion', 'versionNo'),
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
            r'IntakeVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
