// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_patch.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerPatch extends FarmerPatch {
  @override
  final Address? address;
  @override
  final String? giAuthorisedUserNo;
  @override
  final String? name;
  @override
  final String? nameLocal;
  @override
  final bool? noSmartphone;
  @override
  final String? photoKey;
  @override
  final String? villageId;

  factory _$FarmerPatch([void Function(FarmerPatchBuilder)? updates]) =>
      (FarmerPatchBuilder()..update(updates))._build();

  _$FarmerPatch._(
      {this.address,
      this.giAuthorisedUserNo,
      this.name,
      this.nameLocal,
      this.noSmartphone,
      this.photoKey,
      this.villageId})
      : super._();
  @override
  FarmerPatch rebuild(void Function(FarmerPatchBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerPatchBuilder toBuilder() => FarmerPatchBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerPatch &&
        address == other.address &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        name == other.name &&
        nameLocal == other.nameLocal &&
        noSmartphone == other.noSmartphone &&
        photoKey == other.photoKey &&
        villageId == other.villageId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, noSmartphone.hashCode);
    _$hash = $jc(_$hash, photoKey.hashCode);
    _$hash = $jc(_$hash, villageId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerPatch')
          ..add('address', address)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('name', name)
          ..add('nameLocal', nameLocal)
          ..add('noSmartphone', noSmartphone)
          ..add('photoKey', photoKey)
          ..add('villageId', villageId))
        .toString();
  }
}

class FarmerPatchBuilder implements Builder<FarmerPatch, FarmerPatchBuilder> {
  _$FarmerPatch? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  bool? _noSmartphone;
  bool? get noSmartphone => _$this._noSmartphone;
  set noSmartphone(bool? noSmartphone) => _$this._noSmartphone = noSmartphone;

  String? _photoKey;
  String? get photoKey => _$this._photoKey;
  set photoKey(String? photoKey) => _$this._photoKey = photoKey;

  String? _villageId;
  String? get villageId => _$this._villageId;
  set villageId(String? villageId) => _$this._villageId = villageId;

  FarmerPatchBuilder() {
    FarmerPatch._defaults(this);
  }

  FarmerPatchBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _name = $v.name;
      _nameLocal = $v.nameLocal;
      _noSmartphone = $v.noSmartphone;
      _photoKey = $v.photoKey;
      _villageId = $v.villageId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerPatch other) {
    _$v = other as _$FarmerPatch;
  }

  @override
  void update(void Function(FarmerPatchBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerPatch build() => _build();

  _$FarmerPatch _build() {
    _$FarmerPatch _$result;
    try {
      _$result = _$v ??
          _$FarmerPatch._(
            address: _address?.build(),
            giAuthorisedUserNo: giAuthorisedUserNo,
            name: name,
            nameLocal: nameLocal,
            noSmartphone: noSmartphone,
            photoKey: photoKey,
            villageId: villageId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FarmerPatch', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
