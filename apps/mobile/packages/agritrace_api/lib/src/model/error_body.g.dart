// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_body.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorBody extends ErrorBody {
  @override
  final String code;
  @override
  final JsonObject? details;
  @override
  final String message;

  factory _$ErrorBody([void Function(ErrorBodyBuilder)? updates]) =>
      (ErrorBodyBuilder()..update(updates))._build();

  _$ErrorBody._({required this.code, this.details, required this.message})
      : super._();
  @override
  ErrorBody rebuild(void Function(ErrorBodyBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorBodyBuilder toBuilder() => ErrorBodyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorBody &&
        code == other.code &&
        details == other.details &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorBody')
          ..add('code', code)
          ..add('details', details)
          ..add('message', message))
        .toString();
  }
}

class ErrorBodyBuilder implements Builder<ErrorBody, ErrorBodyBuilder> {
  _$ErrorBody? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  JsonObject? _details;
  JsonObject? get details => _$this._details;
  set details(JsonObject? details) => _$this._details = details;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ErrorBodyBuilder() {
    ErrorBody._defaults(this);
  }

  ErrorBodyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _details = $v.details;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorBody other) {
    _$v = other as _$ErrorBody;
  }

  @override
  void update(void Function(ErrorBodyBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorBody build() => _build();

  _$ErrorBody _build() {
    final _$result = _$v ??
        _$ErrorBody._(
          code:
              BuiltValueNullFieldError.checkNotNull(code, r'ErrorBody', 'code'),
          details: details,
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'ErrorBody', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
