// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Address extends Address {
  @override
  final String? block;
  @override
  final String? district;
  @override
  final String? pin;
  @override
  final String? state;
  @override
  final String? taluk;
  @override
  final String? village;

  factory _$Address([void Function(AddressBuilder)? updates]) =>
      (AddressBuilder()..update(updates))._build();

  _$Address._(
      {this.block,
      this.district,
      this.pin,
      this.state,
      this.taluk,
      this.village})
      : super._();
  @override
  Address rebuild(void Function(AddressBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AddressBuilder toBuilder() => AddressBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Address &&
        block == other.block &&
        district == other.district &&
        pin == other.pin &&
        state == other.state &&
        taluk == other.taluk &&
        village == other.village;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, block.hashCode);
    _$hash = $jc(_$hash, district.hashCode);
    _$hash = $jc(_$hash, pin.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, taluk.hashCode);
    _$hash = $jc(_$hash, village.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Address')
          ..add('block', block)
          ..add('district', district)
          ..add('pin', pin)
          ..add('state', state)
          ..add('taluk', taluk)
          ..add('village', village))
        .toString();
  }
}

class AddressBuilder implements Builder<Address, AddressBuilder> {
  _$Address? _$v;

  String? _block;
  String? get block => _$this._block;
  set block(String? block) => _$this._block = block;

  String? _district;
  String? get district => _$this._district;
  set district(String? district) => _$this._district = district;

  String? _pin;
  String? get pin => _$this._pin;
  set pin(String? pin) => _$this._pin = pin;

  String? _state;
  String? get state => _$this._state;
  set state(String? state) => _$this._state = state;

  String? _taluk;
  String? get taluk => _$this._taluk;
  set taluk(String? taluk) => _$this._taluk = taluk;

  String? _village;
  String? get village => _$this._village;
  set village(String? village) => _$this._village = village;

  AddressBuilder() {
    Address._defaults(this);
  }

  AddressBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _block = $v.block;
      _district = $v.district;
      _pin = $v.pin;
      _state = $v.state;
      _taluk = $v.taluk;
      _village = $v.village;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Address other) {
    _$v = other as _$Address;
  }

  @override
  void update(void Function(AddressBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Address build() => _build();

  _$Address _build() {
    final _$result = _$v ??
        _$Address._(
          block: block,
          district: district,
          pin: pin,
          state: state,
          taluk: taluk,
          village: village,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
