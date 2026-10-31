// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_kind.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ChangeKind _$create = const ChangeKind._('create');
const ChangeKind _$correct = const ChangeKind._('correct');
const ChangeKind _$undo = const ChangeKind._('undo');
const ChangeKind _$system = const ChangeKind._('system');

ChangeKind _$valueOf(String name) {
  switch (name) {
    case 'create':
      return _$create;
    case 'correct':
      return _$correct;
    case 'undo':
      return _$undo;
    case 'system':
      return _$system;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ChangeKind> _$values = BuiltSet<ChangeKind>(const <ChangeKind>[
  _$create,
  _$correct,
  _$undo,
  _$system,
]);

class _$ChangeKindMeta {
  const _$ChangeKindMeta();
  ChangeKind get create => _$create;
  ChangeKind get correct => _$correct;
  ChangeKind get undo => _$undo;
  ChangeKind get system => _$system;
  ChangeKind valueOf(String name) => _$valueOf(name);
  BuiltSet<ChangeKind> get values => _$values;
}

abstract class _$ChangeKindMixin {
  // ignore: non_constant_identifier_names
  _$ChangeKindMeta get ChangeKind => const _$ChangeKindMeta();
}

Serializer<ChangeKind> _$changeKindSerializer = _$ChangeKindSerializer();

class _$ChangeKindSerializer implements PrimitiveSerializer<ChangeKind> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
    'system': 'system',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'create': 'create',
    'correct': 'correct',
    'undo': 'undo',
    'system': 'system',
  };

  @override
  final Iterable<Type> types = const <Type>[ChangeKind];
  @override
  final String wireName = 'ChangeKind';

  @override
  Object serialize(Serializers serializers, ChangeKind object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ChangeKind deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ChangeKind.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
