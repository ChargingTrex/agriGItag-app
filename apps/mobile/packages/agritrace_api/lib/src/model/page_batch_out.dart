//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/batch_out.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'page_batch_out.g.dart';

/// PageBatchOut
///
/// Properties:
/// * [hasMore] - True when another page exists.
/// * [items] - Items on this page, in the endpoint's documented order.
/// * [nextCursor] - Opaque cursor for the next page; null on the last.
@BuiltValue()
abstract class PageBatchOut
    implements Built<PageBatchOut, PageBatchOutBuilder> {
  /// True when another page exists.
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Items on this page, in the endpoint's documented order.
  @BuiltValueField(wireName: r'items')
  BuiltList<BatchOut> get items;

  /// Opaque cursor for the next page; null on the last.
  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  PageBatchOut._();

  factory PageBatchOut([void updates(PageBatchOutBuilder b)]) = _$PageBatchOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PageBatchOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PageBatchOut> get serializer => _$PageBatchOutSerializer();
}

class _$PageBatchOutSerializer implements PrimitiveSerializer<PageBatchOut> {
  @override
  final Iterable<Type> types = const [PageBatchOut, _$PageBatchOut];

  @override
  final String wireName = r'PageBatchOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PageBatchOut object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(BatchOut)]),
    );
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PageBatchOut object, {
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
    required PageBatchOutBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BatchOut)]),
          ) as BuiltList<BatchOut>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PageBatchOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PageBatchOutBuilder();
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
