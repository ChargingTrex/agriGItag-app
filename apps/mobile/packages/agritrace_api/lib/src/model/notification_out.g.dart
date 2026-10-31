// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationOut extends NotificationOut {
  @override
  final NotificationChannel channel;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final String lang;
  @override
  final BuiltMap<String, JsonObject?> payload;
  @override
  final NotificationStatus status;
  @override
  final String templateKey;

  factory _$NotificationOut([void Function(NotificationOutBuilder)? updates]) =>
      (NotificationOutBuilder()..update(updates))._build();

  _$NotificationOut._(
      {required this.channel,
      required this.createdAt,
      required this.id,
      required this.lang,
      required this.payload,
      required this.status,
      required this.templateKey})
      : super._();
  @override
  NotificationOut rebuild(void Function(NotificationOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationOutBuilder toBuilder() => NotificationOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationOut &&
        channel == other.channel &&
        createdAt == other.createdAt &&
        id == other.id &&
        lang == other.lang &&
        payload == other.payload &&
        status == other.status &&
        templateKey == other.templateKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, channel.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, templateKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationOut')
          ..add('channel', channel)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('lang', lang)
          ..add('payload', payload)
          ..add('status', status)
          ..add('templateKey', templateKey))
        .toString();
  }
}

class NotificationOutBuilder
    implements Builder<NotificationOut, NotificationOutBuilder> {
  _$NotificationOut? _$v;

  NotificationChannel? _channel;
  NotificationChannel? get channel => _$this._channel;
  set channel(NotificationChannel? channel) => _$this._channel = channel;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lang;
  String? get lang => _$this._lang;
  set lang(String? lang) => _$this._lang = lang;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  NotificationStatus? _status;
  NotificationStatus? get status => _$this._status;
  set status(NotificationStatus? status) => _$this._status = status;

  String? _templateKey;
  String? get templateKey => _$this._templateKey;
  set templateKey(String? templateKey) => _$this._templateKey = templateKey;

  NotificationOutBuilder() {
    NotificationOut._defaults(this);
  }

  NotificationOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _channel = $v.channel;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _lang = $v.lang;
      _payload = $v.payload.toBuilder();
      _status = $v.status;
      _templateKey = $v.templateKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationOut other) {
    _$v = other as _$NotificationOut;
  }

  @override
  void update(void Function(NotificationOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationOut build() => _build();

  _$NotificationOut _build() {
    _$NotificationOut _$result;
    try {
      _$result = _$v ??
          _$NotificationOut._(
            channel: BuiltValueNullFieldError.checkNotNull(
                channel, r'NotificationOut', 'channel'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'NotificationOut', 'createdAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'NotificationOut', 'id'),
            lang: BuiltValueNullFieldError.checkNotNull(
                lang, r'NotificationOut', 'lang'),
            payload: payload.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'NotificationOut', 'status'),
            templateKey: BuiltValueNullFieldError.checkNotNull(
                templateKey, r'NotificationOut', 'templateKey'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
