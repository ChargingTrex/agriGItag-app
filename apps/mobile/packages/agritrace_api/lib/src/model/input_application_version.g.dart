// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_application_version.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const InputApplicationVersionChangeKindEnum
    _$inputApplicationVersionChangeKindEnum_create =
    const InputApplicationVersionChangeKindEnum._('create');
const InputApplicationVersionChangeKindEnum
    _$inputApplicationVersionChangeKindEnum_correct =
    const InputApplicationVersionChangeKindEnum._('correct');
const InputApplicationVersionChangeKindEnum
    _$inputApplicationVersionChangeKindEnum_undo =
    const InputApplicationVersionChangeKindEnum._('undo');

InputApplicationVersionChangeKindEnum
    _$inputApplicationVersionChangeKindEnumValueOf(String name) {
  switch (name) {
    case 'create':
      return _$inputApplicationVersionChangeKindEnum_create;
    case 'correct':
      return _$inputApplicationVersionChangeKindEnum_correct;
    case 'undo':
      return _$inputApplicationVersionChangeKindEnum_undo;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InputApplicationVersionChangeKindEnum>
    _$inputApplicationVersionChangeKindEnumValues = BuiltSet<
        InputApplicationVersionChangeKindEnum>(const <InputApplicationVersionChangeKindEnum>[
  _$inputApplicationVersionChangeKindEnum_create,
  _$inputApplicationVersionChangeKindEnum_correct,
  _$inputApplicationVersionChangeKindEnum_undo,
]);

const InputApplicationVersionEventTypeEnum
    _$inputApplicationVersionEventTypeEnum_inputApplication =
    const InputApplicationVersionEventTypeEnum._('inputApplication');

InputApplicationVersionEventTypeEnum
    _$inputApplicationVersionEventTypeEnumValueOf(String name) {
  switch (name) {
    case 'inputApplication':
      return _$inputApplicationVersionEventTypeEnum_inputApplication;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<InputApplicationVersionEventTypeEnum>
    _$inputApplicationVersionEventTypeEnumValues = BuiltSet<
        InputApplicationVersionEventTypeEnum>(const <InputApplicationVersionEventTypeEnum>[
  _$inputApplicationVersionEventTypeEnum_inputApplication,
]);

Serializer<InputApplicationVersionChangeKindEnum>
    _$inputApplicationVersionChangeKindEnumSerializer =
    _$InputApplicationVersionChangeKindEnumSerializer();
Serializer<InputApplicationVersionEventTypeEnum>
    _$inputApplicationVersionEventTypeEnumSerializer =
    _$InputApplicationVersionEventTypeEnumSerializer();

class _$InputApplicationVersionChangeKindEnumSerializer
    implements PrimitiveSerializer<InputApplicationVersionChangeKindEnum> {
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
    InputApplicationVersionChangeKindEnum
  ];
  @override
  final String wireName = 'InputApplicationVersionChangeKindEnum';

  @override
  Object serialize(
          Serializers serializers, InputApplicationVersionChangeKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InputApplicationVersionChangeKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InputApplicationVersionChangeKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$InputApplicationVersionEventTypeEnumSerializer
    implements PrimitiveSerializer<InputApplicationVersionEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'inputApplication': 'input_application',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'input_application': 'inputApplication',
  };

  @override
  final Iterable<Type> types = const <Type>[
    InputApplicationVersionEventTypeEnum
  ];
  @override
  final String wireName = 'InputApplicationVersionEventTypeEnum';

  @override
  Object serialize(
          Serializers serializers, InputApplicationVersionEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  InputApplicationVersionEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      InputApplicationVersionEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$InputApplicationVersion extends InputApplicationVersion {
  @override
  final String? batchId;
  @override
  final InputApplicationVersionChangeKindEnum? changeKind;
  @override
  final ThreeClocks clocks;
  @override
  final String eventId;
  @override
  final InputApplicationVersionEventTypeEnum eventType;
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
  final InputApplicationPayload payload;
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

  factory _$InputApplicationVersion(
          [void Function(InputApplicationVersionBuilder)? updates]) =>
      (InputApplicationVersionBuilder()..update(updates))._build();

  _$InputApplicationVersion._(
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
  InputApplicationVersion rebuild(
          void Function(InputApplicationVersionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InputApplicationVersionBuilder toBuilder() =>
      InputApplicationVersionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InputApplicationVersion &&
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
    return (newBuiltValueToStringHelper(r'InputApplicationVersion')
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

class InputApplicationVersionBuilder
    implements
        Builder<InputApplicationVersion, InputApplicationVersionBuilder> {
  _$InputApplicationVersion? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  InputApplicationVersionChangeKindEnum? _changeKind;
  InputApplicationVersionChangeKindEnum? get changeKind => _$this._changeKind;
  set changeKind(InputApplicationVersionChangeKindEnum? changeKind) =>
      _$this._changeKind = changeKind;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  InputApplicationVersionEventTypeEnum? _eventType;
  InputApplicationVersionEventTypeEnum? get eventType => _$this._eventType;
  set eventType(InputApplicationVersionEventTypeEnum? eventType) =>
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

  InputApplicationPayloadBuilder? _payload;
  InputApplicationPayloadBuilder get payload =>
      _$this._payload ??= InputApplicationPayloadBuilder();
  set payload(InputApplicationPayloadBuilder? payload) =>
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

  InputApplicationVersionBuilder() {
    InputApplicationVersion._defaults(this);
  }

  InputApplicationVersionBuilder get _$this {
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
  void replace(InputApplicationVersion other) {
    _$v = other as _$InputApplicationVersion;
  }

  @override
  void update(void Function(InputApplicationVersionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InputApplicationVersion build() => _build();

  _$InputApplicationVersion _build() {
    _$InputApplicationVersion _$result;
    try {
      _$result = _$v ??
          _$InputApplicationVersion._(
            batchId: batchId,
            changeKind: changeKind,
            clocks: clocks.build(),
            eventId: BuiltValueNullFieldError.checkNotNull(
                eventId, r'InputApplicationVersion', 'eventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'InputApplicationVersion', 'eventType'),
            gps: _gps?.build(),
            instanceNo: instanceNo,
            lotId: lotId,
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'InputApplicationVersion', 'occurredOn'),
            payload: payload.build(),
            photos: _photos?.build(),
            plotId: plotId,
            reasonCode: reasonCode,
            reasonText: reasonText,
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'InputApplicationVersion', 'subjectType'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'InputApplicationVersion', 'versionNo'),
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
            r'InputApplicationVersion', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
