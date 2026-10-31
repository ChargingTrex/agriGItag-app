// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FarmerInLangEnum _$farmerInLangEnum_ta = const FarmerInLangEnum._('ta');
const FarmerInLangEnum _$farmerInLangEnum_en = const FarmerInLangEnum._('en');

FarmerInLangEnum _$farmerInLangEnumValueOf(String name) {
  switch (name) {
    case 'ta':
      return _$farmerInLangEnum_ta;
    case 'en':
      return _$farmerInLangEnum_en;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FarmerInLangEnum> _$farmerInLangEnumValues =
    BuiltSet<FarmerInLangEnum>(const <FarmerInLangEnum>[
  _$farmerInLangEnum_ta,
  _$farmerInLangEnum_en,
]);

Serializer<FarmerInLangEnum> _$farmerInLangEnumSerializer =
    _$FarmerInLangEnumSerializer();

class _$FarmerInLangEnumSerializer
    implements PrimitiveSerializer<FarmerInLangEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ta': 'ta',
    'en': 'en',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ta': 'ta',
    'en': 'en',
  };

  @override
  final Iterable<Type> types = const <Type>[FarmerInLangEnum];
  @override
  final String wireName = 'FarmerInLangEnum';

  @override
  Object serialize(Serializers serializers, FarmerInLangEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FarmerInLangEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FarmerInLangEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FarmerIn extends FarmerIn {
  @override
  final Address? address;
  @override
  final String? clientId;
  @override
  final String? giAuthorisedUserNo;
  @override
  final FarmerInLangEnum? lang;
  @override
  final String name;
  @override
  final String? nameLocal;
  @override
  final bool? noSmartphone;
  @override
  final String? phone;
  @override
  final String? photoKey;
  @override
  final String? villageId;

  factory _$FarmerIn([void Function(FarmerInBuilder)? updates]) =>
      (FarmerInBuilder()..update(updates))._build();

  _$FarmerIn._(
      {this.address,
      this.clientId,
      this.giAuthorisedUserNo,
      this.lang,
      required this.name,
      this.nameLocal,
      this.noSmartphone,
      this.phone,
      this.photoKey,
      this.villageId})
      : super._();
  @override
  FarmerIn rebuild(void Function(FarmerInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerInBuilder toBuilder() => FarmerInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerIn &&
        address == other.address &&
        clientId == other.clientId &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        lang == other.lang &&
        name == other.name &&
        nameLocal == other.nameLocal &&
        noSmartphone == other.noSmartphone &&
        phone == other.phone &&
        photoKey == other.photoKey &&
        villageId == other.villageId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jc(_$hash, noSmartphone.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, photoKey.hashCode);
    _$hash = $jc(_$hash, villageId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerIn')
          ..add('address', address)
          ..add('clientId', clientId)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('lang', lang)
          ..add('name', name)
          ..add('nameLocal', nameLocal)
          ..add('noSmartphone', noSmartphone)
          ..add('phone', phone)
          ..add('photoKey', photoKey)
          ..add('villageId', villageId))
        .toString();
  }
}

class FarmerInBuilder implements Builder<FarmerIn, FarmerInBuilder> {
  _$FarmerIn? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  FarmerInLangEnum? _lang;
  FarmerInLangEnum? get lang => _$this._lang;
  set lang(FarmerInLangEnum? lang) => _$this._lang = lang;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  bool? _noSmartphone;
  bool? get noSmartphone => _$this._noSmartphone;
  set noSmartphone(bool? noSmartphone) => _$this._noSmartphone = noSmartphone;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _photoKey;
  String? get photoKey => _$this._photoKey;
  set photoKey(String? photoKey) => _$this._photoKey = photoKey;

  String? _villageId;
  String? get villageId => _$this._villageId;
  set villageId(String? villageId) => _$this._villageId = villageId;

  FarmerInBuilder() {
    FarmerIn._defaults(this);
  }

  FarmerInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _clientId = $v.clientId;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _lang = $v.lang;
      _name = $v.name;
      _nameLocal = $v.nameLocal;
      _noSmartphone = $v.noSmartphone;
      _phone = $v.phone;
      _photoKey = $v.photoKey;
      _villageId = $v.villageId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerIn other) {
    _$v = other as _$FarmerIn;
  }

  @override
  void update(void Function(FarmerInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerIn build() => _build();

  _$FarmerIn _build() {
    _$FarmerIn _$result;
    try {
      _$result = _$v ??
          _$FarmerIn._(
            address: _address?.build(),
            clientId: clientId,
            giAuthorisedUserNo: giAuthorisedUserNo,
            lang: lang,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'FarmerIn', 'name'),
            nameLocal: nameLocal,
            noSmartphone: noSmartphone,
            phone: phone,
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
            r'FarmerIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
