// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_audit_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageAuditRow extends PageAuditRow {
  @override
  final bool hasMore;
  @override
  final BuiltList<AuditRow> items;
  @override
  final String? nextCursor;

  factory _$PageAuditRow([void Function(PageAuditRowBuilder)? updates]) =>
      (PageAuditRowBuilder()..update(updates))._build();

  _$PageAuditRow._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageAuditRow rebuild(void Function(PageAuditRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageAuditRowBuilder toBuilder() => PageAuditRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageAuditRow &&
        hasMore == other.hasMore &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PageAuditRow')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageAuditRowBuilder
    implements Builder<PageAuditRow, PageAuditRowBuilder> {
  _$PageAuditRow? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<AuditRow>? _items;
  ListBuilder<AuditRow> get items => _$this._items ??= ListBuilder<AuditRow>();
  set items(ListBuilder<AuditRow>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageAuditRowBuilder() {
    PageAuditRow._defaults(this);
  }

  PageAuditRowBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _hasMore = $v.hasMore;
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PageAuditRow other) {
    _$v = other as _$PageAuditRow;
  }

  @override
  void update(void Function(PageAuditRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageAuditRow build() => _build();

  _$PageAuditRow _build() {
    _$PageAuditRow _$result;
    try {
      _$result = _$v ??
          _$PageAuditRow._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageAuditRow', 'hasMore'),
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PageAuditRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
