//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'publish_out.g.dart';

/// A queued public page build (D-007); the worker writes the page.
///
/// Properties:
/// * [batchId] - Batch published.
/// * [buildNo] - Build number of this publish.
/// * [code] - Batch code (QR and public page).
/// * [pageBuildId] - `page_builds` row; `GET /v1/batches/{id}/builds` (B10).
/// * [status] - `queued` until the build task writes the page.
@BuiltValue()
abstract class PublishOut implements Built<PublishOut, PublishOutBuilder> {
  /// Batch published.
  @BuiltValueField(wireName: r'batch_id')
  String get batchId;

  /// Build number of this publish.
  @BuiltValueField(wireName: r'build_no')
  int get buildNo;

  /// Batch code (QR and public page).
  @BuiltValueField(wireName: r'code')
  String get code;

  /// `page_builds` row; `GET /v1/batches/{id}/builds` (B10).
  @BuiltValueField(wireName: r'page_build_id')
  String get pageBuildId;

  /// `queued` until the build task writes the page.
  @BuiltValueField(wireName: r'status')
  String get status;

  PublishOut._();

  factory PublishOut([void updates(PublishOutBuilder b)]) = _$PublishOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PublishOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PublishOut> get serializer => _$PublishOutSerializer();
}

class _$PublishOutSerializer implements PrimitiveSerializer<PublishOut> {
  @override
  final Iterable<Type> types = const [PublishOut, _$PublishOut];

  @override
  final String wireName = r'PublishOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PublishOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batch_id';
    yield serializers.serialize(
      object.batchId,
      specifiedType: const FullType(String),
    );
    yield r'build_no';
    yield serializers.serialize(
      object.buildNo,
      specifiedType: const FullType(int),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'page_build_id';
    yield serializers.serialize(
      object.pageBuildId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PublishOut object, {
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
    required PublishOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.batchId = valueDes;
          break;
        case r'build_no':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.buildNo = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'page_build_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pageBuildId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PublishOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PublishOutBuilder();
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
