// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_reject.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FarmerReject extends FarmerReject {
  @override
  final String reasonCode;
  @override
  final String? reasonText;

  factory _$FarmerReject([void Function(FarmerRejectBuilder)? updates]) =>
      (FarmerRejectBuilder()..update(updates))._build();

  _$FarmerReject._({required this.reasonCode, this.reasonText}) : super._();
  @override
  FarmerReject rebuild(void Function(FarmerRejectBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerRejectBuilder toBuilder() => FarmerRejectBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerReject &&
        reasonCode == other.reasonCode &&
        reasonText == other.reasonText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, reasonText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerReject')
          ..add('reasonCode', reasonCode)
          ..add('reasonText', reasonText))
        .toString();
  }
}

class FarmerRejectBuilder
    implements Builder<FarmerReject, FarmerRejectBuilder> {
  _$FarmerReject? _$v;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _reasonText;
  String? get reasonText => _$this._reasonText;
  set reasonText(String? reasonText) => _$this._reasonText = reasonText;

  FarmerRejectBuilder() {
    FarmerReject._defaults(this);
  }

  FarmerRejectBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reasonCode = $v.reasonCode;
      _reasonText = $v.reasonText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerReject other) {
    _$v = other as _$FarmerReject;
  }

  @override
  void update(void Function(FarmerRejectBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerReject build() => _build();

  _$FarmerReject _build() {
    final _$result = _$v ??
        _$FarmerReject._(
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'FarmerReject', 'reasonCode'),
          reasonText: reasonText,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
