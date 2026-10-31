// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_application_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InputApplicationPayload extends InputApplicationPayload {
  @override
  final String? inputId;
  @override
  final String? inputName;
  @override
  final QuantityInput? quantity;

  factory _$InputApplicationPayload(
          [void Function(InputApplicationPayloadBuilder)? updates]) =>
      (InputApplicationPayloadBuilder()..update(updates))._build();

  _$InputApplicationPayload._({this.inputId, this.inputName, this.quantity})
      : super._();
  @override
  InputApplicationPayload rebuild(
          void Function(InputApplicationPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InputApplicationPayloadBuilder toBuilder() =>
      InputApplicationPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InputApplicationPayload &&
        inputId == other.inputId &&
        inputName == other.inputName &&
        quantity == other.quantity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, inputId.hashCode);
    _$hash = $jc(_$hash, inputName.hashCode);
    _$hash = $jc(_$hash, quantity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InputApplicationPayload')
          ..add('inputId', inputId)
          ..add('inputName', inputName)
          ..add('quantity', quantity))
        .toString();
  }
}

class InputApplicationPayloadBuilder
    implements
        Builder<InputApplicationPayload, InputApplicationPayloadBuilder> {
  _$InputApplicationPayload? _$v;

  String? _inputId;
  String? get inputId => _$this._inputId;
  set inputId(String? inputId) => _$this._inputId = inputId;

  String? _inputName;
  String? get inputName => _$this._inputName;
  set inputName(String? inputName) => _$this._inputName = inputName;

  QuantityInputBuilder? _quantity;
  QuantityInputBuilder get quantity =>
      _$this._quantity ??= QuantityInputBuilder();
  set quantity(QuantityInputBuilder? quantity) => _$this._quantity = quantity;

  InputApplicationPayloadBuilder() {
    InputApplicationPayload._defaults(this);
  }

  InputApplicationPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _inputId = $v.inputId;
      _inputName = $v.inputName;
      _quantity = $v.quantity?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InputApplicationPayload other) {
    _$v = other as _$InputApplicationPayload;
  }

  @override
  void update(void Function(InputApplicationPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InputApplicationPayload build() => _build();

  _$InputApplicationPayload _build() {
    _$InputApplicationPayload _$result;
    try {
      _$result = _$v ??
          _$InputApplicationPayload._(
            inputId: inputId,
            inputName: inputName,
            quantity: _quantity?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'quantity';
        _quantity?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InputApplicationPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
