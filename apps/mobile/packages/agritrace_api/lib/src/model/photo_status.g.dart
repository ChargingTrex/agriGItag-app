// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PhotoStatus _$pendingUpload = const PhotoStatus._('pendingUpload');
const PhotoStatus _$uploaded = const PhotoStatus._('uploaded');
const PhotoStatus _$verified = const PhotoStatus._('verified');
const PhotoStatus _$checksumMismatch = const PhotoStatus._('checksumMismatch');
const PhotoStatus _$exifMismatch = const PhotoStatus._('exifMismatch');

PhotoStatus _$valueOf(String name) {
  switch (name) {
    case 'pendingUpload':
      return _$pendingUpload;
    case 'uploaded':
      return _$uploaded;
    case 'verified':
      return _$verified;
    case 'checksumMismatch':
      return _$checksumMismatch;
    case 'exifMismatch':
      return _$exifMismatch;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PhotoStatus> _$values =
    BuiltSet<PhotoStatus>(const <PhotoStatus>[
  _$pendingUpload,
  _$uploaded,
  _$verified,
  _$checksumMismatch,
  _$exifMismatch,
]);

class _$PhotoStatusMeta {
  const _$PhotoStatusMeta();
  PhotoStatus get pendingUpload => _$pendingUpload;
  PhotoStatus get uploaded => _$uploaded;
  PhotoStatus get verified => _$verified;
  PhotoStatus get checksumMismatch => _$checksumMismatch;
  PhotoStatus get exifMismatch => _$exifMismatch;
  PhotoStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<PhotoStatus> get values => _$values;
}

abstract class _$PhotoStatusMixin {
  // ignore: non_constant_identifier_names
  _$PhotoStatusMeta get PhotoStatus => const _$PhotoStatusMeta();
}

Serializer<PhotoStatus> _$photoStatusSerializer = _$PhotoStatusSerializer();

class _$PhotoStatusSerializer implements PrimitiveSerializer<PhotoStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pendingUpload': 'pending_upload',
    'uploaded': 'uploaded',
    'verified': 'verified',
    'checksumMismatch': 'checksum_mismatch',
    'exifMismatch': 'exif_mismatch',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending_upload': 'pendingUpload',
    'uploaded': 'uploaded',
    'verified': 'verified',
    'checksum_mismatch': 'checksumMismatch',
    'exif_mismatch': 'exifMismatch',
  };

  @override
  final Iterable<Type> types = const <Type>[PhotoStatus];
  @override
  final String wireName = 'PhotoStatus';

  @override
  Object serialize(Serializers serializers, PhotoStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PhotoStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PhotoStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
