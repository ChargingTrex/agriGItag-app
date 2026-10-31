// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_lot_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageLotOut extends PageLotOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<LotOut> items;
  @override
  final String? nextCursor;

  factory _$PageLotOut([void Function(PageLotOutBuilder)? updates]) =>
      (PageLotOutBuilder()..update(updates))._build();

  _$PageLotOut._({required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageLotOut rebuild(void Function(PageLotOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageLotOutBuilder toBuilder() => PageLotOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageLotOut &&
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
    return (newBuiltValueToStringHelper(r'PageLotOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageLotOutBuilder implements Builder<PageLotOut, PageLotOutBuilder> {
  _$PageLotOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<LotOut>? _items;
  ListBuilder<LotOut> get items => _$this._items ??= ListBuilder<LotOut>();
  set items(ListBuilder<LotOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageLotOutBuilder() {
    PageLotOut._defaults(this);
  }

  PageLotOutBuilder get _$this {
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
  void replace(PageLotOut other) {
    _$v = other as _$PageLotOut;
  }

  @override
  void update(void Function(PageLotOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageLotOut build() => _build();

  _$PageLotOut _build() {
    _$PageLotOut _$result;
    try {
      _$result = _$v ??
          _$PageLotOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageLotOut', 'hasMore'),
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
            r'PageLotOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
