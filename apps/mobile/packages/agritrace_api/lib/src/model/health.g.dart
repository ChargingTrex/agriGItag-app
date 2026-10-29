// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Health extends Health {
  @override
  final String db;
  @override
  final String redis;
  @override
  final String s3;

  factory _$Health([void Function(HealthBuilder)? updates]) =>
      (HealthBuilder()..update(updates))._build();

  _$Health._({required this.db, required this.redis, required this.s3})
      : super._();
  @override
  Health rebuild(void Function(HealthBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HealthBuilder toBuilder() => HealthBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Health &&
        db == other.db &&
        redis == other.redis &&
        s3 == other.s3;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, db.hashCode);
    _$hash = $jc(_$hash, redis.hashCode);
    _$hash = $jc(_$hash, s3.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Health')
          ..add('db', db)
          ..add('redis', redis)
          ..add('s3', s3))
        .toString();
  }
}

class HealthBuilder implements Builder<Health, HealthBuilder> {
  _$Health? _$v;

  String? _db;
  String? get db => _$this._db;
  set db(String? db) => _$this._db = db;

  String? _redis;
  String? get redis => _$this._redis;
  set redis(String? redis) => _$this._redis = redis;

  String? _s3;
  String? get s3 => _$this._s3;
  set s3(String? s3) => _$this._s3 = s3;

  HealthBuilder() {
    Health._defaults(this);
  }

  HealthBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _db = $v.db;
      _redis = $v.redis;
      _s3 = $v.s3;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Health other) {
    _$v = other as _$Health;
  }

  @override
  void update(void Function(HealthBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Health build() => _build();

  _$Health _build() {
    final _$result = _$v ??
        _$Health._(
          db: BuiltValueNullFieldError.checkNotNull(db, r'Health', 'db'),
          redis:
              BuiltValueNullFieldError.checkNotNull(redis, r'Health', 'redis'),
          s3: BuiltValueNullFieldError.checkNotNull(s3, r'Health', 's3'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
