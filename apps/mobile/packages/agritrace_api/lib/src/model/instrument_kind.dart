//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'instrument_kind.g.dart';

/// Kind of registered measuring instrument (FR42, PRD §5 Instrument).
class InstrumentKind extends EnumClass {
  @BuiltValueEnumConst(wireName: r'moisture_meter')
  static const InstrumentKind moistureMeter = _$moistureMeter;
  @BuiltValueEnumConst(wireName: r'colorimeter')
  static const InstrumentKind colorimeter = _$colorimeter;
  @BuiltValueEnumConst(wireName: r'hygrometer')
  static const InstrumentKind hygrometer = _$hygrometer;
  @BuiltValueEnumConst(wireName: r'scale')
  static const InstrumentKind scale = _$scale;

  static Serializer<InstrumentKind> get serializer =>
      _$instrumentKindSerializer;

  const InstrumentKind._(String name) : super(name);

  static BuiltSet<InstrumentKind> get values => _$values;
  static InstrumentKind valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class InstrumentKindMixin = Object with _$InstrumentKindMixin;
