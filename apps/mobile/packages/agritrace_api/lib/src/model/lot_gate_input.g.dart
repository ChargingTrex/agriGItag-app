// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_gate_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LotGateInput extends LotGateInput {
  @override
  final Max? max;
  @override
  final Min? min;
  @override
  final String parameter;
  @override
  final ReadingStage stage;

  factory _$LotGateInput([void Function(LotGateInputBuilder)? updates]) =>
      (LotGateInputBuilder()..update(updates))._build();

  _$LotGateInput._(
      {this.max, this.min, required this.parameter, required this.stage})
      : super._();
  @override
  LotGateInput rebuild(void Function(LotGateInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LotGateInputBuilder toBuilder() => LotGateInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LotGateInput &&
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
    return (newBuiltValueToStringHelper(r'LotGateInput')
          ..add('max', max)
          ..add('min', min)
          ..add('parameter', parameter)
          ..add('stage', stage))
        .toString();
  }
}

class LotGateInputBuilder
    implements Builder<LotGateInput, LotGateInputBuilder> {
  _$LotGateInput? _$v;

  MaxBuilder? _max;
  MaxBuilder get max => _$this._max ??= MaxBuilder();
  set max(MaxBuilder? max) => _$this._max = max;

  MinBuilder? _min;
  MinBuilder get min => _$this._min ??= MinBuilder();
  set min(MinBuilder? min) => _$this._min = min;

  String? _parameter;
  String? get parameter => _$this._parameter;
  set parameter(String? parameter) => _$this._parameter = parameter;

  ReadingStage? _stage;
  ReadingStage? get stage => _$this._stage;
  set stage(ReadingStage? stage) => _$this._stage = stage;

  LotGateInputBuilder() {
    LotGateInput._defaults(this);
  }

  LotGateInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _max = $v.max?.toBuilder();
      _min = $v.min?.toBuilder();
      _parameter = $v.parameter;
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LotGateInput other) {
    _$v = other as _$LotGateInput;
  }

  @override
  void update(void Function(LotGateInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LotGateInput build() => _build();

  _$LotGateInput _build() {
    _$LotGateInput _$result;
    try {
      _$result = _$v ??
          _$LotGateInput._(
            max: _max?.build(),
            min: _min?.build(),
            parameter: BuiltValueNullFieldError.checkNotNull(
                parameter, r'LotGateInput', 'parameter'),
            stage: BuiltValueNullFieldError.checkNotNull(
                stage, r'LotGateInput', 'stage'),
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
            r'LotGateInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
