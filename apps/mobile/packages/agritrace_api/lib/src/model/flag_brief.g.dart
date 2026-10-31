// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_brief.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagBrief extends FlagBrief {
  @override
  final String id;
  @override
  final String ruleCode;
  @override
  final Severity severity;
  @override
  final FlagStatus status;
  @override
  final String subjectId;
  @override
  final FlagSubject subjectType;

  factory _$FlagBrief([void Function(FlagBriefBuilder)? updates]) =>
      (FlagBriefBuilder()..update(updates))._build();

  _$FlagBrief._(
      {required this.id,
      required this.ruleCode,
      required this.severity,
      required this.status,
      required this.subjectId,
      required this.subjectType})
      : super._();
  @override
  FlagBrief rebuild(void Function(FlagBriefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagBriefBuilder toBuilder() => FlagBriefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagBrief &&
        id == other.id &&
        ruleCode == other.ruleCode &&
        severity == other.severity &&
        status == other.status &&
        subjectId == other.subjectId &&
        subjectType == other.subjectType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ruleCode.hashCode);
    _$hash = $jc(_$hash, severity.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, subjectId.hashCode);
    _$hash = $jc(_$hash, subjectType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagBrief')
          ..add('id', id)
          ..add('ruleCode', ruleCode)
          ..add('severity', severity)
          ..add('status', status)
          ..add('subjectId', subjectId)
          ..add('subjectType', subjectType))
        .toString();
  }
}

class FlagBriefBuilder implements Builder<FlagBrief, FlagBriefBuilder> {
  _$FlagBrief? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ruleCode;
  String? get ruleCode => _$this._ruleCode;
  set ruleCode(String? ruleCode) => _$this._ruleCode = ruleCode;

  Severity? _severity;
  Severity? get severity => _$this._severity;
  set severity(Severity? severity) => _$this._severity = severity;

  FlagStatus? _status;
  FlagStatus? get status => _$this._status;
  set status(FlagStatus? status) => _$this._status = status;

  String? _subjectId;
  String? get subjectId => _$this._subjectId;
  set subjectId(String? subjectId) => _$this._subjectId = subjectId;

  FlagSubject? _subjectType;
  FlagSubject? get subjectType => _$this._subjectType;
  set subjectType(FlagSubject? subjectType) =>
      _$this._subjectType = subjectType;

  FlagBriefBuilder() {
    FlagBrief._defaults(this);
  }

  FlagBriefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ruleCode = $v.ruleCode;
      _severity = $v.severity;
      _status = $v.status;
      _subjectId = $v.subjectId;
      _subjectType = $v.subjectType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagBrief other) {
    _$v = other as _$FlagBrief;
  }

  @override
  void update(void Function(FlagBriefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagBrief build() => _build();

  _$FlagBrief _build() {
    final _$result = _$v ??
        _$FlagBrief._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'FlagBrief', 'id'),
          ruleCode: BuiltValueNullFieldError.checkNotNull(
              ruleCode, r'FlagBrief', 'ruleCode'),
          severity: BuiltValueNullFieldError.checkNotNull(
              severity, r'FlagBrief', 'severity'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'FlagBrief', 'status'),
          subjectId: BuiltValueNullFieldError.checkNotNull(
              subjectId, r'FlagBrief', 'subjectId'),
          subjectType: BuiltValueNullFieldError.checkNotNull(
              subjectType, r'FlagBrief', 'subjectType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
