// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandardRef extends StandardRef {
  @override
  final String clauseRef;
  @override
  final String edition;
  @override
  final String name;
  @override
  final String? schedule;

  factory _$StandardRef([void Function(StandardRefBuilder)? updates]) =>
      (StandardRefBuilder()..update(updates))._build();

  _$StandardRef._(
      {required this.clauseRef,
      required this.edition,
      required this.name,
      this.schedule})
      : super._();
  @override
  StandardRef rebuild(void Function(StandardRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardRefBuilder toBuilder() => StandardRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandardRef &&
        clauseRef == other.clauseRef &&
        edition == other.edition &&
        name == other.name &&
        schedule == other.schedule;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clauseRef.hashCode);
    _$hash = $jc(_$hash, edition.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, schedule.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandardRef')
          ..add('clauseRef', clauseRef)
          ..add('edition', edition)
          ..add('name', name)
          ..add('schedule', schedule))
        .toString();
  }
}

class StandardRefBuilder implements Builder<StandardRef, StandardRefBuilder> {
  _$StandardRef? _$v;

  String? _clauseRef;
  String? get clauseRef => _$this._clauseRef;
  set clauseRef(String? clauseRef) => _$this._clauseRef = clauseRef;

  String? _edition;
  String? get edition => _$this._edition;
  set edition(String? edition) => _$this._edition = edition;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _schedule;
  String? get schedule => _$this._schedule;
  set schedule(String? schedule) => _$this._schedule = schedule;

  StandardRefBuilder() {
    StandardRef._defaults(this);
  }

  StandardRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clauseRef = $v.clauseRef;
      _edition = $v.edition;
      _name = $v.name;
      _schedule = $v.schedule;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandardRef other) {
    _$v = other as _$StandardRef;
  }

  @override
  void update(void Function(StandardRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandardRef build() => _build();

  _$StandardRef _build() {
    final _$result = _$v ??
        _$StandardRef._(
          clauseRef: BuiltValueNullFieldError.checkNotNull(
              clauseRef, r'StandardRef', 'clauseRef'),
          edition: BuiltValueNullFieldError.checkNotNull(
              edition, r'StandardRef', 'edition'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'StandardRef', 'name'),
          schedule: schedule,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
