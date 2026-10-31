// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_quality_reading_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageQualityReadingOut extends PageQualityReadingOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<QualityReadingOut> items;
  @override
  final String? nextCursor;

  factory _$PageQualityReadingOut(
          [void Function(PageQualityReadingOutBuilder)? updates]) =>
      (PageQualityReadingOutBuilder()..update(updates))._build();

  _$PageQualityReadingOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageQualityReadingOut rebuild(
          void Function(PageQualityReadingOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageQualityReadingOutBuilder toBuilder() =>
      PageQualityReadingOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageQualityReadingOut &&
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
    return (newBuiltValueToStringHelper(r'PageQualityReadingOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageQualityReadingOutBuilder
    implements Builder<PageQualityReadingOut, PageQualityReadingOutBuilder> {
  _$PageQualityReadingOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<QualityReadingOut>? _items;
  ListBuilder<QualityReadingOut> get items =>
      _$this._items ??= ListBuilder<QualityReadingOut>();
  set items(ListBuilder<QualityReadingOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageQualityReadingOutBuilder() {
    PageQualityReadingOut._defaults(this);
  }

  PageQualityReadingOutBuilder get _$this {
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
  void replace(PageQualityReadingOut other) {
    _$v = other as _$PageQualityReadingOut;
  }

  @override
  void update(void Function(PageQualityReadingOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageQualityReadingOut build() => _build();

  _$PageQualityReadingOut _build() {
    _$PageQualityReadingOut _$result;
    try {
      _$result = _$v ??
          _$PageQualityReadingOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageQualityReadingOut', 'hasMore'),
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
            r'PageQualityReadingOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
