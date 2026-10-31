// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_consent_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageConsentOut extends PageConsentOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<ConsentOut> items;
  @override
  final String? nextCursor;

  factory _$PageConsentOut([void Function(PageConsentOutBuilder)? updates]) =>
      (PageConsentOutBuilder()..update(updates))._build();

  _$PageConsentOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageConsentOut rebuild(void Function(PageConsentOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageConsentOutBuilder toBuilder() => PageConsentOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageConsentOut &&
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
    return (newBuiltValueToStringHelper(r'PageConsentOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageConsentOutBuilder
    implements Builder<PageConsentOut, PageConsentOutBuilder> {
  _$PageConsentOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<ConsentOut>? _items;
  ListBuilder<ConsentOut> get items =>
      _$this._items ??= ListBuilder<ConsentOut>();
  set items(ListBuilder<ConsentOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageConsentOutBuilder() {
    PageConsentOut._defaults(this);
  }

  PageConsentOutBuilder get _$this {
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
  void replace(PageConsentOut other) {
    _$v = other as _$PageConsentOut;
  }

  @override
  void update(void Function(PageConsentOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageConsentOut build() => _build();

  _$PageConsentOut _build() {
    _$PageConsentOut _$result;
    try {
      _$result = _$v ??
          _$PageConsentOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageConsentOut', 'hasMore'),
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
            r'PageConsentOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
