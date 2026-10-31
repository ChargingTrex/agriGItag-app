//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'sync_entry.g.dart';

/// One offline entry; `data` is validated per entry, so one bad entry never rejects the batch.
///
/// Properties:
/// * [clientId] - Id of the record created (event version, reading, plot, consent); idempotency key.
/// * [data] - `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: not in the pilot. The entry's `client_id` is used as the record's id.
/// * [kind] - What `data` holds.
@BuiltValue()
abstract class SyncEntry implements Built<SyncEntry, SyncEntryBuilder> {
  /// Id of the record created (event version, reading, plot, consent); idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: not in the pilot. The entry's `client_id` is used as the record's id.
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  /// What `data` holds.
  @BuiltValueField(wireName: r'kind')
  SyncEntryKindEnum get kind;
  // enum kindEnum {  event_version,  quality_reading,  plot,  consent,  flag_resolution,  };

  SyncEntry._();

  factory SyncEntry([void updates(SyncEntryBuilder b)]) = _$SyncEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SyncEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SyncEntry> get serializer => _$SyncEntrySerializer();
}

class _$SyncEntrySerializer implements PrimitiveSerializer<SyncEntry> {
  @override
  final Iterable<Type> types = const [SyncEntry, _$SyncEntry];

  @override
  final String wireName = r'SyncEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SyncEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_id';
    yield serializers.serialize(
      object.clientId,
      specifiedType: const FullType(String),
    );
    yield r'data';
    yield serializers.serialize(
      object.data,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(SyncEntryKindEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SyncEntry object, {
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
    required SyncEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientId = valueDes;
          break;
        case r'data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.data.replace(valueDes);
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SyncEntryKindEnum),
          ) as SyncEntryKindEnum;
          result.kind = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SyncEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SyncEntryBuilder();
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

/// What `data` holds.
class SyncEntryKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'event_version')
  static const SyncEntryKindEnum eventVersion =
      _$syncEntryKindEnum_eventVersion;
  @BuiltValueEnumConst(wireName: r'quality_reading')
  static const SyncEntryKindEnum qualityReading =
      _$syncEntryKindEnum_qualityReading;
  @BuiltValueEnumConst(wireName: r'plot')
  static const SyncEntryKindEnum plot = _$syncEntryKindEnum_plot;
  @BuiltValueEnumConst(wireName: r'consent')
  static const SyncEntryKindEnum consent = _$syncEntryKindEnum_consent;
  @BuiltValueEnumConst(wireName: r'flag_resolution')
  static const SyncEntryKindEnum flagResolution =
      _$syncEntryKindEnum_flagResolution;

  static Serializer<SyncEntryKindEnum> get serializer =>
      _$syncEntryKindEnumSerializer;

  const SyncEntryKindEnum._(String name) : super(name);

  static BuiltSet<SyncEntryKindEnum> get values => _$syncEntryKindEnumValues;
  static SyncEntryKindEnum valueOf(String name) =>
      _$syncEntryKindEnumValueOf(name);
}
