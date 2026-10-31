// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_batch_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageBatchOut extends PageBatchOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<BatchOut> items;
  @override
  final String? nextCursor;

  factory _$PageBatchOut([void Function(PageBatchOutBuilder)? updates]) =>
      (PageBatchOutBuilder()..update(updates))._build();

  _$PageBatchOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageBatchOut rebuild(void Function(PageBatchOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageBatchOutBuilder toBuilder() => PageBatchOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageBatchOut &&
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
    return (newBuiltValueToStringHelper(r'PageBatchOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageBatchOutBuilder
    implements Builder<PageBatchOut, PageBatchOutBuilder> {
  _$PageBatchOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<BatchOut>? _items;
  ListBuilder<BatchOut> get items => _$this._items ??= ListBuilder<BatchOut>();
  set items(ListBuilder<BatchOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageBatchOutBuilder() {
    PageBatchOut._defaults(this);
  }

  PageBatchOutBuilder get _$this {
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
  void replace(PageBatchOut other) {
    _$v = other as _$PageBatchOut;
  }

  @override
  void update(void Function(PageBatchOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageBatchOut build() => _build();

  _$PageBatchOut _build() {
    _$PageBatchOut _$result;
    try {
      _$result = _$v ??
          _$PageBatchOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageBatchOut', 'hasMore'),
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
            r'PageBatchOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
