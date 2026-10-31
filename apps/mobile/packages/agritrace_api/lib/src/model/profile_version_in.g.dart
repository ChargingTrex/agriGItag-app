// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_version_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ProfileVersionInStatusEnum _$profileVersionInStatusEnum_draft =
    const ProfileVersionInStatusEnum._('draft');
const ProfileVersionInStatusEnum _$profileVersionInStatusEnum_published =
    const ProfileVersionInStatusEnum._('published');

ProfileVersionInStatusEnum _$profileVersionInStatusEnumValueOf(String name) {
  switch (name) {
    case 'draft':
      return _$profileVersionInStatusEnum_draft;
    case 'published':
      return _$profileVersionInStatusEnum_published;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ProfileVersionInStatusEnum> _$profileVersionInStatusEnumValues =
    BuiltSet<ProfileVersionInStatusEnum>(const <ProfileVersionInStatusEnum>[
  _$profileVersionInStatusEnum_draft,
  _$profileVersionInStatusEnum_published,
]);

Serializer<ProfileVersionInStatusEnum> _$profileVersionInStatusEnumSerializer =
    _$ProfileVersionInStatusEnumSerializer();

class _$ProfileVersionInStatusEnumSerializer
    implements PrimitiveSerializer<ProfileVersionInStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'draft': 'draft',
    'published': 'published',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'draft': 'draft',
    'published': 'published',
  };

  @override
  final Iterable<Type> types = const <Type>[ProfileVersionInStatusEnum];
  @override
  final String wireName = 'ProfileVersionInStatusEnum';

  @override
  Object serialize(Serializers serializers, ProfileVersionInStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ProfileVersionInStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ProfileVersionInStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ProfileVersionIn extends ProfileVersionIn {
  @override
  final bool? allowIncomplete;
  @override
  final StandardsProfileRulesInput rules;
  @override
  final ProfileVersionInStatusEnum? status;

  factory _$ProfileVersionIn(
          [void Function(ProfileVersionInBuilder)? updates]) =>
      (ProfileVersionInBuilder()..update(updates))._build();

  _$ProfileVersionIn._({this.allowIncomplete, required this.rules, this.status})
      : super._();
  @override
  ProfileVersionIn rebuild(void Function(ProfileVersionInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileVersionInBuilder toBuilder() =>
      ProfileVersionInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileVersionIn &&
        allowIncomplete == other.allowIncomplete &&
        rules == other.rules &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, allowIncomplete.hashCode);
    _$hash = $jc(_$hash, rules.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileVersionIn')
          ..add('allowIncomplete', allowIncomplete)
          ..add('rules', rules)
          ..add('status', status))
        .toString();
  }
}

class ProfileVersionInBuilder
    implements Builder<ProfileVersionIn, ProfileVersionInBuilder> {
  _$ProfileVersionIn? _$v;

  bool? _allowIncomplete;
  bool? get allowIncomplete => _$this._allowIncomplete;
  set allowIncomplete(bool? allowIncomplete) =>
      _$this._allowIncomplete = allowIncomplete;

  StandardsProfileRulesInputBuilder? _rules;
  StandardsProfileRulesInputBuilder get rules =>
      _$this._rules ??= StandardsProfileRulesInputBuilder();
  set rules(StandardsProfileRulesInputBuilder? rules) => _$this._rules = rules;

  ProfileVersionInStatusEnum? _status;
  ProfileVersionInStatusEnum? get status => _$this._status;
  set status(ProfileVersionInStatusEnum? status) => _$this._status = status;

  ProfileVersionInBuilder() {
    ProfileVersionIn._defaults(this);
  }

  ProfileVersionInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _allowIncomplete = $v.allowIncomplete;
      _rules = $v.rules.toBuilder();
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileVersionIn other) {
    _$v = other as _$ProfileVersionIn;
  }

  @override
  void update(void Function(ProfileVersionInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileVersionIn build() => _build();

  _$ProfileVersionIn _build() {
    _$ProfileVersionIn _$result;
    try {
      _$result = _$v ??
          _$ProfileVersionIn._(
            allowIncomplete: allowIncomplete,
            rules: rules.build(),
            status: status,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rules';
        rules.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProfileVersionIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
