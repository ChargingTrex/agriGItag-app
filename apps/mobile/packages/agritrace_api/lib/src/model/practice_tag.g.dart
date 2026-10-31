// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_tag.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PracticeTag _$organic = const PracticeTag._('organic');
const PracticeTag _$inorganic = const PracticeTag._('inorganic');
const PracticeTag _$ipm = const PracticeTag._('ipm');

PracticeTag _$valueOf(String name) {
  switch (name) {
    case 'organic':
      return _$organic;
    case 'inorganic':
      return _$inorganic;
    case 'ipm':
      return _$ipm;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PracticeTag> _$values =
    BuiltSet<PracticeTag>(const <PracticeTag>[
  _$organic,
  _$inorganic,
  _$ipm,
]);

class _$PracticeTagMeta {
  const _$PracticeTagMeta();
  PracticeTag get organic => _$organic;
  PracticeTag get inorganic => _$inorganic;
  PracticeTag get ipm => _$ipm;
  PracticeTag valueOf(String name) => _$valueOf(name);
  BuiltSet<PracticeTag> get values => _$values;
}

abstract class _$PracticeTagMixin {
  // ignore: non_constant_identifier_names
  _$PracticeTagMeta get PracticeTag => const _$PracticeTagMeta();
}

Serializer<PracticeTag> _$practiceTagSerializer = _$PracticeTagSerializer();

class _$PracticeTagSerializer implements PrimitiveSerializer<PracticeTag> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'organic': 'organic',
    'inorganic': 'inorganic',
    'ipm': 'ipm',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'organic': 'organic',
    'inorganic': 'inorganic',
    'ipm': 'ipm',
  };

  @override
  final Iterable<Type> types = const <Type>[PracticeTag];
  @override
  final String wireName = 'PracticeTag';

  @override
  Object serialize(Serializers serializers, PracticeTag object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PracticeTag deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PracticeTag.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
