// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PinIn extends PinIn {
  @override
  final String pin;

  factory _$PinIn([void Function(PinInBuilder)? updates]) =>
      (PinInBuilder()..update(updates))._build();

  _$PinIn._({required this.pin}) : super._();
  @override
  PinIn rebuild(void Function(PinInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PinInBuilder toBuilder() => PinInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PinIn && pin == other.pin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PinIn')..add('pin', pin)).toString();
  }
}

class PinInBuilder implements Builder<PinIn, PinInBuilder> {
  _$PinIn? _$v;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  PinInBuilder() {
    PinIn._defaults(this);
  }

  PinInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pin = $v.pin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PinIn other) {
    _$v = other as _$PinIn;
  }

  @override
  void update(void Function(PinInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PinIn build() => _build();

  _$PinIn _build() {
    final _$result = _$v ??
        _$PinIn._(
          pin: BuiltValueNullFieldError.checkNotNull(pin, r'PinIn', 'pin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
