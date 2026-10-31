// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photos_confirm_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PhotosConfirmIn extends PhotosConfirmIn {
  @override
  final BuiltList<PhotoRef> photos;

  factory _$PhotosConfirmIn([void Function(PhotosConfirmInBuilder)? updates]) =>
      (PhotosConfirmInBuilder()..update(updates))._build();

  _$PhotosConfirmIn._({required this.photos}) : super._();
  @override
  PhotosConfirmIn rebuild(void Function(PhotosConfirmInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PhotosConfirmInBuilder toBuilder() => PhotosConfirmInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PhotosConfirmIn && photos == other.photos;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PhotosConfirmIn')
          ..add('photos', photos))
        .toString();
  }
}

class PhotosConfirmInBuilder
    implements Builder<PhotosConfirmIn, PhotosConfirmInBuilder> {
  _$PhotosConfirmIn? _$v;

  ListBuilder<PhotoRef>? _photos;
  ListBuilder<PhotoRef> get photos =>
      _$this._photos ??= ListBuilder<PhotoRef>();
  set photos(ListBuilder<PhotoRef>? photos) => _$this._photos = photos;

  PhotosConfirmInBuilder() {
    PhotosConfirmIn._defaults(this);
  }

  PhotosConfirmInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _photos = $v.photos.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PhotosConfirmIn other) {
    _$v = other as _$PhotosConfirmIn;
  }

  @override
  void update(void Function(PhotosConfirmInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PhotosConfirmIn build() => _build();

  _$PhotosConfirmIn _build() {
    _$PhotosConfirmIn _$result;
    try {
      _$result = _$v ??
          _$PhotosConfirmIn._(
            photos: photos.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photos';
        photos.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PhotosConfirmIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
