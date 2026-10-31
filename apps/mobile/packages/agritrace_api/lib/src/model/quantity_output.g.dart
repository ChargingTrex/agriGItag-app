// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QuantityOutput extends QuantityOutput {
  @override
  final String unit;
  @override
  final String value;

  factory _$QuantityOutput([void Function(QuantityOutputBuilder)? updates]) =>
      (QuantityOutputBuilder()..update(updates))._build();

  _$QuantityOutput._({required this.unit, required this.value}) : super._();
  @override
  QuantityOutput rebuild(void Function(QuantityOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuantityOutputBuilder toBuilder() => QuantityOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuantityOutput &&
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
    return (newBuiltValueToStringHelper(r'QuantityOutput')
          ..add('unit', unit)
          ..add('value', value))
        .toString();
  }
}

class QuantityOutputBuilder
    implements Builder<QuantityOutput, QuantityOutputBuilder> {
  _$QuantityOutput? _$v;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  QuantityOutputBuilder() {
    QuantityOutput._defaults(this);
  }

  QuantityOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unit = $v.unit;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuantityOutput other) {
    _$v = other as _$QuantityOutput;
  }

  @override
  void update(void Function(QuantityOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuantityOutput build() => _build();

  _$QuantityOutput _build() {
    final _$result = _$v ??
        _$QuantityOutput._(
          unit: BuiltValueNullFieldError.checkNotNull(
              unit, r'QuantityOutput', 'unit'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'QuantityOutput', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
