//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/standards_scheme.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'standards_profile_out.g.dart';

/// A Standards Profile with the number of its current published version (FR47).
///
/// Properties:
/// * [cropId] - Crop the profile grades.
/// * [id] - Profile id.
/// * [name] - Profile name.
/// * [publishedVersionNo] - Version number currently published; null when none is published.
/// * [scheme] - agmark, iso, fssai or custom.
/// * [standardRef] - Standard document reference.
@BuiltValue()
abstract class StandardsProfileOut
    implements Built<StandardsProfileOut, StandardsProfileOutBuilder> {
  /// Crop the profile grades.
  @BuiltValueField(wireName: r'crop_id')
  String get cropId;

  /// Profile id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// Profile name.
  @BuiltValueField(wireName: r'name')
  String get name;

  /// Version number currently published; null when none is published.
  @BuiltValueField(wireName: r'published_version_no')
  int? get publishedVersionNo;

  /// agmark, iso, fssai or custom.
  @BuiltValueField(wireName: r'scheme')
  StandardsScheme get scheme;
  // enum schemeEnum {  agmark,  iso,  fssai,  custom,  };

  /// Standard document reference.
  @BuiltValueField(wireName: r'standard_ref')
  String get standardRef;

  StandardsProfileOut._();

  factory StandardsProfileOut([void updates(StandardsProfileOutBuilder b)]) =
      _$StandardsProfileOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StandardsProfileOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StandardsProfileOut> get serializer =>
      _$StandardsProfileOutSerializer();
}

class _$StandardsProfileOutSerializer
    implements PrimitiveSerializer<StandardsProfileOut> {
  @override
  final Iterable<Type> types = const [
    StandardsProfileOut,
    _$StandardsProfileOut
  ];

  @override
  final String wireName = r'StandardsProfileOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StandardsProfileOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'crop_id';
    yield serializers.serialize(
      object.cropId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'published_version_no';
    yield object.publishedVersionNo == null
        ? null
        : serializers.serialize(
            object.publishedVersionNo,
            specifiedType: const FullType.nullable(int),
          );
    yield r'scheme';
    yield serializers.serialize(
      object.scheme,
      specifiedType: const FullType(StandardsScheme),
    );
    yield r'standard_ref';
    yield serializers.serialize(
      object.standardRef,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StandardsProfileOut object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StandardsProfileOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'crop_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cropId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'published_version_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.publishedVersionNo = valueDes;
          break;
        case r'scheme':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StandardsScheme),
          ) as StandardsScheme;
          result.scheme = valueDes;
          break;
        case r'standard_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.standardRef = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StandardsProfileOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StandardsProfileOutBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
