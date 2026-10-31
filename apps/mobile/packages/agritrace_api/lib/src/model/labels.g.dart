// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labels.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Labels extends Labels {
  @override
  final String en;
  @override
  final String ta;

  factory _$Labels([void Function(LabelsBuilder)? updates]) =>
      (LabelsBuilder()..update(updates))._build();

  _$Labels._({required this.en, required this.ta}) : super._();
  @override
  Labels rebuild(void Function(LabelsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LabelsBuilder toBuilder() => LabelsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Labels && en == other.en && ta == other.ta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, en.hashCode);
    _$hash = $jc(_$hash, ta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Labels')
          ..add('en', en)
          ..add('ta', ta))
        .toString();
  }
}

class LabelsBuilder implements Builder<Labels, LabelsBuilder> {
  _$Labels? _$v;

  String? _en;
  String? get en => _$this._en;
  set en(String? en) => _$this._en = en;

  String? _ta;
  String? get ta => _$this._ta;
  set ta(String? ta) => _$this._ta = ta;

  LabelsBuilder() {
    Labels._defaults(this);
  }

  LabelsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _en = $v.en;
      _ta = $v.ta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Labels other) {
    _$v = other as _$Labels;
  }

  @override
  void update(void Function(LabelsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Labels build() => _build();

  _$Labels _build() {
    final _$result = _$v ??
        _$Labels._(
          en: BuiltValueNullFieldError.checkNotNull(en, r'Labels', 'en'),
          ta: BuiltValueNullFieldError.checkNotNull(ta, r'Labels', 'ta'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
