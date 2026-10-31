// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nursery_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NurseryPayload extends NurseryPayload {
  @override
  final QuantityInput? nurseryArea;
  @override
  final String? seedVariety;

  factory _$NurseryPayload([void Function(NurseryPayloadBuilder)? updates]) =>
      (NurseryPayloadBuilder()..update(updates))._build();

  _$NurseryPayload._({this.nurseryArea, this.seedVariety}) : super._();
  @override
  NurseryPayload rebuild(void Function(NurseryPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NurseryPayloadBuilder toBuilder() => NurseryPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NurseryPayload &&
        nurseryArea == other.nurseryArea &&
        seedVariety == other.seedVariety;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nurseryArea.hashCode);
    _$hash = $jc(_$hash, seedVariety.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NurseryPayload')
          ..add('nurseryArea', nurseryArea)
          ..add('seedVariety', seedVariety))
        .toString();
  }
}

class NurseryPayloadBuilder
    implements Builder<NurseryPayload, NurseryPayloadBuilder> {
  _$NurseryPayload? _$v;

  QuantityInputBuilder? _nurseryArea;
  QuantityInputBuilder get nurseryArea =>
      _$this._nurseryArea ??= QuantityInputBuilder();
  set nurseryArea(QuantityInputBuilder? nurseryArea) =>
      _$this._nurseryArea = nurseryArea;

  String? _seedVariety;
  String? get seedVariety => _$this._seedVariety;
  set seedVariety(String? seedVariety) => _$this._seedVariety = seedVariety;

  NurseryPayloadBuilder() {
    NurseryPayload._defaults(this);
  }

  NurseryPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nurseryArea = $v.nurseryArea?.toBuilder();
      _seedVariety = $v.seedVariety;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NurseryPayload other) {
    _$v = other as _$NurseryPayload;
  }

  @override
  void update(void Function(NurseryPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NurseryPayload build() => _build();

  _$NurseryPayload _build() {
    _$NurseryPayload _$result;
    try {
      _$result = _$v ??
          _$NurseryPayload._(
            nurseryArea: _nurseryArea?.build(),
            seedVariety: seedVariety,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'nurseryArea';
        _nurseryArea?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NurseryPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
