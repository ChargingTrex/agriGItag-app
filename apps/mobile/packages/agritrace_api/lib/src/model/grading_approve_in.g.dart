// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_approve_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GradingApproveIn extends GradingApproveIn {
  @override
  final QuantityInput graded;

  factory _$GradingApproveIn(
          [void Function(GradingApproveInBuilder)? updates]) =>
      (GradingApproveInBuilder()..update(updates))._build();

  _$GradingApproveIn._({required this.graded}) : super._();
  @override
  GradingApproveIn rebuild(void Function(GradingApproveInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GradingApproveInBuilder toBuilder() =>
      GradingApproveInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GradingApproveIn && graded == other.graded;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, graded.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GradingApproveIn')
          ..add('graded', graded))
        .toString();
  }
}

class GradingApproveInBuilder
    implements Builder<GradingApproveIn, GradingApproveInBuilder> {
  _$GradingApproveIn? _$v;

  QuantityInputBuilder? _graded;
  QuantityInputBuilder get graded => _$this._graded ??= QuantityInputBuilder();
  set graded(QuantityInputBuilder? graded) => _$this._graded = graded;

  GradingApproveInBuilder() {
    GradingApproveIn._defaults(this);
  }

  GradingApproveInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _graded = $v.graded.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GradingApproveIn other) {
    _$v = other as _$GradingApproveIn;
  }

  @override
  void update(void Function(GradingApproveInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GradingApproveIn build() => _build();

  _$GradingApproveIn _build() {
    _$GradingApproveIn _$result;
    try {
      _$result = _$v ??
          _$GradingApproveIn._(
            graded: graded.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'graded';
        graded.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GradingApproveIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
