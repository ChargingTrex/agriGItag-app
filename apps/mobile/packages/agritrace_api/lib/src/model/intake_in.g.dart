// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intake_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IntakeIn extends IntakeIn {
  @override
  final String clientId;
  @override
  final String? correctionReason;
  @override
  final String? intakeMoistureReadingId;
  @override
  final String lotId;
  @override
  final PricePerKg? pricePerKg;
  @override
  final String? processorId;
  @override
  final QuantityInput received;
  @override
  final Date saleDate;
  @override
  final String? supersedesIntakeId;

  factory _$IntakeIn([void Function(IntakeInBuilder)? updates]) =>
      (IntakeInBuilder()..update(updates))._build();

  _$IntakeIn._(
      {required this.clientId,
      this.correctionReason,
      this.intakeMoistureReadingId,
      required this.lotId,
      this.pricePerKg,
      this.processorId,
      required this.received,
      required this.saleDate,
      this.supersedesIntakeId})
      : super._();
  @override
  IntakeIn rebuild(void Function(IntakeInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IntakeInBuilder toBuilder() => IntakeInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IntakeIn &&
        clientId == other.clientId &&
        correctionReason == other.correctionReason &&
        intakeMoistureReadingId == other.intakeMoistureReadingId &&
        lotId == other.lotId &&
        pricePerKg == other.pricePerKg &&
        processorId == other.processorId &&
        received == other.received &&
        saleDate == other.saleDate &&
        supersedesIntakeId == other.supersedesIntakeId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, correctionReason.hashCode);
    _$hash = $jc(_$hash, intakeMoistureReadingId.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, pricePerKg.hashCode);
    _$hash = $jc(_$hash, processorId.hashCode);
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jc(_$hash, saleDate.hashCode);
    _$hash = $jc(_$hash, supersedesIntakeId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IntakeIn')
          ..add('clientId', clientId)
          ..add('correctionReason', correctionReason)
          ..add('intakeMoistureReadingId', intakeMoistureReadingId)
          ..add('lotId', lotId)
          ..add('pricePerKg', pricePerKg)
          ..add('processorId', processorId)
          ..add('received', received)
          ..add('saleDate', saleDate)
          ..add('supersedesIntakeId', supersedesIntakeId))
        .toString();
  }
}

class IntakeInBuilder implements Builder<IntakeIn, IntakeInBuilder> {
  _$IntakeIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _correctionReason;
  String? get correctionReason => _$this._correctionReason;
  set correctionReason(String? correctionReason) =>
      _$this._correctionReason = correctionReason;

  String? _intakeMoistureReadingId;
  String? get intakeMoistureReadingId => _$this._intakeMoistureReadingId;
  set intakeMoistureReadingId(String? intakeMoistureReadingId) =>
      _$this._intakeMoistureReadingId = intakeMoistureReadingId;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  PricePerKgBuilder? _pricePerKg;
  PricePerKgBuilder get pricePerKg =>
      _$this._pricePerKg ??= PricePerKgBuilder();
  set pricePerKg(PricePerKgBuilder? pricePerKg) =>
      _$this._pricePerKg = pricePerKg;

  String? _processorId;
  String? get processorId => _$this._processorId;
  set processorId(String? processorId) => _$this._processorId = processorId;

  QuantityInputBuilder? _received;
  QuantityInputBuilder get received =>
      _$this._received ??= QuantityInputBuilder();
  set received(QuantityInputBuilder? received) => _$this._received = received;

  Date? _saleDate;
  Date? get saleDate => _$this._saleDate;
  set saleDate(Date? saleDate) => _$this._saleDate = saleDate;

  String? _supersedesIntakeId;
  String? get supersedesIntakeId => _$this._supersedesIntakeId;
  set supersedesIntakeId(String? supersedesIntakeId) =>
      _$this._supersedesIntakeId = supersedesIntakeId;

  IntakeInBuilder() {
    IntakeIn._defaults(this);
  }

  IntakeInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _correctionReason = $v.correctionReason;
      _intakeMoistureReadingId = $v.intakeMoistureReadingId;
      _lotId = $v.lotId;
      _pricePerKg = $v.pricePerKg?.toBuilder();
      _processorId = $v.processorId;
      _received = $v.received.toBuilder();
      _saleDate = $v.saleDate;
      _supersedesIntakeId = $v.supersedesIntakeId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IntakeIn other) {
    _$v = other as _$IntakeIn;
  }

  @override
  void update(void Function(IntakeInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IntakeIn build() => _build();

  _$IntakeIn _build() {
    _$IntakeIn _$result;
    try {
      _$result = _$v ??
          _$IntakeIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'IntakeIn', 'clientId'),
            correctionReason: correctionReason,
            intakeMoistureReadingId: intakeMoistureReadingId,
            lotId: BuiltValueNullFieldError.checkNotNull(
                lotId, r'IntakeIn', 'lotId'),
            pricePerKg: _pricePerKg?.build(),
            processorId: processorId,
            received: received.build(),
            saleDate: BuiltValueNullFieldError.checkNotNull(
                saleDate, r'IntakeIn', 'saleDate'),
            supersedesIntakeId: supersedesIntakeId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pricePerKg';
        _pricePerKg?.build();

        _$failedField = 'received';
        received.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IntakeIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
