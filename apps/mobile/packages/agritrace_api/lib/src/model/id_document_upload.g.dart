// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_document_upload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IdDocumentUploadMethodEnum _$idDocumentUploadMethodEnum_PUT =
    const IdDocumentUploadMethodEnum._('PUT');

IdDocumentUploadMethodEnum _$idDocumentUploadMethodEnumValueOf(String name) {
  switch (name) {
    case 'PUT':
      return _$idDocumentUploadMethodEnum_PUT;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IdDocumentUploadMethodEnum> _$idDocumentUploadMethodEnumValues =
    BuiltSet<IdDocumentUploadMethodEnum>(const <IdDocumentUploadMethodEnum>[
  _$idDocumentUploadMethodEnum_PUT,
]);

Serializer<IdDocumentUploadMethodEnum> _$idDocumentUploadMethodEnumSerializer =
    _$IdDocumentUploadMethodEnumSerializer();

class _$IdDocumentUploadMethodEnumSerializer
    implements PrimitiveSerializer<IdDocumentUploadMethodEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'PUT': 'PUT',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'PUT': 'PUT',
  };

  @override
  final Iterable<Type> types = const <Type>[IdDocumentUploadMethodEnum];
  @override
  final String wireName = 'IdDocumentUploadMethodEnum';

  @override
  Object serialize(Serializers serializers, IdDocumentUploadMethodEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IdDocumentUploadMethodEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IdDocumentUploadMethodEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IdDocumentUpload extends IdDocumentUpload {
  @override
  final DateTime expiresAt;
  @override
  final BuiltMap<String, String> headers;
  @override
  final String id;
  @override
  final IdDocumentUploadMethodEnum method;
  @override
  final String url;

  factory _$IdDocumentUpload(
          [void Function(IdDocumentUploadBuilder)? updates]) =>
      (IdDocumentUploadBuilder()..update(updates))._build();

  _$IdDocumentUpload._(
      {required this.expiresAt,
      required this.headers,
      required this.id,
      required this.method,
      required this.url})
      : super._();
  @override
  IdDocumentUpload rebuild(void Function(IdDocumentUploadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdDocumentUploadBuilder toBuilder() =>
      IdDocumentUploadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IdDocumentUpload &&
        expiresAt == other.expiresAt &&
        headers == other.headers &&
        id == other.id &&
        method == other.method &&
        url == other.url;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, headers.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IdDocumentUpload')
          ..add('expiresAt', expiresAt)
          ..add('headers', headers)
          ..add('id', id)
          ..add('method', method)
          ..add('url', url))
        .toString();
  }
}

class IdDocumentUploadBuilder
    implements Builder<IdDocumentUpload, IdDocumentUploadBuilder> {
  _$IdDocumentUpload? _$v;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  MapBuilder<String, String>? _headers;
  MapBuilder<String, String> get headers =>
      _$this._headers ??= MapBuilder<String, String>();
  set headers(MapBuilder<String, String>? headers) => _$this._headers = headers;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  IdDocumentUploadMethodEnum? _method;
  IdDocumentUploadMethodEnum? get method => _$this._method;
  set method(IdDocumentUploadMethodEnum? method) => _$this._method = method;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  IdDocumentUploadBuilder() {
    IdDocumentUpload._defaults(this);
  }

  IdDocumentUploadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresAt = $v.expiresAt;
      _headers = $v.headers.toBuilder();
      _id = $v.id;
      _method = $v.method;
      _url = $v.url;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IdDocumentUpload other) {
    _$v = other as _$IdDocumentUpload;
  }

  @override
  void update(void Function(IdDocumentUploadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IdDocumentUpload build() => _build();

  _$IdDocumentUpload _build() {
    _$IdDocumentUpload _$result;
    try {
      _$result = _$v ??
          _$IdDocumentUpload._(
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'IdDocumentUpload', 'expiresAt'),
            headers: headers.build(),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'IdDocumentUpload', 'id'),
            method: BuiltValueNullFieldError.checkNotNull(
                method, r'IdDocumentUpload', 'method'),
            url: BuiltValueNullFieldError.checkNotNull(
                url, r'IdDocumentUpload', 'url'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'headers';
        headers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IdDocumentUpload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
