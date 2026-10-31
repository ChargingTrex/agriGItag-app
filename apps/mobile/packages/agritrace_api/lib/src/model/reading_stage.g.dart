// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_stage.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReadingStage _$dryingEnd = const ReadingStage._('dryingEnd');
const ReadingStage _$intake = const ReadingStage._('intake');
const ReadingStage _$grading = const ReadingStage._('grading');
const ReadingStage _$storage = const ReadingStage._('storage');

ReadingStage _$valueOf(String name) {
  switch (name) {
    case 'dryingEnd':
      return _$dryingEnd;
    case 'intake':
      return _$intake;
    case 'grading':
      return _$grading;
    case 'storage':
      return _$storage;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReadingStage> _$values =
    BuiltSet<ReadingStage>(const <ReadingStage>[
  _$dryingEnd,
  _$intake,
  _$grading,
  _$storage,
]);

class _$ReadingStageMeta {
  const _$ReadingStageMeta();
  ReadingStage get dryingEnd => _$dryingEnd;
  ReadingStage get intake => _$intake;
  ReadingStage get grading => _$grading;
  ReadingStage get storage => _$storage;
  ReadingStage valueOf(String name) => _$valueOf(name);
  BuiltSet<ReadingStage> get values => _$values;
}

abstract class _$ReadingStageMixin {
  // ignore: non_constant_identifier_names
  _$ReadingStageMeta get ReadingStage => const _$ReadingStageMeta();
}

Serializer<ReadingStage> _$readingStageSerializer = _$ReadingStageSerializer();

class _$ReadingStageSerializer implements PrimitiveSerializer<ReadingStage> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'dryingEnd': 'drying_end',
    'intake': 'intake',
    'grading': 'grading',
    'storage': 'storage',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'drying_end': 'dryingEnd',
    'intake': 'intake',
    'grading': 'grading',
    'storage': 'storage',
  };

  @override
  final Iterable<Type> types = const <Type>[ReadingStage];
  @override
  final String wireName = 'ReadingStage';

  @override
  Object serialize(Serializers serializers, ReadingStage object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReadingStage deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReadingStage.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
