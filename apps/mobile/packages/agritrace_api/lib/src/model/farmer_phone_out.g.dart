// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_phone_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerPhoneOut extends FarmerPhoneOut {
  @override
  final String farmerId;
  @override
  final String? phone;

  factory _$FarmerPhoneOut([void Function(FarmerPhoneOutBuilder)? updates]) =>
      (FarmerPhoneOutBuilder()..update(updates))._build();

  _$FarmerPhoneOut._({required this.farmerId, this.phone}) : super._();
  @override
  FarmerPhoneOut rebuild(void Function(FarmerPhoneOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerPhoneOutBuilder toBuilder() => FarmerPhoneOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerPhoneOut &&
        farmerId == other.farmerId &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerPhoneOut')
          ..add('farmerId', farmerId)
          ..add('phone', phone))
        .toString();
  }
}

class FarmerPhoneOutBuilder
    implements Builder<FarmerPhoneOut, FarmerPhoneOutBuilder> {
  _$FarmerPhoneOut? _$v;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  FarmerPhoneOutBuilder() {
    FarmerPhoneOut._defaults(this);
  }

  FarmerPhoneOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _farmerId = $v.farmerId;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerPhoneOut other) {
    _$v = other as _$FarmerPhoneOut;
  }

  @override
  void update(void Function(FarmerPhoneOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerPhoneOut build() => _build();

  _$FarmerPhoneOut _build() {
    final _$result = _$v ??
        _$FarmerPhoneOut._(
          farmerId: BuiltValueNullFieldError.checkNotNull(
              farmerId, r'FarmerPhoneOut', 'farmerId'),
          phone: phone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
