// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fpo_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FpoIn extends FpoIn {
  @override
  final Address? address;
  @override
  final String code;
  @override
  final String? fssaiNo;
  @override
  final String? giAuthorisedUserNo;
  @override
  final OrgKind? kind;
  @override
  final String name;
  @override
  final bool? publicShowFarmerNames;

  factory _$FpoIn([void Function(FpoInBuilder)? updates]) =>
      (FpoInBuilder()..update(updates))._build();

  _$FpoIn._(
      {this.address,
      required this.code,
      this.fssaiNo,
      this.giAuthorisedUserNo,
      this.kind,
      required this.name,
      this.publicShowFarmerNames})
      : super._();
  @override
  FpoIn rebuild(void Function(FpoInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FpoInBuilder toBuilder() => FpoInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FpoIn &&
        address == other.address &&
        code == other.code &&
        fssaiNo == other.fssaiNo &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        kind == other.kind &&
        name == other.name &&
        publicShowFarmerNames == other.publicShowFarmerNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, fssaiNo.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, publicShowFarmerNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FpoIn')
          ..add('address', address)
          ..add('code', code)
          ..add('fssaiNo', fssaiNo)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('kind', kind)
          ..add('name', name)
          ..add('publicShowFarmerNames', publicShowFarmerNames))
        .toString();
  }
}

class FpoInBuilder implements Builder<FpoIn, FpoInBuilder> {
  _$FpoIn? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _fssaiNo;
  String? get fssaiNo => _$this._fssaiNo;
  set fssaiNo(String? fssaiNo) => _$this._fssaiNo = fssaiNo;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  OrgKind? _kind;
  OrgKind? get kind => _$this._kind;
  set kind(OrgKind? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _publicShowFarmerNames;
  bool? get publicShowFarmerNames => _$this._publicShowFarmerNames;
  set publicShowFarmerNames(bool? publicShowFarmerNames) =>
      _$this._publicShowFarmerNames = publicShowFarmerNames;

  FpoInBuilder() {
    FpoIn._defaults(this);
  }

  FpoInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _code = $v.code;
      _fssaiNo = $v.fssaiNo;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _kind = $v.kind;
      _name = $v.name;
      _publicShowFarmerNames = $v.publicShowFarmerNames;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FpoIn other) {
    _$v = other as _$FpoIn;
  }

  @override
  void update(void Function(FpoInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FpoIn build() => _build();

  _$FpoIn _build() {
    _$FpoIn _$result;
    try {
      _$result = _$v ??
          _$FpoIn._(
            address: _address?.build(),
            code: BuiltValueNullFieldError.checkNotNull(code, r'FpoIn', 'code'),
            fssaiNo: fssaiNo,
            giAuthorisedUserNo: giAuthorisedUserNo,
            kind: kind,
            name: BuiltValueNullFieldError.checkNotNull(name, r'FpoIn', 'name'),
            publicShowFarmerNames: publicShowFarmerNames,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'FpoIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
