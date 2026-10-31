//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_row_error.g.dart';

/// Why one CSV row was not imported.
///
/// Properties:
/// * [code] - Registered error code (docs/api/error-codes.md), e.g. `field_required`.
/// * [field] - Column the problem is in, when known.
/// * [row] - Line number in the file; the header is line 1, the first data row 2.
@BuiltValue()
abstract class ImportRowError
    implements Built<ImportRowError, ImportRowErrorBuilder> {
  /// Registered error code (docs/api/error-codes.md), e.g. `field_required`.
  @BuiltValueField(wireName: r'code')
  String get code;

  /// Column the problem is in, when known.
  @BuiltValueField(wireName: r'field')
  String? get field;

  /// Line number in the file; the header is line 1, the first data row 2.
  @BuiltValueField(wireName: r'row')
  int get row;

  ImportRowError._();

  factory ImportRowError([void updates(ImportRowErrorBuilder b)]) =
      _$ImportRowError;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportRowErrorBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportRowError> get serializer =>
      _$ImportRowErrorSerializer();
}

class _$ImportRowErrorSerializer
    implements PrimitiveSerializer<ImportRowError> {
  @override
  final Iterable<Type> types = const [ImportRowError, _$ImportRowError];

  @override
  final String wireName = r'ImportRowError';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportRowError object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    if (object.field != null) {
      yield r'field';
      yield serializers.serialize(
        object.field,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'row';
    yield serializers.serialize(
      object.row,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportRowError object, {
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
    required ImportRowErrorBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'field':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.field = valueDes;
          break;
        case r'row':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.row = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportRowError deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportRowErrorBuilder();
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
