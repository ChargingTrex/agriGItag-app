// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GradingIn extends GradingIn {
  @override
  final String declaredGrade;
  @override
  final BuiltList<String>? readingIds;
  @override
  final BuiltList<QualityReadingIn>? readings;

  factory _$GradingIn([void Function(GradingInBuilder)? updates]) =>
      (GradingInBuilder()..update(updates))._build();

  _$GradingIn._({required this.declaredGrade, this.readingIds, this.readings})
      : super._();
  @override
  GradingIn rebuild(void Function(GradingInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GradingInBuilder toBuilder() => GradingInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GradingIn &&
        declaredGrade == other.declaredGrade &&
        readingIds == other.readingIds &&
        readings == other.readings;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, declaredGrade.hashCode);
    _$hash = $jc(_$hash, readingIds.hashCode);
    _$hash = $jc(_$hash, readings.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GradingIn')
          ..add('declaredGrade', declaredGrade)
          ..add('readingIds', readingIds)
          ..add('readings', readings))
        .toString();
  }
}

class GradingInBuilder implements Builder<GradingIn, GradingInBuilder> {
  _$GradingIn? _$v;

  String? _declaredGrade;
  String? get declaredGrade => _$this._declaredGrade;
  set declaredGrade(String? declaredGrade) =>
      _$this._declaredGrade = declaredGrade;

  ListBuilder<String>? _readingIds;
  ListBuilder<String> get readingIds =>
      _$this._readingIds ??= ListBuilder<String>();
  set readingIds(ListBuilder<String>? readingIds) =>
      _$this._readingIds = readingIds;

  ListBuilder<QualityReadingIn>? _readings;
  ListBuilder<QualityReadingIn> get readings =>
      _$this._readings ??= ListBuilder<QualityReadingIn>();
  set readings(ListBuilder<QualityReadingIn>? readings) =>
      _$this._readings = readings;

  GradingInBuilder() {
    GradingIn._defaults(this);
  }

  GradingInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _declaredGrade = $v.declaredGrade;
      _readingIds = $v.readingIds?.toBuilder();
      _readings = $v.readings?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GradingIn other) {
    _$v = other as _$GradingIn;
  }

  @override
  void update(void Function(GradingInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GradingIn build() => _build();

  _$GradingIn _build() {
    _$GradingIn _$result;
    try {
      _$result = _$v ??
          _$GradingIn._(
            declaredGrade: BuiltValueNullFieldError.checkNotNull(
                declaredGrade, r'GradingIn', 'declaredGrade'),
            readingIds: _readingIds?.build(),
            readings: _readings?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'readingIds';
        _readingIds?.build();
        _$failedField = 'readings';
        _readings?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GradingIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
