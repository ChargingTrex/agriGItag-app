// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_version_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileVersionOut extends ProfileVersionOut {
  @override
  final String clauseRef;
  @override
  final String edition;
  @override
  final String id;
  @override
  final String profileId;
  @override
  final DateTime? publishedAt;
  @override
  final StandardsProfileRulesOutput rules;
  @override
  final ProfileVersionStatus status;
  @override
  final int versionNo;

  factory _$ProfileVersionOut(
          [void Function(ProfileVersionOutBuilder)? updates]) =>
      (ProfileVersionOutBuilder()..update(updates))._build();

  _$ProfileVersionOut._(
      {required this.clauseRef,
      required this.edition,
      required this.id,
      required this.profileId,
      this.publishedAt,
      required this.rules,
      required this.status,
      required this.versionNo})
      : super._();
  @override
  ProfileVersionOut rebuild(void Function(ProfileVersionOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileVersionOutBuilder toBuilder() =>
      ProfileVersionOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileVersionOut &&
        clauseRef == other.clauseRef &&
        edition == other.edition &&
        id == other.id &&
        profileId == other.profileId &&
        publishedAt == other.publishedAt &&
        rules == other.rules &&
        status == other.status &&
        versionNo == other.versionNo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clauseRef.hashCode);
    _$hash = $jc(_$hash, edition.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, profileId.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jc(_$hash, rules.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, versionNo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileVersionOut')
          ..add('clauseRef', clauseRef)
          ..add('edition', edition)
          ..add('id', id)
          ..add('profileId', profileId)
          ..add('publishedAt', publishedAt)
          ..add('rules', rules)
          ..add('status', status)
          ..add('versionNo', versionNo))
        .toString();
  }
}

class ProfileVersionOutBuilder
    implements Builder<ProfileVersionOut, ProfileVersionOutBuilder> {
  _$ProfileVersionOut? _$v;

  String? _clauseRef;
  String? get clauseRef => _$this._clauseRef;
  set clauseRef(String? clauseRef) => _$this._clauseRef = clauseRef;

  String? _edition;
  String? get edition => _$this._edition;
  set edition(String? edition) => _$this._edition = edition;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _profileId;
  String? get profileId => _$this._profileId;
  set profileId(String? profileId) => _$this._profileId = profileId;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  StandardsProfileRulesOutputBuilder? _rules;
  StandardsProfileRulesOutputBuilder get rules =>
      _$this._rules ??= StandardsProfileRulesOutputBuilder();
  set rules(StandardsProfileRulesOutputBuilder? rules) => _$this._rules = rules;

  ProfileVersionStatus? _status;
  ProfileVersionStatus? get status => _$this._status;
  set status(ProfileVersionStatus? status) => _$this._status = status;

  int? _versionNo;
  int? get versionNo => _$this._versionNo;
  set versionNo(int? versionNo) => _$this._versionNo = versionNo;

  ProfileVersionOutBuilder() {
    ProfileVersionOut._defaults(this);
  }

  ProfileVersionOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clauseRef = $v.clauseRef;
      _edition = $v.edition;
      _id = $v.id;
      _profileId = $v.profileId;
      _publishedAt = $v.publishedAt;
      _rules = $v.rules.toBuilder();
      _status = $v.status;
      _versionNo = $v.versionNo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileVersionOut other) {
    _$v = other as _$ProfileVersionOut;
  }

  @override
  void update(void Function(ProfileVersionOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileVersionOut build() => _build();

  _$ProfileVersionOut _build() {
    _$ProfileVersionOut _$result;
    try {
      _$result = _$v ??
          _$ProfileVersionOut._(
            clauseRef: BuiltValueNullFieldError.checkNotNull(
                clauseRef, r'ProfileVersionOut', 'clauseRef'),
            edition: BuiltValueNullFieldError.checkNotNull(
                edition, r'ProfileVersionOut', 'edition'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ProfileVersionOut', 'id'),
            profileId: BuiltValueNullFieldError.checkNotNull(
                profileId, r'ProfileVersionOut', 'profileId'),
            publishedAt: publishedAt,
            rules: rules.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ProfileVersionOut', 'status'),
            versionNo: BuiltValueNullFieldError.checkNotNull(
                versionNo, r'ProfileVersionOut', 'versionNo'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rules';
        rules.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProfileVersionOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
