// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standards_profile_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StandardsProfileOut extends StandardsProfileOut {
  @override
  final String cropId;
  @override
  final String id;
  @override
  final String name;
  @override
  final int? publishedVersionNo;
  @override
  final StandardsScheme scheme;
  @override
  final String standardRef;

  factory _$StandardsProfileOut(
          [void Function(StandardsProfileOutBuilder)? updates]) =>
      (StandardsProfileOutBuilder()..update(updates))._build();

  _$StandardsProfileOut._(
      {required this.cropId,
      required this.id,
      required this.name,
      this.publishedVersionNo,
      required this.scheme,
      required this.standardRef})
      : super._();
  @override
  StandardsProfileOut rebuild(
          void Function(StandardsProfileOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StandardsProfileOutBuilder toBuilder() =>
      StandardsProfileOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StandardsProfileOut &&
        cropId == other.cropId &&
        id == other.id &&
        name == other.name &&
        publishedVersionNo == other.publishedVersionNo &&
        scheme == other.scheme &&
        standardRef == other.standardRef;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, cropId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, publishedVersionNo.hashCode);
    _$hash = $jc(_$hash, scheme.hashCode);
    _$hash = $jc(_$hash, standardRef.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StandardsProfileOut')
          ..add('cropId', cropId)
          ..add('id', id)
          ..add('name', name)
          ..add('publishedVersionNo', publishedVersionNo)
          ..add('scheme', scheme)
          ..add('standardRef', standardRef))
        .toString();
  }
}

class StandardsProfileOutBuilder
    implements Builder<StandardsProfileOut, StandardsProfileOutBuilder> {
  _$StandardsProfileOut? _$v;

  String? _cropId;
  String? get cropId => _$this._cropId;
  set cropId(String? cropId) => _$this._cropId = cropId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _publishedVersionNo;
  int? get publishedVersionNo => _$this._publishedVersionNo;
  set publishedVersionNo(int? publishedVersionNo) =>
      _$this._publishedVersionNo = publishedVersionNo;

  StandardsScheme? _scheme;
  StandardsScheme? get scheme => _$this._scheme;
  set scheme(StandardsScheme? scheme) => _$this._scheme = scheme;

  String? _standardRef;
  String? get standardRef => _$this._standardRef;
  set standardRef(String? standardRef) => _$this._standardRef = standardRef;

  StandardsProfileOutBuilder() {
    StandardsProfileOut._defaults(this);
  }

  StandardsProfileOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _cropId = $v.cropId;
      _id = $v.id;
      _name = $v.name;
      _publishedVersionNo = $v.publishedVersionNo;
      _scheme = $v.scheme;
      _standardRef = $v.standardRef;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StandardsProfileOut other) {
    _$v = other as _$StandardsProfileOut;
  }

  @override
  void update(void Function(StandardsProfileOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StandardsProfileOut build() => _build();

  _$StandardsProfileOut _build() {
    final _$result = _$v ??
        _$StandardsProfileOut._(
          cropId: BuiltValueNullFieldError.checkNotNull(
              cropId, r'StandardsProfileOut', 'cropId'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'StandardsProfileOut', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'StandardsProfileOut', 'name'),
          publishedVersionNo: publishedVersionNo,
          scheme: BuiltValueNullFieldError.checkNotNull(
              scheme, r'StandardsProfileOut', 'scheme'),
          standardRef: BuiltValueNullFieldError.checkNotNull(
              standardRef, r'StandardsProfileOut', 'standardRef'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
