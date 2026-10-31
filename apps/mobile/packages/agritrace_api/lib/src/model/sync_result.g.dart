// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SyncResultStatusEnum _$syncResultStatusEnum_accepted =
    const SyncResultStatusEnum._('accepted');
const SyncResultStatusEnum _$syncResultStatusEnum_duplicate =
    const SyncResultStatusEnum._('duplicate');
const SyncResultStatusEnum _$syncResultStatusEnum_rejected =
    const SyncResultStatusEnum._('rejected');

SyncResultStatusEnum _$syncResultStatusEnumValueOf(String name) {
  switch (name) {
    case 'accepted':
      return _$syncResultStatusEnum_accepted;
    case 'duplicate':
      return _$syncResultStatusEnum_duplicate;
    case 'rejected':
      return _$syncResultStatusEnum_rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SyncResultStatusEnum> _$syncResultStatusEnumValues =
    BuiltSet<SyncResultStatusEnum>(const <SyncResultStatusEnum>[
  _$syncResultStatusEnum_accepted,
  _$syncResultStatusEnum_duplicate,
  _$syncResultStatusEnum_rejected,
]);

Serializer<SyncResultStatusEnum> _$syncResultStatusEnumSerializer =
    _$SyncResultStatusEnumSerializer();

class _$SyncResultStatusEnumSerializer
    implements PrimitiveSerializer<SyncResultStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'accepted': 'accepted',
    'duplicate': 'duplicate',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'accepted': 'accepted',
    'duplicate': 'duplicate',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[SyncResultStatusEnum];
  @override
  final String wireName = 'SyncResultStatusEnum';

  @override
  Object serialize(Serializers serializers, SyncResultStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SyncResultStatusEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SyncResultStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SyncResult extends SyncResult {
  @override
  final String clientId;
  @override
  final ErrorBody? error;
  @override
  final BuiltList<PhotoUpload>? photoUploads;
  @override
  final String? serverId;
  @override
  final SyncResultStatusEnum status;

  factory _$SyncResult([void Function(SyncResultBuilder)? updates]) =>
      (SyncResultBuilder()..update(updates))._build();

  _$SyncResult._(
      {required this.clientId,
      this.error,
      this.photoUploads,
      this.serverId,
      required this.status})
      : super._();
  @override
  SyncResult rebuild(void Function(SyncResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncResultBuilder toBuilder() => SyncResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncResult &&
        clientId == other.clientId &&
        error == other.error &&
        photoUploads == other.photoUploads &&
        serverId == other.serverId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, photoUploads.hashCode);
    _$hash = $jc(_$hash, serverId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncResult')
          ..add('clientId', clientId)
          ..add('error', error)
          ..add('photoUploads', photoUploads)
          ..add('serverId', serverId)
          ..add('status', status))
        .toString();
  }
}

class SyncResultBuilder implements Builder<SyncResult, SyncResultBuilder> {
  _$SyncResult? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  ErrorBodyBuilder? _error;
  ErrorBodyBuilder get error => _$this._error ??= ErrorBodyBuilder();
  set error(ErrorBodyBuilder? error) => _$this._error = error;

  ListBuilder<PhotoUpload>? _photoUploads;
  ListBuilder<PhotoUpload> get photoUploads =>
      _$this._photoUploads ??= ListBuilder<PhotoUpload>();
  set photoUploads(ListBuilder<PhotoUpload>? photoUploads) =>
      _$this._photoUploads = photoUploads;

  String? _serverId;
  String? get serverId => _$this._serverId;
  set serverId(String? serverId) => _$this._serverId = serverId;

  SyncResultStatusEnum? _status;
  SyncResultStatusEnum? get status => _$this._status;
  set status(SyncResultStatusEnum? status) => _$this._status = status;

  SyncResultBuilder() {
    SyncResult._defaults(this);
  }

  SyncResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _error = $v.error?.toBuilder();
      _photoUploads = $v.photoUploads?.toBuilder();
      _serverId = $v.serverId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncResult other) {
    _$v = other as _$SyncResult;
  }

  @override
  void update(void Function(SyncResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncResult build() => _build();

  _$SyncResult _build() {
    _$SyncResult _$result;
    try {
      _$result = _$v ??
          _$SyncResult._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'SyncResult', 'clientId'),
            error: _error?.build(),
            photoUploads: _photoUploads?.build(),
            serverId: serverId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'SyncResult', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
        _$failedField = 'photoUploads';
        _photoUploads?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
