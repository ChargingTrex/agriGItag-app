// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventOut extends EventOut {
  @override
  final ChangeKind changeKind;
  @override
  final String enteredByUserId;
  @override
  final EventType eventType;
  @override
  final String id;
  @override
  final int instanceNo;
  @override
  final bool isSystemGenerated;
  @override
  final Date? occurredEndOn;
  @override
  final Date occurredOn;
  @override
  final String? onBehalfOfFarmerId;
  @override
  final BuiltMap<String, JsonObject?> payload;
  @override
  final BuiltList<EventPhotoOut> photos;
  @override
  final String? reasonCode;
  @override
  final EventStatus status;
  @override
  final int versionNo;

  factory _$EventOut([void Function(EventOutBuilder)? updates]) =>
      (EventOutBuilder()..update(updates))._build();

  _$EventOut._(
      {required this.changeKind,
      required this.enteredByUserId,
      required this.eventType,
      required this.id,
      required this.instanceNo,
      required this.isSystemGenerated,
      this.occurredEndOn,
      required this.occurredOn,
      this.onBehalfOfFarmerId,
      required this.payload,
      required this.photos,
      this.reasonCode,
      required this.status,
      required this.versionNo})
      : super._();
  @override
  EventOut rebuild(void Function(EventOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventOutBuilder toBuilder() => EventOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventOut &&
        changeKind == other.changeKind &&
        enteredByUserId == other.enteredByUserId &&
        eventType == other.eventType &&
        id == other.id &&
        instanceNo == other.instanceNo &&
        isSystemGenerated == other.isSystemGenerated &&
        occurredEndOn == other.occurredEndOn &&
        occurredOn == other.occurredOn &&
        onBehalfOfFarmerId == other.onBehalfOfFarmerId &&
        payload == other.payload &&
        photos == other.photos &&
        reasonCode == other.reasonCode &&
        status == other.status &&
        versionNo == other.versionNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changeKind.hashCode);
    _$hash = $jc(_$hash, enteredByUserId.hashCode);
    _$hash = $jc(_$hash, eventType.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, instanceNo.hashCode);
    _$hash = $jc(_$hash, isSystemGenerated.hashCode);
    _$hash = $jc(_$hash, occurredEndOn.hashCode);
    _$hash = $jc(_$hash, occurredOn.hashCode);
    _$hash = $jc(_$hash, onBehalfOfFarmerId.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, versionNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventOut')
          ..add('changeKind', changeKind)
          ..add('enteredByUserId', enteredByUserId)
          ..add('eventType', eventType)
          ..add('id', id)
          ..add('instanceNo', instanceNo)
          ..add('isSystemGenerated', isSystemGenerated)
          ..add('occurredEndOn', occurredEndOn)
          ..add('occurredOn', occurredOn)
          ..add('onBehalfOfFarmerId', onBehalfOfFarmerId)
          ..add('payload', payload)
          ..add('photos', photos)
          ..add('reasonCode', reasonCode)
          ..add('status', status)
          ..add('versionNo', versionNo))
        .toString();
  }
}

class EventOutBuilder implements Builder<EventOut, EventOutBuilder> {
  _$EventOut? _$v;

  ChangeKind? _changeKind;
  ChangeKind? get changeKind => _$this._changeKind;
  set changeKind(ChangeKind? changeKind) => _$this._changeKind = changeKind;

  String? _enteredByUserId;
  String? get enteredByUserId => _$this._enteredByUserId;
  set enteredByUserId(String? enteredByUserId) =>
      _$this._enteredByUserId = enteredByUserId;

  EventType? _eventType;
  EventType? get eventType => _$this._eventType;
  set eventType(EventType? eventType) => _$this._eventType = eventType;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _instanceNo;
  int? get instanceNo => _$this._instanceNo;
  set instanceNo(int? instanceNo) => _$this._instanceNo = instanceNo;

  bool? _isSystemGenerated;
  bool? get isSystemGenerated => _$this._isSystemGenerated;
  set isSystemGenerated(bool? isSystemGenerated) =>
      _$this._isSystemGenerated = isSystemGenerated;

  Date? _occurredEndOn;
  Date? get occurredEndOn => _$this._occurredEndOn;
  set occurredEndOn(Date? occurredEndOn) =>
      _$this._occurredEndOn = occurredEndOn;

  Date? _occurredOn;
  Date? get occurredOn => _$this._occurredOn;
  set occurredOn(Date? occurredOn) => _$this._occurredOn = occurredOn;

  String? _onBehalfOfFarmerId;
  String? get onBehalfOfFarmerId => _$this._onBehalfOfFarmerId;
  set onBehalfOfFarmerId(String? onBehalfOfFarmerId) =>
      _$this._onBehalfOfFarmerId = onBehalfOfFarmerId;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  ListBuilder<EventPhotoOut>? _photos;
  ListBuilder<EventPhotoOut> get photos =>
      _$this._photos ??= ListBuilder<EventPhotoOut>();
  set photos(ListBuilder<EventPhotoOut>? photos) => _$this._photos = photos;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  EventStatus? _status;
  EventStatus? get status => _$this._status;
  set status(EventStatus? status) => _$this._status = status;

  int? _versionNo;
  int? get versionNo => _$this._versionNo;
  set versionNo(int? versionNo) => _$this._versionNo = versionNo;

  EventOutBuilder() {
    EventOut._defaults(this);
  }

  EventOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _changeKind = $v.changeKind;
      _enteredByUserId = $v.enteredByUserId;
      _eventType = $v.eventType;
      _id = $v.id;
      _instanceNo = $v.instanceNo;
      _isSystemGenerated = $v.isSystemGenerated;
      _occurredEndOn = $v.occurredEndOn;
      _occurredOn = $v.occurredOn;
      _onBehalfOfFarmerId = $v.onBehalfOfFarmerId;
      _payload = $v.payload.toBuilder();
      _photos = $v.photos.toBuilder();
      _reasonCode = $v.reasonCode;
      _status = $v.status;
      _versionNo = $v.versionNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventOut other) {
    _$v = other as _$EventOut;
  }

  @override
  void update(void Function(EventOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventOut build() => _build();

  _$EventOut _build() {
    _$EventOut _$result;
    try {
      _$result = _$v ??
          _$EventOut._(
            changeKind: BuiltValueNullFieldError.checkNotNull(
                changeKind, r'EventOut', 'changeKind'),
            enteredByUserId: BuiltValueNullFieldError.checkNotNull(
                enteredByUserId, r'EventOut', 'enteredByUserId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'EventOut', 'eventType'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'EventOut', 'id'),
            instanceNo: BuiltValueNullFieldError.checkNotNull(
                instanceNo, r'EventOut', 'instanceNo'),
            isSystemGenerated: BuiltValueNullFieldError.checkNotNull(
                isSystemGenerated, r'EventOut', 'isSystemGenerated'),
            occurredEndOn: occurredEndOn,
            occurredOn: BuiltValueNullFieldError.checkNotNull(
                occurredOn, r'EventOut', 'occurredOn'),
            onBehalfOfFarmerId: onBehalfOfFarmerId,
            payload: payload.build(),
            photos: photos.build(),
            reasonCode: reasonCode,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'EventOut', 'status'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'EventOut', 'versionNo'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
        _$failedField = 'photos';
        photos.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
