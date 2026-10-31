//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'photo_status.g.dart';

/// Upload and verification state of an evidence photo (FR61, D-011).
class PhotoStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending_upload')
  static const PhotoStatus pendingUpload = _$pendingUpload;
  @BuiltValueEnumConst(wireName: r'uploaded')
  static const PhotoStatus uploaded = _$uploaded;
  @BuiltValueEnumConst(wireName: r'verified')
  static const PhotoStatus verified = _$verified;
  @BuiltValueEnumConst(wireName: r'checksum_mismatch')
  static const PhotoStatus checksumMismatch = _$checksumMismatch;
  @BuiltValueEnumConst(wireName: r'exif_mismatch')
  static const PhotoStatus exifMismatch = _$exifMismatch;

  static Serializer<PhotoStatus> get serializer => _$photoStatusSerializer;

  const PhotoStatus._(String name) : super(name);

  static BuiltSet<PhotoStatus> get values => _$values;
  static PhotoStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PhotoStatusMixin = Object with _$PhotoStatusMixin;
