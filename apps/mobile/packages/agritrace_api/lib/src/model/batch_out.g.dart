// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BatchOut extends BatchOut {
  @override
  final Date? bestBeforeDate;
  @override
  final String code;
  @override
  final String? computedGrade;
  @override
  final String createdBy;
  @override
  final String cropId;
  @override
  final int currentBuildNo;
  @override
  final BuiltList<FlagBrief>? flags;
  @override
  final BuiltList<GiBlockReason> giBlockReasons;
  @override
  final bool giLabelRequested;
  @override
  final bool giVerified;
  @override
  final QuantityOutput? graded;
  @override
  final String id;
  @override
  final Date? packDate;
  @override
  final QuantityOutput? packed;
  @override
  final String processorId;
  @override
  final String? secondSignoffBy;
  @override
  final bool secondSignoffRequired;
  @override
  final BuiltList<ShareOut> shares;
  @override
  final String? standardsProfileVersionId;
  @override
  final BatchStatus status;
  @override
  final String? superlotCode;
  @override
  final QuantityOutput? totalReceived;

  factory _$BatchOut([void Function(BatchOutBuilder)? updates]) =>
      (BatchOutBuilder()..update(updates))._build();

  _$BatchOut._(
      {this.bestBeforeDate,
      required this.code,
      this.computedGrade,
      required this.createdBy,
      required this.cropId,
      required this.currentBuildNo,
      this.flags,
      required this.giBlockReasons,
      required this.giLabelRequested,
      required this.giVerified,
      this.graded,
      required this.id,
      this.packDate,
      this.packed,
      required this.processorId,
      this.secondSignoffBy,
      required this.secondSignoffRequired,
      required this.shares,
      this.standardsProfileVersionId,
      required this.status,
      this.superlotCode,
      this.totalReceived})
      : super._();
  @override
  BatchOut rebuild(void Function(BatchOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BatchOutBuilder toBuilder() => BatchOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BatchOut &&
        bestBeforeDate == other.bestBeforeDate &&
        code == other.code &&
        computedGrade == other.computedGrade &&
        createdBy == other.createdBy &&
        cropId == other.cropId &&
        currentBuildNo == other.currentBuildNo &&
        flags == other.flags &&
        giBlockReasons == other.giBlockReasons &&
        giLabelRequested == other.giLabelRequested &&
        giVerified == other.giVerified &&
        graded == other.graded &&
        id == other.id &&
        packDate == other.packDate &&
        packed == other.packed &&
        processorId == other.processorId &&
        secondSignoffBy == other.secondSignoffBy &&
        secondSignoffRequired == other.secondSignoffRequired &&
        shares == other.shares &&
        standardsProfileVersionId == other.standardsProfileVersionId &&
        status == other.status &&
        superlotCode == other.superlotCode &&
        totalReceived == other.totalReceived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bestBeforeDate.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, computedGrade.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, cropId.hashCode);
    _$hash = $jc(_$hash, currentBuildNo.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, giBlockReasons.hashCode);
    _$hash = $jc(_$hash, giLabelRequested.hashCode);
    _$hash = $jc(_$hash, giVerified.hashCode);
    _$hash = $jc(_$hash, graded.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, packDate.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jc(_$hash, processorId.hashCode);
    _$hash = $jc(_$hash, secondSignoffBy.hashCode);
    _$hash = $jc(_$hash, secondSignoffRequired.hashCode);
    _$hash = $jc(_$hash, shares.hashCode);
    _$hash = $jc(_$hash, standardsProfileVersionId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, superlotCode.hashCode);
    _$hash = $jc(_$hash, totalReceived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BatchOut')
          ..add('bestBeforeDate', bestBeforeDate)
          ..add('code', code)
          ..add('computedGrade', computedGrade)
          ..add('createdBy', createdBy)
          ..add('cropId', cropId)
          ..add('currentBuildNo', currentBuildNo)
          ..add('flags', flags)
          ..add('giBlockReasons', giBlockReasons)
          ..add('giLabelRequested', giLabelRequested)
          ..add('giVerified', giVerified)
          ..add('graded', graded)
          ..add('id', id)
          ..add('packDate', packDate)
          ..add('packed', packed)
          ..add('processorId', processorId)
          ..add('secondSignoffBy', secondSignoffBy)
          ..add('secondSignoffRequired', secondSignoffRequired)
          ..add('shares', shares)
          ..add('standardsProfileVersionId', standardsProfileVersionId)
          ..add('status', status)
          ..add('superlotCode', superlotCode)
          ..add('totalReceived', totalReceived))
        .toString();
  }
}

class BatchOutBuilder implements Builder<BatchOut, BatchOutBuilder> {
  _$BatchOut? _$v;

  Date? _bestBeforeDate;
  Date? get bestBeforeDate => _$this._bestBeforeDate;
  set bestBeforeDate(Date? bestBeforeDate) =>
      _$this._bestBeforeDate = bestBeforeDate;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _computedGrade;
  String? get computedGrade => _$this._computedGrade;
  set computedGrade(String? computedGrade) =>
      _$this._computedGrade = computedGrade;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _cropId;
  String? get cropId => _$this._cropId;
  set cropId(String? cropId) => _$this._cropId = cropId;

  int? _currentBuildNo;
  int? get currentBuildNo => _$this._currentBuildNo;
  set currentBuildNo(int? currentBuildNo) =>
      _$this._currentBuildNo = currentBuildNo;

  ListBuilder<FlagBrief>? _flags;
  ListBuilder<FlagBrief> get flags =>
      _$this._flags ??= ListBuilder<FlagBrief>();
  set flags(ListBuilder<FlagBrief>? flags) => _$this._flags = flags;

  ListBuilder<GiBlockReason>? _giBlockReasons;
  ListBuilder<GiBlockReason> get giBlockReasons =>
      _$this._giBlockReasons ??= ListBuilder<GiBlockReason>();
  set giBlockReasons(ListBuilder<GiBlockReason>? giBlockReasons) =>
      _$this._giBlockReasons = giBlockReasons;

  bool? _giLabelRequested;
  bool? get giLabelRequested => _$this._giLabelRequested;
  set giLabelRequested(bool? giLabelRequested) =>
      _$this._giLabelRequested = giLabelRequested;

  bool? _giVerified;
  bool? get giVerified => _$this._giVerified;
  set giVerified(bool? giVerified) => _$this._giVerified = giVerified;

  QuantityOutputBuilder? _graded;
  QuantityOutputBuilder get graded =>
      _$this._graded ??= QuantityOutputBuilder();
  set graded(QuantityOutputBuilder? graded) => _$this._graded = graded;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  Date? _packDate;
  Date? get packDate => _$this._packDate;
  set packDate(Date? packDate) => _$this._packDate = packDate;

  QuantityOutputBuilder? _packed;
  QuantityOutputBuilder get packed =>
      _$this._packed ??= QuantityOutputBuilder();
  set packed(QuantityOutputBuilder? packed) => _$this._packed = packed;

  String? _processorId;
  String? get processorId => _$this._processorId;
  set processorId(String? processorId) => _$this._processorId = processorId;

  String? _secondSignoffBy;
  String? get secondSignoffBy => _$this._secondSignoffBy;
  set secondSignoffBy(String? secondSignoffBy) =>
      _$this._secondSignoffBy = secondSignoffBy;

  bool? _secondSignoffRequired;
  bool? get secondSignoffRequired => _$this._secondSignoffRequired;
  set secondSignoffRequired(bool? secondSignoffRequired) =>
      _$this._secondSignoffRequired = secondSignoffRequired;

  ListBuilder<ShareOut>? _shares;
  ListBuilder<ShareOut> get shares =>
      _$this._shares ??= ListBuilder<ShareOut>();
  set shares(ListBuilder<ShareOut>? shares) => _$this._shares = shares;

  String? _standardsProfileVersionId;
  String? get standardsProfileVersionId => _$this._standardsProfileVersionId;
  set standardsProfileVersionId(String? standardsProfileVersionId) =>
      _$this._standardsProfileVersionId = standardsProfileVersionId;

  BatchStatus? _status;
  BatchStatus? get status => _$this._status;
  set status(BatchStatus? status) => _$this._status = status;

  String? _superlotCode;
  String? get superlotCode => _$this._superlotCode;
  set superlotCode(String? superlotCode) => _$this._superlotCode = superlotCode;

  QuantityOutputBuilder? _totalReceived;
  QuantityOutputBuilder get totalReceived =>
      _$this._totalReceived ??= QuantityOutputBuilder();
  set totalReceived(QuantityOutputBuilder? totalReceived) =>
      _$this._totalReceived = totalReceived;

  BatchOutBuilder() {
    BatchOut._defaults(this);
  }

  BatchOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bestBeforeDate = $v.bestBeforeDate;
      _code = $v.code;
      _computedGrade = $v.computedGrade;
      _createdBy = $v.createdBy;
      _cropId = $v.cropId;
      _currentBuildNo = $v.currentBuildNo;
      _flags = $v.flags?.toBuilder();
      _giBlockReasons = $v.giBlockReasons.toBuilder();
      _giLabelRequested = $v.giLabelRequested;
      _giVerified = $v.giVerified;
      _graded = $v.graded?.toBuilder();
      _id = $v.id;
      _packDate = $v.packDate;
      _packed = $v.packed?.toBuilder();
      _processorId = $v.processorId;
      _secondSignoffBy = $v.secondSignoffBy;
      _secondSignoffRequired = $v.secondSignoffRequired;
      _shares = $v.shares.toBuilder();
      _standardsProfileVersionId = $v.standardsProfileVersionId;
      _status = $v.status;
      _superlotCode = $v.superlotCode;
      _totalReceived = $v.totalReceived?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BatchOut other) {
    _$v = other as _$BatchOut;
  }

  @override
  void update(void Function(BatchOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BatchOut build() => _build();

  _$BatchOut _build() {
    _$BatchOut _$result;
    try {
      _$result = _$v ??
          _$BatchOut._(
            bestBeforeDate: bestBeforeDate,
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'BatchOut', 'code'),
            computedGrade: computedGrade,
            createdBy: BuiltValueNullFieldError.checkNotNull(
                createdBy, r'BatchOut', 'createdBy'),
            cropId: BuiltValueNullFieldError.checkNotNull(
                cropId, r'BatchOut', 'cropId'),
            currentBuildNo: BuiltValueNullFieldError.checkNotNull(
                currentBuildNo, r'BatchOut', 'currentBuildNo'),
            flags: _flags?.build(),
            giBlockReasons: giBlockReasons.build(),
            giLabelRequested: BuiltValueNullFieldError.checkNotNull(
                giLabelRequested, r'BatchOut', 'giLabelRequested'),
            giVerified: BuiltValueNullFieldError.checkNotNull(
                giVerified, r'BatchOut', 'giVerified'),
            graded: _graded?.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'BatchOut', 'id'),
            packDate: packDate,
            packed: _packed?.build(),
            processorId: BuiltValueNullFieldError.checkNotNull(
                processorId, r'BatchOut', 'processorId'),
            secondSignoffBy: secondSignoffBy,
            secondSignoffRequired: BuiltValueNullFieldError.checkNotNull(
                secondSignoffRequired, r'BatchOut', 'secondSignoffRequired'),
            shares: shares.build(),
            standardsProfileVersionId: standardsProfileVersionId,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BatchOut', 'status'),
            superlotCode: superlotCode,
            totalReceived: _totalReceived?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'flags';
        _flags?.build();
        _$failedField = 'giBlockReasons';
        giBlockReasons.build();

        _$failedField = 'graded';
        _graded?.build();

        _$failedField = 'packed';
        _packed?.build();

        _$failedField = 'shares';
        shares.build();

        _$failedField = 'totalReceived';
        _totalReceived?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BatchOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
