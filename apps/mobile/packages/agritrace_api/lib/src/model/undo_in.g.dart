// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'undo_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UndoIn extends UndoIn {
  @override
  final String clientId;
  @override
  final ThreeClocks? clocks;
  @override
  final String? reasonCode;
  @override
  final String? reasonText;
  @override
  final int versionNo;

  factory _$UndoIn([void Function(UndoInBuilder)? updates]) =>
      (UndoInBuilder()..update(updates))._build();

  _$UndoIn._(
      {required this.clientId,
      this.clocks,
      this.reasonCode,
      this.reasonText,
      required this.versionNo})
      : super._();
  @override
  UndoIn rebuild(void Function(UndoInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UndoInBuilder toBuilder() => UndoInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UndoIn &&
        clientId == other.clientId &&
        clocks == other.clocks &&
        reasonCode == other.reasonCode &&
        reasonText == other.reasonText &&
        versionNo == other.versionNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, clocks.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, reasonText.hashCode);
    _$hash = $jc(_$hash, versionNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UndoIn')
          ..add('clientId', clientId)
          ..add('clocks', clocks)
          ..add('reasonCode', reasonCode)
          ..add('reasonText', reasonText)
          ..add('versionNo', versionNo))
        .toString();
  }
}

class UndoInBuilder implements Builder<UndoIn, UndoInBuilder> {
  _$UndoIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  ThreeClocksBuilder? _clocks;
  ThreeClocksBuilder get clocks => _$this._clocks ??= ThreeClocksBuilder();
  set clocks(ThreeClocksBuilder? clocks) => _$this._clocks = clocks;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _reasonText;
  String? get reasonText => _$this._reasonText;
  set reasonText(String? reasonText) => _$this._reasonText = reasonText;

  int? _versionNo;
  int? get versionNo => _$this._versionNo;
  set versionNo(int? versionNo) => _$this._versionNo = versionNo;

  UndoInBuilder() {
    UndoIn._defaults(this);
  }

  UndoInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _clocks = $v.clocks?.toBuilder();
      _reasonCode = $v.reasonCode;
      _reasonText = $v.reasonText;
      _versionNo = $v.versionNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UndoIn other) {
    _$v = other as _$UndoIn;
  }

  @override
  void update(void Function(UndoInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UndoIn build() => _build();

  _$UndoIn _build() {
    _$UndoIn _$result;
    try {
      _$result = _$v ??
          _$UndoIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'UndoIn', 'clientId'),
            clocks: _clocks?.build(),
            reasonCode: reasonCode,
            reasonText: reasonText,
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'UndoIn', 'versionNo'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'clocks';
        _clocks?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UndoIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
