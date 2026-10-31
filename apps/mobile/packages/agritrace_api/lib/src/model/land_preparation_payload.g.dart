// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'land_preparation_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LandPreparationPayload extends LandPreparationPayload {
  @override
  final QuantityInput? cultivatedArea;
  @override
  final Date? lastPloughedOn;

  factory _$LandPreparationPayload(
          [void Function(LandPreparationPayloadBuilder)? updates]) =>
      (LandPreparationPayloadBuilder()..update(updates))._build();

  _$LandPreparationPayload._({this.cultivatedArea, this.lastPloughedOn})
      : super._();
  @override
  LandPreparationPayload rebuild(
          void Function(LandPreparationPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LandPreparationPayloadBuilder toBuilder() =>
      LandPreparationPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LandPreparationPayload &&
        cultivatedArea == other.cultivatedArea &&
        lastPloughedOn == other.lastPloughedOn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cultivatedArea.hashCode);
    _$hash = $jc(_$hash, lastPloughedOn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LandPreparationPayload')
          ..add('cultivatedArea', cultivatedArea)
          ..add('lastPloughedOn', lastPloughedOn))
        .toString();
  }
}

class LandPreparationPayloadBuilder
    implements Builder<LandPreparationPayload, LandPreparationPayloadBuilder> {
  _$LandPreparationPayload? _$v;

  QuantityInputBuilder? _cultivatedArea;
  QuantityInputBuilder get cultivatedArea =>
      _$this._cultivatedArea ??= QuantityInputBuilder();
  set cultivatedArea(QuantityInputBuilder? cultivatedArea) =>
      _$this._cultivatedArea = cultivatedArea;

  Date? _lastPloughedOn;
  Date? get lastPloughedOn => _$this._lastPloughedOn;
  set lastPloughedOn(Date? lastPloughedOn) =>
      _$this._lastPloughedOn = lastPloughedOn;

  LandPreparationPayloadBuilder() {
    LandPreparationPayload._defaults(this);
  }

  LandPreparationPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cultivatedArea = $v.cultivatedArea?.toBuilder();
      _lastPloughedOn = $v.lastPloughedOn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LandPreparationPayload other) {
    _$v = other as _$LandPreparationPayload;
  }

  @override
  void update(void Function(LandPreparationPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LandPreparationPayload build() => _build();

  _$LandPreparationPayload _build() {
    _$LandPreparationPayload _$result;
    try {
      _$result = _$v ??
          _$LandPreparationPayload._(
            cultivatedArea: _cultivatedArea?.build(),
            lastPloughedOn: lastPloughedOn,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'cultivatedArea';
        _cultivatedArea?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'LandPreparationPayload', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
