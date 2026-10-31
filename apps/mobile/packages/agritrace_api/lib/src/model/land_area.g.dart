// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'land_area.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LandArea extends LandArea {
  @override
  final BuiltList<AreaByBlock> byBlock;
  @override
  final BuiltList<AreaByVillage> byVillage;
  @override
  final AreaStats total;

  factory _$LandArea([void Function(LandAreaBuilder)? updates]) =>
      (LandAreaBuilder()..update(updates))._build();

  _$LandArea._(
      {required this.byBlock, required this.byVillage, required this.total})
      : super._();
  @override
  LandArea rebuild(void Function(LandAreaBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LandAreaBuilder toBuilder() => LandAreaBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LandArea &&
        byBlock == other.byBlock &&
        byVillage == other.byVillage &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, byBlock.hashCode);
    _$hash = $jc(_$hash, byVillage.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LandArea')
          ..add('byBlock', byBlock)
          ..add('byVillage', byVillage)
          ..add('total', total))
        .toString();
  }
}

class LandAreaBuilder implements Builder<LandArea, LandAreaBuilder> {
  _$LandArea? _$v;

  ListBuilder<AreaByBlock>? _byBlock;
  ListBuilder<AreaByBlock> get byBlock =>
      _$this._byBlock ??= ListBuilder<AreaByBlock>();
  set byBlock(ListBuilder<AreaByBlock>? byBlock) => _$this._byBlock = byBlock;

  ListBuilder<AreaByVillage>? _byVillage;
  ListBuilder<AreaByVillage> get byVillage =>
      _$this._byVillage ??= ListBuilder<AreaByVillage>();
  set byVillage(ListBuilder<AreaByVillage>? byVillage) =>
      _$this._byVillage = byVillage;

  AreaStatsBuilder? _total;
  AreaStatsBuilder get total => _$this._total ??= AreaStatsBuilder();
  set total(AreaStatsBuilder? total) => _$this._total = total;

  LandAreaBuilder() {
    LandArea._defaults(this);
  }

  LandAreaBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _byBlock = $v.byBlock.toBuilder();
      _byVillage = $v.byVillage.toBuilder();
      _total = $v.total.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LandArea other) {
    _$v = other as _$LandArea;
  }

  @override
  void update(void Function(LandAreaBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LandArea build() => _build();

  _$LandArea _build() {
    _$LandArea _$result;
    try {
      _$result = _$v ??
          _$LandArea._(
            byBlock: byBlock.build(),
            byVillage: byVillage.build(),
            total: total.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'byBlock';
        byBlock.build();
        _$failedField = 'byVillage';
        byVillage.build();
        _$failedField = 'total';
        total.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LandArea', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
