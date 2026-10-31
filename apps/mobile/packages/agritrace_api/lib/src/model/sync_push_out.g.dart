// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_push_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SyncPushOut extends SyncPushOut {
  @override
  final BuiltList<SyncResult> results;
  @override
  final DateTime serverTime;

  factory _$SyncPushOut([void Function(SyncPushOutBuilder)? updates]) =>
      (SyncPushOutBuilder()..update(updates))._build();

  _$SyncPushOut._({required this.results, required this.serverTime})
      : super._();
  @override
  SyncPushOut rebuild(void Function(SyncPushOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SyncPushOutBuilder toBuilder() => SyncPushOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SyncPushOut &&
        results == other.results &&
        serverTime == other.serverTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jc(_$hash, serverTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SyncPushOut')
          ..add('results', results)
          ..add('serverTime', serverTime))
        .toString();
  }
}

class SyncPushOutBuilder implements Builder<SyncPushOut, SyncPushOutBuilder> {
  _$SyncPushOut? _$v;

  ListBuilder<SyncResult>? _results;
  ListBuilder<SyncResult> get results =>
      _$this._results ??= ListBuilder<SyncResult>();
  set results(ListBuilder<SyncResult>? results) => _$this._results = results;

  DateTime? _serverTime;
  DateTime? get serverTime => _$this._serverTime;
  set serverTime(DateTime? serverTime) => _$this._serverTime = serverTime;

  SyncPushOutBuilder() {
    SyncPushOut._defaults(this);
  }

  SyncPushOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _results = $v.results.toBuilder();
      _serverTime = $v.serverTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SyncPushOut other) {
    _$v = other as _$SyncPushOut;
  }

  @override
  void update(void Function(SyncPushOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SyncPushOut build() => _build();

  _$SyncPushOut _build() {
    _$SyncPushOut _$result;
    try {
      _$result = _$v ??
          _$SyncPushOut._(
            results: results.build(),
            serverTime: BuiltValueNullFieldError.checkNotNull(
                serverTime, r'SyncPushOut', 'serverTime'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SyncPushOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
