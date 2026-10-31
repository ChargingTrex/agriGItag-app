//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/error_body.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/photo_upload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_result.g.dart';

/// Outcome of one entry (or of a REST correction / undo).
///
/// Properties:
/// * [clientId] - The entry's client id.
/// * [error] - Why the entry was rejected.
/// * [photoUploads] - Uploads still owed; on a duplicate only photos not yet uploaded.
/// * [serverId] - Id of the stored record (equals client_id).
/// * [status] - accepted: stored now; duplicate: already stored by you; rejected: see `error`.
@BuiltValue()
abstract class SyncResult implements Built<SyncResult, SyncResultBuilder> {
  /// The entry's client id.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// Why the entry was rejected.
  @BuiltValueField(wireName: r'error')
  ErrorBody? get error;

  /// Uploads still owed; on a duplicate only photos not yet uploaded.
  @BuiltValueField(wireName: r'photo_uploads')
  BuiltList<PhotoUpload>? get photoUploads;

  /// Id of the stored record (equals client_id).
  @BuiltValueField(wireName: r'server_id')
  String? get serverId;

  /// accepted: stored now; duplicate: already stored by you; rejected: see `error`.
  @BuiltValueField(wireName: r'status')
  SyncResultStatusEnum get status;
  // enum statusEnum {  accepted,  duplicate,  rejected,  };

  SyncResult._();

  factory SyncResult([void updates(SyncResultBuilder b)]) = _$SyncResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncResult> get serializer => _$SyncResultSerializer();
}

class _$SyncResultSerializer implements PrimitiveSerializer<SyncResult> {
  @override
  final Iterable<Type> types = const [SyncResult, _$SyncResult];

  @override
  final String wireName = r'SyncResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    if (object.error != null) {
      yield r'error';
      yield serializers.serialize(
        object.error,
        specifiedType: const FullType.nullable(ErrorBody),
      );
    }
    if (object.photoUploads != null) {
      yield r'photo_uploads';
      yield serializers.serialize(
        object.photoUploads,
        specifiedType: const FullType(BuiltList, [FullType(PhotoUpload)]),
      );
    }
    if (object.serverId != null) {
      yield r'server_id';
      yield serializers.serialize(
        object.serverId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(SyncResultStatusEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncResult object, {
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
    required SyncResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'error':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ErrorBody),
          ) as ErrorBody?;
          if (valueDes == null) continue;
          result.error.replace(valueDes);
          break;
        case r'photo_uploads':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(BuiltList, [FullType(PhotoUpload)]),
          ) as BuiltList<PhotoUpload>?;
          if (valueDes == null) continue;
          result.photoUploads.replace(valueDes);
          break;
        case r'server_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.serverId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SyncResultStatusEnum),
          ) as SyncResultStatusEnum;
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
  SyncResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncResultBuilder();
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

/// accepted: stored now; duplicate: already stored by you; rejected: see `error`.
class SyncResultStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const SyncResultStatusEnum accepted = _$syncResultStatusEnum_accepted;
  @BuiltValueEnumConst(wireName: r'duplicate')
  static const SyncResultStatusEnum duplicate =
      _$syncResultStatusEnum_duplicate;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const SyncResultStatusEnum rejected = _$syncResultStatusEnum_rejected;

  static Serializer<SyncResultStatusEnum> get serializer =>
      _$syncResultStatusEnumSerializer;

  const SyncResultStatusEnum._(String name) : super(name);

  static BuiltSet<SyncResultStatusEnum> get values =>
      _$syncResultStatusEnumValues;
  static SyncResultStatusEnum valueOf(String name) =>
      _$syncResultStatusEnumValueOf(name);
}
