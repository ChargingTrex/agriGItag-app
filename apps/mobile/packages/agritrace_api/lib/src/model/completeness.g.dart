// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completeness.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Completeness extends Completeness {
  @override
  final QuantityOutput? complete;
  @override
  final int completeLots;
  @override
  final int lots;

  factory _$Completeness([void Function(CompletenessBuilder)? updates]) =>
      (CompletenessBuilder()..update(updates))._build();

  _$Completeness._(
      {this.complete, required this.completeLots, required this.lots})
      : super._();
  @override
  Completeness rebuild(void Function(CompletenessBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompletenessBuilder toBuilder() => CompletenessBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Completeness &&
        complete == other.complete &&
        completeLots == other.completeLots &&
        lots == other.lots;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, complete.hashCode);
    _$hash = $jc(_$hash, completeLots.hashCode);
    _$hash = $jc(_$hash, lots.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Completeness')
          ..add('complete', complete)
          ..add('completeLots', completeLots)
          ..add('lots', lots))
        .toString();
  }
}

class CompletenessBuilder
    implements Builder<Completeness, CompletenessBuilder> {
  _$Completeness? _$v;

  QuantityOutputBuilder? _complete;
  QuantityOutputBuilder get complete =>
      _$this._complete ??= QuantityOutputBuilder();
  set complete(QuantityOutputBuilder? complete) => _$this._complete = complete;

  int? _completeLots;
  int? get completeLots => _$this._completeLots;
  set completeLots(int? completeLots) => _$this._completeLots = completeLots;

  int? _lots;
  int? get lots => _$this._lots;
  set lots(int? lots) => _$this._lots = lots;

  CompletenessBuilder() {
    Completeness._defaults(this);
  }

  CompletenessBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _complete = $v.complete?.toBuilder();
      _completeLots = $v.completeLots;
      _lots = $v.lots;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Completeness other) {
    _$v = other as _$Completeness;
  }

  @override
  void update(void Function(CompletenessBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Completeness build() => _build();

  _$Completeness _build() {
    _$Completeness _$result;
    try {
      _$result = _$v ??
          _$Completeness._(
            complete: _complete?.build(),
            completeLots: BuiltValueNullFieldError.checkNotNull(
                completeLots, r'Completeness', 'completeLots'),
            lots: BuiltValueNullFieldError.checkNotNull(
                lots, r'Completeness', 'lots'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'complete';
        _complete?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Completeness', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
