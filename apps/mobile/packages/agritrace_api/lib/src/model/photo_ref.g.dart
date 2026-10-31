// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhotoRef extends PhotoRef {
  @override
  final String clientId;

  factory _$PhotoRef([void Function(PhotoRefBuilder)? updates]) =>
      (PhotoRefBuilder()..update(updates))._build();

  _$PhotoRef._({required this.clientId}) : super._();
  @override
  PhotoRef rebuild(void Function(PhotoRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhotoRefBuilder toBuilder() => PhotoRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhotoRef && clientId == other.clientId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhotoRef')..add('clientId', clientId))
        .toString();
  }
}

class PhotoRefBuilder implements Builder<PhotoRef, PhotoRefBuilder> {
  _$PhotoRef? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  PhotoRefBuilder() {
    PhotoRef._defaults(this);
  }

  PhotoRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhotoRef other) {
    _$v = other as _$PhotoRef;
  }

  @override
  void update(void Function(PhotoRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhotoRef build() => _build();

  _$PhotoRef _build() {
    final _$result = _$v ??
        _$PhotoRef._(
          clientId: BuiltValueNullFieldError.checkNotNull(
              clientId, r'PhotoRef', 'clientId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
