// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserOut extends UserOut {
  @override
  final String id;
  @override
  final bool isSuperAdmin;
  @override
  final String lang;
  @override
  final String name;
  @override
  final String? nameLocal;
  @override
  final String phone;

  factory _$UserOut([void Function(UserOutBuilder)? updates]) =>
      (UserOutBuilder()..update(updates))._build();

  _$UserOut._(
      {required this.id,
      required this.isSuperAdmin,
      required this.lang,
      required this.name,
      this.nameLocal,
      required this.phone})
      : super._();
  @override
  UserOut rebuild(void Function(UserOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserOutBuilder toBuilder() => UserOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserOut &&
        id == other.id &&
        isSuperAdmin == other.isSuperAdmin &&
        lang == other.lang &&
        name == other.name &&
        nameLocal == other.nameLocal &&
        phone == other.phone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isSuperAdmin.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserOut')
          ..add('id', id)
          ..add('isSuperAdmin', isSuperAdmin)
          ..add('lang', lang)
          ..add('name', name)
          ..add('nameLocal', nameLocal)
          ..add('phone', phone))
        .toString();
  }
}

class UserOutBuilder implements Builder<UserOut, UserOutBuilder> {
  _$UserOut? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isSuperAdmin;
  bool? get isSuperAdmin => _$this._isSuperAdmin;
  set isSuperAdmin(bool? isSuperAdmin) => _$this._isSuperAdmin = isSuperAdmin;

  String? _lang;
  String? get lang => _$this._lang;
  set lang(String? lang) => _$this._lang = lang;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  UserOutBuilder() {
    UserOut._defaults(this);
  }

  UserOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _isSuperAdmin = $v.isSuperAdmin;
      _lang = $v.lang;
      _name = $v.name;
      _nameLocal = $v.nameLocal;
      _phone = $v.phone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserOut other) {
    _$v = other as _$UserOut;
  }

  @override
  void update(void Function(UserOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserOut build() => _build();

  _$UserOut _build() {
    final _$result = _$v ??
        _$UserOut._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'UserOut', 'id'),
          isSuperAdmin: BuiltValueNullFieldError.checkNotNull(
              isSuperAdmin, r'UserOut', 'isSuperAdmin'),
          lang: BuiltValueNullFieldError.checkNotNull(lang, r'UserOut', 'lang'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'UserOut', 'name'),
          nameLocal: nameLocal,
          phone:
              BuiltValueNullFieldError.checkNotNull(phone, r'UserOut', 'phone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
