// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const OtpVerifyInPlatformEnum _$otpVerifyInPlatformEnum_android =
    const OtpVerifyInPlatformEnum._('android');
const OtpVerifyInPlatformEnum _$otpVerifyInPlatformEnum_ios =
    const OtpVerifyInPlatformEnum._('ios');
const OtpVerifyInPlatformEnum _$otpVerifyInPlatformEnum_web =
    const OtpVerifyInPlatformEnum._('web');

OtpVerifyInPlatformEnum _$otpVerifyInPlatformEnumValueOf(String name) {
  switch (name) {
    case 'android':
      return _$otpVerifyInPlatformEnum_android;
    case 'ios':
      return _$otpVerifyInPlatformEnum_ios;
    case 'web':
      return _$otpVerifyInPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<OtpVerifyInPlatformEnum> _$otpVerifyInPlatformEnumValues =
    BuiltSet<OtpVerifyInPlatformEnum>(const <OtpVerifyInPlatformEnum>[
  _$otpVerifyInPlatformEnum_android,
  _$otpVerifyInPlatformEnum_ios,
  _$otpVerifyInPlatformEnum_web,
]);

Serializer<OtpVerifyInPlatformEnum> _$otpVerifyInPlatformEnumSerializer =
    _$OtpVerifyInPlatformEnumSerializer();

class _$OtpVerifyInPlatformEnumSerializer
    implements PrimitiveSerializer<OtpVerifyInPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'ios': 'ios',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[OtpVerifyInPlatformEnum];
  @override
  final String wireName = 'OtpVerifyInPlatformEnum';

  @override
  Object serialize(Serializers serializers, OtpVerifyInPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  OtpVerifyInPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      OtpVerifyInPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$OtpVerifyIn extends OtpVerifyIn {
  @override
  final String? appVersion;
  @override
  final String code;
  @override
  final String deviceId;
  @override
  final String phone;
  @override
  final OtpVerifyInPlatformEnum platform;

  factory _$OtpVerifyIn([void Function(OtpVerifyInBuilder)? updates]) =>
      (OtpVerifyInBuilder()..update(updates))._build();

  _$OtpVerifyIn._(
      {this.appVersion,
      required this.code,
      required this.deviceId,
      required this.phone,
      required this.platform})
      : super._();
  @override
  OtpVerifyIn rebuild(void Function(OtpVerifyInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OtpVerifyInBuilder toBuilder() => OtpVerifyInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OtpVerifyIn &&
        appVersion == other.appVersion &&
        code == other.code &&
        deviceId == other.deviceId &&
        phone == other.phone &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OtpVerifyIn')
          ..add('appVersion', appVersion)
          ..add('code', code)
          ..add('deviceId', deviceId)
          ..add('phone', phone)
          ..add('platform', platform))
        .toString();
  }
}

class OtpVerifyInBuilder implements Builder<OtpVerifyIn, OtpVerifyInBuilder> {
  _$OtpVerifyIn? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  OtpVerifyInPlatformEnum? _platform;
  OtpVerifyInPlatformEnum? get platform => _$this._platform;
  set platform(OtpVerifyInPlatformEnum? platform) =>
      _$this._platform = platform;

  OtpVerifyInBuilder() {
    OtpVerifyIn._defaults(this);
  }

  OtpVerifyInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _code = $v.code;
      _deviceId = $v.deviceId;
      _phone = $v.phone;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OtpVerifyIn other) {
    _$v = other as _$OtpVerifyIn;
  }

  @override
  void update(void Function(OtpVerifyInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OtpVerifyIn build() => _build();

  _$OtpVerifyIn _build() {
    final _$result = _$v ??
        _$OtpVerifyIn._(
          appVersion: appVersion,
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'OtpVerifyIn', 'code'),
          deviceId: BuiltValueNullFieldError.checkNotNull(
              deviceId, r'OtpVerifyIn', 'deviceId'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'OtpVerifyIn', 'phone'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'OtpVerifyIn', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
