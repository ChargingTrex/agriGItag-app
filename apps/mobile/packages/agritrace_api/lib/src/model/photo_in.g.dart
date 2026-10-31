// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PhotoInContentTypeEnum _$photoInContentTypeEnum_imageSlashJpeg =
    const PhotoInContentTypeEnum._('imageSlashJpeg');
const PhotoInContentTypeEnum _$photoInContentTypeEnum_audioSlashOgg =
    const PhotoInContentTypeEnum._('audioSlashOgg');
const PhotoInContentTypeEnum _$photoInContentTypeEnum_audioSlashMp4 =
    const PhotoInContentTypeEnum._('audioSlashMp4');

PhotoInContentTypeEnum _$photoInContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashJpeg':
      return _$photoInContentTypeEnum_imageSlashJpeg;
    case 'audioSlashOgg':
      return _$photoInContentTypeEnum_audioSlashOgg;
    case 'audioSlashMp4':
      return _$photoInContentTypeEnum_audioSlashMp4;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PhotoInContentTypeEnum> _$photoInContentTypeEnumValues =
    BuiltSet<PhotoInContentTypeEnum>(const <PhotoInContentTypeEnum>[
  _$photoInContentTypeEnum_imageSlashJpeg,
  _$photoInContentTypeEnum_audioSlashOgg,
  _$photoInContentTypeEnum_audioSlashMp4,
]);

Serializer<PhotoInContentTypeEnum> _$photoInContentTypeEnumSerializer =
    _$PhotoInContentTypeEnumSerializer();

class _$PhotoInContentTypeEnumSerializer
    implements PrimitiveSerializer<PhotoInContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashJpeg': 'image/jpeg',
    'audioSlashOgg': 'audio/ogg',
    'audioSlashMp4': 'audio/mp4',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/jpeg': 'imageSlashJpeg',
    'audio/ogg': 'audioSlashOgg',
    'audio/mp4': 'audioSlashMp4',
  };

  @override
  final Iterable<Type> types = const <Type>[PhotoInContentTypeEnum];
  @override
  final String wireName = 'PhotoInContentTypeEnum';

  @override
  Object serialize(Serializers serializers, PhotoInContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PhotoInContentTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PhotoInContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PhotoIn extends PhotoIn {
  @override
  final String clientId;
  @override
  final PhotoInContentTypeEnum? contentType;
  @override
  final GeoPoint? exifGps;
  @override
  final DateTime? exifTakenAt;
  @override
  final String sha256;
  @override
  final int sizeBytes;

  factory _$PhotoIn([void Function(PhotoInBuilder)? updates]) =>
      (PhotoInBuilder()..update(updates))._build();

  _$PhotoIn._(
      {required this.clientId,
      this.contentType,
      this.exifGps,
      this.exifTakenAt,
      required this.sha256,
      required this.sizeBytes})
      : super._();
  @override
  PhotoIn rebuild(void Function(PhotoInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhotoInBuilder toBuilder() => PhotoInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhotoIn &&
        clientId == other.clientId &&
        contentType == other.contentType &&
        exifGps == other.exifGps &&
        exifTakenAt == other.exifTakenAt &&
        sha256 == other.sha256 &&
        sizeBytes == other.sizeBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, exifGps.hashCode);
    _$hash = $jc(_$hash, exifTakenAt.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhotoIn')
          ..add('clientId', clientId)
          ..add('contentType', contentType)
          ..add('exifGps', exifGps)
          ..add('exifTakenAt', exifTakenAt)
          ..add('sha256', sha256)
          ..add('sizeBytes', sizeBytes))
        .toString();
  }
}

class PhotoInBuilder implements Builder<PhotoIn, PhotoInBuilder> {
  _$PhotoIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  PhotoInContentTypeEnum? _contentType;
  PhotoInContentTypeEnum? get contentType => _$this._contentType;
  set contentType(PhotoInContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  GeoPointBuilder? _exifGps;
  GeoPointBuilder get exifGps => _$this._exifGps ??= GeoPointBuilder();
  set exifGps(GeoPointBuilder? exifGps) => _$this._exifGps = exifGps;

  DateTime? _exifTakenAt;
  DateTime? get exifTakenAt => _$this._exifTakenAt;
  set exifTakenAt(DateTime? exifTakenAt) => _$this._exifTakenAt = exifTakenAt;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  PhotoInBuilder() {
    PhotoIn._defaults(this);
  }

  PhotoInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _contentType = $v.contentType;
      _exifGps = $v.exifGps?.toBuilder();
      _exifTakenAt = $v.exifTakenAt;
      _sha256 = $v.sha256;
      _sizeBytes = $v.sizeBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhotoIn other) {
    _$v = other as _$PhotoIn;
  }

  @override
  void update(void Function(PhotoInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhotoIn build() => _build();

  _$PhotoIn _build() {
    _$PhotoIn _$result;
    try {
      _$result = _$v ??
          _$PhotoIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'PhotoIn', 'clientId'),
            contentType: contentType,
            exifGps: _exifGps?.build(),
            exifTakenAt: exifTakenAt,
            sha256: BuiltValueNullFieldError.checkNotNull(
                sha256, r'PhotoIn', 'sha256'),
            sizeBytes: BuiltValueNullFieldError.checkNotNull(
                sizeBytes, r'PhotoIn', 'sizeBytes'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exifGps';
        _exifGps?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PhotoIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
