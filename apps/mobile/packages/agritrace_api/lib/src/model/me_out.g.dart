// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeOut extends MeOut {
  @override
  final DeviceOut? device;
  @override
  final BuiltList<MembershipOut> memberships;
  @override
  final UserOut user;

  factory _$MeOut([void Function(MeOutBuilder)? updates]) =>
      (MeOutBuilder()..update(updates))._build();

  _$MeOut._({this.device, required this.memberships, required this.user})
      : super._();
  @override
  MeOut rebuild(void Function(MeOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeOutBuilder toBuilder() => MeOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeOut &&
        device == other.device &&
        memberships == other.memberships &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jc(_$hash, memberships.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeOut')
          ..add('device', device)
          ..add('memberships', memberships)
          ..add('user', user))
        .toString();
  }
}

class MeOutBuilder implements Builder<MeOut, MeOutBuilder> {
  _$MeOut? _$v;

  DeviceOutBuilder? _device;
  DeviceOutBuilder get device => _$this._device ??= DeviceOutBuilder();
  set device(DeviceOutBuilder? device) => _$this._device = device;

  ListBuilder<MembershipOut>? _memberships;
  ListBuilder<MembershipOut> get memberships =>
      _$this._memberships ??= ListBuilder<MembershipOut>();
  set memberships(ListBuilder<MembershipOut>? memberships) =>
      _$this._memberships = memberships;

  UserOutBuilder? _user;
  UserOutBuilder get user => _$this._user ??= UserOutBuilder();
  set user(UserOutBuilder? user) => _$this._user = user;

  MeOutBuilder() {
    MeOut._defaults(this);
  }

  MeOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _device = $v.device?.toBuilder();
      _memberships = $v.memberships.toBuilder();
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeOut other) {
    _$v = other as _$MeOut;
  }

  @override
  void update(void Function(MeOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeOut build() => _build();

  _$MeOut _build() {
    _$MeOut _$result;
    try {
      _$result = _$v ??
          _$MeOut._(
            device: _device?.build(),
            memberships: memberships.build(),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'device';
        _device?.build();
        _$failedField = 'memberships';
        memberships.build();
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'MeOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
