// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GradingVersionChangeKindEnum _$gradingVersionChangeKindEnum_create =
    const GradingVersionChangeKindEnum._('create');
const GradingVersionChangeKindEnum _$gradingVersionChangeKindEnum_correct =
    const GradingVersionChangeKindEnum._('correct');
const GradingVersionChangeKindEnum _$gradingVersionChangeKindEnum_undo =
    const GradingVersionChangeKindEnum._('undo');

GradingVersionChangeKindEnum _$gradingVersionChangeKindEnumValueOf(
    String name) {
  switch (name) {
    case 'create':
      return _$gradingVersionChangeKindEnum_create;
    case 'correct':
      return _$gradingVersionChangeKindEnum_correct;
    case 'undo':
      return _$gradingVersionChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GradingVersionChangeKindEnum>
    _$gradingVersionChangeKindEnumValues =
    BuiltSet<GradingVersionChangeKindEnum>(const <GradingVersionChangeKindEnum>[
  _$gradingVersionChangeKindEnum_create,
  _$gradingVersionChangeKindEnum_correct,
  _$gradingVersionChangeKindEnum_undo,
]);

const GradingVersionEventTypeEnum _$gradingVersionEventTypeEnum_grading =
    const GradingVersionEventTypeEnum._('grading');

GradingVersionEventTypeEnum _$gradingVersionEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'grading':
      return _$gradingVersionEventTypeEnum_grading;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GradingVersionEventTypeEnum>
    _$gradingVersionEventTypeEnumValues =
    BuiltSet<GradingVersionEventTypeEnum>(const <GradingVersionEventTypeEnum>[
  _$gradingVersionEventTypeEnum_grading,
]);

Serializer<GradingVersionChangeKindEnum>
    _$gradingVersionChangeKindEnumSerializer =
    _$GradingVersionChangeKindEnumSerializer();
Serializer<GradingVersionEventTypeEnum>
    _$gradingVersionEventTypeEnumSerializer =
    _$GradingVersionEventTypeEnumSerializer();

class _$GradingVersionChangeKindEnumSerializer
    implements PrimitiveSerializer<GradingVersionChangeKindEnum> {
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
  final Iterable<Type> types = const <Type>[GradingVersionChangeKindEnum];
  @override
  final String wireName = 'GradingVersionChangeKindEnum';

  @override
  Object serialize(Serializers serializers, GradingVersionChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GradingVersionChangeKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GradingVersionChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GradingVersionEventTypeEnumSerializer
    implements PrimitiveSerializer<GradingVersionEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'grading': 'grading',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'grading': 'grading',
  };

  @override
  final Iterable<Type> types = const <Type>[GradingVersionEventTypeEnum];
  @override
  final String wireName = 'GradingVersionEventTypeEnum';

  @override
  Object serialize(Serializers serializers, GradingVersionEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GradingVersionEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GradingVersionEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GradingVersion extends GradingVersion {
  @override
  final String? batchId;
  @override
  final GradingVersionChangeKindEnum? changeKind;
  @override
  final ThreeClocks clocks;
  @override
  final String eventId;
  @override
  final GradingVersionEventTypeEnum eventType;
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
  final GradingPayload payload;
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

  factory _$GradingVersion([void Function(GradingVersionBuilder)? updates]) =>
      (GradingVersionBuilder()..update(updates))._build();

  _$GradingVersion._(
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
  GradingVersion rebuild(void Function(GradingVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GradingVersionBuilder toBuilder() => GradingVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GradingVersion &&
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
    return (newBuiltValueToStringHelper(r'GradingVersion')
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

class GradingVersionBuilder
    implements Builder<GradingVersion, GradingVersionBuilder> {
  _$GradingVersion? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  GradingVersionChangeKindEnum? _changeKind;
  GradingVersionChangeKindEnum? get changeKind => _$this._changeKind;
  set changeKind(GradingVersionChangeKindEnum? changeKind) =>
      _$this._changeKind = changeKind;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  GradingVersionEventTypeEnum? _eventType;
  GradingVersionEventTypeEnum? get eventType => _$this._eventType;
  set eventType(GradingVersionEventTypeEnum? eventType) =>
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

  GradingPayloadBuilder? _payload;
  GradingPayloadBuilder get payload =>
      _$this._payload ??= GradingPayloadBuilder();
  set payload(GradingPayloadBuilder? payload) => _$this._payload = payload;

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

  GradingVersionBuilder() {
    GradingVersion._defaults(this);
  }

  GradingVersionBuilder get _$this {
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
  void replace(GradingVersion other) {
    _$v = other as _$GradingVersion;
  }

  @override
  void update(void Function(GradingVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GradingVersion build() => _build();

  _$GradingVersion _build() {
    _$GradingVersion _$result;
    try {
      _$result = _$v ??
          _$GradingVersion._(
            batchId: batchId,
            changeKind: changeKind,
            clocks: clocks.build(),
            eventId: BuiltValueNullFieldError.checkNotNull(
                eventId, r'GradingVersion', 'eventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'GradingVersion', 'eventType'),
            gps: _gps?.build(),
            instanceNo: instanceNo,
            lotId: lotId,
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'GradingVersion', 'occurredOn'),
            payload: payload.build(),
            photos: _photos?.build(),
            plotId: plotId,
            reasonCode: reasonCode,
            reasonText: reasonText,
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'GradingVersion', 'subjectType'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'GradingVersion', 'versionNo'),
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
            r'GradingVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
