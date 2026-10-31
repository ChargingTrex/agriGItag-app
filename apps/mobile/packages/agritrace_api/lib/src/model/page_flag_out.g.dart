// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_flag_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageFlagOut extends PageFlagOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<FlagOut> items;
  @override
  final String? nextCursor;

  factory _$PageFlagOut([void Function(PageFlagOutBuilder)? updates]) =>
      (PageFlagOutBuilder()..update(updates))._build();

  _$PageFlagOut._({required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageFlagOut rebuild(void Function(PageFlagOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageFlagOutBuilder toBuilder() => PageFlagOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageFlagOut &&
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
    return (newBuiltValueToStringHelper(r'PageFlagOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageFlagOutBuilder implements Builder<PageFlagOut, PageFlagOutBuilder> {
  _$PageFlagOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<FlagOut>? _items;
  ListBuilder<FlagOut> get items => _$this._items ??= ListBuilder<FlagOut>();
  set items(ListBuilder<FlagOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageFlagOutBuilder() {
    PageFlagOut._defaults(this);
  }

  PageFlagOutBuilder get _$this {
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
  void replace(PageFlagOut other) {
    _$v = other as _$PageFlagOut;
  }

  @override
  void update(void Function(PageFlagOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageFlagOut build() => _build();

  _$PageFlagOut _build() {
    _$PageFlagOut _$result;
    try {
      _$result = _$v ??
          _$PageFlagOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageFlagOut', 'hasMore'),
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
            r'PageFlagOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
