// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fpo_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FpoOut extends FpoOut {
  @override
  final Address? address;
  @override
  final String addressLine;
  @override
  final String code;
  @override
  final String? fssaiNo;
  @override
  final String? giAuthorisedUserNo;
  @override
  final String id;
  @override
  final OrgKind kind;
  @override
  final String name;
  @override
  final bool publicShowFarmerNames;

  factory _$FpoOut([void Function(FpoOutBuilder)? updates]) =>
      (FpoOutBuilder()..update(updates))._build();

  _$FpoOut._(
      {this.address,
      required this.addressLine,
      required this.code,
      this.fssaiNo,
      this.giAuthorisedUserNo,
      required this.id,
      required this.kind,
      required this.name,
      required this.publicShowFarmerNames})
      : super._();
  @override
  FpoOut rebuild(void Function(FpoOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FpoOutBuilder toBuilder() => FpoOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FpoOut &&
        address == other.address &&
        addressLine == other.addressLine &&
        code == other.code &&
        fssaiNo == other.fssaiNo &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        id == other.id &&
        kind == other.kind &&
        name == other.name &&
        publicShowFarmerNames == other.publicShowFarmerNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, addressLine.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, fssaiNo.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, publicShowFarmerNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FpoOut')
          ..add('address', address)
          ..add('addressLine', addressLine)
          ..add('code', code)
          ..add('fssaiNo', fssaiNo)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('id', id)
          ..add('kind', kind)
          ..add('name', name)
          ..add('publicShowFarmerNames', publicShowFarmerNames))
        .toString();
  }
}

class FpoOutBuilder implements Builder<FpoOut, FpoOutBuilder> {
  _$FpoOut? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _addressLine;
  String? get addressLine => _$this._addressLine;
  set addressLine(String? addressLine) => _$this._addressLine = addressLine;

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

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  FpoOutBuilder() {
    FpoOut._defaults(this);
  }

  FpoOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _addressLine = $v.addressLine;
      _code = $v.code;
      _fssaiNo = $v.fssaiNo;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _id = $v.id;
      _kind = $v.kind;
      _name = $v.name;
      _publicShowFarmerNames = $v.publicShowFarmerNames;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FpoOut other) {
    _$v = other as _$FpoOut;
  }

  @override
  void update(void Function(FpoOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FpoOut build() => _build();

  _$FpoOut _build() {
    _$FpoOut _$result;
    try {
      _$result = _$v ??
          _$FpoOut._(
            address: _address?.build(),
            addressLine: BuiltValueNullFieldError.checkNotNull(
                addressLine, r'FpoOut', 'addressLine'),
            code:
                BuiltValueNullFieldError.checkNotNull(code, r'FpoOut', 'code'),
            fssaiNo: fssaiNo,
            giAuthorisedUserNo: giAuthorisedUserNo,
            id: BuiltValueNullFieldError.checkNotNull(id, r'FpoOut', 'id'),
            kind:
                BuiltValueNullFieldError.checkNotNull(kind, r'FpoOut', 'kind'),
            name:
                BuiltValueNullFieldError.checkNotNull(name, r'FpoOut', 'name'),
            publicShowFarmerNames: BuiltValueNullFieldError.checkNotNull(
                publicShowFarmerNames, r'FpoOut', 'publicShowFarmerNames'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FpoOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
