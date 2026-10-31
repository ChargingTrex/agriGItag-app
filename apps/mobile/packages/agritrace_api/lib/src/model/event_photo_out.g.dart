// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_photo_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventPhotoOut extends EventPhotoOut {
  @override
  final String id;
  @override
  final PhotoStatus status;
  @override
  final BuiltMap<String, JsonObject?>? variants;

  factory _$EventPhotoOut([void Function(EventPhotoOutBuilder)? updates]) =>
      (EventPhotoOutBuilder()..update(updates))._build();

  _$EventPhotoOut._({required this.id, required this.status, this.variants})
      : super._();
  @override
  EventPhotoOut rebuild(void Function(EventPhotoOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventPhotoOutBuilder toBuilder() => EventPhotoOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventPhotoOut &&
        id == other.id &&
        status == other.status &&
        variants == other.variants;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, variants.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventPhotoOut')
          ..add('id', id)
          ..add('status', status)
          ..add('variants', variants))
        .toString();
  }
}

class EventPhotoOutBuilder
    implements Builder<EventPhotoOut, EventPhotoOutBuilder> {
  _$EventPhotoOut? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PhotoStatus? _status;
  PhotoStatus? get status => _$this._status;
  set status(PhotoStatus? status) => _$this._status = status;

  MapBuilder<String, JsonObject?>? _variants;
  MapBuilder<String, JsonObject?> get variants =>
      _$this._variants ??= MapBuilder<String, JsonObject?>();
  set variants(MapBuilder<String, JsonObject?>? variants) =>
      _$this._variants = variants;

  EventPhotoOutBuilder() {
    EventPhotoOut._defaults(this);
  }

  EventPhotoOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _variants = $v.variants?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventPhotoOut other) {
    _$v = other as _$EventPhotoOut;
  }

  @override
  void update(void Function(EventPhotoOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventPhotoOut build() => _build();

  _$EventPhotoOut _build() {
    _$EventPhotoOut _$result;
    try {
      _$result = _$v ??
          _$EventPhotoOut._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'EventPhotoOut', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'EventPhotoOut', 'status'),
            variants: _variants?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'variants';
        _variants?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventPhotoOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
