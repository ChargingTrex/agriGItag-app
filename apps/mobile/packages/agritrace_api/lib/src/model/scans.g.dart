// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scans.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Scans extends Scans {
  @override
  final int last7Days;
  @override
  final int total;

  factory _$Scans([void Function(ScansBuilder)? updates]) =>
      (ScansBuilder()..update(updates))._build();

  _$Scans._({required this.last7Days, required this.total}) : super._();
  @override
  Scans rebuild(void Function(ScansBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ScansBuilder toBuilder() => ScansBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Scans &&
        last7Days == other.last7Days &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, last7Days.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Scans')
          ..add('last7Days', last7Days)
          ..add('total', total))
        .toString();
  }
}

class ScansBuilder implements Builder<Scans, ScansBuilder> {
  _$Scans? _$v;

  int? _last7Days;
  int? get last7Days => _$this._last7Days;
  set last7Days(int? last7Days) => _$this._last7Days = last7Days;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ScansBuilder() {
    Scans._defaults(this);
  }

  ScansBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _last7Days = $v.last7Days;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Scans other) {
    _$v = other as _$Scans;
  }

  @override
  void update(void Function(ScansBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Scans build() => _build();

  _$Scans _build() {
    final _$result = _$v ??
        _$Scans._(
          last7Days: BuiltValueNullFieldError.checkNotNull(
              last7Days, r'Scans', 'last7Days'),
          total:
              BuiltValueNullFieldError.checkNotNull(total, r'Scans', 'total'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
