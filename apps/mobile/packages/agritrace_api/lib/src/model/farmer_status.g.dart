// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FarmerStatus _$pending = const FarmerStatus._('pending');
const FarmerStatus _$active = const FarmerStatus._('active');
const FarmerStatus _$suspended = const FarmerStatus._('suspended');

FarmerStatus _$valueOf(String name) {
  switch (name) {
    case 'pending':
      return _$pending;
    case 'active':
      return _$active;
    case 'suspended':
      return _$suspended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FarmerStatus> _$values =
    BuiltSet<FarmerStatus>(const <FarmerStatus>[
  _$pending,
  _$active,
  _$suspended,
]);

class _$FarmerStatusMeta {
  const _$FarmerStatusMeta();
  FarmerStatus get pending => _$pending;
  FarmerStatus get active => _$active;
  FarmerStatus get suspended => _$suspended;
  FarmerStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<FarmerStatus> get values => _$values;
}

abstract class _$FarmerStatusMixin {
  // ignore: non_constant_identifier_names
  _$FarmerStatusMeta get FarmerStatus => const _$FarmerStatusMeta();
}

Serializer<FarmerStatus> _$farmerStatusSerializer = _$FarmerStatusSerializer();

class _$FarmerStatusSerializer implements PrimitiveSerializer<FarmerStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'active': 'active',
    'suspended': 'suspended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'active': 'active',
    'suspended': 'suspended',
  };

  @override
  final Iterable<Type> types = const <Type>[FarmerStatus];
  @override
  final String wireName = 'FarmerStatus';

  @override
  Object serialize(Serializers serializers, FarmerStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FarmerStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FarmerStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
