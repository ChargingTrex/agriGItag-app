// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_standards_profile_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageStandardsProfileOut extends PageStandardsProfileOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<StandardsProfileOut> items;
  @override
  final String? nextCursor;

  factory _$PageStandardsProfileOut(
          [void Function(PageStandardsProfileOutBuilder)? updates]) =>
      (PageStandardsProfileOutBuilder()..update(updates))._build();

  _$PageStandardsProfileOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageStandardsProfileOut rebuild(
          void Function(PageStandardsProfileOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageStandardsProfileOutBuilder toBuilder() =>
      PageStandardsProfileOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageStandardsProfileOut &&
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
    return (newBuiltValueToStringHelper(r'PageStandardsProfileOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageStandardsProfileOutBuilder
    implements
        Builder<PageStandardsProfileOut, PageStandardsProfileOutBuilder> {
  _$PageStandardsProfileOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<StandardsProfileOut>? _items;
  ListBuilder<StandardsProfileOut> get items =>
      _$this._items ??= ListBuilder<StandardsProfileOut>();
  set items(ListBuilder<StandardsProfileOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageStandardsProfileOutBuilder() {
    PageStandardsProfileOut._defaults(this);
  }

  PageStandardsProfileOutBuilder get _$this {
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
  void replace(PageStandardsProfileOut other) {
    _$v = other as _$PageStandardsProfileOut;
  }

  @override
  void update(void Function(PageStandardsProfileOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageStandardsProfileOut build() => _build();

  _$PageStandardsProfileOut _build() {
    _$PageStandardsProfileOut _$result;
    try {
      _$result = _$v ??
          _$PageStandardsProfileOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageStandardsProfileOut', 'hasMore'),
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
            r'PageStandardsProfileOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
