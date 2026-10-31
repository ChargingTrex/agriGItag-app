// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_tags.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PracticeTags extends PracticeTags {
  @override
  final bool? contradiction;
  @override
  final BuiltList<PracticeTag>? declared;
  @override
  final BuiltList<PracticeTag>? derived;

  factory _$PracticeTags([void Function(PracticeTagsBuilder)? updates]) =>
      (PracticeTagsBuilder()..update(updates))._build();

  _$PracticeTags._({this.contradiction, this.declared, this.derived})
      : super._();
  @override
  PracticeTags rebuild(void Function(PracticeTagsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PracticeTagsBuilder toBuilder() => PracticeTagsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PracticeTags &&
        contradiction == other.contradiction &&
        declared == other.declared &&
        derived == other.derived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contradiction.hashCode);
    _$hash = $jc(_$hash, declared.hashCode);
    _$hash = $jc(_$hash, derived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PracticeTags')
          ..add('contradiction', contradiction)
          ..add('declared', declared)
          ..add('derived', derived))
        .toString();
  }
}

class PracticeTagsBuilder
    implements Builder<PracticeTags, PracticeTagsBuilder> {
  _$PracticeTags? _$v;

  bool? _contradiction;
  bool? get contradiction => _$this._contradiction;
  set contradiction(bool? contradiction) =>
      _$this._contradiction = contradiction;

  ListBuilder<PracticeTag>? _declared;
  ListBuilder<PracticeTag> get declared =>
      _$this._declared ??= ListBuilder<PracticeTag>();
  set declared(ListBuilder<PracticeTag>? declared) =>
      _$this._declared = declared;

  ListBuilder<PracticeTag>? _derived;
  ListBuilder<PracticeTag> get derived =>
      _$this._derived ??= ListBuilder<PracticeTag>();
  set derived(ListBuilder<PracticeTag>? derived) => _$this._derived = derived;

  PracticeTagsBuilder() {
    PracticeTags._defaults(this);
  }

  PracticeTagsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contradiction = $v.contradiction;
      _declared = $v.declared?.toBuilder();
      _derived = $v.derived?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PracticeTags other) {
    _$v = other as _$PracticeTags;
  }

  @override
  void update(void Function(PracticeTagsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PracticeTags build() => _build();

  _$PracticeTags _build() {
    _$PracticeTags _$result;
    try {
      _$result = _$v ??
          _$PracticeTags._(
            contradiction: contradiction,
            declared: _declared?.build(),
            derived: _derived?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'declared';
        _declared?.build();
        _$failedField = 'derived';
        _derived?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PracticeTags', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
