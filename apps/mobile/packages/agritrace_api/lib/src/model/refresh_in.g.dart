// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshIn extends RefreshIn {
  @override
  final String? refreshToken;

  factory _$RefreshIn([void Function(RefreshInBuilder)? updates]) =>
      (RefreshInBuilder()..update(updates))._build();

  _$RefreshIn._({this.refreshToken}) : super._();
  @override
  RefreshIn rebuild(void Function(RefreshInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshInBuilder toBuilder() => RefreshInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshIn && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshIn')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshInBuilder implements Builder<RefreshIn, RefreshInBuilder> {
  _$RefreshIn? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshInBuilder() {
    RefreshIn._defaults(this);
  }

  RefreshInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshIn other) {
    _$v = other as _$RefreshIn;
  }

  @override
  void update(void Function(RefreshInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshIn build() => _build();

  _$RefreshIn _build() {
    final _$result = _$v ??
        _$RefreshIn._(
          refreshToken: refreshToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
