// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_row_error.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportRowError extends ImportRowError {
  @override
  final String code;
  @override
  final String? field;
  @override
  final int row;

  factory _$ImportRowError([void Function(ImportRowErrorBuilder)? updates]) =>
      (ImportRowErrorBuilder()..update(updates))._build();

  _$ImportRowError._({required this.code, this.field, required this.row})
      : super._();
  @override
  ImportRowError rebuild(void Function(ImportRowErrorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportRowErrorBuilder toBuilder() => ImportRowErrorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportRowError &&
        code == other.code &&
        field == other.field &&
        row == other.row;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jc(_$hash, row.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportRowError')
          ..add('code', code)
          ..add('field', field)
          ..add('row', row))
        .toString();
  }
}

class ImportRowErrorBuilder
    implements Builder<ImportRowError, ImportRowErrorBuilder> {
  _$ImportRowError? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _field;
  String? get field => _$this._field;
  set field(String? field) => _$this._field = field;

  int? _row;
  int? get row => _$this._row;
  set row(int? row) => _$this._row = row;

  ImportRowErrorBuilder() {
    ImportRowError._defaults(this);
  }

  ImportRowErrorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _field = $v.field;
      _row = $v.row;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportRowError other) {
    _$v = other as _$ImportRowError;
  }

  @override
  void update(void Function(ImportRowErrorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportRowError build() => _build();

  _$ImportRowError _build() {
    final _$result = _$v ??
        _$ImportRowError._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ImportRowError', 'code'),
          field: field,
          row: BuiltValueNullFieldError.checkNotNull(
              row, r'ImportRowError', 'row'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
