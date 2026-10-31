//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/quality_reading_out.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'page_quality_reading_out.g.dart';

/// PageQualityReadingOut
///
/// Properties:
/// * [hasMore] - True when another page exists.
/// * [items] - Items on this page, in the endpoint's documented order.
/// * [nextCursor] - Opaque cursor for the next page; null on the last.
@BuiltValue()
abstract class PageQualityReadingOut
    implements Built<PageQualityReadingOut, PageQualityReadingOutBuilder> {
  /// True when another page exists.
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Items on this page, in the endpoint's documented order.
  @BuiltValueField(wireName: r'items')
  BuiltList<QualityReadingOut> get items;

  /// Opaque cursor for the next page; null on the last.
  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  PageQualityReadingOut._();

  factory PageQualityReadingOut(
      [void updates(PageQualityReadingOutBuilder b)]) = _$PageQualityReadingOut;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PageQualityReadingOutBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PageQualityReadingOut> get serializer =>
      _$PageQualityReadingOutSerializer();
}

class _$PageQualityReadingOutSerializer
    implements PrimitiveSerializer<PageQualityReadingOut> {
  @override
  final Iterable<Type> types = const [
    PageQualityReadingOut,
    _$PageQualityReadingOut
  ];

  @override
  final String wireName = r'PageQualityReadingOut';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PageQualityReadingOut object, {
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
      specifiedType: const FullType(BuiltList, [FullType(QualityReadingOut)]),
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
    PageQualityReadingOut object, {
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
    required PageQualityReadingOutBuilder result,
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
            specifiedType:
                const FullType(BuiltList, [FullType(QualityReadingOut)]),
          ) as BuiltList<QualityReadingOut>;
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
  PageQualityReadingOut deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PageQualityReadingOutBuilder();
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
