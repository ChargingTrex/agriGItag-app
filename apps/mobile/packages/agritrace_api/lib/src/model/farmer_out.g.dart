// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerOut extends FarmerOut {
  @override
  final Address? address;
  @override
  final String addressLine;
  @override
  final DateTime? approvedAt;
  @override
  final String? approvedBy;
  @override
  final String code;
  @override
  final String fpoId;
  @override
  final String? giAuthorisedUserNo;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? nameLocal;
  @override
  final bool noSmartphone;
  @override
  final String? phoneMasked;
  @override
  final String? photoKey;
  @override
  final FarmerStatus status;
  @override
  final String? userId;
  @override
  final String? villageId;

  factory _$FarmerOut([void Function(FarmerOutBuilder)? updates]) =>
      (FarmerOutBuilder()..update(updates))._build();

  _$FarmerOut._(
      {this.address,
      required this.addressLine,
      this.approvedAt,
      this.approvedBy,
      required this.code,
      required this.fpoId,
      this.giAuthorisedUserNo,
      required this.id,
      required this.name,
      this.nameLocal,
      required this.noSmartphone,
      this.phoneMasked,
      this.photoKey,
      required this.status,
      this.userId,
      this.villageId})
      : super._();
  @override
  FarmerOut rebuild(void Function(FarmerOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerOutBuilder toBuilder() => FarmerOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerOut &&
        address == other.address &&
        addressLine == other.addressLine &&
        approvedAt == other.approvedAt &&
        approvedBy == other.approvedBy &&
        code == other.code &&
        fpoId == other.fpoId &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        id == other.id &&
        name == other.name &&
        nameLocal == other.nameLocal &&
        noSmartphone == other.noSmartphone &&
        phoneMasked == other.phoneMasked &&
        photoKey == other.photoKey &&
        status == other.status &&
        userId == other.userId &&
        villageId == other.villageId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, addressLine.hashCode);
    _$hash = $jc(_$hash, approvedAt.hashCode);
    _$hash = $jc(_$hash, approvedBy.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, noSmartphone.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, photoKey.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, villageId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerOut')
          ..add('address', address)
          ..add('addressLine', addressLine)
          ..add('approvedAt', approvedAt)
          ..add('approvedBy', approvedBy)
          ..add('code', code)
          ..add('fpoId', fpoId)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('id', id)
          ..add('name', name)
          ..add('nameLocal', nameLocal)
          ..add('noSmartphone', noSmartphone)
          ..add('phoneMasked', phoneMasked)
          ..add('photoKey', photoKey)
          ..add('status', status)
          ..add('userId', userId)
          ..add('villageId', villageId))
        .toString();
  }
}

class FarmerOutBuilder implements Builder<FarmerOut, FarmerOutBuilder> {
  _$FarmerOut? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _addressLine;
  String? get addressLine => _$this._addressLine;
  set addressLine(String? addressLine) => _$this._addressLine = addressLine;

  DateTime? _approvedAt;
  DateTime? get approvedAt => _$this._approvedAt;
  set approvedAt(DateTime? approvedAt) => _$this._approvedAt = approvedAt;

  String? _approvedBy;
  String? get approvedBy => _$this._approvedBy;
  set approvedBy(String? approvedBy) => _$this._approvedBy = approvedBy;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  bool? _noSmartphone;
  bool? get noSmartphone => _$this._noSmartphone;
  set noSmartphone(bool? noSmartphone) => _$this._noSmartphone = noSmartphone;

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  String? _photoKey;
  String? get photoKey => _$this._photoKey;
  set photoKey(String? photoKey) => _$this._photoKey = photoKey;

  FarmerStatus? _status;
  FarmerStatus? get status => _$this._status;
  set status(FarmerStatus? status) => _$this._status = status;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _villageId;
  String? get villageId => _$this._villageId;
  set villageId(String? villageId) => _$this._villageId = villageId;

  FarmerOutBuilder() {
    FarmerOut._defaults(this);
  }

  FarmerOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _addressLine = $v.addressLine;
      _approvedAt = $v.approvedAt;
      _approvedBy = $v.approvedBy;
      _code = $v.code;
      _fpoId = $v.fpoId;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _id = $v.id;
      _name = $v.name;
      _nameLocal = $v.nameLocal;
      _noSmartphone = $v.noSmartphone;
      _phoneMasked = $v.phoneMasked;
      _photoKey = $v.photoKey;
      _status = $v.status;
      _userId = $v.userId;
      _villageId = $v.villageId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerOut other) {
    _$v = other as _$FarmerOut;
  }

  @override
  void update(void Function(FarmerOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerOut build() => _build();

  _$FarmerOut _build() {
    _$FarmerOut _$result;
    try {
      _$result = _$v ??
          _$FarmerOut._(
            address: _address?.build(),
            addressLine: BuiltValueNullFieldError.checkNotNull(
                addressLine, r'FarmerOut', 'addressLine'),
            approvedAt: approvedAt,
            approvedBy: approvedBy,
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'FarmerOut', 'code'),
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'FarmerOut', 'fpoId'),
            giAuthorisedUserNo: giAuthorisedUserNo,
            id: BuiltValueNullFieldError.checkNotNull(id, r'FarmerOut', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'FarmerOut', 'name'),
            nameLocal: nameLocal,
            noSmartphone: BuiltValueNullFieldError.checkNotNull(
                noSmartphone, r'FarmerOut', 'noSmartphone'),
            phoneMasked: phoneMasked,
            photoKey: photoKey,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'FarmerOut', 'status'),
            userId: userId,
            villageId: villageId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FarmerOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
