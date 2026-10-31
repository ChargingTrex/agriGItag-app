//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/lot_out.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'page_lot_out.g.dart';

/// PageLotOut
///
/// Properties:
/// * [hasMore] - True when another page exists.
/// * [items] - Items on this page, in the endpoint's documented order.
/// * [nextCursor] - Opaque cursor for the next page; null on the last.
@BuiltValue()
abstract class PageLotOut implements Built<PageLotOut, PageLotOutBuilder> {
  /// True when another page exists.
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Items on this page, in the endpoint's documented order.
  @BuiltValueField(wireName: r'items')
  BuiltList<LotOut> get items;

  /// Opaque cursor for the next page; null on the last.
  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  PageLotOut._();

  factory PageLotOut([void updates(PageLotOutBuilder b)]) = _$PageLotOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PageLotOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PageLotOut> get serializer => _$PageLotOutSerializer();
}

class _$PageLotOutSerializer implements PrimitiveSerializer<PageLotOut> {
  @override
  final Iterable<Type> types = const [PageLotOut, _$PageLotOut];

  @override
  final String wireName = r'PageLotOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PageLotOut object, {
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
      specifiedType: const FullType(BuiltList, [FullType(LotOut)]),
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
    PageLotOut object, {
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
    required PageLotOutBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(LotOut)]),
          ) as BuiltList<LotOut>;
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
  PageLotOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PageLotOutBuilder();
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
