// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MembershipOut extends MembershipOut {
  @override
  final String fpoId;
  @override
  final Role role;

  factory _$MembershipOut([void Function(MembershipOutBuilder)? updates]) =>
      (MembershipOutBuilder()..update(updates))._build();

  _$MembershipOut._({required this.fpoId, required this.role}) : super._();
  @override
  MembershipOut rebuild(void Function(MembershipOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MembershipOutBuilder toBuilder() => MembershipOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MembershipOut && fpoId == other.fpoId && role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MembershipOut')
          ..add('fpoId', fpoId)
          ..add('role', role))
        .toString();
  }
}

class MembershipOutBuilder
    implements Builder<MembershipOut, MembershipOutBuilder> {
  _$MembershipOut? _$v;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  Role? _role;
  Role? get role => _$this._role;
  set role(Role? role) => _$this._role = role;

  MembershipOutBuilder() {
    MembershipOut._defaults(this);
  }

  MembershipOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fpoId = $v.fpoId;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MembershipOut other) {
    _$v = other as _$MembershipOut;
  }

  @override
  void update(void Function(MembershipOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MembershipOut build() => _build();

  _$MembershipOut _build() {
    final _$result = _$v ??
        _$MembershipOut._(
          fpoId: BuiltValueNullFieldError.checkNotNull(
              fpoId, r'MembershipOut', 'fpoId'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'MembershipOut', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
