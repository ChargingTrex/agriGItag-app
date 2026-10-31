// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signed_quantity_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SignedQuantityInput extends SignedQuantityInput {
  @override
  final String unit;
  @override
  final Value1 value;

  factory _$SignedQuantityInput(
          [void Function(SignedQuantityInputBuilder)? updates]) =>
      (SignedQuantityInputBuilder()..update(updates))._build();

  _$SignedQuantityInput._({required this.unit, required this.value})
      : super._();
  @override
  SignedQuantityInput rebuild(
          void Function(SignedQuantityInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SignedQuantityInputBuilder toBuilder() =>
      SignedQuantityInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SignedQuantityInput &&
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
    return (newBuiltValueToStringHelper(r'SignedQuantityInput')
          ..add('unit', unit)
          ..add('value', value))
        .toString();
  }
}

class SignedQuantityInputBuilder
    implements Builder<SignedQuantityInput, SignedQuantityInputBuilder> {
  _$SignedQuantityInput? _$v;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  Value1Builder? _value;
  Value1Builder get value => _$this._value ??= Value1Builder();
  set value(Value1Builder? value) => _$this._value = value;

  SignedQuantityInputBuilder() {
    SignedQuantityInput._defaults(this);
  }

  SignedQuantityInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _unit = $v.unit;
      _value = $v.value.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SignedQuantityInput other) {
    _$v = other as _$SignedQuantityInput;
  }

  @override
  void update(void Function(SignedQuantityInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SignedQuantityInput build() => _build();

  _$SignedQuantityInput _build() {
    _$SignedQuantityInput _$result;
    try {
      _$result = _$v ??
          _$SignedQuantityInput._(
            unit: BuiltValueNullFieldError.checkNotNull(
                unit, r'SignedQuantityInput', 'unit'),
            value: value.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'value';
        value.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SignedQuantityInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
