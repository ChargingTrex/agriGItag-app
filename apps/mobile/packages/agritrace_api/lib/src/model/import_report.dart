//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/import_row_error.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'import_report.g.dart';

/// Row-level outcome of a CSV import (dry run or commit).
///
/// Properties:
/// * [accepted] - Rows imported (or importable, on a dry run).
/// * [dryRun] - True: nothing was written; the counts are what a commit would do.
/// * [rejected] - Rows not imported, in file order.
@BuiltValue()
abstract class ImportReport
    implements Built<ImportReport, ImportReportBuilder> {
  /// Rows imported (or importable, on a dry run).
  @BuiltValueField(wireName: r'accepted')
  int get accepted;

  /// True: nothing was written; the counts are what a commit would do.
  @BuiltValueField(wireName: r'dry_run')
  bool get dryRun;

  /// Rows not imported, in file order.
  @BuiltValueField(wireName: r'rejected')
  BuiltList<ImportRowError> get rejected;

  ImportReport._();

  factory ImportReport([void updates(ImportReportBuilder b)]) = _$ImportReport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImportReportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImportReport> get serializer => _$ImportReportSerializer();
}

class _$ImportReportSerializer implements PrimitiveSerializer<ImportReport> {
  @override
  final Iterable<Type> types = const [ImportReport, _$ImportReport];

  @override
  final String wireName = r'ImportReport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImportReport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accepted';
    yield serializers.serialize(
      object.accepted,
      specifiedType: const FullType(int),
    );
    yield r'dry_run';
    yield serializers.serialize(
      object.dryRun,
      specifiedType: const FullType(bool),
    );
    yield r'rejected';
    yield serializers.serialize(
      object.rejected,
      specifiedType: const FullType(BuiltList, [FullType(ImportRowError)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImportReport object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImportReportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.accepted = valueDes;
          break;
        case r'dry_run':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.dryRun = valueDes;
          break;
        case r'rejected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ImportRowError)]),
          ) as BuiltList<ImportRowError>;
          result.rejected.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImportReport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImportReportBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
