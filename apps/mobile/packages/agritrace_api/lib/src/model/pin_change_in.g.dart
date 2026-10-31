// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_change_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PinChangeIn extends PinChangeIn {
  @override
  final String? currentPin;
  @override
  final String pin;

  factory _$PinChangeIn([void Function(PinChangeInBuilder)? updates]) =>
      (PinChangeInBuilder()..update(updates))._build();

  _$PinChangeIn._({this.currentPin, required this.pin}) : super._();
  @override
  PinChangeIn rebuild(void Function(PinChangeInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PinChangeInBuilder toBuilder() => PinChangeInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PinChangeIn &&
        currentPin == other.currentPin &&
        pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPin.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PinChangeIn')
          ..add('currentPin', currentPin)
          ..add('pin', pin))
        .toString();
  }
}

class PinChangeInBuilder implements Builder<PinChangeIn, PinChangeInBuilder> {
  _$PinChangeIn? _$v;

  String? _currentPin;
  String? get currentPin => _$this._currentPin;
  set currentPin(String? currentPin) => _$this._currentPin = currentPin;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  PinChangeInBuilder() {
    PinChangeIn._defaults(this);
  }

  PinChangeInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPin = $v.currentPin;
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PinChangeIn other) {
    _$v = other as _$PinChangeIn;
  }

  @override
  void update(void Function(PinChangeInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PinChangeIn build() => _build();

  _$PinChangeIn _build() {
    final _$result = _$v ??
        _$PinChangeIn._(
          currentPin: currentPin,
          pin:
              BuiltValueNullFieldError.checkNotNull(pin, r'PinChangeIn', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
