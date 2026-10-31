// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_counts.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagCounts extends FlagCounts {
  @override
  final int hold;
  @override
  final int info;
  @override
  final int warn;

  factory _$FlagCounts([void Function(FlagCountsBuilder)? updates]) =>
      (FlagCountsBuilder()..update(updates))._build();

  _$FlagCounts._({required this.hold, required this.info, required this.warn})
      : super._();
  @override
  FlagCounts rebuild(void Function(FlagCountsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagCountsBuilder toBuilder() => FlagCountsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagCounts &&
        hold == other.hold &&
        info == other.info &&
        warn == other.warn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hold.hashCode);
    _$hash = $jc(_$hash, info.hashCode);
    _$hash = $jc(_$hash, warn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagCounts')
          ..add('hold', hold)
          ..add('info', info)
          ..add('warn', warn))
        .toString();
  }
}

class FlagCountsBuilder implements Builder<FlagCounts, FlagCountsBuilder> {
  _$FlagCounts? _$v;

  int? _hold;
  int? get hold => _$this._hold;
  set hold(int? hold) => _$this._hold = hold;

  int? _info;
  int? get info => _$this._info;
  set info(int? info) => _$this._info = info;

  int? _warn;
  int? get warn => _$this._warn;
  set warn(int? warn) => _$this._warn = warn;

  FlagCountsBuilder() {
    FlagCounts._defaults(this);
  }

  FlagCountsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hold = $v.hold;
      _info = $v.info;
      _warn = $v.warn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagCounts other) {
    _$v = other as _$FlagCounts;
  }

  @override
  void update(void Function(FlagCountsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagCounts build() => _build();

  _$FlagCounts _build() {
    final _$result = _$v ??
        _$FlagCounts._(
          hold: BuiltValueNullFieldError.checkNotNull(
              hold, r'FlagCounts', 'hold'),
          info: BuiltValueNullFieldError.checkNotNull(
              info, r'FlagCounts', 'info'),
          warn: BuiltValueNullFieldError.checkNotNull(
              warn, r'FlagCounts', 'warn'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
