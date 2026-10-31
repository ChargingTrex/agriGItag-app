// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finished_batch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinishedBatch extends FinishedBatch {
  @override
  final String batchId;
  @override
  final String code;
  @override
  final Date? packDate;
  @override
  final QuantityOutput? packed;
  @override
  final QuantityOutput? remaining;
  @override
  final int scans;
  @override
  final BatchStatus status;

  factory _$FinishedBatch([void Function(FinishedBatchBuilder)? updates]) =>
      (FinishedBatchBuilder()..update(updates))._build();

  _$FinishedBatch._(
      {required this.batchId,
      required this.code,
      this.packDate,
      this.packed,
      this.remaining,
      required this.scans,
      required this.status})
      : super._();
  @override
  FinishedBatch rebuild(void Function(FinishedBatchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinishedBatchBuilder toBuilder() => FinishedBatchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinishedBatch &&
        batchId == other.batchId &&
        code == other.code &&
        packDate == other.packDate &&
        packed == other.packed &&
        remaining == other.remaining &&
        scans == other.scans &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, packDate.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jc(_$hash, remaining.hashCode);
    _$hash = $jc(_$hash, scans.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinishedBatch')
          ..add('batchId', batchId)
          ..add('code', code)
          ..add('packDate', packDate)
          ..add('packed', packed)
          ..add('remaining', remaining)
          ..add('scans', scans)
          ..add('status', status))
        .toString();
  }
}

class FinishedBatchBuilder
    implements Builder<FinishedBatch, FinishedBatchBuilder> {
  _$FinishedBatch? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  Date? _packDate;
  Date? get packDate => _$this._packDate;
  set packDate(Date? packDate) => _$this._packDate = packDate;

  QuantityOutputBuilder? _packed;
  QuantityOutputBuilder get packed =>
      _$this._packed ??= QuantityOutputBuilder();
  set packed(QuantityOutputBuilder? packed) => _$this._packed = packed;

  QuantityOutputBuilder? _remaining;
  QuantityOutputBuilder get remaining =>
      _$this._remaining ??= QuantityOutputBuilder();
  set remaining(QuantityOutputBuilder? remaining) =>
      _$this._remaining = remaining;

  int? _scans;
  int? get scans => _$this._scans;
  set scans(int? scans) => _$this._scans = scans;

  BatchStatus? _status;
  BatchStatus? get status => _$this._status;
  set status(BatchStatus? status) => _$this._status = status;

  FinishedBatchBuilder() {
    FinishedBatch._defaults(this);
  }

  FinishedBatchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _code = $v.code;
      _packDate = $v.packDate;
      _packed = $v.packed?.toBuilder();
      _remaining = $v.remaining?.toBuilder();
      _scans = $v.scans;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinishedBatch other) {
    _$v = other as _$FinishedBatch;
  }

  @override
  void update(void Function(FinishedBatchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinishedBatch build() => _build();

  _$FinishedBatch _build() {
    _$FinishedBatch _$result;
    try {
      _$result = _$v ??
          _$FinishedBatch._(
            batchId: BuiltValueNullFieldError.checkNotNull(
                batchId, r'FinishedBatch', 'batchId'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'FinishedBatch', 'code'),
            packDate: packDate,
            packed: _packed?.build(),
            remaining: _remaining?.build(),
            scans: BuiltValueNullFieldError.checkNotNull(
                scans, r'FinishedBatch', 'scans'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'FinishedBatch', 'status'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packed';
        _packed?.build();
        _$failedField = 'remaining';
        _remaining?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinishedBatch', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
