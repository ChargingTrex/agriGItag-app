// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_farmer_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageFarmerOut extends PageFarmerOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<FarmerOut> items;
  @override
  final String? nextCursor;

  factory _$PageFarmerOut([void Function(PageFarmerOutBuilder)? updates]) =>
      (PageFarmerOutBuilder()..update(updates))._build();

  _$PageFarmerOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageFarmerOut rebuild(void Function(PageFarmerOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageFarmerOutBuilder toBuilder() => PageFarmerOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageFarmerOut &&
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
    return (newBuiltValueToStringHelper(r'PageFarmerOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageFarmerOutBuilder
    implements Builder<PageFarmerOut, PageFarmerOutBuilder> {
  _$PageFarmerOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<FarmerOut>? _items;
  ListBuilder<FarmerOut> get items =>
      _$this._items ??= ListBuilder<FarmerOut>();
  set items(ListBuilder<FarmerOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageFarmerOutBuilder() {
    PageFarmerOut._defaults(this);
  }

  PageFarmerOutBuilder get _$this {
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
  void replace(PageFarmerOut other) {
    _$v = other as _$PageFarmerOut;
  }

  @override
  void update(void Function(PageFarmerOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageFarmerOut build() => _build();

  _$PageFarmerOut _build() {
    _$PageFarmerOut _$result;
    try {
      _$result = _$v ??
          _$PageFarmerOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageFarmerOut', 'hasMore'),
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
            r'PageFarmerOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
