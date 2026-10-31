// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceOut extends DeviceOut {
  @override
  final String? appVersion;
  @override
  final String id;
  @override
  final DateTime? lastSeenAt;
  @override
  final String platform;

  factory _$DeviceOut([void Function(DeviceOutBuilder)? updates]) =>
      (DeviceOutBuilder()..update(updates))._build();

  _$DeviceOut._(
      {this.appVersion,
      required this.id,
      this.lastSeenAt,
      required this.platform})
      : super._();
  @override
  DeviceOut rebuild(void Function(DeviceOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceOutBuilder toBuilder() => DeviceOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceOut &&
        appVersion == other.appVersion &&
        id == other.id &&
        lastSeenAt == other.lastSeenAt &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceOut')
          ..add('appVersion', appVersion)
          ..add('id', id)
          ..add('lastSeenAt', lastSeenAt)
          ..add('platform', platform))
        .toString();
  }
}

class DeviceOutBuilder implements Builder<DeviceOut, DeviceOutBuilder> {
  _$DeviceOut? _$v;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  String? _platform;
  String? get platform => _$this._platform;
  set platform(String? platform) => _$this._platform = platform;

  DeviceOutBuilder() {
    DeviceOut._defaults(this);
  }

  DeviceOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _appVersion = $v.appVersion;
      _id = $v.id;
      _lastSeenAt = $v.lastSeenAt;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceOut other) {
    _$v = other as _$DeviceOut;
  }

  @override
  void update(void Function(DeviceOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceOut build() => _build();

  _$DeviceOut _build() {
    final _$result = _$v ??
        _$DeviceOut._(
          appVersion: appVersion,
          id: BuiltValueNullFieldError.checkNotNull(id, r'DeviceOut', 'id'),
          lastSeenAt: lastSeenAt,
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'DeviceOut', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
