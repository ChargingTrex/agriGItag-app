// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_report.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImportReport extends ImportReport {
  @override
  final int accepted;
  @override
  final bool dryRun;
  @override
  final BuiltList<ImportRowError> rejected;

  factory _$ImportReport([void Function(ImportReportBuilder)? updates]) =>
      (ImportReportBuilder()..update(updates))._build();

  _$ImportReport._(
      {required this.accepted, required this.dryRun, required this.rejected})
      : super._();
  @override
  ImportReport rebuild(void Function(ImportReportBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImportReportBuilder toBuilder() => ImportReportBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImportReport &&
        accepted == other.accepted &&
        dryRun == other.dryRun &&
        rejected == other.rejected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, dryRun.hashCode);
    _$hash = $jc(_$hash, rejected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImportReport')
          ..add('accepted', accepted)
          ..add('dryRun', dryRun)
          ..add('rejected', rejected))
        .toString();
  }
}

class ImportReportBuilder
    implements Builder<ImportReport, ImportReportBuilder> {
  _$ImportReport? _$v;

  int? _accepted;
  int? get accepted => _$this._accepted;
  set accepted(int? accepted) => _$this._accepted = accepted;

  bool? _dryRun;
  bool? get dryRun => _$this._dryRun;
  set dryRun(bool? dryRun) => _$this._dryRun = dryRun;

  ListBuilder<ImportRowError>? _rejected;
  ListBuilder<ImportRowError> get rejected =>
      _$this._rejected ??= ListBuilder<ImportRowError>();
  set rejected(ListBuilder<ImportRowError>? rejected) =>
      _$this._rejected = rejected;

  ImportReportBuilder() {
    ImportReport._defaults(this);
  }

  ImportReportBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accepted = $v.accepted;
      _dryRun = $v.dryRun;
      _rejected = $v.rejected.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImportReport other) {
    _$v = other as _$ImportReport;
  }

  @override
  void update(void Function(ImportReportBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImportReport build() => _build();

  _$ImportReport _build() {
    _$ImportReport _$result;
    try {
      _$result = _$v ??
          _$ImportReport._(
            accepted: BuiltValueNullFieldError.checkNotNull(
                accepted, r'ImportReport', 'accepted'),
            dryRun: BuiltValueNullFieldError.checkNotNull(
                dryRun, r'ImportReport', 'dryRun'),
            rejected: rejected.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rejected';
        rejected.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ImportReport', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
