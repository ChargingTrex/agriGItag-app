//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'build_out.g.dart';

/// One build of a batch's public page.
///
/// Properties:
/// * [batchId] - Batch the page is for.
/// * [buildNo] - Build number per batch, 1 upwards; each publish or rebuild adds one.
/// * [builtAt] - When the page was written (FR17); null until built.
/// * [error] - On `failed`: `{code: public_record_invalid, details: [{loc, msg, type}]}`; values are never echoed.
/// * [generation] - Generation stamp shown in the page footer and data.json.
/// * [htmlKey] - public-pages key of index.html, e.g. `batches/<code>/index.html`.
/// * [id] - `page_builds` row id.
/// * [jsonKey] - public-pages key of data.json.
/// * [qrKey] - public-pages key of qr.png.
/// * [status] - `queued`, `built`, `failed` (see `error`) or `superseded` (a newer build ran first).
/// * [trigger] - What asked for it: `publish` or `rebuild`.
@BuiltValue()
abstract class BuildOut implements Built<BuildOut, BuildOutBuilder> {
  /// Batch the page is for.
  @BuiltValueField(wireName: r'batch_id')
  String get batchId;

  /// Build number per batch, 1 upwards; each publish or rebuild adds one.
  @BuiltValueField(wireName: r'build_no')
  int get buildNo;

  /// When the page was written (FR17); null until built.
  @BuiltValueField(wireName: r'built_at')
  DateTime? get builtAt;

  /// On `failed`: `{code: public_record_invalid, details: [{loc, msg, type}]}`; values are never echoed.
  @BuiltValueField(wireName: r'error')
  BuiltMap<String, JsonObject?>? get error;

  /// Generation stamp shown in the page footer and data.json.
  @BuiltValueField(wireName: r'generation')
  int get generation;

  /// public-pages key of index.html, e.g. `batches/<code>/index.html`.
  @BuiltValueField(wireName: r'html_key')
  String? get htmlKey;

  /// `page_builds` row id.
  @BuiltValueField(wireName: r'id')
  String get id;

  /// public-pages key of data.json.
  @BuiltValueField(wireName: r'json_key')
  String? get jsonKey;

  /// public-pages key of qr.png.
  @BuiltValueField(wireName: r'qr_key')
  String? get qrKey;

  /// `queued`, `built`, `failed` (see `error`) or `superseded` (a newer build ran first).
  @BuiltValueField(wireName: r'status')
  String get status;

  /// What asked for it: `publish` or `rebuild`.
  @BuiltValueField(wireName: r'trigger')
  String get trigger;

  BuildOut._();

  factory BuildOut([void updates(BuildOutBuilder b)]) = _$BuildOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BuildOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BuildOut> get serializer => _$BuildOutSerializer();
}

class _$BuildOutSerializer implements PrimitiveSerializer<BuildOut> {
  @override
  final Iterable<Type> types = const [BuildOut, _$BuildOut];

  @override
  final String wireName = r'BuildOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BuildOut object, {
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
    yield r'built_at';
    yield object.builtAt == null
        ? null
        : serializers.serialize(
            object.builtAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'error';
    yield object.error == null
        ? null
        : serializers.serialize(
            object.error,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'generation';
    yield serializers.serialize(
      object.generation,
      specifiedType: const FullType(int),
    );
    yield r'html_key';
    yield object.htmlKey == null
        ? null
        : serializers.serialize(
            object.htmlKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'json_key';
    yield object.jsonKey == null
        ? null
        : serializers.serialize(
            object.jsonKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'qr_key';
    yield object.qrKey == null
        ? null
        : serializers.serialize(
            object.qrKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'trigger';
    yield serializers.serialize(
      object.trigger,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BuildOut object, {
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
    required BuildOutBuilder result,
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
        case r'built_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.builtAt = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.error.replace(valueDes);
          break;
        case r'generation':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generation = valueDes;
          break;
        case r'html_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.htmlKey = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'json_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.jsonKey = valueDes;
          break;
        case r'qr_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.qrKey = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'trigger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.trigger = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BuildOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BuildOutBuilder();
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
