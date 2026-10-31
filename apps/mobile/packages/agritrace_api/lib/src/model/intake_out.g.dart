// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IntakeOut extends IntakeOut {
  @override
  final String acceptedByUserId;
  @override
  final String? correctionReason;
  @override
  final BuiltList<FlagBrief>? flags;
  @override
  final String id;
  @override
  final String? intakeMoistureReadingId;
  @override
  final String lotId;
  @override
  final String? pricePerKg;
  @override
  final String processorId;
  @override
  final QuantityOutput received;
  @override
  final Reconciliation? reconciliation;
  @override
  final Date saleDate;
  @override
  final String? supersedesIntakeId;

  factory _$IntakeOut([void Function(IntakeOutBuilder)? updates]) =>
      (IntakeOutBuilder()..update(updates))._build();

  _$IntakeOut._(
      {required this.acceptedByUserId,
      this.correctionReason,
      this.flags,
      required this.id,
      this.intakeMoistureReadingId,
      required this.lotId,
      this.pricePerKg,
      required this.processorId,
      required this.received,
      this.reconciliation,
      required this.saleDate,
      this.supersedesIntakeId})
      : super._();
  @override
  IntakeOut rebuild(void Function(IntakeOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IntakeOutBuilder toBuilder() => IntakeOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IntakeOut &&
        acceptedByUserId == other.acceptedByUserId &&
        correctionReason == other.correctionReason &&
        flags == other.flags &&
        id == other.id &&
        intakeMoistureReadingId == other.intakeMoistureReadingId &&
        lotId == other.lotId &&
        pricePerKg == other.pricePerKg &&
        processorId == other.processorId &&
        received == other.received &&
        reconciliation == other.reconciliation &&
        saleDate == other.saleDate &&
        supersedesIntakeId == other.supersedesIntakeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, acceptedByUserId.hashCode);
    _$hash = $jc(_$hash, correctionReason.hashCode);
    _$hash = $jc(_$hash, flags.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, intakeMoistureReadingId.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, pricePerKg.hashCode);
    _$hash = $jc(_$hash, processorId.hashCode);
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jc(_$hash, reconciliation.hashCode);
    _$hash = $jc(_$hash, saleDate.hashCode);
    _$hash = $jc(_$hash, supersedesIntakeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IntakeOut')
          ..add('acceptedByUserId', acceptedByUserId)
          ..add('correctionReason', correctionReason)
          ..add('flags', flags)
          ..add('id', id)
          ..add('intakeMoistureReadingId', intakeMoistureReadingId)
          ..add('lotId', lotId)
          ..add('pricePerKg', pricePerKg)
          ..add('processorId', processorId)
          ..add('received', received)
          ..add('reconciliation', reconciliation)
          ..add('saleDate', saleDate)
          ..add('supersedesIntakeId', supersedesIntakeId))
        .toString();
  }
}

class IntakeOutBuilder implements Builder<IntakeOut, IntakeOutBuilder> {
  _$IntakeOut? _$v;

  String? _acceptedByUserId;
  String? get acceptedByUserId => _$this._acceptedByUserId;
  set acceptedByUserId(String? acceptedByUserId) =>
      _$this._acceptedByUserId = acceptedByUserId;

  String? _correctionReason;
  String? get correctionReason => _$this._correctionReason;
  set correctionReason(String? correctionReason) =>
      _$this._correctionReason = correctionReason;

  ListBuilder<FlagBrief>? _flags;
  ListBuilder<FlagBrief> get flags =>
      _$this._flags ??= ListBuilder<FlagBrief>();
  set flags(ListBuilder<FlagBrief>? flags) => _$this._flags = flags;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _intakeMoistureReadingId;
  String? get intakeMoistureReadingId => _$this._intakeMoistureReadingId;
  set intakeMoistureReadingId(String? intakeMoistureReadingId) =>
      _$this._intakeMoistureReadingId = intakeMoistureReadingId;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  String? _pricePerKg;
  String? get pricePerKg => _$this._pricePerKg;
  set pricePerKg(String? pricePerKg) => _$this._pricePerKg = pricePerKg;

  String? _processorId;
  String? get processorId => _$this._processorId;
  set processorId(String? processorId) => _$this._processorId = processorId;

  QuantityOutputBuilder? _received;
  QuantityOutputBuilder get received =>
      _$this._received ??= QuantityOutputBuilder();
  set received(QuantityOutputBuilder? received) => _$this._received = received;

  ReconciliationBuilder? _reconciliation;
  ReconciliationBuilder get reconciliation =>
      _$this._reconciliation ??= ReconciliationBuilder();
  set reconciliation(ReconciliationBuilder? reconciliation) =>
      _$this._reconciliation = reconciliation;

  Date? _saleDate;
  Date? get saleDate => _$this._saleDate;
  set saleDate(Date? saleDate) => _$this._saleDate = saleDate;

  String? _supersedesIntakeId;
  String? get supersedesIntakeId => _$this._supersedesIntakeId;
  set supersedesIntakeId(String? supersedesIntakeId) =>
      _$this._supersedesIntakeId = supersedesIntakeId;

  IntakeOutBuilder() {
    IntakeOut._defaults(this);
  }

  IntakeOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _acceptedByUserId = $v.acceptedByUserId;
      _correctionReason = $v.correctionReason;
      _flags = $v.flags?.toBuilder();
      _id = $v.id;
      _intakeMoistureReadingId = $v.intakeMoistureReadingId;
      _lotId = $v.lotId;
      _pricePerKg = $v.pricePerKg;
      _processorId = $v.processorId;
      _received = $v.received.toBuilder();
      _reconciliation = $v.reconciliation?.toBuilder();
      _saleDate = $v.saleDate;
      _supersedesIntakeId = $v.supersedesIntakeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IntakeOut other) {
    _$v = other as _$IntakeOut;
  }

  @override
  void update(void Function(IntakeOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IntakeOut build() => _build();

  _$IntakeOut _build() {
    _$IntakeOut _$result;
    try {
      _$result = _$v ??
          _$IntakeOut._(
            acceptedByUserId: BuiltValueNullFieldError.checkNotNull(
                acceptedByUserId, r'IntakeOut', 'acceptedByUserId'),
            correctionReason: correctionReason,
            flags: _flags?.build(),
            id: BuiltValueNullFieldError.checkNotNull(id, r'IntakeOut', 'id'),
            intakeMoistureReadingId: intakeMoistureReadingId,
            lotId: BuiltValueNullFieldError.checkNotNull(
                lotId, r'IntakeOut', 'lotId'),
            pricePerKg: pricePerKg,
            processorId: BuiltValueNullFieldError.checkNotNull(
                processorId, r'IntakeOut', 'processorId'),
            received: received.build(),
            reconciliation: _reconciliation?.build(),
            saleDate: BuiltValueNullFieldError.checkNotNull(
                saleDate, r'IntakeOut', 'saleDate'),
            supersedesIntakeId: supersedesIntakeId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'flags';
        _flags?.build();

        _$failedField = 'received';
        received.build();
        _$failedField = 'reconciliation';
        _reconciliation?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IntakeOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
