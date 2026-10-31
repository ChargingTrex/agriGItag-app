//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:agritrace_api/src/model/scans.dart';
import 'package:agritrace_api/src/model/finished_goods.dart';
import 'package:built_collection/built_collection.dart';
import 'package:agritrace_api/src/model/completeness.dart';
import 'package:agritrace_api/src/model/sync_health_row.dart';
import 'package:agritrace_api/src/model/stage_tile.dart';
import 'package:agritrace_api/src/model/flag_counts.dart';
import 'package:agritrace_api/src/model/land_area.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'dashboard.g.dart';

/// FPO dashboard (FR13, P06). Filters narrow completeness, stage tiles and land area only.
///
/// Properties:
/// * [batches] - Batches by status (whole FPO), every status present.
/// * [completeness] - Lots with all mandatory events ÷ lots.
/// * [finishedGoods] - Finished Goods inventory (whole FPO).
/// * [flags] - Active flags by severity (whole FPO).
/// * [fpoId] - FPO the numbers are for.
/// * [landArea] - Land Area Analytics.
/// * [scans] - Public page scans (whole FPO).
/// * [stages] - Stage-progress tiles in farm order.
/// * [syncHealth] - Sync timings by network type, last 7 days, from devices of the FPO's members; a member of several FPOs is counted in each.
@BuiltValue()
abstract class Dashboard implements Built<Dashboard, DashboardBuilder> {
  /// Batches by status (whole FPO), every status present.
  @BuiltValueField(wireName: r'batches')
  BuiltMap<String, int> get batches;

  /// Lots with all mandatory events ÷ lots.
  @BuiltValueField(wireName: r'completeness')
  Completeness get completeness;

  /// Finished Goods inventory (whole FPO).
  @BuiltValueField(wireName: r'finished_goods')
  FinishedGoods get finishedGoods;

  /// Active flags by severity (whole FPO).
  @BuiltValueField(wireName: r'flags')
  FlagCounts get flags;

  /// FPO the numbers are for.
  @BuiltValueField(wireName: r'fpo_id')
  String get fpoId;

  /// Land Area Analytics.
  @BuiltValueField(wireName: r'land_area')
  LandArea get landArea;

  /// Public page scans (whole FPO).
  @BuiltValueField(wireName: r'scans')
  Scans get scans;

  /// Stage-progress tiles in farm order.
  @BuiltValueField(wireName: r'stages')
  BuiltList<StageTile> get stages;

  /// Sync timings by network type, last 7 days, from devices of the FPO's members; a member of several FPOs is counted in each.
  @BuiltValueField(wireName: r'sync_health')
  BuiltList<SyncHealthRow> get syncHealth;

  Dashboard._();

  factory Dashboard([void updates(DashboardBuilder b)]) = _$Dashboard;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DashboardBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Dashboard> get serializer => _$DashboardSerializer();
}

class _$DashboardSerializer implements PrimitiveSerializer<Dashboard> {
  @override
  final Iterable<Type> types = const [Dashboard, _$Dashboard];

  @override
  final String wireName = r'Dashboard';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Dashboard object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'batches';
    yield serializers.serialize(
      object.batches,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(int)]),
    );
    yield r'completeness';
    yield serializers.serialize(
      object.completeness,
      specifiedType: const FullType(Completeness),
    );
    yield r'finished_goods';
    yield serializers.serialize(
      object.finishedGoods,
      specifiedType: const FullType(FinishedGoods),
    );
    yield r'flags';
    yield serializers.serialize(
      object.flags,
      specifiedType: const FullType(FlagCounts),
    );
    yield r'fpo_id';
    yield serializers.serialize(
      object.fpoId,
      specifiedType: const FullType(String),
    );
    yield r'land_area';
    yield serializers.serialize(
      object.landArea,
      specifiedType: const FullType(LandArea),
    );
    yield r'scans';
    yield serializers.serialize(
      object.scans,
      specifiedType: const FullType(Scans),
    );
    yield r'stages';
    yield serializers.serialize(
      object.stages,
      specifiedType: const FullType(BuiltList, [FullType(StageTile)]),
    );
    yield r'sync_health';
    yield serializers.serialize(
      object.syncHealth,
      specifiedType: const FullType(BuiltList, [FullType(SyncHealthRow)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Dashboard object, {
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
    required DashboardBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'batches':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(int)]),
          ) as BuiltMap<String, int>;
          result.batches.replace(valueDes);
          break;
        case r'completeness':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Completeness),
          ) as Completeness;
          result.completeness.replace(valueDes);
          break;
        case r'finished_goods':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FinishedGoods),
          ) as FinishedGoods;
          result.finishedGoods.replace(valueDes);
          break;
        case r'flags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FlagCounts),
          ) as FlagCounts;
          result.flags.replace(valueDes);
          break;
        case r'fpo_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fpoId = valueDes;
          break;
        case r'land_area':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LandArea),
          ) as LandArea;
          result.landArea.replace(valueDes);
          break;
        case r'scans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Scans),
          ) as Scans;
          result.scans.replace(valueDes);
          break;
        case r'stages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StageTile)]),
          ) as BuiltList<StageTile>;
          result.stages.replace(valueDes);
          break;
        case r'sync_health':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SyncHealthRow)]),
          ) as BuiltList<SyncHealthRow>;
          result.syncHealth.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Dashboard deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DashboardBuilder();
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
