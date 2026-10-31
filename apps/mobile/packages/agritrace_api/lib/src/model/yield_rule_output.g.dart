// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yield_rule_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$YieldRuleOutput extends YieldRuleOutput {
  @override
  final num ceilingKgPerAcre;
  @override
  final num holdMarginPct;
  @override
  final String? note;
  @override
  final num warnMarginPct;

  factory _$YieldRuleOutput([void Function(YieldRuleOutputBuilder)? updates]) =>
      (YieldRuleOutputBuilder()..update(updates))._build();

  _$YieldRuleOutput._(
      {required this.ceilingKgPerAcre,
      required this.holdMarginPct,
      this.note,
      required this.warnMarginPct})
      : super._();
  @override
  YieldRuleOutput rebuild(void Function(YieldRuleOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  YieldRuleOutputBuilder toBuilder() => YieldRuleOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is YieldRuleOutput &&
        ceilingKgPerAcre == other.ceilingKgPerAcre &&
        holdMarginPct == other.holdMarginPct &&
        note == other.note &&
        warnMarginPct == other.warnMarginPct;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ceilingKgPerAcre.hashCode);
    _$hash = $jc(_$hash, holdMarginPct.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, warnMarginPct.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'YieldRuleOutput')
          ..add('ceilingKgPerAcre', ceilingKgPerAcre)
          ..add('holdMarginPct', holdMarginPct)
          ..add('note', note)
          ..add('warnMarginPct', warnMarginPct))
        .toString();
  }
}

class YieldRuleOutputBuilder
    implements Builder<YieldRuleOutput, YieldRuleOutputBuilder> {
  _$YieldRuleOutput? _$v;

  num? _ceilingKgPerAcre;
  num? get ceilingKgPerAcre => _$this._ceilingKgPerAcre;
  set ceilingKgPerAcre(num? ceilingKgPerAcre) =>
      _$this._ceilingKgPerAcre = ceilingKgPerAcre;

  num? _holdMarginPct;
  num? get holdMarginPct => _$this._holdMarginPct;
  set holdMarginPct(num? holdMarginPct) =>
      _$this._holdMarginPct = holdMarginPct;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  num? _warnMarginPct;
  num? get warnMarginPct => _$this._warnMarginPct;
  set warnMarginPct(num? warnMarginPct) =>
      _$this._warnMarginPct = warnMarginPct;

  YieldRuleOutputBuilder() {
    YieldRuleOutput._defaults(this);
  }

  YieldRuleOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ceilingKgPerAcre = $v.ceilingKgPerAcre;
      _holdMarginPct = $v.holdMarginPct;
      _note = $v.note;
      _warnMarginPct = $v.warnMarginPct;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(YieldRuleOutput other) {
    _$v = other as _$YieldRuleOutput;
  }

  @override
  void update(void Function(YieldRuleOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  YieldRuleOutput build() => _build();

  _$YieldRuleOutput _build() {
    final _$result = _$v ??
        _$YieldRuleOutput._(
          ceilingKgPerAcre: BuiltValueNullFieldError.checkNotNull(
              ceilingKgPerAcre, r'YieldRuleOutput', 'ceilingKgPerAcre'),
          holdMarginPct: BuiltValueNullFieldError.checkNotNull(
              holdMarginPct, r'YieldRuleOutput', 'holdMarginPct'),
          note: note,
          warnMarginPct: BuiltValueNullFieldError.checkNotNull(
              warnMarginPct, r'YieldRuleOutput', 'warnMarginPct'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
