// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuditRow extends AuditRow {
  @override
  final String action;
  @override
  final String? actorUserId;
  @override
  final String? assistSessionId;
  @override
  final DateTime at;
  @override
  final BuiltMap<String, JsonObject?> diff;
  @override
  final String? entityId;
  @override
  final String entityType;
  @override
  final String id;
  @override
  final String? onBehalfOfFarmerId;
  @override
  final String? requestId;

  factory _$AuditRow([void Function(AuditRowBuilder)? updates]) =>
      (AuditRowBuilder()..update(updates))._build();

  _$AuditRow._(
      {required this.action,
      this.actorUserId,
      this.assistSessionId,
      required this.at,
      required this.diff,
      this.entityId,
      required this.entityType,
      required this.id,
      this.onBehalfOfFarmerId,
      this.requestId})
      : super._();
  @override
  AuditRow rebuild(void Function(AuditRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuditRowBuilder toBuilder() => AuditRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuditRow &&
        action == other.action &&
        actorUserId == other.actorUserId &&
        assistSessionId == other.assistSessionId &&
        at == other.at &&
        diff == other.diff &&
        entityId == other.entityId &&
        entityType == other.entityType &&
        id == other.id &&
        onBehalfOfFarmerId == other.onBehalfOfFarmerId &&
        requestId == other.requestId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actorUserId.hashCode);
    _$hash = $jc(_$hash, assistSessionId.hashCode);
    _$hash = $jc(_$hash, at.hashCode);
    _$hash = $jc(_$hash, diff.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, onBehalfOfFarmerId.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuditRow')
          ..add('action', action)
          ..add('actorUserId', actorUserId)
          ..add('assistSessionId', assistSessionId)
          ..add('at', at)
          ..add('diff', diff)
          ..add('entityId', entityId)
          ..add('entityType', entityType)
          ..add('id', id)
          ..add('onBehalfOfFarmerId', onBehalfOfFarmerId)
          ..add('requestId', requestId))
        .toString();
  }
}

class AuditRowBuilder implements Builder<AuditRow, AuditRowBuilder> {
  _$AuditRow? _$v;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _actorUserId;
  String? get actorUserId => _$this._actorUserId;
  set actorUserId(String? actorUserId) => _$this._actorUserId = actorUserId;

  String? _assistSessionId;
  String? get assistSessionId => _$this._assistSessionId;
  set assistSessionId(String? assistSessionId) =>
      _$this._assistSessionId = assistSessionId;

  DateTime? _at;
  DateTime? get at => _$this._at;
  set at(DateTime? at) => _$this._at = at;

  MapBuilder<String, JsonObject?>? _diff;
  MapBuilder<String, JsonObject?> get diff =>
      _$this._diff ??= MapBuilder<String, JsonObject?>();
  set diff(MapBuilder<String, JsonObject?>? diff) => _$this._diff = diff;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  String? _entityType;
  String? get entityType => _$this._entityType;
  set entityType(String? entityType) => _$this._entityType = entityType;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _onBehalfOfFarmerId;
  String? get onBehalfOfFarmerId => _$this._onBehalfOfFarmerId;
  set onBehalfOfFarmerId(String? onBehalfOfFarmerId) =>
      _$this._onBehalfOfFarmerId = onBehalfOfFarmerId;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  AuditRowBuilder() {
    AuditRow._defaults(this);
  }

  AuditRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _actorUserId = $v.actorUserId;
      _assistSessionId = $v.assistSessionId;
      _at = $v.at;
      _diff = $v.diff.toBuilder();
      _entityId = $v.entityId;
      _entityType = $v.entityType;
      _id = $v.id;
      _onBehalfOfFarmerId = $v.onBehalfOfFarmerId;
      _requestId = $v.requestId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuditRow other) {
    _$v = other as _$AuditRow;
  }

  @override
  void update(void Function(AuditRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuditRow build() => _build();

  _$AuditRow _build() {
    _$AuditRow _$result;
    try {
      _$result = _$v ??
          _$AuditRow._(
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'AuditRow', 'action'),
            actorUserId: actorUserId,
            assistSessionId: assistSessionId,
            at: BuiltValueNullFieldError.checkNotNull(at, r'AuditRow', 'at'),
            diff: diff.build(),
            entityId: entityId,
            entityType: BuiltValueNullFieldError.checkNotNull(
                entityType, r'AuditRow', 'entityType'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'AuditRow', 'id'),
            onBehalfOfFarmerId: onBehalfOfFarmerId,
            requestId: requestId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'diff';
        diff.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuditRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
