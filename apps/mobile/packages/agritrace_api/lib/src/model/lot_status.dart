//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'lot_status.g.dart';

/// Component lot lifecycle (Stages 4–7).
class LotStatus extends EnumClass {
  @BuiltValueEnumConst(wireName: r'open')
  static const LotStatus open = _$open;
  @BuiltValueEnumConst(wireName: r'drying')
  static const LotStatus drying = _$drying;
  @BuiltValueEnumConst(wireName: r'ready_for_sale')
  static const LotStatus readyForSale = _$readyForSale;
  @BuiltValueEnumConst(wireName: r'received')
  static const LotStatus received = _$received;
  @BuiltValueEnumConst(wireName: r'batched')
  static const LotStatus batched = _$batched;
  @BuiltValueEnumConst(wireName: r'closed')
  static const LotStatus closed = _$closed;

  static Serializer<LotStatus> get serializer => _$lotStatusSerializer;

  const LotStatus._(String name) : super(name);

  static BuiltSet<LotStatus> get values => _$values;
  static LotStatus valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class LotStatusMixin = Object with _$LotStatusMixin;
