// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Dashboard extends Dashboard {
  @override
  final BuiltMap<String, int> batches;
  @override
  final Completeness completeness;
  @override
  final FinishedGoods finishedGoods;
  @override
  final FlagCounts flags;
  @override
  final String fpoId;
  @override
  final LandArea landArea;
  @override
  final Scans scans;
  @override
  final BuiltList<StageTile> stages;
  @override
  final BuiltList<SyncHealthRow> syncHealth;

  factory _$Dashboard([void Function(DashboardBuilder)? updates]) =>
      (DashboardBuilder()..update(updates))._build();

  _$Dashboard._(
      {required this.batches,
      required this.completeness,
      required this.finishedGoods,
      required this.flags,
      required this.fpoId,
      required this.landArea,
      required this.scans,
      required this.stages,
      required this.syncHealth})
      : super._();
  @override
  Dashboard rebuild(void Function(DashboardBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DashboardBuilder toBuilder() => DashboardBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Dashboard &&
        batches == other.batches &&
        completeness == other.completeness &&
        finishedGoods == other.finishedGoods &&
        flags == other.flags &&
        fpoId == other.fpoId &&
        landArea == other.landArea &&
        scans == other.scans &&
        stages == other.stages &&
        syncHealth == other.syncHealth;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batches.hashCode);
    _$hash = $jc(_$hash, completeness.hashCode);
    _$hash = $jc(_$hash, finishedGoods.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, landArea.hashCode);
    _$hash = $jc(_$hash, scans.hashCode);
    _$hash = $jc(_$hash, stages.hashCode);
    _$hash = $jc(_$hash, syncHealth.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Dashboard')
          ..add('batches', batches)
          ..add('completeness', completeness)
          ..add('finishedGoods', finishedGoods)
          ..add('flags', flags)
          ..add('fpoId', fpoId)
          ..add('landArea', landArea)
          ..add('scans', scans)
          ..add('stages', stages)
          ..add('syncHealth', syncHealth))
        .toString();
  }
}

class DashboardBuilder implements Builder<Dashboard, DashboardBuilder> {
  _$Dashboard? _$v;

  MapBuilder<String, int>? _batches;
  MapBuilder<String, int> get batches =>
      _$this._batches ??= MapBuilder<String, int>();
  set batches(MapBuilder<String, int>? batches) => _$this._batches = batches;

  CompletenessBuilder? _completeness;
  CompletenessBuilder get completeness =>
      _$this._completeness ??= CompletenessBuilder();
  set completeness(CompletenessBuilder? completeness) =>
      _$this._completeness = completeness;

  FinishedGoodsBuilder? _finishedGoods;
  FinishedGoodsBuilder get finishedGoods =>
      _$this._finishedGoods ??= FinishedGoodsBuilder();
  set finishedGoods(FinishedGoodsBuilder? finishedGoods) =>
      _$this._finishedGoods = finishedGoods;

  FlagCountsBuilder? _flags;
  FlagCountsBuilder get flags => _$this._flags ??= FlagCountsBuilder();
  set flags(FlagCountsBuilder? flags) => _$this._flags = flags;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  LandAreaBuilder? _landArea;
  LandAreaBuilder get landArea => _$this._landArea ??= LandAreaBuilder();
  set landArea(LandAreaBuilder? landArea) => _$this._landArea = landArea;

  ScansBuilder? _scans;
  ScansBuilder get scans => _$this._scans ??= ScansBuilder();
  set scans(ScansBuilder? scans) => _$this._scans = scans;

  ListBuilder<StageTile>? _stages;
  ListBuilder<StageTile> get stages =>
      _$this._stages ??= ListBuilder<StageTile>();
  set stages(ListBuilder<StageTile>? stages) => _$this._stages = stages;

  ListBuilder<SyncHealthRow>? _syncHealth;
  ListBuilder<SyncHealthRow> get syncHealth =>
      _$this._syncHealth ??= ListBuilder<SyncHealthRow>();
  set syncHealth(ListBuilder<SyncHealthRow>? syncHealth) =>
      _$this._syncHealth = syncHealth;

  DashboardBuilder() {
    Dashboard._defaults(this);
  }

  DashboardBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batches = $v.batches.toBuilder();
      _completeness = $v.completeness.toBuilder();
      _finishedGoods = $v.finishedGoods.toBuilder();
      _flags = $v.flags.toBuilder();
      _fpoId = $v.fpoId;
      _landArea = $v.landArea.toBuilder();
      _scans = $v.scans.toBuilder();
      _stages = $v.stages.toBuilder();
      _syncHealth = $v.syncHealth.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Dashboard other) {
    _$v = other as _$Dashboard;
  }

  @override
  void update(void Function(DashboardBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Dashboard build() => _build();

  _$Dashboard _build() {
    _$Dashboard _$result;
    try {
      _$result = _$v ??
          _$Dashboard._(
            batches: batches.build(),
            completeness: completeness.build(),
            finishedGoods: finishedGoods.build(),
            flags: flags.build(),
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'Dashboard', 'fpoId'),
            landArea: landArea.build(),
            scans: scans.build(),
            stages: stages.build(),
            syncHealth: syncHealth.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'batches';
        batches.build();
        _$failedField = 'completeness';
        completeness.build();
        _$failedField = 'finishedGoods';
        finishedGoods.build();
        _$failedField = 'flags';
        flags.build();

        _$failedField = 'landArea';
        landArea.build();
        _$failedField = 'scans';
        scans.build();
        _$failedField = 'stages';
        stages.build();
        _$failedField = 'syncHealth';
        syncHealth.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Dashboard', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
