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
/// * [assistSessionId] - Assist session this entry was captured in (D-032): one of the caller's sessions, open or ended, pushed earlier as an `assist_session` entry or started online. Records assist mode for this entry only (event version, audit row, consent witness); the entry's farmer must be the session's (`forbidden` otherwise); unknown or another officer's → `assist_session_invalid`. When absent, the `X-Assist-Session` header applies. Ignored on `farmer` entries.
/// * [clientId] - Id of the record created (event version, reading, plot, consent, farmer, assist session); idempotency key.
/// * [data] - `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: `FlagResolutionEntry` `{flag_id, resolution, reason_code, note}` (its `server_id` is the flag id); `farmer`: `FarmerIn` (field officer or FPO admin; stored `pending`, D-031); `assist_session`: `AssistStartIn` without `client_id` (field officer only, D-032). Otherwise the entry's `client_id` is used as the record's id.
/// * [kind] - What `data` holds.
@BuiltValue()
abstract class SyncEntry implements Built<SyncEntry, SyncEntryBuilder> {
  /// Assist session this entry was captured in (D-032): one of the caller's sessions, open or ended, pushed earlier as an `assist_session` entry or started online. Records assist mode for this entry only (event version, audit row, consent witness); the entry's farmer must be the session's (`forbidden` otherwise); unknown or another officer's → `assist_session_invalid`. When absent, the `X-Assist-Session` header applies. Ignored on `farmer` entries.
  @BuiltValueField(wireName: r'assist_session_id')
  String? get assistSessionId;

  /// Id of the record created (event version, reading, plot, consent, farmer, assist session); idempotency key.
  @BuiltValueField(wireName: r'client_id')
  String get clientId;

  /// `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: `FlagResolutionEntry` `{flag_id, resolution, reason_code, note}` (its `server_id` is the flag id); `farmer`: `FarmerIn` (field officer or FPO admin; stored `pending`, D-031); `assist_session`: `AssistStartIn` without `client_id` (field officer only, D-032). Otherwise the entry's `client_id` is used as the record's id.
  @BuiltValueField(wireName: r'data')
  BuiltMap<String, JsonObject?> get data;

  /// What `data` holds.
  @BuiltValueField(wireName: r'kind')
  SyncEntryKindEnum get kind;
  // enum kindEnum {  event_version,  quality_reading,  plot,  consent,  flag_resolution,  farmer,  assist_session,  };

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
    if (object.assistSessionId != null) {
      yield r'assist_session_id';
      yield serializers.serialize(
        object.assistSessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
        case r'assist_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assistSessionId = valueDes;
          break;
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
  @BuiltValueEnumConst(wireName: r'farmer')
  static const SyncEntryKindEnum farmer = _$syncEntryKindEnum_farmer;
  @BuiltValueEnumConst(wireName: r'assist_session')
  static const SyncEntryKindEnum assistSession =
      _$syncEntryKindEnum_assistSession;

  static Serializer<SyncEntryKindEnum> get serializer =>
      _$syncEntryKindEnumSerializer;

  const SyncEntryKindEnum._(String name) : super(name);

  static BuiltSet<SyncEntryKindEnum> get values => _$syncEntryKindEnumValues;
  static SyncEntryKindEnum valueOf(String name) =>
      _$syncEntryKindEnumValueOf(name);
}
