// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reconciliation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Reconciliation extends Reconciliation {
  @override
  final QuantityOutput? harvested;
  @override
  final bool inOrder;
  @override
  final QuantityOutput? packed;
  @override
  final QuantityOutput? received;
  @override
  final QuantityOutput? used;

  factory _$Reconciliation([void Function(ReconciliationBuilder)? updates]) =>
      (ReconciliationBuilder()..update(updates))._build();

  _$Reconciliation._(
      {this.harvested,
      required this.inOrder,
      this.packed,
      this.received,
      this.used})
      : super._();
  @override
  Reconciliation rebuild(void Function(ReconciliationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReconciliationBuilder toBuilder() => ReconciliationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Reconciliation &&
        harvested == other.harvested &&
        inOrder == other.inOrder &&
        packed == other.packed &&
        received == other.received &&
        used == other.used;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, harvested.hashCode);
    _$hash = $jc(_$hash, inOrder.hashCode);
    _$hash = $jc(_$hash, packed.hashCode);
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jc(_$hash, used.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Reconciliation')
          ..add('harvested', harvested)
          ..add('inOrder', inOrder)
          ..add('packed', packed)
          ..add('received', received)
          ..add('used', used))
        .toString();
  }
}

class ReconciliationBuilder
    implements Builder<Reconciliation, ReconciliationBuilder> {
  _$Reconciliation? _$v;

  QuantityOutputBuilder? _harvested;
  QuantityOutputBuilder get harvested =>
      _$this._harvested ??= QuantityOutputBuilder();
  set harvested(QuantityOutputBuilder? harvested) =>
      _$this._harvested = harvested;

  bool? _inOrder;
  bool? get inOrder => _$this._inOrder;
  set inOrder(bool? inOrder) => _$this._inOrder = inOrder;

  QuantityOutputBuilder? _packed;
  QuantityOutputBuilder get packed =>
      _$this._packed ??= QuantityOutputBuilder();
  set packed(QuantityOutputBuilder? packed) => _$this._packed = packed;

  QuantityOutputBuilder? _received;
  QuantityOutputBuilder get received =>
      _$this._received ??= QuantityOutputBuilder();
  set received(QuantityOutputBuilder? received) => _$this._received = received;

  QuantityOutputBuilder? _used;
  QuantityOutputBuilder get used => _$this._used ??= QuantityOutputBuilder();
  set used(QuantityOutputBuilder? used) => _$this._used = used;

  ReconciliationBuilder() {
    Reconciliation._defaults(this);
  }

  ReconciliationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _harvested = $v.harvested?.toBuilder();
      _inOrder = $v.inOrder;
      _packed = $v.packed?.toBuilder();
      _received = $v.received?.toBuilder();
      _used = $v.used?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Reconciliation other) {
    _$v = other as _$Reconciliation;
  }

  @override
  void update(void Function(ReconciliationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Reconciliation build() => _build();

  _$Reconciliation _build() {
    _$Reconciliation _$result;
    try {
      _$result = _$v ??
          _$Reconciliation._(
            harvested: _harvested?.build(),
            inOrder: BuiltValueNullFieldError.checkNotNull(
                inOrder, r'Reconciliation', 'inOrder'),
            packed: _packed?.build(),
            received: _received?.build(),
            used: _used?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'harvested';
        _harvested?.build();

        _$failedField = 'packed';
        _packed?.build();
        _$failedField = 'received';
        _received?.build();
        _$failedField = 'used';
        _used?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Reconciliation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
