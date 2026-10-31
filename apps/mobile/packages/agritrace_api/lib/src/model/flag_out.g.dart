// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagOut extends FlagOut {
  @override
  final Role? assignedRole;
  @override
  final BuiltMap<String, JsonObject?>? details;
  @override
  final String fpoId;
  @override
  final String id;
  @override
  final DateTime raisedAt;
  @override
  final String? resolutionNote;
  @override
  final String? resolutionReasonCode;
  @override
  final DateTime? resolvedAt;
  @override
  final String? resolvedBy;
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

  factory _$FlagOut([void Function(FlagOutBuilder)? updates]) =>
      (FlagOutBuilder()..update(updates))._build();

  _$FlagOut._(
      {this.assignedRole,
      this.details,
      required this.fpoId,
      required this.id,
      required this.raisedAt,
      this.resolutionNote,
      this.resolutionReasonCode,
      this.resolvedAt,
      this.resolvedBy,
      required this.ruleCode,
      required this.severity,
      required this.status,
      required this.subjectId,
      required this.subjectType})
      : super._();
  @override
  FlagOut rebuild(void Function(FlagOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagOutBuilder toBuilder() => FlagOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagOut &&
        assignedRole == other.assignedRole &&
        details == other.details &&
        fpoId == other.fpoId &&
        id == other.id &&
        raisedAt == other.raisedAt &&
        resolutionNote == other.resolutionNote &&
        resolutionReasonCode == other.resolutionReasonCode &&
        resolvedAt == other.resolvedAt &&
        resolvedBy == other.resolvedBy &&
        ruleCode == other.ruleCode &&
        severity == other.severity &&
        status == other.status &&
        subjectId == other.subjectId &&
        subjectType == other.subjectType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assignedRole.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, raisedAt.hashCode);
    _$hash = $jc(_$hash, resolutionNote.hashCode);
    _$hash = $jc(_$hash, resolutionReasonCode.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jc(_$hash, resolvedBy.hashCode);
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
    return (newBuiltValueToStringHelper(r'FlagOut')
          ..add('assignedRole', assignedRole)
          ..add('details', details)
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('raisedAt', raisedAt)
          ..add('resolutionNote', resolutionNote)
          ..add('resolutionReasonCode', resolutionReasonCode)
          ..add('resolvedAt', resolvedAt)
          ..add('resolvedBy', resolvedBy)
          ..add('ruleCode', ruleCode)
          ..add('severity', severity)
          ..add('status', status)
          ..add('subjectId', subjectId)
          ..add('subjectType', subjectType))
        .toString();
  }
}

class FlagOutBuilder implements Builder<FlagOut, FlagOutBuilder> {
  _$FlagOut? _$v;

  Role? _assignedRole;
  Role? get assignedRole => _$this._assignedRole;
  set assignedRole(Role? assignedRole) => _$this._assignedRole = assignedRole;

  MapBuilder<String, JsonObject?>? _details;
  MapBuilder<String, JsonObject?> get details =>
      _$this._details ??= MapBuilder<String, JsonObject?>();
  set details(MapBuilder<String, JsonObject?>? details) =>
      _$this._details = details;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _raisedAt;
  DateTime? get raisedAt => _$this._raisedAt;
  set raisedAt(DateTime? raisedAt) => _$this._raisedAt = raisedAt;

  String? _resolutionNote;
  String? get resolutionNote => _$this._resolutionNote;
  set resolutionNote(String? resolutionNote) =>
      _$this._resolutionNote = resolutionNote;

  String? _resolutionReasonCode;
  String? get resolutionReasonCode => _$this._resolutionReasonCode;
  set resolutionReasonCode(String? resolutionReasonCode) =>
      _$this._resolutionReasonCode = resolutionReasonCode;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  String? _resolvedBy;
  String? get resolvedBy => _$this._resolvedBy;
  set resolvedBy(String? resolvedBy) => _$this._resolvedBy = resolvedBy;

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

  FlagOutBuilder() {
    FlagOut._defaults(this);
  }

  FlagOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assignedRole = $v.assignedRole;
      _details = $v.details?.toBuilder();
      _fpoId = $v.fpoId;
      _id = $v.id;
      _raisedAt = $v.raisedAt;
      _resolutionNote = $v.resolutionNote;
      _resolutionReasonCode = $v.resolutionReasonCode;
      _resolvedAt = $v.resolvedAt;
      _resolvedBy = $v.resolvedBy;
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
  void replace(FlagOut other) {
    _$v = other as _$FlagOut;
  }

  @override
  void update(void Function(FlagOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagOut build() => _build();

  _$FlagOut _build() {
    _$FlagOut _$result;
    try {
      _$result = _$v ??
          _$FlagOut._(
            assignedRole: assignedRole,
            details: _details?.build(),
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'FlagOut', 'fpoId'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'FlagOut', 'id'),
            raisedAt: BuiltValueNullFieldError.checkNotNull(
                raisedAt, r'FlagOut', 'raisedAt'),
            resolutionNote: resolutionNote,
            resolutionReasonCode: resolutionReasonCode,
            resolvedAt: resolvedAt,
            resolvedBy: resolvedBy,
            ruleCode: BuiltValueNullFieldError.checkNotNull(
                ruleCode, r'FlagOut', 'ruleCode'),
            severity: BuiltValueNullFieldError.checkNotNull(
                severity, r'FlagOut', 'severity'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'FlagOut', 'status'),
            subjectId: BuiltValueNullFieldError.checkNotNull(
                subjectId, r'FlagOut', 'subjectId'),
            subjectType: BuiltValueNullFieldError.checkNotNull(
                subjectType, r'FlagOut', 'subjectType'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        _details?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FlagOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
