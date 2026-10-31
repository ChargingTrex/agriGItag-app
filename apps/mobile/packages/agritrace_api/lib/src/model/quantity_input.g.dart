// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$QuantityInput extends QuantityInput {
  @override
  final String unit;
  @override
  final Value value;

  factory _$QuantityInput([void Function(QuantityInputBuilder)? updates]) =>
      (QuantityInputBuilder()..update(updates))._build();

  _$QuantityInput._({required this.unit, required this.value}) : super._();
  @override
  QuantityInput rebuild(void Function(QuantityInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  QuantityInputBuilder toBuilder() => QuantityInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is QuantityInput && unit == other.unit && value == other.value;
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
    return (newBuiltValueToStringHelper(r'QuantityInput')
          ..add('unit', unit)
          ..add('value', value))
        .toString();
  }
}

class QuantityInputBuilder
    implements Builder<QuantityInput, QuantityInputBuilder> {
  _$QuantityInput? _$v;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  ValueBuilder? _value;
  ValueBuilder get value => _$this._value ??= ValueBuilder();
  set value(ValueBuilder? value) => _$this._value = value;

  QuantityInputBuilder() {
    QuantityInput._defaults(this);
  }

  QuantityInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unit = $v.unit;
      _value = $v.value.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(QuantityInput other) {
    _$v = other as _$QuantityInput;
  }

  @override
  void update(void Function(QuantityInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  QuantityInput build() => _build();

  _$QuantityInput _build() {
    _$QuantityInput _$result;
    try {
      _$result = _$v ??
          _$QuantityInput._(
            unit: BuiltValueNullFieldError.checkNotNull(
                unit, r'QuantityInput', 'unit'),
            value: value.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'value';
        value.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'QuantityInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
