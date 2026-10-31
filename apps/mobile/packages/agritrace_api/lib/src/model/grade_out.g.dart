// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GradeOut extends GradeOut {
  @override
  final String batchId;
  @override
  final DateTime computedAt;
  @override
  final String? computedGrade;
  @override
  final String? declaredGrade;
  @override
  final String id;
  @override
  final bool labCertified;
  @override
  final BuiltMap<String, ParameterResult> perParameter;
  @override
  final String profileVersionId;
  @override
  final GradeStatus status;

  factory _$GradeOut([void Function(GradeOutBuilder)? updates]) =>
      (GradeOutBuilder()..update(updates))._build();

  _$GradeOut._(
      {required this.batchId,
      required this.computedAt,
      this.computedGrade,
      this.declaredGrade,
      required this.id,
      required this.labCertified,
      required this.perParameter,
      required this.profileVersionId,
      required this.status})
      : super._();
  @override
  GradeOut rebuild(void Function(GradeOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GradeOutBuilder toBuilder() => GradeOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GradeOut &&
        batchId == other.batchId &&
        computedAt == other.computedAt &&
        computedGrade == other.computedGrade &&
        declaredGrade == other.declaredGrade &&
        id == other.id &&
        labCertified == other.labCertified &&
        perParameter == other.perParameter &&
        profileVersionId == other.profileVersionId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, computedAt.hashCode);
    _$hash = $jc(_$hash, computedGrade.hashCode);
    _$hash = $jc(_$hash, declaredGrade.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, labCertified.hashCode);
    _$hash = $jc(_$hash, perParameter.hashCode);
    _$hash = $jc(_$hash, profileVersionId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GradeOut')
          ..add('batchId', batchId)
          ..add('computedAt', computedAt)
          ..add('computedGrade', computedGrade)
          ..add('declaredGrade', declaredGrade)
          ..add('id', id)
          ..add('labCertified', labCertified)
          ..add('perParameter', perParameter)
          ..add('profileVersionId', profileVersionId)
          ..add('status', status))
        .toString();
  }
}

class GradeOutBuilder implements Builder<GradeOut, GradeOutBuilder> {
  _$GradeOut? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  DateTime? _computedAt;
  DateTime? get computedAt => _$this._computedAt;
  set computedAt(DateTime? computedAt) => _$this._computedAt = computedAt;

  String? _computedGrade;
  String? get computedGrade => _$this._computedGrade;
  set computedGrade(String? computedGrade) =>
      _$this._computedGrade = computedGrade;

  String? _declaredGrade;
  String? get declaredGrade => _$this._declaredGrade;
  set declaredGrade(String? declaredGrade) =>
      _$this._declaredGrade = declaredGrade;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _labCertified;
  bool? get labCertified => _$this._labCertified;
  set labCertified(bool? labCertified) => _$this._labCertified = labCertified;

  MapBuilder<String, ParameterResult>? _perParameter;
  MapBuilder<String, ParameterResult> get perParameter =>
      _$this._perParameter ??= MapBuilder<String, ParameterResult>();
  set perParameter(MapBuilder<String, ParameterResult>? perParameter) =>
      _$this._perParameter = perParameter;

  String? _profileVersionId;
  String? get profileVersionId => _$this._profileVersionId;
  set profileVersionId(String? profileVersionId) =>
      _$this._profileVersionId = profileVersionId;

  GradeStatus? _status;
  GradeStatus? get status => _$this._status;
  set status(GradeStatus? status) => _$this._status = status;

  GradeOutBuilder() {
    GradeOut._defaults(this);
  }

  GradeOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _computedAt = $v.computedAt;
      _computedGrade = $v.computedGrade;
      _declaredGrade = $v.declaredGrade;
      _id = $v.id;
      _labCertified = $v.labCertified;
      _perParameter = $v.perParameter.toBuilder();
      _profileVersionId = $v.profileVersionId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GradeOut other) {
    _$v = other as _$GradeOut;
  }

  @override
  void update(void Function(GradeOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GradeOut build() => _build();

  _$GradeOut _build() {
    _$GradeOut _$result;
    try {
      _$result = _$v ??
          _$GradeOut._(
            batchId: BuiltValueNullFieldError.checkNotNull(
                batchId, r'GradeOut', 'batchId'),
            computedAt: BuiltValueNullFieldError.checkNotNull(
                computedAt, r'GradeOut', 'computedAt'),
            computedGrade: computedGrade,
            declaredGrade: declaredGrade,
            id: BuiltValueNullFieldError.checkNotNull(id, r'GradeOut', 'id'),
            labCertified: BuiltValueNullFieldError.checkNotNull(
                labCertified, r'GradeOut', 'labCertified'),
            perParameter: perParameter.build(),
            profileVersionId: BuiltValueNullFieldError.checkNotNull(
                profileVersionId, r'GradeOut', 'profileVersionId'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GradeOut', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'perParameter';
        perParameter.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GradeOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
