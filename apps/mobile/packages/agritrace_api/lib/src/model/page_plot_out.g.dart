// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_plot_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PagePlotOut extends PagePlotOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<PlotOut> items;
  @override
  final String? nextCursor;

  factory _$PagePlotOut([void Function(PagePlotOutBuilder)? updates]) =>
      (PagePlotOutBuilder()..update(updates))._build();

  _$PagePlotOut._({required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PagePlotOut rebuild(void Function(PagePlotOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PagePlotOutBuilder toBuilder() => PagePlotOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PagePlotOut &&
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
    return (newBuiltValueToStringHelper(r'PagePlotOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PagePlotOutBuilder implements Builder<PagePlotOut, PagePlotOutBuilder> {
  _$PagePlotOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<PlotOut>? _items;
  ListBuilder<PlotOut> get items => _$this._items ??= ListBuilder<PlotOut>();
  set items(ListBuilder<PlotOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PagePlotOutBuilder() {
    PagePlotOut._defaults(this);
  }

  PagePlotOutBuilder get _$this {
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
  void replace(PagePlotOut other) {
    _$v = other as _$PagePlotOut;
  }

  @override
  void update(void Function(PagePlotOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PagePlotOut build() => _build();

  _$PagePlotOut _build() {
    _$PagePlotOut _$result;
    try {
      _$result = _$v ??
          _$PagePlotOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PagePlotOut', 'hasMore'),
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
            r'PagePlotOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
