// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'village_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VillageOut extends VillageOut {
  @override
  final String? block;
  @override
  final String district;
  @override
  final String id;
  @override
  final String? lgdCode;
  @override
  final String nameEn;
  @override
  final String? nameLocal;
  @override
  final String? pincode;
  @override
  final String state;
  @override
  final String? taluk;

  factory _$VillageOut([void Function(VillageOutBuilder)? updates]) =>
      (VillageOutBuilder()..update(updates))._build();

  _$VillageOut._(
      {this.block,
      required this.district,
      required this.id,
      this.lgdCode,
      required this.nameEn,
      this.nameLocal,
      this.pincode,
      required this.state,
      this.taluk})
      : super._();
  @override
  VillageOut rebuild(void Function(VillageOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VillageOutBuilder toBuilder() => VillageOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VillageOut &&
        block == other.block &&
        district == other.district &&
        id == other.id &&
        lgdCode == other.lgdCode &&
        nameEn == other.nameEn &&
        nameLocal == other.nameLocal &&
        pincode == other.pincode &&
        state == other.state &&
        taluk == other.taluk;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, block.hashCode);
    _$hash = $jc(_$hash, district.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lgdCode.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, pincode.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, taluk.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VillageOut')
          ..add('block', block)
          ..add('district', district)
          ..add('id', id)
          ..add('lgdCode', lgdCode)
          ..add('nameEn', nameEn)
          ..add('nameLocal', nameLocal)
          ..add('pincode', pincode)
          ..add('state', state)
          ..add('taluk', taluk))
        .toString();
  }
}

class VillageOutBuilder implements Builder<VillageOut, VillageOutBuilder> {
  _$VillageOut? _$v;

  String? _block;
  String? get block => _$this._block;
  set block(String? block) => _$this._block = block;

  String? _district;
  String? get district => _$this._district;
  set district(String? district) => _$this._district = district;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lgdCode;
  String? get lgdCode => _$this._lgdCode;
  set lgdCode(String? lgdCode) => _$this._lgdCode = lgdCode;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  String? _pincode;
  String? get pincode => _$this._pincode;
  set pincode(String? pincode) => _$this._pincode = pincode;

  String? _state;
  String? get state => _$this._state;
  set state(String? state) => _$this._state = state;

  String? _taluk;
  String? get taluk => _$this._taluk;
  set taluk(String? taluk) => _$this._taluk = taluk;

  VillageOutBuilder() {
    VillageOut._defaults(this);
  }

  VillageOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _block = $v.block;
      _district = $v.district;
      _id = $v.id;
      _lgdCode = $v.lgdCode;
      _nameEn = $v.nameEn;
      _nameLocal = $v.nameLocal;
      _pincode = $v.pincode;
      _state = $v.state;
      _taluk = $v.taluk;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VillageOut other) {
    _$v = other as _$VillageOut;
  }

  @override
  void update(void Function(VillageOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VillageOut build() => _build();

  _$VillageOut _build() {
    final _$result = _$v ??
        _$VillageOut._(
          block: block,
          district: BuiltValueNullFieldError.checkNotNull(
              district, r'VillageOut', 'district'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'VillageOut', 'id'),
          lgdCode: lgdCode,
          nameEn: BuiltValueNullFieldError.checkNotNull(
              nameEn, r'VillageOut', 'nameEn'),
          nameLocal: nameLocal,
          pincode: pincode,
          state: BuiltValueNullFieldError.checkNotNull(
              state, r'VillageOut', 'state'),
          taluk: taluk,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
