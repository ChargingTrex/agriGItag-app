// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ShareOut extends ShareOut {
  @override
  final QuantityOutput contributed;
  @override
  final String farmerId;
  @override
  final String lotId;
  @override
  final String sharePct;

  factory _$ShareOut([void Function(ShareOutBuilder)? updates]) =>
      (ShareOutBuilder()..update(updates))._build();

  _$ShareOut._(
      {required this.contributed,
      required this.farmerId,
      required this.lotId,
      required this.sharePct})
      : super._();
  @override
  ShareOut rebuild(void Function(ShareOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ShareOutBuilder toBuilder() => ShareOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ShareOut &&
        contributed == other.contributed &&
        farmerId == other.farmerId &&
        lotId == other.lotId &&
        sharePct == other.sharePct;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contributed.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, sharePct.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ShareOut')
          ..add('contributed', contributed)
          ..add('farmerId', farmerId)
          ..add('lotId', lotId)
          ..add('sharePct', sharePct))
        .toString();
  }
}

class ShareOutBuilder implements Builder<ShareOut, ShareOutBuilder> {
  _$ShareOut? _$v;

  QuantityOutputBuilder? _contributed;
  QuantityOutputBuilder get contributed =>
      _$this._contributed ??= QuantityOutputBuilder();
  set contributed(QuantityOutputBuilder? contributed) =>
      _$this._contributed = contributed;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  String? _sharePct;
  String? get sharePct => _$this._sharePct;
  set sharePct(String? sharePct) => _$this._sharePct = sharePct;

  ShareOutBuilder() {
    ShareOut._defaults(this);
  }

  ShareOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contributed = $v.contributed.toBuilder();
      _farmerId = $v.farmerId;
      _lotId = $v.lotId;
      _sharePct = $v.sharePct;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ShareOut other) {
    _$v = other as _$ShareOut;
  }

  @override
  void update(void Function(ShareOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ShareOut build() => _build();

  _$ShareOut _build() {
    _$ShareOut _$result;
    try {
      _$result = _$v ??
          _$ShareOut._(
            contributed: contributed.build(),
            farmerId: BuiltValueNullFieldError.checkNotNull(
                farmerId, r'ShareOut', 'farmerId'),
            lotId: BuiltValueNullFieldError.checkNotNull(
                lotId, r'ShareOut', 'lotId'),
            sharePct: BuiltValueNullFieldError.checkNotNull(
                sharePct, r'ShareOut', 'sharePct'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'contributed';
        contributed.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ShareOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
