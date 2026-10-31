// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assist_start_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssistStartIn extends AssistStartIn {
  @override
  final String clientId;
  @override
  final String farmerId;
  @override
  final DateTime? startedAt;
  @override
  final GeoPoint? startedGps;

  factory _$AssistStartIn([void Function(AssistStartInBuilder)? updates]) =>
      (AssistStartInBuilder()..update(updates))._build();

  _$AssistStartIn._(
      {required this.clientId,
      required this.farmerId,
      this.startedAt,
      this.startedGps})
      : super._();
  @override
  AssistStartIn rebuild(void Function(AssistStartInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssistStartInBuilder toBuilder() => AssistStartInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssistStartIn &&
        clientId == other.clientId &&
        farmerId == other.farmerId &&
        startedAt == other.startedAt &&
        startedGps == other.startedGps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, startedGps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssistStartIn')
          ..add('clientId', clientId)
          ..add('farmerId', farmerId)
          ..add('startedAt', startedAt)
          ..add('startedGps', startedGps))
        .toString();
  }
}

class AssistStartInBuilder
    implements Builder<AssistStartIn, AssistStartInBuilder> {
  _$AssistStartIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  GeoPointBuilder? _startedGps;
  GeoPointBuilder get startedGps => _$this._startedGps ??= GeoPointBuilder();
  set startedGps(GeoPointBuilder? startedGps) =>
      _$this._startedGps = startedGps;

  AssistStartInBuilder() {
    AssistStartIn._defaults(this);
  }

  AssistStartInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _farmerId = $v.farmerId;
      _startedAt = $v.startedAt;
      _startedGps = $v.startedGps?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssistStartIn other) {
    _$v = other as _$AssistStartIn;
  }

  @override
  void update(void Function(AssistStartInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssistStartIn build() => _build();

  _$AssistStartIn _build() {
    _$AssistStartIn _$result;
    try {
      _$result = _$v ??
          _$AssistStartIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'AssistStartIn', 'clientId'),
            farmerId: BuiltValueNullFieldError.checkNotNull(
                farmerId, r'AssistStartIn', 'farmerId'),
            startedAt: startedAt,
            startedGps: _startedGps?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'startedGps';
        _startedGps?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AssistStartIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
