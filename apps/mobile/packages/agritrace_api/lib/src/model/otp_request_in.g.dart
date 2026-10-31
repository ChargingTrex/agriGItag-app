// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OtpRequestIn extends OtpRequestIn {
  @override
  final String phone;

  factory _$OtpRequestIn([void Function(OtpRequestInBuilder)? updates]) =>
      (OtpRequestInBuilder()..update(updates))._build();

  _$OtpRequestIn._({required this.phone}) : super._();
  @override
  OtpRequestIn rebuild(void Function(OtpRequestInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OtpRequestInBuilder toBuilder() => OtpRequestInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OtpRequestIn && phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OtpRequestIn')..add('phone', phone))
        .toString();
  }
}

class OtpRequestInBuilder
    implements Builder<OtpRequestIn, OtpRequestInBuilder> {
  _$OtpRequestIn? _$v;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  OtpRequestInBuilder() {
    OtpRequestIn._defaults(this);
  }

  OtpRequestInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OtpRequestIn other) {
    _$v = other as _$OtpRequestIn;
  }

  @override
  void update(void Function(OtpRequestInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OtpRequestIn build() => _build();

  _$OtpRequestIn _build() {
    final _$result = _$v ??
        _$OtpRequestIn._(
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'OtpRequestIn', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
