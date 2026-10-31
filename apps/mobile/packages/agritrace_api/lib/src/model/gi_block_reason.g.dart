// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gi_block_reason.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GiBlockReason extends GiBlockReason {
  @override
  final String? detail;
  @override
  final String? lotId;
  @override
  final String reason;

  factory _$GiBlockReason([void Function(GiBlockReasonBuilder)? updates]) =>
      (GiBlockReasonBuilder()..update(updates))._build();

  _$GiBlockReason._({this.detail, this.lotId, required this.reason})
      : super._();
  @override
  GiBlockReason rebuild(void Function(GiBlockReasonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GiBlockReasonBuilder toBuilder() => GiBlockReasonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GiBlockReason &&
        detail == other.detail &&
        lotId == other.lotId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jc(_$hash, lotId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GiBlockReason')
          ..add('detail', detail)
          ..add('lotId', lotId)
          ..add('reason', reason))
        .toString();
  }
}

class GiBlockReasonBuilder
    implements Builder<GiBlockReason, GiBlockReasonBuilder> {
  _$GiBlockReason? _$v;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(String? detail) => _$this._detail = detail;

  String? _lotId;
  String? get lotId => _$this._lotId;
  set lotId(String? lotId) => _$this._lotId = lotId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  GiBlockReasonBuilder() {
    GiBlockReason._defaults(this);
  }

  GiBlockReasonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _detail = $v.detail;
      _lotId = $v.lotId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GiBlockReason other) {
    _$v = other as _$GiBlockReason;
  }

  @override
  void update(void Function(GiBlockReasonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GiBlockReason build() => _build();

  _$GiBlockReason _build() {
    final _$result = _$v ??
        _$GiBlockReason._(
          detail: detail,
          lotId: lotId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'GiBlockReason', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
