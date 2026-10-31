// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_event_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageEventOut extends PageEventOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<EventOut> items;
  @override
  final String? nextCursor;

  factory _$PageEventOut([void Function(PageEventOutBuilder)? updates]) =>
      (PageEventOutBuilder()..update(updates))._build();

  _$PageEventOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageEventOut rebuild(void Function(PageEventOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageEventOutBuilder toBuilder() => PageEventOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageEventOut &&
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
    return (newBuiltValueToStringHelper(r'PageEventOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageEventOutBuilder
    implements Builder<PageEventOut, PageEventOutBuilder> {
  _$PageEventOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<EventOut>? _items;
  ListBuilder<EventOut> get items => _$this._items ??= ListBuilder<EventOut>();
  set items(ListBuilder<EventOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageEventOutBuilder() {
    PageEventOut._defaults(this);
  }

  PageEventOutBuilder get _$this {
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
  void replace(PageEventOut other) {
    _$v = other as _$PageEventOut;
  }

  @override
  void update(void Function(PageEventOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageEventOut build() => _build();

  _$PageEventOut _build() {
    _$PageEventOut _$result;
    try {
      _$result = _$v ??
          _$PageEventOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageEventOut', 'hasMore'),
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
            r'PageEventOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
