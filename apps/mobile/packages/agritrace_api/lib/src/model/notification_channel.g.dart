// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_channel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationChannel _$push = const NotificationChannel._('push');
const NotificationChannel _$sms = const NotificationChannel._('sms');
const NotificationChannel _$whatsapp = const NotificationChannel._('whatsapp');
const NotificationChannel _$console = const NotificationChannel._('console');

NotificationChannel _$valueOf(String name) {
  switch (name) {
    case 'push':
      return _$push;
    case 'sms':
      return _$sms;
    case 'whatsapp':
      return _$whatsapp;
    case 'console':
      return _$console;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NotificationChannel> _$values =
    BuiltSet<NotificationChannel>(const <NotificationChannel>[
  _$push,
  _$sms,
  _$whatsapp,
  _$console,
]);

class _$NotificationChannelMeta {
  const _$NotificationChannelMeta();
  NotificationChannel get push => _$push;
  NotificationChannel get sms => _$sms;
  NotificationChannel get whatsapp => _$whatsapp;
  NotificationChannel get console => _$console;
  NotificationChannel valueOf(String name) => _$valueOf(name);
  BuiltSet<NotificationChannel> get values => _$values;
}

abstract class _$NotificationChannelMixin {
  // ignore: non_constant_identifier_names
  _$NotificationChannelMeta get NotificationChannel =>
      const _$NotificationChannelMeta();
}

Serializer<NotificationChannel> _$notificationChannelSerializer =
    _$NotificationChannelSerializer();

class _$NotificationChannelSerializer
    implements PrimitiveSerializer<NotificationChannel> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'push': 'push',
    'sms': 'sms',
    'whatsapp': 'whatsapp',
    'console': 'console',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'push': 'push',
    'sms': 'sms',
    'whatsapp': 'whatsapp',
    'console': 'console',
  };

  @override
  final Iterable<Type> types = const <Type>[NotificationChannel];
  @override
  final String wireName = 'NotificationChannel';

  @override
  Object serialize(Serializers serializers, NotificationChannel object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  NotificationChannel deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      NotificationChannel.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
