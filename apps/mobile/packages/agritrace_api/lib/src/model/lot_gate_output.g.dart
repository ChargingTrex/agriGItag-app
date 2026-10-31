// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_gate_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LotGateOutput extends LotGateOutput {
  @override
  final num? max;
  @override
  final num? min;
  @override
  final String parameter;
  @override
  final ReadingStage stage;

  factory _$LotGateOutput([void Function(LotGateOutputBuilder)? updates]) =>
      (LotGateOutputBuilder()..update(updates))._build();

  _$LotGateOutput._(
      {this.max, this.min, required this.parameter, required this.stage})
      : super._();
  @override
  LotGateOutput rebuild(void Function(LotGateOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LotGateOutputBuilder toBuilder() => LotGateOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LotGateOutput &&
        max == other.max &&
        min == other.min &&
        parameter == other.parameter &&
        stage == other.stage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, max.hashCode);
    _$hash = $jc(_$hash, min.hashCode);
    _$hash = $jc(_$hash, parameter.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LotGateOutput')
          ..add('max', max)
          ..add('min', min)
          ..add('parameter', parameter)
          ..add('stage', stage))
        .toString();
  }
}

class LotGateOutputBuilder
    implements Builder<LotGateOutput, LotGateOutputBuilder> {
  _$LotGateOutput? _$v;

  num? _max;
  num? get max => _$this._max;
  set max(num? max) => _$this._max = max;

  num? _min;
  num? get min => _$this._min;
  set min(num? min) => _$this._min = min;

  String? _parameter;
  String? get parameter => _$this._parameter;
  set parameter(String? parameter) => _$this._parameter = parameter;

  ReadingStage? _stage;
  ReadingStage? get stage => _$this._stage;
  set stage(ReadingStage? stage) => _$this._stage = stage;

  LotGateOutputBuilder() {
    LotGateOutput._defaults(this);
  }

  LotGateOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _max = $v.max;
      _min = $v.min;
      _parameter = $v.parameter;
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LotGateOutput other) {
    _$v = other as _$LotGateOutput;
  }

  @override
  void update(void Function(LotGateOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LotGateOutput build() => _build();

  _$LotGateOutput _build() {
    final _$result = _$v ??
        _$LotGateOutput._(
          max: max,
          min: min,
          parameter: BuiltValueNullFieldError.checkNotNull(
              parameter, r'LotGateOutput', 'parameter'),
          stage: BuiltValueNullFieldError.checkNotNull(
              stage, r'LotGateOutput', 'stage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
