// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PhotoUploadMethodEnum _$photoUploadMethodEnum_PUT =
    const PhotoUploadMethodEnum._('PUT');

PhotoUploadMethodEnum _$photoUploadMethodEnumValueOf(String name) {
  switch (name) {
    case 'PUT':
      return _$photoUploadMethodEnum_PUT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PhotoUploadMethodEnum> _$photoUploadMethodEnumValues =
    BuiltSet<PhotoUploadMethodEnum>(const <PhotoUploadMethodEnum>[
  _$photoUploadMethodEnum_PUT,
]);

Serializer<PhotoUploadMethodEnum> _$photoUploadMethodEnumSerializer =
    _$PhotoUploadMethodEnumSerializer();

class _$PhotoUploadMethodEnumSerializer
    implements PrimitiveSerializer<PhotoUploadMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PUT': 'PUT',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PUT': 'PUT',
  };

  @override
  final Iterable<Type> types = const <Type>[PhotoUploadMethodEnum];
  @override
  final String wireName = 'PhotoUploadMethodEnum';

  @override
  Object serialize(Serializers serializers, PhotoUploadMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PhotoUploadMethodEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PhotoUploadMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PhotoUpload extends PhotoUpload {
  @override
  final DateTime expiresAt;
  @override
  final BuiltMap<String, String> headers;
  @override
  final PhotoUploadMethodEnum? method;
  @override
  final String photoClientId;
  @override
  final String url;

  factory _$PhotoUpload([void Function(PhotoUploadBuilder)? updates]) =>
      (PhotoUploadBuilder()..update(updates))._build();

  _$PhotoUpload._(
      {required this.expiresAt,
      required this.headers,
      this.method,
      required this.photoClientId,
      required this.url})
      : super._();
  @override
  PhotoUpload rebuild(void Function(PhotoUploadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhotoUploadBuilder toBuilder() => PhotoUploadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhotoUpload &&
        expiresAt == other.expiresAt &&
        headers == other.headers &&
        method == other.method &&
        photoClientId == other.photoClientId &&
        url == other.url;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, headers.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, photoClientId.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhotoUpload')
          ..add('expiresAt', expiresAt)
          ..add('headers', headers)
          ..add('method', method)
          ..add('photoClientId', photoClientId)
          ..add('url', url))
        .toString();
  }
}

class PhotoUploadBuilder implements Builder<PhotoUpload, PhotoUploadBuilder> {
  _$PhotoUpload? _$v;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  MapBuilder<String, String>? _headers;
  MapBuilder<String, String> get headers =>
      _$this._headers ??= MapBuilder<String, String>();
  set headers(MapBuilder<String, String>? headers) => _$this._headers = headers;

  PhotoUploadMethodEnum? _method;
  PhotoUploadMethodEnum? get method => _$this._method;
  set method(PhotoUploadMethodEnum? method) => _$this._method = method;

  String? _photoClientId;
  String? get photoClientId => _$this._photoClientId;
  set photoClientId(String? photoClientId) =>
      _$this._photoClientId = photoClientId;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  PhotoUploadBuilder() {
    PhotoUpload._defaults(this);
  }

  PhotoUploadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresAt = $v.expiresAt;
      _headers = $v.headers.toBuilder();
      _method = $v.method;
      _photoClientId = $v.photoClientId;
      _url = $v.url;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhotoUpload other) {
    _$v = other as _$PhotoUpload;
  }

  @override
  void update(void Function(PhotoUploadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhotoUpload build() => _build();

  _$PhotoUpload _build() {
    _$PhotoUpload _$result;
    try {
      _$result = _$v ??
          _$PhotoUpload._(
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'PhotoUpload', 'expiresAt'),
            headers: headers.build(),
            method: method,
            photoClientId: BuiltValueNullFieldError.checkNotNull(
                photoClientId, r'PhotoUpload', 'photoClientId'),
            url: BuiltValueNullFieldError.checkNotNull(
                url, r'PhotoUpload', 'url'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'headers';
        headers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PhotoUpload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
