// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correction_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CorrectionIn extends CorrectionIn {
  @override
  final String clientId;
  @override
  final Data data;

  factory _$CorrectionIn([void Function(CorrectionInBuilder)? updates]) =>
      (CorrectionInBuilder()..update(updates))._build();

  _$CorrectionIn._({required this.clientId, required this.data}) : super._();
  @override
  CorrectionIn rebuild(void Function(CorrectionInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CorrectionInBuilder toBuilder() => CorrectionInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CorrectionIn &&
        clientId == other.clientId &&
        data == other.data;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, data.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CorrectionIn')
          ..add('clientId', clientId)
          ..add('data', data))
        .toString();
  }
}

class CorrectionInBuilder
    implements Builder<CorrectionIn, CorrectionInBuilder> {
  _$CorrectionIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  DataBuilder? _data;
  DataBuilder get data => _$this._data ??= DataBuilder();
  set data(DataBuilder? data) => _$this._data = data;

  CorrectionInBuilder() {
    CorrectionIn._defaults(this);
  }

  CorrectionInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _data = $v.data.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CorrectionIn other) {
    _$v = other as _$CorrectionIn;
  }

  @override
  void update(void Function(CorrectionInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CorrectionIn build() => _build();

  _$CorrectionIn _build() {
    _$CorrectionIn _$result;
    try {
      _$result = _$v ??
          _$CorrectionIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'CorrectionIn', 'clientId'),
            data: data.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'data';
        data.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CorrectionIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
