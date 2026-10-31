// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BatchIn extends BatchIn {
  @override
  final String clientId;
  @override
  final bool? giLabelRequested;
  @override
  final BuiltList<String> lotIds;
  @override
  final String processorId;

  factory _$BatchIn([void Function(BatchInBuilder)? updates]) =>
      (BatchInBuilder()..update(updates))._build();

  _$BatchIn._(
      {required this.clientId,
      this.giLabelRequested,
      required this.lotIds,
      required this.processorId})
      : super._();
  @override
  BatchIn rebuild(void Function(BatchInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BatchInBuilder toBuilder() => BatchInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BatchIn &&
        clientId == other.clientId &&
        giLabelRequested == other.giLabelRequested &&
        lotIds == other.lotIds &&
        processorId == other.processorId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, giLabelRequested.hashCode);
    _$hash = $jc(_$hash, lotIds.hashCode);
    _$hash = $jc(_$hash, processorId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BatchIn')
          ..add('clientId', clientId)
          ..add('giLabelRequested', giLabelRequested)
          ..add('lotIds', lotIds)
          ..add('processorId', processorId))
        .toString();
  }
}

class BatchInBuilder implements Builder<BatchIn, BatchInBuilder> {
  _$BatchIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  bool? _giLabelRequested;
  bool? get giLabelRequested => _$this._giLabelRequested;
  set giLabelRequested(bool? giLabelRequested) =>
      _$this._giLabelRequested = giLabelRequested;

  ListBuilder<String>? _lotIds;
  ListBuilder<String> get lotIds => _$this._lotIds ??= ListBuilder<String>();
  set lotIds(ListBuilder<String>? lotIds) => _$this._lotIds = lotIds;

  String? _processorId;
  String? get processorId => _$this._processorId;
  set processorId(String? processorId) => _$this._processorId = processorId;

  BatchInBuilder() {
    BatchIn._defaults(this);
  }

  BatchInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _giLabelRequested = $v.giLabelRequested;
      _lotIds = $v.lotIds.toBuilder();
      _processorId = $v.processorId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BatchIn other) {
    _$v = other as _$BatchIn;
  }

  @override
  void update(void Function(BatchInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BatchIn build() => _build();

  _$BatchIn _build() {
    _$BatchIn _$result;
    try {
      _$result = _$v ??
          _$BatchIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'BatchIn', 'clientId'),
            giLabelRequested: giLabelRequested,
            lotIds: lotIds.build(),
            processorId: BuiltValueNullFieldError.checkNotNull(
                processorId, r'BatchIn', 'processorId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'lotIds';
        lotIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BatchIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
