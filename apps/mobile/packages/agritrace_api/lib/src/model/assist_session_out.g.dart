// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assist_session_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssistSessionOut extends AssistSessionOut {
  @override
  final DateTime? endedAt;
  @override
  final String farmerId;
  @override
  final String id;
  @override
  final String officerUserId;
  @override
  final DateTime startedAt;

  factory _$AssistSessionOut(
          [void Function(AssistSessionOutBuilder)? updates]) =>
      (AssistSessionOutBuilder()..update(updates))._build();

  _$AssistSessionOut._(
      {this.endedAt,
      required this.farmerId,
      required this.id,
      required this.officerUserId,
      required this.startedAt})
      : super._();
  @override
  AssistSessionOut rebuild(void Function(AssistSessionOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssistSessionOutBuilder toBuilder() =>
      AssistSessionOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssistSessionOut &&
        endedAt == other.endedAt &&
        farmerId == other.farmerId &&
        id == other.id &&
        officerUserId == other.officerUserId &&
        startedAt == other.startedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, farmerId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, officerUserId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssistSessionOut')
          ..add('endedAt', endedAt)
          ..add('farmerId', farmerId)
          ..add('id', id)
          ..add('officerUserId', officerUserId)
          ..add('startedAt', startedAt))
        .toString();
  }
}

class AssistSessionOutBuilder
    implements Builder<AssistSessionOut, AssistSessionOutBuilder> {
  _$AssistSessionOut? _$v;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  String? _farmerId;
  String? get farmerId => _$this._farmerId;
  set farmerId(String? farmerId) => _$this._farmerId = farmerId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _officerUserId;
  String? get officerUserId => _$this._officerUserId;
  set officerUserId(String? officerUserId) =>
      _$this._officerUserId = officerUserId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  AssistSessionOutBuilder() {
    AssistSessionOut._defaults(this);
  }

  AssistSessionOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _endedAt = $v.endedAt;
      _farmerId = $v.farmerId;
      _id = $v.id;
      _officerUserId = $v.officerUserId;
      _startedAt = $v.startedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssistSessionOut other) {
    _$v = other as _$AssistSessionOut;
  }

  @override
  void update(void Function(AssistSessionOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssistSessionOut build() => _build();

  _$AssistSessionOut _build() {
    final _$result = _$v ??
        _$AssistSessionOut._(
          endedAt: endedAt,
          farmerId: BuiltValueNullFieldError.checkNotNull(
              farmerId, r'AssistSessionOut', 'farmerId'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AssistSessionOut', 'id'),
          officerUserId: BuiltValueNullFieldError.checkNotNull(
              officerUserId, r'AssistSessionOut', 'officerUserId'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'AssistSessionOut', 'startedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
