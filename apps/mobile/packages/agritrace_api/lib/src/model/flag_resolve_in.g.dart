// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_resolve_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FlagResolveInResolutionEnum _$flagResolveInResolutionEnum_looksFine =
    const FlagResolveInResolutionEnum._('looksFine');
const FlagResolveInResolutionEnum _$flagResolveInResolutionEnum_fixed =
    const FlagResolveInResolutionEnum._('fixed');
const FlagResolveInResolutionEnum _$flagResolveInResolutionEnum_escalated =
    const FlagResolveInResolutionEnum._('escalated');

FlagResolveInResolutionEnum _$flagResolveInResolutionEnumValueOf(String name) {
  switch (name) {
    case 'looksFine':
      return _$flagResolveInResolutionEnum_looksFine;
    case 'fixed':
      return _$flagResolveInResolutionEnum_fixed;
    case 'escalated':
      return _$flagResolveInResolutionEnum_escalated;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FlagResolveInResolutionEnum>
    _$flagResolveInResolutionEnumValues =
    BuiltSet<FlagResolveInResolutionEnum>(const <FlagResolveInResolutionEnum>[
  _$flagResolveInResolutionEnum_looksFine,
  _$flagResolveInResolutionEnum_fixed,
  _$flagResolveInResolutionEnum_escalated,
]);

Serializer<FlagResolveInResolutionEnum>
    _$flagResolveInResolutionEnumSerializer =
    _$FlagResolveInResolutionEnumSerializer();

class _$FlagResolveInResolutionEnumSerializer
    implements PrimitiveSerializer<FlagResolveInResolutionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'looksFine': 'looks_fine',
    'fixed': 'fixed',
    'escalated': 'escalated',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'looks_fine': 'looksFine',
    'fixed': 'fixed',
    'escalated': 'escalated',
  };

  @override
  final Iterable<Type> types = const <Type>[FlagResolveInResolutionEnum];
  @override
  final String wireName = 'FlagResolveInResolutionEnum';

  @override
  Object serialize(Serializers serializers, FlagResolveInResolutionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FlagResolveInResolutionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FlagResolveInResolutionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FlagResolveIn extends FlagResolveIn {
  @override
  final String? note;
  @override
  final String? reasonCode;
  @override
  final FlagResolveInResolutionEnum resolution;

  factory _$FlagResolveIn([void Function(FlagResolveInBuilder)? updates]) =>
      (FlagResolveInBuilder()..update(updates))._build();

  _$FlagResolveIn._({this.note, this.reasonCode, required this.resolution})
      : super._();
  @override
  FlagResolveIn rebuild(void Function(FlagResolveInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagResolveInBuilder toBuilder() => FlagResolveInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagResolveIn &&
        note == other.note &&
        reasonCode == other.reasonCode &&
        resolution == other.resolution;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagResolveIn')
          ..add('note', note)
          ..add('reasonCode', reasonCode)
          ..add('resolution', resolution))
        .toString();
  }
}

class FlagResolveInBuilder
    implements Builder<FlagResolveIn, FlagResolveInBuilder> {
  _$FlagResolveIn? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  FlagResolveInResolutionEnum? _resolution;
  FlagResolveInResolutionEnum? get resolution => _$this._resolution;
  set resolution(FlagResolveInResolutionEnum? resolution) =>
      _$this._resolution = resolution;

  FlagResolveInBuilder() {
    FlagResolveIn._defaults(this);
  }

  FlagResolveInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _reasonCode = $v.reasonCode;
      _resolution = $v.resolution;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagResolveIn other) {
    _$v = other as _$FlagResolveIn;
  }

  @override
  void update(void Function(FlagResolveInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagResolveIn build() => _build();

  _$FlagResolveIn _build() {
    final _$result = _$v ??
        _$FlagResolveIn._(
          note: note,
          reasonCode: reasonCode,
          resolution: BuiltValueNullFieldError.checkNotNull(
              resolution, r'FlagResolveIn', 'resolution'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
