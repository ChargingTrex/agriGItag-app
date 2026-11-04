//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'farmer_export.g.dart';

/// Everything stored about one farmer, for a DPDP access request (B24, runbook §1).  Rows are the database columns as JSON (geometries as GeoJSON); officers appear only as ids.
///
/// Properties:
/// * [assistSessions] - Assist sessions for the farmer, without the GPS fix.
/// * [auditLog] - Audit rows about the farmer, their account or plots, or made on their behalf; no GPS.
/// * [batchShares] - The farmer's shares in batches.
/// * [consents] - Consent records, withdrawn ones included.
/// * [devices] - The account's devices (platform, app version, last seen), without the token hashes.
/// * [eventVersions] - Versions of events on the farmer's plots and lots, or entered by or for the farmer, payload as stored; `gps` as GeoJSON. Photos are listed in `evidence_photos`, not inlined.
/// * [evidencePhotos] - Photos of those versions and readings: `bucket`, `object_key`, `url` (presigned GET).
/// * [farmer] - The `farmers` row.
/// * [idDocuments] - ID-document rows, each with `url`: a presigned GET of the image (id-docs bucket).
/// * [intakes] - Processor intakes of those lots.
/// * [linksExpireAt] - When every presigned `url` stops working (15 min).
/// * [lots] - The farmer's lots.
/// * [notifications] - Messages sent to the farmer's account (payload without secrets); erasure deletes them.
/// * [plots] - Plots, land record reference included; `pin` and `walked_boundary` as GeoJSON.
/// * [qualityReadings] - Quality readings of the farmer's lots (moisture etc.); `gps` as GeoJSON.
/// * [user] - {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links.
@BuiltValue()
abstract class FarmerExport
    implements Built<FarmerExport, FarmerExportBuilder> {
  /// Assist sessions for the farmer, without the GPS fix.
  @BuiltValueField(wireName: r'assist_sessions')
  BuiltList<BuiltMap<String, JsonObject?>?> get assistSessions;

  /// Audit rows about the farmer, their account or plots, or made on their behalf; no GPS.
  @BuiltValueField(wireName: r'audit_log')
  BuiltList<BuiltMap<String, JsonObject?>?> get auditLog;

  /// The farmer's shares in batches.
  @BuiltValueField(wireName: r'batch_shares')
  BuiltList<BuiltMap<String, JsonObject?>?> get batchShares;

  /// Consent records, withdrawn ones included.
  @BuiltValueField(wireName: r'consents')
  BuiltList<BuiltMap<String, JsonObject?>?> get consents;

  /// The account's devices (platform, app version, last seen), without the token hashes.
  @BuiltValueField(wireName: r'devices')
  BuiltList<BuiltMap<String, JsonObject?>?> get devices;

  /// Versions of events on the farmer's plots and lots, or entered by or for the farmer, payload as stored; `gps` as GeoJSON. Photos are listed in `evidence_photos`, not inlined.
  @BuiltValueField(wireName: r'event_versions')
  BuiltList<BuiltMap<String, JsonObject?>?> get eventVersions;

  /// Photos of those versions and readings: `bucket`, `object_key`, `url` (presigned GET).
  @BuiltValueField(wireName: r'evidence_photos')
  BuiltList<BuiltMap<String, JsonObject?>?> get evidencePhotos;

  /// The `farmers` row.
  @BuiltValueField(wireName: r'farmer')
  BuiltMap<String, JsonObject?> get farmer;

  /// ID-document rows, each with `url`: a presigned GET of the image (id-docs bucket).
  @BuiltValueField(wireName: r'id_documents')
  BuiltList<BuiltMap<String, JsonObject?>?> get idDocuments;

  /// Processor intakes of those lots.
  @BuiltValueField(wireName: r'intakes')
  BuiltList<BuiltMap<String, JsonObject?>?> get intakes;

  /// When every presigned `url` stops working (15 min).
  @BuiltValueField(wireName: r'links_expire_at')
  DateTime get linksExpireAt;

  /// The farmer's lots.
  @BuiltValueField(wireName: r'lots')
  BuiltList<BuiltMap<String, JsonObject?>?> get lots;

  /// Messages sent to the farmer's account (payload without secrets); erasure deletes them.
  @BuiltValueField(wireName: r'notifications')
  BuiltList<BuiltMap<String, JsonObject?>?> get notifications;

  /// Plots, land record reference included; `pin` and `walked_boundary` as GeoJSON.
  @BuiltValueField(wireName: r'plots')
  BuiltList<BuiltMap<String, JsonObject?>?> get plots;

  /// Quality readings of the farmer's lots (moisture etc.); `gps` as GeoJSON.
  @BuiltValueField(wireName: r'quality_readings')
  BuiltList<BuiltMap<String, JsonObject?>?> get qualityReadings;

  /// {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links.
  @BuiltValueField(wireName: r'user')
  BuiltMap<String, JsonObject?>? get user;

  FarmerExport._();

  factory FarmerExport([void updates(FarmerExportBuilder b)]) = _$FarmerExport;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FarmerExportBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FarmerExport> get serializer => _$FarmerExportSerializer();
}

class _$FarmerExportSerializer implements PrimitiveSerializer<FarmerExport> {
  @override
  final Iterable<Type> types = const [FarmerExport, _$FarmerExport];

  @override
  final String wireName = r'FarmerExport';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FarmerExport object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'assist_sessions';
    yield serializers.serialize(
      object.assistSessions,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'audit_log';
    yield serializers.serialize(
      object.auditLog,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'batch_shares';
    yield serializers.serialize(
      object.batchShares,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'consents';
    yield serializers.serialize(
      object.consents,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'devices';
    yield serializers.serialize(
      object.devices,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'event_versions';
    yield serializers.serialize(
      object.eventVersions,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'evidence_photos';
    yield serializers.serialize(
      object.evidencePhotos,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'farmer';
    yield serializers.serialize(
      object.farmer,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'id_documents';
    yield serializers.serialize(
      object.idDocuments,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'intakes';
    yield serializers.serialize(
      object.intakes,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'links_expire_at';
    yield serializers.serialize(
      object.linksExpireAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'lots';
    yield serializers.serialize(
      object.lots,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'notifications';
    yield serializers.serialize(
      object.notifications,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'plots';
    yield serializers.serialize(
      object.plots,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'quality_readings';
    yield serializers.serialize(
      object.qualityReadings,
      specifiedType: const FullType(BuiltList, [
        FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
      ]),
    );
    yield r'user';
    yield object.user == null
        ? null
        : serializers.serialize(
            object.user,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    FarmerExport object, {
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
    required FarmerExportBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assist_sessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.assistSessions.replace(valueDes);
          break;
        case r'audit_log':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.auditLog.replace(valueDes);
          break;
        case r'batch_shares':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.batchShares.replace(valueDes);
          break;
        case r'consents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.consents.replace(valueDes);
          break;
        case r'devices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.devices.replace(valueDes);
          break;
        case r'event_versions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.eventVersions.replace(valueDes);
          break;
        case r'evidence_photos':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.evidencePhotos.replace(valueDes);
          break;
        case r'farmer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.farmer.replace(valueDes);
          break;
        case r'id_documents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.idDocuments.replace(valueDes);
          break;
        case r'intakes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.intakes.replace(valueDes);
          break;
        case r'links_expire_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.linksExpireAt = valueDes;
          break;
        case r'lots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.lots.replace(valueDes);
          break;
        case r'notifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.notifications.replace(valueDes);
          break;
        case r'plots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.plots.replace(valueDes);
          break;
        case r'quality_readings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType.nullable(
                  BuiltMap, [FullType(String), FullType.nullable(JsonObject)])
            ]),
          ) as BuiltList<BuiltMap<String, JsonObject?>?>;
          result.qualityReadings.replace(valueDes);
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FarmerExport deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FarmerExportBuilder();
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
