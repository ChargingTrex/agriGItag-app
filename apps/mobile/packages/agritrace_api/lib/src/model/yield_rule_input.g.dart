// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yield_rule_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$YieldRuleInput extends YieldRuleInput {
  @override
  final CeilingKgPerAcre ceilingKgPerAcre;
  @override
  final HoldMarginPct holdMarginPct;
  @override
  final String? note;
  @override
  final WarnMarginPct warnMarginPct;

  factory _$YieldRuleInput([void Function(YieldRuleInputBuilder)? updates]) =>
      (YieldRuleInputBuilder()..update(updates))._build();

  _$YieldRuleInput._(
      {required this.ceilingKgPerAcre,
      required this.holdMarginPct,
      this.note,
      required this.warnMarginPct})
      : super._();
  @override
  YieldRuleInput rebuild(void Function(YieldRuleInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  YieldRuleInputBuilder toBuilder() => YieldRuleInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is YieldRuleInput &&
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
    return (newBuiltValueToStringHelper(r'YieldRuleInput')
          ..add('ceilingKgPerAcre', ceilingKgPerAcre)
          ..add('holdMarginPct', holdMarginPct)
          ..add('note', note)
          ..add('warnMarginPct', warnMarginPct))
        .toString();
  }
}

class YieldRuleInputBuilder
    implements Builder<YieldRuleInput, YieldRuleInputBuilder> {
  _$YieldRuleInput? _$v;

  CeilingKgPerAcreBuilder? _ceilingKgPerAcre;
  CeilingKgPerAcreBuilder get ceilingKgPerAcre =>
      _$this._ceilingKgPerAcre ??= CeilingKgPerAcreBuilder();
  set ceilingKgPerAcre(CeilingKgPerAcreBuilder? ceilingKgPerAcre) =>
      _$this._ceilingKgPerAcre = ceilingKgPerAcre;

  HoldMarginPctBuilder? _holdMarginPct;
  HoldMarginPctBuilder get holdMarginPct =>
      _$this._holdMarginPct ??= HoldMarginPctBuilder();
  set holdMarginPct(HoldMarginPctBuilder? holdMarginPct) =>
      _$this._holdMarginPct = holdMarginPct;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  WarnMarginPctBuilder? _warnMarginPct;
  WarnMarginPctBuilder get warnMarginPct =>
      _$this._warnMarginPct ??= WarnMarginPctBuilder();
  set warnMarginPct(WarnMarginPctBuilder? warnMarginPct) =>
      _$this._warnMarginPct = warnMarginPct;

  YieldRuleInputBuilder() {
    YieldRuleInput._defaults(this);
  }

  YieldRuleInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ceilingKgPerAcre = $v.ceilingKgPerAcre.toBuilder();
      _holdMarginPct = $v.holdMarginPct.toBuilder();
      _note = $v.note;
      _warnMarginPct = $v.warnMarginPct.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(YieldRuleInput other) {
    _$v = other as _$YieldRuleInput;
  }

  @override
  void update(void Function(YieldRuleInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  YieldRuleInput build() => _build();

  _$YieldRuleInput _build() {
    _$YieldRuleInput _$result;
    try {
      _$result = _$v ??
          _$YieldRuleInput._(
            ceilingKgPerAcre: ceilingKgPerAcre.build(),
            holdMarginPct: holdMarginPct.build(),
            note: note,
            warnMarginPct: warnMarginPct.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ceilingKgPerAcre';
        ceilingKgPerAcre.build();
        _$failedField = 'holdMarginPct';
        holdMarginPct.build();

        _$failedField = 'warnMarginPct';
        warnMarginPct.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'YieldRuleInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
