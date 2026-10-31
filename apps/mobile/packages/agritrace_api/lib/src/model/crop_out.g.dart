// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CropOut extends CropOut {
  @override
  final bool active;
  @override
  final String code;
  @override
  final BuiltMap<String, JsonObject?> eventSchema;
  @override
  final String? giTagId;
  @override
  final String id;
  @override
  final String lang;
  @override
  final String nameEn;
  @override
  final String? nameLocal;

  factory _$CropOut([void Function(CropOutBuilder)? updates]) =>
      (CropOutBuilder()..update(updates))._build();

  _$CropOut._(
      {required this.active,
      required this.code,
      required this.eventSchema,
      this.giTagId,
      required this.id,
      required this.lang,
      required this.nameEn,
      this.nameLocal})
      : super._();
  @override
  CropOut rebuild(void Function(CropOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CropOutBuilder toBuilder() => CropOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CropOut &&
        active == other.active &&
        code == other.code &&
        eventSchema == other.eventSchema &&
        giTagId == other.giTagId &&
        id == other.id &&
        lang == other.lang &&
        nameEn == other.nameEn &&
        nameLocal == other.nameLocal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, active.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, eventSchema.hashCode);
    _$hash = $jc(_$hash, giTagId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, nameLocal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CropOut')
          ..add('active', active)
          ..add('code', code)
          ..add('eventSchema', eventSchema)
          ..add('giTagId', giTagId)
          ..add('id', id)
          ..add('lang', lang)
          ..add('nameEn', nameEn)
          ..add('nameLocal', nameLocal))
        .toString();
  }
}

class CropOutBuilder implements Builder<CropOut, CropOutBuilder> {
  _$CropOut? _$v;

  bool? _active;
  bool? get active => _$this._active;
  set active(bool? active) => _$this._active = active;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  MapBuilder<String, JsonObject?>? _eventSchema;
  MapBuilder<String, JsonObject?> get eventSchema =>
      _$this._eventSchema ??= MapBuilder<String, JsonObject?>();
  set eventSchema(MapBuilder<String, JsonObject?>? eventSchema) =>
      _$this._eventSchema = eventSchema;

  String? _giTagId;
  String? get giTagId => _$this._giTagId;
  set giTagId(String? giTagId) => _$this._giTagId = giTagId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _lang;
  String? get lang => _$this._lang;
  set lang(String? lang) => _$this._lang = lang;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameLocal;
  String? get nameLocal => _$this._nameLocal;
  set nameLocal(String? nameLocal) => _$this._nameLocal = nameLocal;

  CropOutBuilder() {
    CropOut._defaults(this);
  }

  CropOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _active = $v.active;
      _code = $v.code;
      _eventSchema = $v.eventSchema.toBuilder();
      _giTagId = $v.giTagId;
      _id = $v.id;
      _lang = $v.lang;
      _nameEn = $v.nameEn;
      _nameLocal = $v.nameLocal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CropOut other) {
    _$v = other as _$CropOut;
  }

  @override
  void update(void Function(CropOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CropOut build() => _build();

  _$CropOut _build() {
    _$CropOut _$result;
    try {
      _$result = _$v ??
          _$CropOut._(
            active: BuiltValueNullFieldError.checkNotNull(
                active, r'CropOut', 'active'),
            code:
                BuiltValueNullFieldError.checkNotNull(code, r'CropOut', 'code'),
            eventSchema: eventSchema.build(),
            giTagId: giTagId,
            id: BuiltValueNullFieldError.checkNotNull(id, r'CropOut', 'id'),
            lang:
                BuiltValueNullFieldError.checkNotNull(lang, r'CropOut', 'lang'),
            nameEn: BuiltValueNullFieldError.checkNotNull(
                nameEn, r'CropOut', 'nameEn'),
            nameLocal: nameLocal,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'eventSchema';
        eventSchema.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CropOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
