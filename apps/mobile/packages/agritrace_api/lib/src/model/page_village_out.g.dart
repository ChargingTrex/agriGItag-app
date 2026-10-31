// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_village_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageVillageOut extends PageVillageOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<VillageOut> items;
  @override
  final String? nextCursor;

  factory _$PageVillageOut([void Function(PageVillageOutBuilder)? updates]) =>
      (PageVillageOutBuilder()..update(updates))._build();

  _$PageVillageOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageVillageOut rebuild(void Function(PageVillageOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageVillageOutBuilder toBuilder() => PageVillageOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageVillageOut &&
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
    return (newBuiltValueToStringHelper(r'PageVillageOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageVillageOutBuilder
    implements Builder<PageVillageOut, PageVillageOutBuilder> {
  _$PageVillageOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<VillageOut>? _items;
  ListBuilder<VillageOut> get items =>
      _$this._items ??= ListBuilder<VillageOut>();
  set items(ListBuilder<VillageOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageVillageOutBuilder() {
    PageVillageOut._defaults(this);
  }

  PageVillageOutBuilder get _$this {
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
  void replace(PageVillageOut other) {
    _$v = other as _$PageVillageOut;
  }

  @override
  void update(void Function(PageVillageOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageVillageOut build() => _build();

  _$PageVillageOut _build() {
    _$PageVillageOut _$result;
    try {
      _$result = _$v ??
          _$PageVillageOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageVillageOut', 'hasMore'),
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
            r'PageVillageOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
