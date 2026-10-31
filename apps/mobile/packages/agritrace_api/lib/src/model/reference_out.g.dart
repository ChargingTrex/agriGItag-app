// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReferenceOut extends ReferenceOut {
  @override
  final BuiltMap<String, ReferencePart> parts;

  factory _$ReferenceOut([void Function(ReferenceOutBuilder)? updates]) =>
      (ReferenceOutBuilder()..update(updates))._build();

  _$ReferenceOut._({required this.parts}) : super._();
  @override
  ReferenceOut rebuild(void Function(ReferenceOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReferenceOutBuilder toBuilder() => ReferenceOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReferenceOut && parts == other.parts;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, parts.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReferenceOut')..add('parts', parts))
        .toString();
  }
}

class ReferenceOutBuilder
    implements Builder<ReferenceOut, ReferenceOutBuilder> {
  _$ReferenceOut? _$v;

  MapBuilder<String, ReferencePart>? _parts;
  MapBuilder<String, ReferencePart> get parts =>
      _$this._parts ??= MapBuilder<String, ReferencePart>();
  set parts(MapBuilder<String, ReferencePart>? parts) => _$this._parts = parts;

  ReferenceOutBuilder() {
    ReferenceOut._defaults(this);
  }

  ReferenceOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _parts = $v.parts.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReferenceOut other) {
    _$v = other as _$ReferenceOut;
  }

  @override
  void update(void Function(ReferenceOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReferenceOut build() => _build();

  _$ReferenceOut _build() {
    _$ReferenceOut _$result;
    try {
      _$result = _$v ??
          _$ReferenceOut._(
            parts: parts.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parts';
        parts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReferenceOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
