// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_notification_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PageNotificationOut extends PageNotificationOut {
  @override
  final bool hasMore;
  @override
  final BuiltList<NotificationOut> items;
  @override
  final String? nextCursor;

  factory _$PageNotificationOut(
          [void Function(PageNotificationOutBuilder)? updates]) =>
      (PageNotificationOutBuilder()..update(updates))._build();

  _$PageNotificationOut._(
      {required this.hasMore, required this.items, this.nextCursor})
      : super._();
  @override
  PageNotificationOut rebuild(
          void Function(PageNotificationOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PageNotificationOutBuilder toBuilder() =>
      PageNotificationOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PageNotificationOut &&
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
    return (newBuiltValueToStringHelper(r'PageNotificationOut')
          ..add('hasMore', hasMore)
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class PageNotificationOutBuilder
    implements Builder<PageNotificationOut, PageNotificationOutBuilder> {
  _$PageNotificationOut? _$v;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<NotificationOut>? _items;
  ListBuilder<NotificationOut> get items =>
      _$this._items ??= ListBuilder<NotificationOut>();
  set items(ListBuilder<NotificationOut>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  PageNotificationOutBuilder() {
    PageNotificationOut._defaults(this);
  }

  PageNotificationOutBuilder get _$this {
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
  void replace(PageNotificationOut other) {
    _$v = other as _$PageNotificationOut;
  }

  @override
  void update(void Function(PageNotificationOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PageNotificationOut build() => _build();

  _$PageNotificationOut _build() {
    _$PageNotificationOut _$result;
    try {
      _$result = _$v ??
          _$PageNotificationOut._(
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'PageNotificationOut', 'hasMore'),
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
            r'PageNotificationOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
