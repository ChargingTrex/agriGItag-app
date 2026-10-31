// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_farmer_row.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageFarmerRow extends PageFarmerRow {
  @override
  final bool hasMore;
  @override
  final BuiltList<FarmerRow> items;
  @override
  final String? nextCursor;

  factory _$PageFarmerRow([void Function(PageFarmerRowBuilder)? updates]) =>
      (PageFarmerRowBuilder()..update(updates))._build();

  _$PageFarmerRow._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageFarmerRow rebuild(void Function(PageFarmerRowBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageFarmerRowBuilder toBuilder() => PageFarmerRowBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageFarmerRow &&
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
    return (newBuiltValueToStringHelper(r'PageFarmerRow')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageFarmerRowBuilder
    implements Builder<PageFarmerRow, PageFarmerRowBuilder> {
  _$PageFarmerRow? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<FarmerRow>? _items;
  ListBuilder<FarmerRow> get items =>
      _$this._items ??= ListBuilder<FarmerRow>();
  set items(ListBuilder<FarmerRow>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageFarmerRowBuilder() {
    PageFarmerRow._defaults(this);
  }

  PageFarmerRowBuilder get _$this {
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
  void replace(PageFarmerRow other) {
    _$v = other as _$PageFarmerRow;
  }

  @override
  void update(void Function(PageFarmerRowBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageFarmerRow build() => _build();

  _$PageFarmerRow _build() {
    _$PageFarmerRow _$result;
    try {
      _$result = _$v ??
          _$PageFarmerRow._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageFarmerRow', 'hasMore'),
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
            r'PageFarmerRow', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
