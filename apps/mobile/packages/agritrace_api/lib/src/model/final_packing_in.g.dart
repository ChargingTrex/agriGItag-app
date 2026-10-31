// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'final_packing_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinalPackingIn extends FinalPackingIn {
  @override
  final Date bestBeforeDate;
  @override
  final Date packDate;
  @override
  final QuantityInput packed;

  factory _$FinalPackingIn([void Function(FinalPackingInBuilder)? updates]) =>
      (FinalPackingInBuilder()..update(updates))._build();

  _$FinalPackingIn._(
      {required this.bestBeforeDate,
      required this.packDate,
      required this.packed})
      : super._();
  @override
  FinalPackingIn rebuild(void Function(FinalPackingInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinalPackingInBuilder toBuilder() => FinalPackingInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinalPackingIn &&
        bestBeforeDate == other.bestBeforeDate &&
        packDate == other.packDate &&
        packed == other.packed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bestBeforeDate.hashCode);
    _$hash = $jc(_$hash, packDate.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinalPackingIn')
          ..add('bestBeforeDate', bestBeforeDate)
          ..add('packDate', packDate)
          ..add('packed', packed))
        .toString();
  }
}

class FinalPackingInBuilder
    implements Builder<FinalPackingIn, FinalPackingInBuilder> {
  _$FinalPackingIn? _$v;

  Date? _bestBeforeDate;
  Date? get bestBeforeDate => _$this._bestBeforeDate;
  set bestBeforeDate(Date? bestBeforeDate) =>
      _$this._bestBeforeDate = bestBeforeDate;

  Date? _packDate;
  Date? get packDate => _$this._packDate;
  set packDate(Date? packDate) => _$this._packDate = packDate;

  QuantityInputBuilder? _packed;
  QuantityInputBuilder get packed => _$this._packed ??= QuantityInputBuilder();
  set packed(QuantityInputBuilder? packed) => _$this._packed = packed;

  FinalPackingInBuilder() {
    FinalPackingIn._defaults(this);
  }

  FinalPackingInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bestBeforeDate = $v.bestBeforeDate;
      _packDate = $v.packDate;
      _packed = $v.packed.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinalPackingIn other) {
    _$v = other as _$FinalPackingIn;
  }

  @override
  void update(void Function(FinalPackingInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinalPackingIn build() => _build();

  _$FinalPackingIn _build() {
    _$FinalPackingIn _$result;
    try {
      _$result = _$v ??
          _$FinalPackingIn._(
            bestBeforeDate: BuiltValueNullFieldError.checkNotNull(
                bestBeforeDate, r'FinalPackingIn', 'bestBeforeDate'),
            packDate: BuiltValueNullFieldError.checkNotNull(
                packDate, r'FinalPackingIn', 'packDate'),
            packed: packed.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packed';
        packed.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinalPackingIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
