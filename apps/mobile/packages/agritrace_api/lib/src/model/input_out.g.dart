// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InputOut extends InputOut {
  @override
  final bool active;
  @override
  final InputCategory category;
  @override
  final String? fpoId;
  @override
  final String id;
  @override
  final String? manufacturer;
  @override
  final String nameEn;
  @override
  final String? nameLocal;
  @override
  final String? packSize;
  @override
  final String? photoKey;
  @override
  final String unit;

  factory _$InputOut([void Function(InputOutBuilder)? updates]) =>
      (InputOutBuilder()..update(updates))._build();

  _$InputOut._(
      {required this.active,
      required this.category,
      this.fpoId,
      required this.id,
      this.manufacturer,
      required this.nameEn,
      this.nameLocal,
      this.packSize,
      this.photoKey,
      required this.unit})
      : super._();
  @override
  InputOut rebuild(void Function(InputOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InputOutBuilder toBuilder() => InputOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InputOut &&
        active == other.active &&
        category == other.category &&
        fpoId == other.fpoId &&
        id == other.id &&
        manufacturer == other.manufacturer &&
        nameEn == other.nameEn &&
        nameLocal == other.nameLocal &&
        packSize == other.packSize &&
        photoKey == other.photoKey &&
        unit == other.unit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, manufacturer.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, packSize.hashCode);
    _$hash = $jc(_$hash, photoKey.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InputOut')
          ..add('active', active)
          ..add('category', category)
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('manufacturer', manufacturer)
          ..add('nameEn', nameEn)
          ..add('nameLocal', nameLocal)
          ..add('packSize', packSize)
          ..add('photoKey', photoKey)
          ..add('unit', unit))
        .toString();
  }
}

class InputOutBuilder implements Builder<InputOut, InputOutBuilder> {
  _$InputOut? _$v;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  InputCategory? _category;
  InputCategory? get category => _$this._category;
  set category(InputCategory? category) => _$this._category = category;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _manufacturer;
  String? get manufacturer => _$this._manufacturer;
  set manufacturer(String? manufacturer) => _$this._manufacturer = manufacturer;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  String? _packSize;
  String? get packSize => _$this._packSize;
  set packSize(String? packSize) => _$this._packSize = packSize;

  String? _photoKey;
  String? get photoKey => _$this._photoKey;
  set photoKey(String? photoKey) => _$this._photoKey = photoKey;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  InputOutBuilder() {
    InputOut._defaults(this);
  }

  InputOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _category = $v.category;
      _fpoId = $v.fpoId;
      _id = $v.id;
      _manufacturer = $v.manufacturer;
      _nameEn = $v.nameEn;
      _nameLocal = $v.nameLocal;
      _packSize = $v.packSize;
      _photoKey = $v.photoKey;
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InputOut other) {
    _$v = other as _$InputOut;
  }

  @override
  void update(void Function(InputOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InputOut build() => _build();

  _$InputOut _build() {
    final _$result = _$v ??
        _$InputOut._(
          active: BuiltValueNullFieldError.checkNotNull(
              active, r'InputOut', 'active'),
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'InputOut', 'category'),
          fpoId: fpoId,
          id: BuiltValueNullFieldError.checkNotNull(id, r'InputOut', 'id'),
          manufacturer: manufacturer,
          nameEn: BuiltValueNullFieldError.checkNotNull(
              nameEn, r'InputOut', 'nameEn'),
          nameLocal: nameLocal,
          packSize: packSize,
          photoKey: photoKey,
          unit:
              BuiltValueNullFieldError.checkNotNull(unit, r'InputOut', 'unit'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
