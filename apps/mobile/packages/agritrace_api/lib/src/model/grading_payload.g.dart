// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GradingPayload extends GradingPayload {
  @override
  final String? declaredGrade;
  @override
  final QuantityInput? quantity;

  factory _$GradingPayload([void Function(GradingPayloadBuilder)? updates]) =>
      (GradingPayloadBuilder()..update(updates))._build();

  _$GradingPayload._({this.declaredGrade, this.quantity}) : super._();
  @override
  GradingPayload rebuild(void Function(GradingPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GradingPayloadBuilder toBuilder() => GradingPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GradingPayload &&
        declaredGrade == other.declaredGrade &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, declaredGrade.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GradingPayload')
          ..add('declaredGrade', declaredGrade)
          ..add('quantity', quantity))
        .toString();
  }
}

class GradingPayloadBuilder
    implements Builder<GradingPayload, GradingPayloadBuilder> {
  _$GradingPayload? _$v;

  String? _declaredGrade;
  String? get declaredGrade => _$this._declaredGrade;
  set declaredGrade(String? declaredGrade) =>
      _$this._declaredGrade = declaredGrade;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  GradingPayloadBuilder() {
    GradingPayload._defaults(this);
  }

  GradingPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _declaredGrade = $v.declaredGrade;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GradingPayload other) {
    _$v = other as _$GradingPayload;
  }

  @override
  void update(void Function(GradingPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GradingPayload build() => _build();

  _$GradingPayload _build() {
    _$GradingPayload _$result;
    try {
      _$result = _$v ??
          _$GradingPayload._(
            declaredGrade: declaredGrade,
            quantity: _quantity?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'quantity';
        _quantity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GradingPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
