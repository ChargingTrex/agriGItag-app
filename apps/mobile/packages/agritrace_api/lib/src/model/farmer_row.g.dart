// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerRow extends FarmerRow {
  @override
  final String? block;
  @override
  final String code;
  @override
  final QuantityOutput declaredArea;
  @override
  final String id;
  @override
  final int lots;
  @override
  final int lotsComplete;
  @override
  final String name;
  @override
  final String? nameLocal;
  @override
  final int plots;
  @override
  final FarmerStatus status;
  @override
  final String? village;
  @override
  final String? villageId;
  @override
  final QuantityOutput walkedArea;

  factory _$FarmerRow([void Function(FarmerRowBuilder)? updates]) =>
      (FarmerRowBuilder()..update(updates))._build();

  _$FarmerRow._(
      {this.block,
      required this.code,
      required this.declaredArea,
      required this.id,
      required this.lots,
      required this.lotsComplete,
      required this.name,
      this.nameLocal,
      required this.plots,
      required this.status,
      this.village,
      this.villageId,
      required this.walkedArea})
      : super._();
  @override
  FarmerRow rebuild(void Function(FarmerRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerRowBuilder toBuilder() => FarmerRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerRow &&
        block == other.block &&
        code == other.code &&
        declaredArea == other.declaredArea &&
        id == other.id &&
        lots == other.lots &&
        lotsComplete == other.lotsComplete &&
        name == other.name &&
        nameLocal == other.nameLocal &&
        plots == other.plots &&
        status == other.status &&
        village == other.village &&
        villageId == other.villageId &&
        walkedArea == other.walkedArea;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, block.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, declaredArea.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lots.hashCode);
    _$hash = $jc(_$hash, lotsComplete.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, plots.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, village.hashCode);
    _$hash = $jc(_$hash, villageId.hashCode);
    _$hash = $jc(_$hash, walkedArea.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerRow')
          ..add('block', block)
          ..add('code', code)
          ..add('declaredArea', declaredArea)
          ..add('id', id)
          ..add('lots', lots)
          ..add('lotsComplete', lotsComplete)
          ..add('name', name)
          ..add('nameLocal', nameLocal)
          ..add('plots', plots)
          ..add('status', status)
          ..add('village', village)
          ..add('villageId', villageId)
          ..add('walkedArea', walkedArea))
        .toString();
  }
}

class FarmerRowBuilder implements Builder<FarmerRow, FarmerRowBuilder> {
  _$FarmerRow? _$v;

  String? _block;
  String? get block => _$this._block;
  set block(String? block) => _$this._block = block;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  QuantityOutputBuilder? _declaredArea;
  QuantityOutputBuilder get declaredArea =>
      _$this._declaredArea ??= QuantityOutputBuilder();
  set declaredArea(QuantityOutputBuilder? declaredArea) =>
      _$this._declaredArea = declaredArea;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _lots;
  int? get lots => _$this._lots;
  set lots(int? lots) => _$this._lots = lots;

  int? _lotsComplete;
  int? get lotsComplete => _$this._lotsComplete;
  set lotsComplete(int? lotsComplete) => _$this._lotsComplete = lotsComplete;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  int? _plots;
  int? get plots => _$this._plots;
  set plots(int? plots) => _$this._plots = plots;

  FarmerStatus? _status;
  FarmerStatus? get status => _$this._status;
  set status(FarmerStatus? status) => _$this._status = status;

  String? _village;
  String? get village => _$this._village;
  set village(String? village) => _$this._village = village;

  String? _villageId;
  String? get villageId => _$this._villageId;
  set villageId(String? villageId) => _$this._villageId = villageId;

  QuantityOutputBuilder? _walkedArea;
  QuantityOutputBuilder get walkedArea =>
      _$this._walkedArea ??= QuantityOutputBuilder();
  set walkedArea(QuantityOutputBuilder? walkedArea) =>
      _$this._walkedArea = walkedArea;

  FarmerRowBuilder() {
    FarmerRow._defaults(this);
  }

  FarmerRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _block = $v.block;
      _code = $v.code;
      _declaredArea = $v.declaredArea.toBuilder();
      _id = $v.id;
      _lots = $v.lots;
      _lotsComplete = $v.lotsComplete;
      _name = $v.name;
      _nameLocal = $v.nameLocal;
      _plots = $v.plots;
      _status = $v.status;
      _village = $v.village;
      _villageId = $v.villageId;
      _walkedArea = $v.walkedArea.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerRow other) {
    _$v = other as _$FarmerRow;
  }

  @override
  void update(void Function(FarmerRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerRow build() => _build();

  _$FarmerRow _build() {
    _$FarmerRow _$result;
    try {
      _$result = _$v ??
          _$FarmerRow._(
            block: block,
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'FarmerRow', 'code'),
            declaredArea: declaredArea.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'FarmerRow', 'id'),
            lots: BuiltValueNullFieldError.checkNotNull(
                lots, r'FarmerRow', 'lots'),
            lotsComplete: BuiltValueNullFieldError.checkNotNull(
                lotsComplete, r'FarmerRow', 'lotsComplete'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'FarmerRow', 'name'),
            nameLocal: nameLocal,
            plots: BuiltValueNullFieldError.checkNotNull(
                plots, r'FarmerRow', 'plots'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'FarmerRow', 'status'),
            village: village,
            villageId: villageId,
            walkedArea: walkedArea.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declaredArea';
        declaredArea.build();

        _$failedField = 'walkedArea';
        walkedArea.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FarmerRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
