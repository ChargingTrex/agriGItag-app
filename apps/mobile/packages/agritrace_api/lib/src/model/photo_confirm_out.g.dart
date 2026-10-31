// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_confirm_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PhotoConfirmOutStatusEnum _$photoConfirmOutStatusEnum_received =
    const PhotoConfirmOutStatusEnum._('received');
const PhotoConfirmOutStatusEnum _$photoConfirmOutStatusEnum_missing =
    const PhotoConfirmOutStatusEnum._('missing');

PhotoConfirmOutStatusEnum _$photoConfirmOutStatusEnumValueOf(String name) {
  switch (name) {
    case 'received':
      return _$photoConfirmOutStatusEnum_received;
    case 'missing':
      return _$photoConfirmOutStatusEnum_missing;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PhotoConfirmOutStatusEnum> _$photoConfirmOutStatusEnumValues =
    BuiltSet<PhotoConfirmOutStatusEnum>(const <PhotoConfirmOutStatusEnum>[
  _$photoConfirmOutStatusEnum_received,
  _$photoConfirmOutStatusEnum_missing,
]);

Serializer<PhotoConfirmOutStatusEnum> _$photoConfirmOutStatusEnumSerializer =
    _$PhotoConfirmOutStatusEnumSerializer();

class _$PhotoConfirmOutStatusEnumSerializer
    implements PrimitiveSerializer<PhotoConfirmOutStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'received': 'received',
    'missing': 'missing',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'received': 'received',
    'missing': 'missing',
  };

  @override
  final Iterable<Type> types = const <Type>[PhotoConfirmOutStatusEnum];
  @override
  final String wireName = 'PhotoConfirmOutStatusEnum';

  @override
  Object serialize(Serializers serializers, PhotoConfirmOutStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PhotoConfirmOutStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PhotoConfirmOutStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PhotoConfirmOut extends PhotoConfirmOut {
  @override
  final String clientId;
  @override
  final PhotoConfirmOutStatusEnum status;

  factory _$PhotoConfirmOut([void Function(PhotoConfirmOutBuilder)? updates]) =>
      (PhotoConfirmOutBuilder()..update(updates))._build();

  _$PhotoConfirmOut._({required this.clientId, required this.status})
      : super._();
  @override
  PhotoConfirmOut rebuild(void Function(PhotoConfirmOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhotoConfirmOutBuilder toBuilder() => PhotoConfirmOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhotoConfirmOut &&
        clientId == other.clientId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhotoConfirmOut')
          ..add('clientId', clientId)
          ..add('status', status))
        .toString();
  }
}

class PhotoConfirmOutBuilder
    implements Builder<PhotoConfirmOut, PhotoConfirmOutBuilder> {
  _$PhotoConfirmOut? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  PhotoConfirmOutStatusEnum? _status;
  PhotoConfirmOutStatusEnum? get status => _$this._status;
  set status(PhotoConfirmOutStatusEnum? status) => _$this._status = status;

  PhotoConfirmOutBuilder() {
    PhotoConfirmOut._defaults(this);
  }

  PhotoConfirmOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhotoConfirmOut other) {
    _$v = other as _$PhotoConfirmOut;
  }

  @override
  void update(void Function(PhotoConfirmOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhotoConfirmOut build() => _build();

  _$PhotoConfirmOut _build() {
    final _$result = _$v ??
        _$PhotoConfirmOut._(
          clientId: BuiltValueNullFieldError.checkNotNull(
              clientId, r'PhotoConfirmOut', 'clientId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PhotoConfirmOut', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
