// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BuildOut extends BuildOut {
  @override
  final String batchId;
  @override
  final int buildNo;
  @override
  final DateTime? builtAt;
  @override
  final BuiltMap<String, JsonObject?>? error;
  @override
  final int generation;
  @override
  final String? htmlKey;
  @override
  final String id;
  @override
  final String? jsonKey;
  @override
  final String? qrKey;
  @override
  final String status;
  @override
  final String trigger;

  factory _$BuildOut([void Function(BuildOutBuilder)? updates]) =>
      (BuildOutBuilder()..update(updates))._build();

  _$BuildOut._(
      {required this.batchId,
      required this.buildNo,
      this.builtAt,
      this.error,
      required this.generation,
      this.htmlKey,
      required this.id,
      this.jsonKey,
      this.qrKey,
      required this.status,
      required this.trigger})
      : super._();
  @override
  BuildOut rebuild(void Function(BuildOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuildOutBuilder toBuilder() => BuildOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuildOut &&
        batchId == other.batchId &&
        buildNo == other.buildNo &&
        builtAt == other.builtAt &&
        error == other.error &&
        generation == other.generation &&
        htmlKey == other.htmlKey &&
        id == other.id &&
        jsonKey == other.jsonKey &&
        qrKey == other.qrKey &&
        status == other.status &&
        trigger == other.trigger;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, buildNo.hashCode);
    _$hash = $jc(_$hash, builtAt.hashCode);
    _$hash = $jc(_$hash, error.hashCode);
    _$hash = $jc(_$hash, generation.hashCode);
    _$hash = $jc(_$hash, htmlKey.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, jsonKey.hashCode);
    _$hash = $jc(_$hash, qrKey.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trigger.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuildOut')
          ..add('batchId', batchId)
          ..add('buildNo', buildNo)
          ..add('builtAt', builtAt)
          ..add('error', error)
          ..add('generation', generation)
          ..add('htmlKey', htmlKey)
          ..add('id', id)
          ..add('jsonKey', jsonKey)
          ..add('qrKey', qrKey)
          ..add('status', status)
          ..add('trigger', trigger))
        .toString();
  }
}

class BuildOutBuilder implements Builder<BuildOut, BuildOutBuilder> {
  _$BuildOut? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  int? _buildNo;
  int? get buildNo => _$this._buildNo;
  set buildNo(int? buildNo) => _$this._buildNo = buildNo;

  DateTime? _builtAt;
  DateTime? get builtAt => _$this._builtAt;
  set builtAt(DateTime? builtAt) => _$this._builtAt = builtAt;

  MapBuilder<String, JsonObject?>? _error;
  MapBuilder<String, JsonObject?> get error =>
      _$this._error ??= MapBuilder<String, JsonObject?>();
  set error(MapBuilder<String, JsonObject?>? error) => _$this._error = error;

  int? _generation;
  int? get generation => _$this._generation;
  set generation(int? generation) => _$this._generation = generation;

  String? _htmlKey;
  String? get htmlKey => _$this._htmlKey;
  set htmlKey(String? htmlKey) => _$this._htmlKey = htmlKey;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _jsonKey;
  String? get jsonKey => _$this._jsonKey;
  set jsonKey(String? jsonKey) => _$this._jsonKey = jsonKey;

  String? _qrKey;
  String? get qrKey => _$this._qrKey;
  set qrKey(String? qrKey) => _$this._qrKey = qrKey;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _trigger;
  String? get trigger => _$this._trigger;
  set trigger(String? trigger) => _$this._trigger = trigger;

  BuildOutBuilder() {
    BuildOut._defaults(this);
  }

  BuildOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _buildNo = $v.buildNo;
      _builtAt = $v.builtAt;
      _error = $v.error?.toBuilder();
      _generation = $v.generation;
      _htmlKey = $v.htmlKey;
      _id = $v.id;
      _jsonKey = $v.jsonKey;
      _qrKey = $v.qrKey;
      _status = $v.status;
      _trigger = $v.trigger;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuildOut other) {
    _$v = other as _$BuildOut;
  }

  @override
  void update(void Function(BuildOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuildOut build() => _build();

  _$BuildOut _build() {
    _$BuildOut _$result;
    try {
      _$result = _$v ??
          _$BuildOut._(
            batchId: BuiltValueNullFieldError.checkNotNull(
                batchId, r'BuildOut', 'batchId'),
            buildNo: BuiltValueNullFieldError.checkNotNull(
                buildNo, r'BuildOut', 'buildNo'),
            builtAt: builtAt,
            error: _error?.build(),
            generation: BuiltValueNullFieldError.checkNotNull(
                generation, r'BuildOut', 'generation'),
            htmlKey: htmlKey,
            id: BuiltValueNullFieldError.checkNotNull(id, r'BuildOut', 'id'),
            jsonKey: jsonKey,
            qrKey: qrKey,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'BuildOut', 'status'),
            trigger: BuiltValueNullFieldError.checkNotNull(
                trigger, r'BuildOut', 'trigger'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'error';
        _error?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BuildOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
