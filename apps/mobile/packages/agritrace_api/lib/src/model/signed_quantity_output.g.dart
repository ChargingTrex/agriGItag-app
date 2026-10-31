// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_quantity_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignedQuantityOutput extends SignedQuantityOutput {
  @override
  final String unit;
  @override
  final String value;

  factory _$SignedQuantityOutput(
          [void Function(SignedQuantityOutputBuilder)? updates]) =>
      (SignedQuantityOutputBuilder()..update(updates))._build();

  _$SignedQuantityOutput._({required this.unit, required this.value})
      : super._();
  @override
  SignedQuantityOutput rebuild(
          void Function(SignedQuantityOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignedQuantityOutputBuilder toBuilder() =>
      SignedQuantityOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignedQuantityOutput &&
        unit == other.unit &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SignedQuantityOutput')
          ..add('unit', unit)
          ..add('value', value))
        .toString();
  }
}

class SignedQuantityOutputBuilder
    implements Builder<SignedQuantityOutput, SignedQuantityOutputBuilder> {
  _$SignedQuantityOutput? _$v;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  SignedQuantityOutputBuilder() {
    SignedQuantityOutput._defaults(this);
  }

  SignedQuantityOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unit = $v.unit;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignedQuantityOutput other) {
    _$v = other as _$SignedQuantityOutput;
  }

  @override
  void update(void Function(SignedQuantityOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SignedQuantityOutput build() => _build();

  _$SignedQuantityOutput _build() {
    final _$result = _$v ??
        _$SignedQuantityOutput._(
          unit: BuiltValueNullFieldError.checkNotNull(
              unit, r'SignedQuantityOutput', 'unit'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'SignedQuantityOutput', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
