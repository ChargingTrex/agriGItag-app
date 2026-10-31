// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SessionOutKindEnum _$sessionOutKindEnum_session =
    const SessionOutKindEnum._('session');

SessionOutKindEnum _$sessionOutKindEnumValueOf(String name) {
  switch (name) {
    case 'session':
      return _$sessionOutKindEnum_session;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SessionOutKindEnum> _$sessionOutKindEnumValues =
    BuiltSet<SessionOutKindEnum>(const <SessionOutKindEnum>[
  _$sessionOutKindEnum_session,
]);

Serializer<SessionOutKindEnum> _$sessionOutKindEnumSerializer =
    _$SessionOutKindEnumSerializer();

class _$SessionOutKindEnumSerializer
    implements PrimitiveSerializer<SessionOutKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'session': 'session',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'session': 'session',
  };

  @override
  final Iterable<Type> types = const <Type>[SessionOutKindEnum];
  @override
  final String wireName = 'SessionOutKindEnum';

  @override
  Object serialize(Serializers serializers, SessionOutKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SessionOutKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SessionOutKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SessionOut extends SessionOut {
  @override
  final String accessToken;
  @override
  final int expiresIn;
  @override
  final String fpoId;
  @override
  final SessionOutKindEnum kind;
  @override
  final String? refreshToken;
  @override
  final BuiltList<String> roles;

  factory _$SessionOut([void Function(SessionOutBuilder)? updates]) =>
      (SessionOutBuilder()..update(updates))._build();

  _$SessionOut._(
      {required this.accessToken,
      required this.expiresIn,
      required this.fpoId,
      required this.kind,
      this.refreshToken,
      required this.roles})
      : super._();
  @override
  SessionOut rebuild(void Function(SessionOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionOutBuilder toBuilder() => SessionOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionOut &&
        accessToken == other.accessToken &&
        expiresIn == other.expiresIn &&
        fpoId == other.fpoId &&
        kind == other.kind &&
        refreshToken == other.refreshToken &&
        roles == other.roles;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, roles.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionOut')
          ..add('accessToken', accessToken)
          ..add('expiresIn', expiresIn)
          ..add('fpoId', fpoId)
          ..add('kind', kind)
          ..add('refreshToken', refreshToken)
          ..add('roles', roles))
        .toString();
  }
}

class SessionOutBuilder implements Builder<SessionOut, SessionOutBuilder> {
  _$SessionOut? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  SessionOutKindEnum? _kind;
  SessionOutKindEnum? get kind => _$this._kind;
  set kind(SessionOutKindEnum? kind) => _$this._kind = kind;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  ListBuilder<String>? _roles;
  ListBuilder<String> get roles => _$this._roles ??= ListBuilder<String>();
  set roles(ListBuilder<String>? roles) => _$this._roles = roles;

  SessionOutBuilder() {
    SessionOut._defaults(this);
  }

  SessionOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _expiresIn = $v.expiresIn;
      _fpoId = $v.fpoId;
      _kind = $v.kind;
      _refreshToken = $v.refreshToken;
      _roles = $v.roles.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionOut other) {
    _$v = other as _$SessionOut;
  }

  @override
  void update(void Function(SessionOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionOut build() => _build();

  _$SessionOut _build() {
    _$SessionOut _$result;
    try {
      _$result = _$v ??
          _$SessionOut._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'SessionOut', 'accessToken'),
            expiresIn: BuiltValueNullFieldError.checkNotNull(
                expiresIn, r'SessionOut', 'expiresIn'),
            fpoId: BuiltValueNullFieldError.checkNotNull(
                fpoId, r'SessionOut', 'fpoId'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'SessionOut', 'kind'),
            refreshToken: refreshToken,
            roles: roles.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'roles';
        roles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SessionOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
