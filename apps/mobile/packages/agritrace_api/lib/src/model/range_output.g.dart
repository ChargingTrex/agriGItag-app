// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'range_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RangeOutput extends RangeOutput {
  @override
  final num? max;
  @override
  final num? min;

  factory _$RangeOutput([void Function(RangeOutputBuilder)? updates]) =>
      (RangeOutputBuilder()..update(updates))._build();

  _$RangeOutput._({this.max, this.min}) : super._();
  @override
  RangeOutput rebuild(void Function(RangeOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RangeOutputBuilder toBuilder() => RangeOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RangeOutput && max == other.max && min == other.min;
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
    return (newBuiltValueToStringHelper(r'RangeOutput')
          ..add('max', max)
          ..add('min', min))
        .toString();
  }
}

class RangeOutputBuilder implements Builder<RangeOutput, RangeOutputBuilder> {
  _$RangeOutput? _$v;

  num? _max;
  num? get max => _$this._max;
  set max(num? max) => _$this._max = max;

  num? _min;
  num? get min => _$this._min;
  set min(num? min) => _$this._min = min;

  RangeOutputBuilder() {
    RangeOutput._defaults(this);
  }

  RangeOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _max = $v.max;
      _min = $v.min;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RangeOutput other) {
    _$v = other as _$RangeOutput;
  }

  @override
  void update(void Function(RangeOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RangeOutput build() => _build();

  _$RangeOutput _build() {
    final _$result = _$v ??
        _$RangeOutput._(
          max: max,
          min: min,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
