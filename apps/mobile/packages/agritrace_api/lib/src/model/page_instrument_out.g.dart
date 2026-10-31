// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_instrument_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageInstrumentOut extends PageInstrumentOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<InstrumentOut> items;
  @override
  final String? nextCursor;

  factory _$PageInstrumentOut(
          [void Function(PageInstrumentOutBuilder)? updates]) =>
      (PageInstrumentOutBuilder()..update(updates))._build();

  _$PageInstrumentOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageInstrumentOut rebuild(void Function(PageInstrumentOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageInstrumentOutBuilder toBuilder() =>
      PageInstrumentOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageInstrumentOut &&
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
    return (newBuiltValueToStringHelper(r'PageInstrumentOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageInstrumentOutBuilder
    implements Builder<PageInstrumentOut, PageInstrumentOutBuilder> {
  _$PageInstrumentOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<InstrumentOut>? _items;
  ListBuilder<InstrumentOut> get items =>
      _$this._items ??= ListBuilder<InstrumentOut>();
  set items(ListBuilder<InstrumentOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageInstrumentOutBuilder() {
    PageInstrumentOut._defaults(this);
  }

  PageInstrumentOutBuilder get _$this {
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
  void replace(PageInstrumentOut other) {
    _$v = other as _$PageInstrumentOut;
  }

  @override
  void update(void Function(PageInstrumentOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageInstrumentOut build() => _build();

  _$PageInstrumentOut _build() {
    _$PageInstrumentOut _$result;
    try {
      _$result = _$v ??
          _$PageInstrumentOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageInstrumentOut', 'hasMore'),
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
            r'PageInstrumentOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
