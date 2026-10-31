// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_check_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RegionCheckOutStatusEnum _$regionCheckOutStatusEnum_inside =
    const RegionCheckOutStatusEnum._('inside');
const RegionCheckOutStatusEnum _$regionCheckOutStatusEnum_nearEdge =
    const RegionCheckOutStatusEnum._('nearEdge');
const RegionCheckOutStatusEnum _$regionCheckOutStatusEnum_outside =
    const RegionCheckOutStatusEnum._('outside');

RegionCheckOutStatusEnum _$regionCheckOutStatusEnumValueOf(String name) {
  switch (name) {
    case 'inside':
      return _$regionCheckOutStatusEnum_inside;
    case 'nearEdge':
      return _$regionCheckOutStatusEnum_nearEdge;
    case 'outside':
      return _$regionCheckOutStatusEnum_outside;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RegionCheckOutStatusEnum> _$regionCheckOutStatusEnumValues =
    BuiltSet<RegionCheckOutStatusEnum>(const <RegionCheckOutStatusEnum>[
  _$regionCheckOutStatusEnum_inside,
  _$regionCheckOutStatusEnum_nearEdge,
  _$regionCheckOutStatusEnum_outside,
]);

Serializer<RegionCheckOutStatusEnum> _$regionCheckOutStatusEnumSerializer =
    _$RegionCheckOutStatusEnumSerializer();

class _$RegionCheckOutStatusEnumSerializer
    implements PrimitiveSerializer<RegionCheckOutStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'inside': 'inside',
    'nearEdge': 'near_edge',
    'outside': 'outside',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'inside': 'inside',
    'near_edge': 'nearEdge',
    'outside': 'outside',
  };

  @override
  final Iterable<Type> types = const <Type>[RegionCheckOutStatusEnum];
  @override
  final String wireName = 'RegionCheckOutStatusEnum';

  @override
  Object serialize(Serializers serializers, RegionCheckOutStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RegionCheckOutStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RegionCheckOutStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RegionCheckOut extends RegionCheckOut {
  @override
  final String bufferM;
  @override
  final num distanceM;
  @override
  final String regionVersionId;
  @override
  final RegionCheckOutStatusEnum status;

  factory _$RegionCheckOut([void Function(RegionCheckOutBuilder)? updates]) =>
      (RegionCheckOutBuilder()..update(updates))._build();

  _$RegionCheckOut._(
      {required this.bufferM,
      required this.distanceM,
      required this.regionVersionId,
      required this.status})
      : super._();
  @override
  RegionCheckOut rebuild(void Function(RegionCheckOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegionCheckOutBuilder toBuilder() => RegionCheckOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegionCheckOut &&
        bufferM == other.bufferM &&
        distanceM == other.distanceM &&
        regionVersionId == other.regionVersionId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bufferM.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, regionVersionId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegionCheckOut')
          ..add('bufferM', bufferM)
          ..add('distanceM', distanceM)
          ..add('regionVersionId', regionVersionId)
          ..add('status', status))
        .toString();
  }
}

class RegionCheckOutBuilder
    implements Builder<RegionCheckOut, RegionCheckOutBuilder> {
  _$RegionCheckOut? _$v;

  String? _bufferM;
  String? get bufferM => _$this._bufferM;
  set bufferM(String? bufferM) => _$this._bufferM = bufferM;

  num? _distanceM;
  num? get distanceM => _$this._distanceM;
  set distanceM(num? distanceM) => _$this._distanceM = distanceM;

  String? _regionVersionId;
  String? get regionVersionId => _$this._regionVersionId;
  set regionVersionId(String? regionVersionId) =>
      _$this._regionVersionId = regionVersionId;

  RegionCheckOutStatusEnum? _status;
  RegionCheckOutStatusEnum? get status => _$this._status;
  set status(RegionCheckOutStatusEnum? status) => _$this._status = status;

  RegionCheckOutBuilder() {
    RegionCheckOut._defaults(this);
  }

  RegionCheckOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bufferM = $v.bufferM;
      _distanceM = $v.distanceM;
      _regionVersionId = $v.regionVersionId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegionCheckOut other) {
    _$v = other as _$RegionCheckOut;
  }

  @override
  void update(void Function(RegionCheckOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegionCheckOut build() => _build();

  _$RegionCheckOut _build() {
    final _$result = _$v ??
        _$RegionCheckOut._(
          bufferM: BuiltValueNullFieldError.checkNotNull(
              bufferM, r'RegionCheckOut', 'bufferM'),
          distanceM: BuiltValueNullFieldError.checkNotNull(
              distanceM, r'RegionCheckOut', 'distanceM'),
          regionVersionId: BuiltValueNullFieldError.checkNotNull(
              regionVersionId, r'RegionCheckOut', 'regionVersionId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'RegionCheckOut', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
