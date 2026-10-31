//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'flag_subject.g.dart';

/// What a rule flag is raised on (FR11, FR28, FR69).
class FlagSubject extends EnumClass {
  @BuiltValueEnumConst(wireName: r'plot')
  static const FlagSubject plot = _$plot;
  @BuiltValueEnumConst(wireName: r'event')
  static const FlagSubject event = _$event;
  @BuiltValueEnumConst(wireName: r'lot')
  static const FlagSubject lot = _$lot;
  @BuiltValueEnumConst(wireName: r'batch')
  static const FlagSubject batch = _$batch;
  @BuiltValueEnumConst(wireName: r'reading')
  static const FlagSubject reading = _$reading;

  static Serializer<FlagSubject> get serializer => _$flagSubjectSerializer;

  const FlagSubject._(String name) : super(name);

  static BuiltSet<FlagSubject> get values => _$values;
  static FlagSubject valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FlagSubjectMixin = Object with _$FlagSubjectMixin;
