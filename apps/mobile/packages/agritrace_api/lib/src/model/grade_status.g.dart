// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GradeStatus _$incomplete = const GradeStatus._('incomplete');
const GradeStatus _$ok = const GradeStatus._('ok');
const GradeStatus _$declaredAboveComputed =
    const GradeStatus._('declaredAboveComputed');

GradeStatus _$valueOf(String name) {
  switch (name) {
    case 'incomplete':
      return _$incomplete;
    case 'ok':
      return _$ok;
    case 'declaredAboveComputed':
      return _$declaredAboveComputed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GradeStatus> _$values =
    BuiltSet<GradeStatus>(const <GradeStatus>[
  _$incomplete,
  _$ok,
  _$declaredAboveComputed,
]);

class _$GradeStatusMeta {
  const _$GradeStatusMeta();
  GradeStatus get incomplete => _$incomplete;
  GradeStatus get ok => _$ok;
  GradeStatus get declaredAboveComputed => _$declaredAboveComputed;
  GradeStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<GradeStatus> get values => _$values;
}

abstract class _$GradeStatusMixin {
  // ignore: non_constant_identifier_names
  _$GradeStatusMeta get GradeStatus => const _$GradeStatusMeta();
}

Serializer<GradeStatus> _$gradeStatusSerializer = _$GradeStatusSerializer();

class _$GradeStatusSerializer implements PrimitiveSerializer<GradeStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'incomplete': 'incomplete',
    'ok': 'ok',
    'declaredAboveComputed': 'declared_above_computed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'incomplete': 'incomplete',
    'ok': 'ok',
    'declared_above_computed': 'declaredAboveComputed',
  };

  @override
  final Iterable<Type> types = const <Type>[GradeStatus];
  @override
  final String wireName = 'GradeStatus';

  @override
  Object serialize(Serializers serializers, GradeStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GradeStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GradeStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
