// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_build_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageBuildOut extends PageBuildOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<BuildOut> items;
  @override
  final String? nextCursor;

  factory _$PageBuildOut([void Function(PageBuildOutBuilder)? updates]) =>
      (PageBuildOutBuilder()..update(updates))._build();

  _$PageBuildOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageBuildOut rebuild(void Function(PageBuildOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageBuildOutBuilder toBuilder() => PageBuildOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageBuildOut &&
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
    return (newBuiltValueToStringHelper(r'PageBuildOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageBuildOutBuilder
    implements Builder<PageBuildOut, PageBuildOutBuilder> {
  _$PageBuildOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<BuildOut>? _items;
  ListBuilder<BuildOut> get items => _$this._items ??= ListBuilder<BuildOut>();
  set items(ListBuilder<BuildOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageBuildOutBuilder() {
    PageBuildOut._defaults(this);
  }

  PageBuildOutBuilder get _$this {
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
  void replace(PageBuildOut other) {
    _$v = other as _$PageBuildOut;
  }

  @override
  void update(void Function(PageBuildOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageBuildOut build() => _build();

  _$PageBuildOut _build() {
    _$PageBuildOut _$result;
    try {
      _$result = _$v ??
          _$PageBuildOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageBuildOut', 'hasMore'),
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
            r'PageBuildOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
