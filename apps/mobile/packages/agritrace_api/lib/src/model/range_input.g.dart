// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'range_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RangeInput extends RangeInput {
  @override
  final Max? max;
  @override
  final Min? min;

  factory _$RangeInput([void Function(RangeInputBuilder)? updates]) =>
      (RangeInputBuilder()..update(updates))._build();

  _$RangeInput._({this.max, this.min}) : super._();
  @override
  RangeInput rebuild(void Function(RangeInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RangeInputBuilder toBuilder() => RangeInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RangeInput && max == other.max && min == other.min;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jc(_$hash, min.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RangeInput')
          ..add('max', max)
          ..add('min', min))
        .toString();
  }
}

class RangeInputBuilder implements Builder<RangeInput, RangeInputBuilder> {
  _$RangeInput? _$v;

  MaxBuilder? _max;
  MaxBuilder get max => _$this._max ??= MaxBuilder();
  set max(MaxBuilder? max) => _$this._max = max;

  MinBuilder? _min;
  MinBuilder get min => _$this._min ??= MinBuilder();
  set min(MinBuilder? min) => _$this._min = min;

  RangeInputBuilder() {
    RangeInput._defaults(this);
  }

  RangeInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _max = $v.max?.toBuilder();
      _min = $v.min?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RangeInput other) {
    _$v = other as _$RangeInput;
  }

  @override
  void update(void Function(RangeInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RangeInput build() => _build();

  _$RangeInput _build() {
    _$RangeInput _$result;
    try {
      _$result = _$v ??
          _$RangeInput._(
            max: _max?.build(),
            min: _min?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'max';
        _max?.build();
        _$failedField = 'min';
        _min?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RangeInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
