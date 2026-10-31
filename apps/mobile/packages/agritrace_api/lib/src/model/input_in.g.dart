// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InputIn extends InputIn {
  @override
  final InputCategory category;
  @override
  final bool? globalEntry;
  @override
  final String? manufacturer;
  @override
  final String nameEn;
  @override
  final String? nameLocal;
  @override
  final PackSize? packSize;
  @override
  final String? photoKey;
  @override
  final String unit;

  factory _$InputIn([void Function(InputInBuilder)? updates]) =>
      (InputInBuilder()..update(updates))._build();

  _$InputIn._(
      {required this.category,
      this.globalEntry,
      this.manufacturer,
      required this.nameEn,
      this.nameLocal,
      this.packSize,
      this.photoKey,
      required this.unit})
      : super._();
  @override
  InputIn rebuild(void Function(InputInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InputInBuilder toBuilder() => InputInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InputIn &&
        category == other.category &&
        globalEntry == other.globalEntry &&
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
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, globalEntry.hashCode);
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
    return (newBuiltValueToStringHelper(r'InputIn')
          ..add('category', category)
          ..add('globalEntry', globalEntry)
          ..add('manufacturer', manufacturer)
          ..add('nameEn', nameEn)
          ..add('nameLocal', nameLocal)
          ..add('packSize', packSize)
          ..add('photoKey', photoKey)
          ..add('unit', unit))
        .toString();
  }
}

class InputInBuilder implements Builder<InputIn, InputInBuilder> {
  _$InputIn? _$v;

  InputCategory? _category;
  InputCategory? get category => _$this._category;
  set category(InputCategory? category) => _$this._category = category;

  bool? _globalEntry;
  bool? get globalEntry => _$this._globalEntry;
  set globalEntry(bool? globalEntry) => _$this._globalEntry = globalEntry;

  String? _manufacturer;
  String? get manufacturer => _$this._manufacturer;
  set manufacturer(String? manufacturer) => _$this._manufacturer = manufacturer;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  PackSizeBuilder? _packSize;
  PackSizeBuilder get packSize => _$this._packSize ??= PackSizeBuilder();
  set packSize(PackSizeBuilder? packSize) => _$this._packSize = packSize;

  String? _photoKey;
  String? get photoKey => _$this._photoKey;
  set photoKey(String? photoKey) => _$this._photoKey = photoKey;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  InputInBuilder() {
    InputIn._defaults(this);
  }

  InputInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _globalEntry = $v.globalEntry;
      _manufacturer = $v.manufacturer;
      _nameEn = $v.nameEn;
      _nameLocal = $v.nameLocal;
      _packSize = $v.packSize?.toBuilder();
      _photoKey = $v.photoKey;
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InputIn other) {
    _$v = other as _$InputIn;
  }

  @override
  void update(void Function(InputInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InputIn build() => _build();

  _$InputIn _build() {
    _$InputIn _$result;
    try {
      _$result = _$v ??
          _$InputIn._(
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'InputIn', 'category'),
            globalEntry: globalEntry,
            manufacturer: manufacturer,
            nameEn: BuiltValueNullFieldError.checkNotNull(
                nameEn, r'InputIn', 'nameEn'),
            nameLocal: nameLocal,
            packSize: _packSize?.build(),
            photoKey: photoKey,
            unit:
                BuiltValueNullFieldError.checkNotNull(unit, r'InputIn', 'unit'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'packSize';
        _packSize?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InputIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
