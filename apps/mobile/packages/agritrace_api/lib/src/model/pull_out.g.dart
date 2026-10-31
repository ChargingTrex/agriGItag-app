// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pull_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PullOut extends PullOut {
  @override
  final BuiltList<PullChange> changes;
  @override
  final bool hasMore;
  @override
  final String? nextCursor;

  factory _$PullOut([void Function(PullOutBuilder)? updates]) =>
      (PullOutBuilder()..update(updates))._build();

  _$PullOut._({required this.changes, required this.hasMore, this.nextCursor})
      : super._();
  @override
  PullOut rebuild(void Function(PullOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PullOutBuilder toBuilder() => PullOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PullOut &&
        changes == other.changes &&
        hasMore == other.hasMore &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PullOut')
          ..add('changes', changes)
          ..add('hasMore', hasMore)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PullOutBuilder implements Builder<PullOut, PullOutBuilder> {
  _$PullOut? _$v;

  ListBuilder<PullChange>? _changes;
  ListBuilder<PullChange> get changes =>
      _$this._changes ??= ListBuilder<PullChange>();
  set changes(ListBuilder<PullChange>? changes) => _$this._changes = changes;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PullOutBuilder() {
    PullOut._defaults(this);
  }

  PullOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _changes = $v.changes.toBuilder();
      _hasMore = $v.hasMore;
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PullOut other) {
    _$v = other as _$PullOut;
  }

  @override
  void update(void Function(PullOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PullOut build() => _build();

  _$PullOut _build() {
    _$PullOut _$result;
    try {
      _$result = _$v ??
          _$PullOut._(
            changes: changes.build(),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PullOut', 'hasMore'),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PullOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
