// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_part.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReferencePart extends ReferencePart {
  @override
  final BuiltMap<String, JsonObject?> body;
  @override
  final String etag;
  @override
  final int version;

  factory _$ReferencePart([void Function(ReferencePartBuilder)? updates]) =>
      (ReferencePartBuilder()..update(updates))._build();

  _$ReferencePart._(
      {required this.body, required this.etag, required this.version})
      : super._();
  @override
  ReferencePart rebuild(void Function(ReferencePartBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReferencePartBuilder toBuilder() => ReferencePartBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReferencePart &&
        body == other.body &&
        etag == other.etag &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, etag.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReferencePart')
          ..add('body', body)
          ..add('etag', etag)
          ..add('version', version))
        .toString();
  }
}

class ReferencePartBuilder
    implements Builder<ReferencePart, ReferencePartBuilder> {
  _$ReferencePart? _$v;

  MapBuilder<String, JsonObject?>? _body;
  MapBuilder<String, JsonObject?> get body =>
      _$this._body ??= MapBuilder<String, JsonObject?>();
  set body(MapBuilder<String, JsonObject?>? body) => _$this._body = body;

  String? _etag;
  String? get etag => _$this._etag;
  set etag(String? etag) => _$this._etag = etag;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ReferencePartBuilder() {
    ReferencePart._defaults(this);
  }

  ReferencePartBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body.toBuilder();
      _etag = $v.etag;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReferencePart other) {
    _$v = other as _$ReferencePart;
  }

  @override
  void update(void Function(ReferencePartBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReferencePart build() => _build();

  _$ReferencePart _build() {
    _$ReferencePart _$result;
    try {
      _$result = _$v ??
          _$ReferencePart._(
            body: body.build(),
            etag: BuiltValueNullFieldError.checkNotNull(
                etag, r'ReferencePart', 'etag'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'ReferencePart', 'version'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'body';
        body.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReferencePart', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
