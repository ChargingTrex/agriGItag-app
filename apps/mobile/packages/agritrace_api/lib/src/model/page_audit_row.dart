//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/audit_row.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'page_audit_row.g.dart';

/// PageAuditRow
///
/// Properties:
/// * [hasMore] - True when another page exists.
/// * [items] - Items on this page, in the endpoint's documented order.
/// * [nextCursor] - Opaque cursor for the next page; null on the last.
@BuiltValue()
abstract class PageAuditRow
    implements Built<PageAuditRow, PageAuditRowBuilder> {
  /// True when another page exists.
  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  /// Items on this page, in the endpoint's documented order.
  @BuiltValueField(wireName: r'items')
  BuiltList<AuditRow> get items;

  /// Opaque cursor for the next page; null on the last.
  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  PageAuditRow._();

  factory PageAuditRow([void updates(PageAuditRowBuilder b)]) = _$PageAuditRow;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PageAuditRowBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PageAuditRow> get serializer => _$PageAuditRowSerializer();
}

class _$PageAuditRowSerializer implements PrimitiveSerializer<PageAuditRow> {
  @override
  final Iterable<Type> types = const [PageAuditRow, _$PageAuditRow];

  @override
  final String wireName = r'PageAuditRow';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PageAuditRow object, {
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
      specifiedType: const FullType(BuiltList, [FullType(AuditRow)]),
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
    PageAuditRow object, {
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
    required PageAuditRowBuilder result,
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
            specifiedType: const FullType(BuiltList, [FullType(AuditRow)]),
          ) as BuiltList<AuditRow>;
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
  PageAuditRow deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PageAuditRowBuilder();
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
