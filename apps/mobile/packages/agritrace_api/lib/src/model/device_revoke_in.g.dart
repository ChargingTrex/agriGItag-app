// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_revoke_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceRevokeIn extends DeviceRevokeIn {
  @override
  final String? reason;

  factory _$DeviceRevokeIn([void Function(DeviceRevokeInBuilder)? updates]) =>
      (DeviceRevokeInBuilder()..update(updates))._build();

  _$DeviceRevokeIn._({this.reason}) : super._();
  @override
  DeviceRevokeIn rebuild(void Function(DeviceRevokeInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceRevokeInBuilder toBuilder() => DeviceRevokeInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceRevokeIn && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceRevokeIn')
          ..add('reason', reason))
        .toString();
  }
}

class DeviceRevokeInBuilder
    implements Builder<DeviceRevokeIn, DeviceRevokeInBuilder> {
  _$DeviceRevokeIn? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DeviceRevokeInBuilder() {
    DeviceRevokeIn._defaults(this);
  }

  DeviceRevokeInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceRevokeIn other) {
    _$v = other as _$DeviceRevokeIn;
  }

  @override
  void update(void Function(DeviceRevokeInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceRevokeIn build() => _build();

  _$DeviceRevokeIn _build() {
    final _$result = _$v ??
        _$DeviceRevokeIn._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
