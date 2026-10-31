// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'id_document_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IdDocumentInContentTypeEnum _$idDocumentInContentTypeEnum_imageSlashJpeg =
    const IdDocumentInContentTypeEnum._('imageSlashJpeg');
const IdDocumentInContentTypeEnum _$idDocumentInContentTypeEnum_imageSlashWebp =
    const IdDocumentInContentTypeEnum._('imageSlashWebp');

IdDocumentInContentTypeEnum _$idDocumentInContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashJpeg':
      return _$idDocumentInContentTypeEnum_imageSlashJpeg;
    case 'imageSlashWebp':
      return _$idDocumentInContentTypeEnum_imageSlashWebp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IdDocumentInContentTypeEnum>
    _$idDocumentInContentTypeEnumValues =
    BuiltSet<IdDocumentInContentTypeEnum>(const <IdDocumentInContentTypeEnum>[
  _$idDocumentInContentTypeEnum_imageSlashJpeg,
  _$idDocumentInContentTypeEnum_imageSlashWebp,
]);

Serializer<IdDocumentInContentTypeEnum>
    _$idDocumentInContentTypeEnumSerializer =
    _$IdDocumentInContentTypeEnumSerializer();

class _$IdDocumentInContentTypeEnumSerializer
    implements PrimitiveSerializer<IdDocumentInContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashJpeg': 'image/jpeg',
    'imageSlashWebp': 'image/webp',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/jpeg': 'imageSlashJpeg',
    'image/webp': 'imageSlashWebp',
  };

  @override
  final Iterable<Type> types = const <Type>[IdDocumentInContentTypeEnum];
  @override
  final String wireName = 'IdDocumentInContentTypeEnum';

  @override
  Object serialize(Serializers serializers, IdDocumentInContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IdDocumentInContentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IdDocumentInContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IdDocumentIn extends IdDocumentIn {
  @override
  final String consentRecordId;
  @override
  final IdDocumentInContentTypeEnum contentType;
  @override
  final String docType;
  @override
  final String sha256;

  factory _$IdDocumentIn([void Function(IdDocumentInBuilder)? updates]) =>
      (IdDocumentInBuilder()..update(updates))._build();

  _$IdDocumentIn._(
      {required this.consentRecordId,
      required this.contentType,
      required this.docType,
      required this.sha256})
      : super._();
  @override
  IdDocumentIn rebuild(void Function(IdDocumentInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdDocumentInBuilder toBuilder() => IdDocumentInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IdDocumentIn &&
        consentRecordId == other.consentRecordId &&
        contentType == other.contentType &&
        docType == other.docType &&
        sha256 == other.sha256;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, consentRecordId.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, docType.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IdDocumentIn')
          ..add('consentRecordId', consentRecordId)
          ..add('contentType', contentType)
          ..add('docType', docType)
          ..add('sha256', sha256))
        .toString();
  }
}

class IdDocumentInBuilder
    implements Builder<IdDocumentIn, IdDocumentInBuilder> {
  _$IdDocumentIn? _$v;

  String? _consentRecordId;
  String? get consentRecordId => _$this._consentRecordId;
  set consentRecordId(String? consentRecordId) =>
      _$this._consentRecordId = consentRecordId;

  IdDocumentInContentTypeEnum? _contentType;
  IdDocumentInContentTypeEnum? get contentType => _$this._contentType;
  set contentType(IdDocumentInContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  String? _docType;
  String? get docType => _$this._docType;
  set docType(String? docType) => _$this._docType = docType;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  IdDocumentInBuilder() {
    IdDocumentIn._defaults(this);
  }

  IdDocumentInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _consentRecordId = $v.consentRecordId;
      _contentType = $v.contentType;
      _docType = $v.docType;
      _sha256 = $v.sha256;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IdDocumentIn other) {
    _$v = other as _$IdDocumentIn;
  }

  @override
  void update(void Function(IdDocumentInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IdDocumentIn build() => _build();

  _$IdDocumentIn _build() {
    final _$result = _$v ??
        _$IdDocumentIn._(
          consentRecordId: BuiltValueNullFieldError.checkNotNull(
              consentRecordId, r'IdDocumentIn', 'consentRecordId'),
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'IdDocumentIn', 'contentType'),
          docType: BuiltValueNullFieldError.checkNotNull(
              docType, r'IdDocumentIn', 'docType'),
          sha256: BuiltValueNullFieldError.checkNotNull(
              sha256, r'IdDocumentIn', 'sha256'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
