// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_by_block.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AreaByBlock extends AreaByBlock {
  @override
  final String? block;
  @override
  final QuantityOutput declaredArea;
  @override
  final QuantityOutput giConfirmedArea;
  @override
  final QuantityOutput? giConfirmedShare;
  @override
  final int plots;
  @override
  final QuantityOutput walkedArea;
  @override
  final QuantityOutput walkedDeclaredArea;
  @override
  final int walkedPlots;

  factory _$AreaByBlock([void Function(AreaByBlockBuilder)? updates]) =>
      (AreaByBlockBuilder()..update(updates))._build();

  _$AreaByBlock._(
      {this.block,
      required this.declaredArea,
      required this.giConfirmedArea,
      this.giConfirmedShare,
      required this.plots,
      required this.walkedArea,
      required this.walkedDeclaredArea,
      required this.walkedPlots})
      : super._();
  @override
  AreaByBlock rebuild(void Function(AreaByBlockBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AreaByBlockBuilder toBuilder() => AreaByBlockBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AreaByBlock &&
        block == other.block &&
        declaredArea == other.declaredArea &&
        giConfirmedArea == other.giConfirmedArea &&
        giConfirmedShare == other.giConfirmedShare &&
        plots == other.plots &&
        walkedArea == other.walkedArea &&
        walkedDeclaredArea == other.walkedDeclaredArea &&
        walkedPlots == other.walkedPlots;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, block.hashCode);
    _$hash = $jc(_$hash, declaredArea.hashCode);
    _$hash = $jc(_$hash, giConfirmedArea.hashCode);
    _$hash = $jc(_$hash, giConfirmedShare.hashCode);
    _$hash = $jc(_$hash, plots.hashCode);
    _$hash = $jc(_$hash, walkedArea.hashCode);
    _$hash = $jc(_$hash, walkedDeclaredArea.hashCode);
    _$hash = $jc(_$hash, walkedPlots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AreaByBlock')
          ..add('block', block)
          ..add('declaredArea', declaredArea)
          ..add('giConfirmedArea', giConfirmedArea)
          ..add('giConfirmedShare', giConfirmedShare)
          ..add('plots', plots)
          ..add('walkedArea', walkedArea)
          ..add('walkedDeclaredArea', walkedDeclaredArea)
          ..add('walkedPlots', walkedPlots))
        .toString();
  }
}

class AreaByBlockBuilder implements Builder<AreaByBlock, AreaByBlockBuilder> {
  _$AreaByBlock? _$v;

  String? _block;
  String? get block => _$this._block;
  set block(String? block) => _$this._block = block;

  QuantityOutputBuilder? _declaredArea;
  QuantityOutputBuilder get declaredArea =>
      _$this._declaredArea ??= QuantityOutputBuilder();
  set declaredArea(QuantityOutputBuilder? declaredArea) =>
      _$this._declaredArea = declaredArea;

  QuantityOutputBuilder? _giConfirmedArea;
  QuantityOutputBuilder get giConfirmedArea =>
      _$this._giConfirmedArea ??= QuantityOutputBuilder();
  set giConfirmedArea(QuantityOutputBuilder? giConfirmedArea) =>
      _$this._giConfirmedArea = giConfirmedArea;

  QuantityOutputBuilder? _giConfirmedShare;
  QuantityOutputBuilder get giConfirmedShare =>
      _$this._giConfirmedShare ??= QuantityOutputBuilder();
  set giConfirmedShare(QuantityOutputBuilder? giConfirmedShare) =>
      _$this._giConfirmedShare = giConfirmedShare;

  int? _plots;
  int? get plots => _$this._plots;
  set plots(int? plots) => _$this._plots = plots;

  QuantityOutputBuilder? _walkedArea;
  QuantityOutputBuilder get walkedArea =>
      _$this._walkedArea ??= QuantityOutputBuilder();
  set walkedArea(QuantityOutputBuilder? walkedArea) =>
      _$this._walkedArea = walkedArea;

  QuantityOutputBuilder? _walkedDeclaredArea;
  QuantityOutputBuilder get walkedDeclaredArea =>
      _$this._walkedDeclaredArea ??= QuantityOutputBuilder();
  set walkedDeclaredArea(QuantityOutputBuilder? walkedDeclaredArea) =>
      _$this._walkedDeclaredArea = walkedDeclaredArea;

  int? _walkedPlots;
  int? get walkedPlots => _$this._walkedPlots;
  set walkedPlots(int? walkedPlots) => _$this._walkedPlots = walkedPlots;

  AreaByBlockBuilder() {
    AreaByBlock._defaults(this);
  }

  AreaByBlockBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _block = $v.block;
      _declaredArea = $v.declaredArea.toBuilder();
      _giConfirmedArea = $v.giConfirmedArea.toBuilder();
      _giConfirmedShare = $v.giConfirmedShare?.toBuilder();
      _plots = $v.plots;
      _walkedArea = $v.walkedArea.toBuilder();
      _walkedDeclaredArea = $v.walkedDeclaredArea.toBuilder();
      _walkedPlots = $v.walkedPlots;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AreaByBlock other) {
    _$v = other as _$AreaByBlock;
  }

  @override
  void update(void Function(AreaByBlockBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AreaByBlock build() => _build();

  _$AreaByBlock _build() {
    _$AreaByBlock _$result;
    try {
      _$result = _$v ??
          _$AreaByBlock._(
            block: block,
            declaredArea: declaredArea.build(),
            giConfirmedArea: giConfirmedArea.build(),
            giConfirmedShare: _giConfirmedShare?.build(),
            plots: BuiltValueNullFieldError.checkNotNull(
                plots, r'AreaByBlock', 'plots'),
            walkedArea: walkedArea.build(),
            walkedDeclaredArea: walkedDeclaredArea.build(),
            walkedPlots: BuiltValueNullFieldError.checkNotNull(
                walkedPlots, r'AreaByBlock', 'walkedPlots'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declaredArea';
        declaredArea.build();
        _$failedField = 'giConfirmedArea';
        giConfirmedArea.build();
        _$failedField = 'giConfirmedShare';
        _giConfirmedShare?.build();

        _$failedField = 'walkedArea';
        walkedArea.build();
        _$failedField = 'walkedDeclaredArea';
        walkedDeclaredArea.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AreaByBlock', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
