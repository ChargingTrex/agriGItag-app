// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LocationStatus _$confirmed = const LocationStatus._('confirmed');
const LocationStatus _$needsReview = const LocationStatus._('needsReview');
const LocationStatus _$outside = const LocationStatus._('outside');
const LocationStatus _$nearEdge = const LocationStatus._('nearEdge');

LocationStatus _$valueOf(String name) {
  switch (name) {
    case 'confirmed':
      return _$confirmed;
    case 'needsReview':
      return _$needsReview;
    case 'outside':
      return _$outside;
    case 'nearEdge':
      return _$nearEdge;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LocationStatus> _$values =
    BuiltSet<LocationStatus>(const <LocationStatus>[
  _$confirmed,
  _$needsReview,
  _$outside,
  _$nearEdge,
]);

class _$LocationStatusMeta {
  const _$LocationStatusMeta();
  LocationStatus get confirmed => _$confirmed;
  LocationStatus get needsReview => _$needsReview;
  LocationStatus get outside => _$outside;
  LocationStatus get nearEdge => _$nearEdge;
  LocationStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<LocationStatus> get values => _$values;
}

abstract class _$LocationStatusMixin {
  // ignore: non_constant_identifier_names
  _$LocationStatusMeta get LocationStatus => const _$LocationStatusMeta();
}

Serializer<LocationStatus> _$locationStatusSerializer =
    _$LocationStatusSerializer();

class _$LocationStatusSerializer
    implements PrimitiveSerializer<LocationStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'confirmed': 'confirmed',
    'needsReview': 'needs_review',
    'outside': 'outside',
    'nearEdge': 'near_edge',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'confirmed': 'confirmed',
    'needs_review': 'needsReview',
    'outside': 'outside',
    'near_edge': 'nearEdge',
  };

  @override
  final Iterable<Type> types = const <Type>[LocationStatus];
  @override
  final String wireName = 'LocationStatus';

  @override
  Object serialize(Serializers serializers, LocationStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LocationStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LocationStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
