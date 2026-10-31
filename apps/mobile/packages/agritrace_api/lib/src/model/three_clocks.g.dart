// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'three_clocks.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ThreeClocks extends ThreeClocks {
  @override
  final DateTime deviceTime;
  @override
  final DateTime? gpsTime;
  @override
  final DateTime? serverReceivedAt;

  factory _$ThreeClocks([void Function(ThreeClocksBuilder)? updates]) =>
      (ThreeClocksBuilder()..update(updates))._build();

  _$ThreeClocks._(
      {required this.deviceTime, this.gpsTime, this.serverReceivedAt})
      : super._();
  @override
  ThreeClocks rebuild(void Function(ThreeClocksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ThreeClocksBuilder toBuilder() => ThreeClocksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ThreeClocks &&
        deviceTime == other.deviceTime &&
        gpsTime == other.gpsTime &&
        serverReceivedAt == other.serverReceivedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceTime.hashCode);
    _$hash = $jc(_$hash, gpsTime.hashCode);
    _$hash = $jc(_$hash, serverReceivedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ThreeClocks')
          ..add('deviceTime', deviceTime)
          ..add('gpsTime', gpsTime)
          ..add('serverReceivedAt', serverReceivedAt))
        .toString();
  }
}

class ThreeClocksBuilder implements Builder<ThreeClocks, ThreeClocksBuilder> {
  _$ThreeClocks? _$v;

  DateTime? _deviceTime;
  DateTime? get deviceTime => _$this._deviceTime;
  set deviceTime(DateTime? deviceTime) => _$this._deviceTime = deviceTime;

  DateTime? _gpsTime;
  DateTime? get gpsTime => _$this._gpsTime;
  set gpsTime(DateTime? gpsTime) => _$this._gpsTime = gpsTime;

  DateTime? _serverReceivedAt;
  DateTime? get serverReceivedAt => _$this._serverReceivedAt;
  set serverReceivedAt(DateTime? serverReceivedAt) =>
      _$this._serverReceivedAt = serverReceivedAt;

  ThreeClocksBuilder() {
    ThreeClocks._defaults(this);
  }

  ThreeClocksBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceTime = $v.deviceTime;
      _gpsTime = $v.gpsTime;
      _serverReceivedAt = $v.serverReceivedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ThreeClocks other) {
    _$v = other as _$ThreeClocks;
  }

  @override
  void update(void Function(ThreeClocksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ThreeClocks build() => _build();

  _$ThreeClocks _build() {
    final _$result = _$v ??
        _$ThreeClocks._(
          deviceTime: BuiltValueNullFieldError.checkNotNull(
              deviceTime, r'ThreeClocks', 'deviceTime'),
          gpsTime: gpsTime,
          serverReceivedAt: serverReceivedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
