// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producer_group_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProducerGroupOut extends ProducerGroupOut {
  @override
  final String fpoId;
  @override
  final String id;
  @override
  final ProducerGroupKind kind;
  @override
  final String name;

  factory _$ProducerGroupOut(
          [void Function(ProducerGroupOutBuilder)? updates]) =>
      (ProducerGroupOutBuilder()..update(updates))._build();

  _$ProducerGroupOut._(
      {required this.fpoId,
      required this.id,
      required this.kind,
      required this.name})
      : super._();
  @override
  ProducerGroupOut rebuild(void Function(ProducerGroupOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProducerGroupOutBuilder toBuilder() =>
      ProducerGroupOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProducerGroupOut &&
        fpoId == other.fpoId &&
        id == other.id &&
        kind == other.kind &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProducerGroupOut')
          ..add('fpoId', fpoId)
          ..add('id', id)
          ..add('kind', kind)
          ..add('name', name))
        .toString();
  }
}

class ProducerGroupOutBuilder
    implements Builder<ProducerGroupOut, ProducerGroupOutBuilder> {
  _$ProducerGroupOut? _$v;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ProducerGroupKind? _kind;
  ProducerGroupKind? get kind => _$this._kind;
  set kind(ProducerGroupKind? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ProducerGroupOutBuilder() {
    ProducerGroupOut._defaults(this);
  }

  ProducerGroupOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fpoId = $v.fpoId;
      _id = $v.id;
      _kind = $v.kind;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProducerGroupOut other) {
    _$v = other as _$ProducerGroupOut;
  }

  @override
  void update(void Function(ProducerGroupOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProducerGroupOut build() => _build();

  _$ProducerGroupOut _build() {
    final _$result = _$v ??
        _$ProducerGroupOut._(
          fpoId: BuiltValueNullFieldError.checkNotNull(
              fpoId, r'ProducerGroupOut', 'fpoId'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ProducerGroupOut', 'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'ProducerGroupOut', 'kind'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ProducerGroupOut', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
