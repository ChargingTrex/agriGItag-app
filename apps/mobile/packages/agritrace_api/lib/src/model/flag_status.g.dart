// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FlagStatus _$open = const FlagStatus._('open');
const FlagStatus _$cleared = const FlagStatus._('cleared');
const FlagStatus _$fixed = const FlagStatus._('fixed');
const FlagStatus _$escalated = const FlagStatus._('escalated');

FlagStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'cleared':
      return _$cleared;
    case 'fixed':
      return _$fixed;
    case 'escalated':
      return _$escalated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FlagStatus> _$values = BuiltSet<FlagStatus>(const <FlagStatus>[
  _$open,
  _$cleared,
  _$fixed,
  _$escalated,
]);

class _$FlagStatusMeta {
  const _$FlagStatusMeta();
  FlagStatus get open => _$open;
  FlagStatus get cleared => _$cleared;
  FlagStatus get fixed => _$fixed;
  FlagStatus get escalated => _$escalated;
  FlagStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<FlagStatus> get values => _$values;
}

abstract class _$FlagStatusMixin {
  // ignore: non_constant_identifier_names
  _$FlagStatusMeta get FlagStatus => const _$FlagStatusMeta();
}

Serializer<FlagStatus> _$flagStatusSerializer = _$FlagStatusSerializer();

class _$FlagStatusSerializer implements PrimitiveSerializer<FlagStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'cleared': 'cleared',
    'fixed': 'fixed',
    'escalated': 'escalated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'cleared': 'cleared',
    'fixed': 'fixed',
    'escalated': 'escalated',
  };

  @override
  final Iterable<Type> types = const <Type>[FlagStatus];
  @override
  final String wireName = 'FlagStatus';

  @override
  Object serialize(Serializers serializers, FlagStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FlagStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FlagStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
