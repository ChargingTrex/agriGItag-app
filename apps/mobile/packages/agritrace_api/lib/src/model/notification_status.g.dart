// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const NotificationStatus _$queued = const NotificationStatus._('queued');
const NotificationStatus _$sent = const NotificationStatus._('sent');
const NotificationStatus _$failed = const NotificationStatus._('failed');

NotificationStatus _$valueOf(String name) {
  switch (name) {
    case 'queued':
      return _$queued;
    case 'sent':
      return _$sent;
    case 'failed':
      return _$failed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<NotificationStatus> _$values =
    BuiltSet<NotificationStatus>(const <NotificationStatus>[
  _$queued,
  _$sent,
  _$failed,
]);

class _$NotificationStatusMeta {
  const _$NotificationStatusMeta();
  NotificationStatus get queued => _$queued;
  NotificationStatus get sent => _$sent;
  NotificationStatus get failed => _$failed;
  NotificationStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<NotificationStatus> get values => _$values;
}

abstract class _$NotificationStatusMixin {
  // ignore: non_constant_identifier_names
  _$NotificationStatusMeta get NotificationStatus =>
      const _$NotificationStatusMeta();
}

Serializer<NotificationStatus> _$notificationStatusSerializer =
    _$NotificationStatusSerializer();

class _$NotificationStatusSerializer
    implements PrimitiveSerializer<NotificationStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'sent': 'sent',
    'failed': 'failed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'sent': 'sent',
    'failed': 'failed',
  };

  @override
  final Iterable<Type> types = const <Type>[NotificationStatus];
  @override
  final String wireName = 'NotificationStatus';

  @override
  Object serialize(Serializers serializers, NotificationStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  NotificationStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      NotificationStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
