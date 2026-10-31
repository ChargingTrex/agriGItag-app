// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'producer_group_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProducerGroupIn extends ProducerGroupIn {
  @override
  final ProducerGroupKind? kind;
  @override
  final String name;

  factory _$ProducerGroupIn([void Function(ProducerGroupInBuilder)? updates]) =>
      (ProducerGroupInBuilder()..update(updates))._build();

  _$ProducerGroupIn._({this.kind, required this.name}) : super._();
  @override
  ProducerGroupIn rebuild(void Function(ProducerGroupInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProducerGroupInBuilder toBuilder() => ProducerGroupInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProducerGroupIn && kind == other.kind && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProducerGroupIn')
          ..add('kind', kind)
          ..add('name', name))
        .toString();
  }
}

class ProducerGroupInBuilder
    implements Builder<ProducerGroupIn, ProducerGroupInBuilder> {
  _$ProducerGroupIn? _$v;

  ProducerGroupKind? _kind;
  ProducerGroupKind? get kind => _$this._kind;
  set kind(ProducerGroupKind? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ProducerGroupInBuilder() {
    ProducerGroupIn._defaults(this);
  }

  ProducerGroupInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _kind = $v.kind;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProducerGroupIn other) {
    _$v = other as _$ProducerGroupIn;
  }

  @override
  void update(void Function(ProducerGroupInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProducerGroupIn build() => _build();

  _$ProducerGroupIn _build() {
    final _$result = _$v ??
        _$ProducerGroupIn._(
          kind: kind,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ProducerGroupIn', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
