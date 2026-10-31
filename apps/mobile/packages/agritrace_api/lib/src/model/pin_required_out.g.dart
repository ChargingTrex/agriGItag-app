// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_required_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PinRequiredOutKindEnum _$pinRequiredOutKindEnum_pinRequired =
    const PinRequiredOutKindEnum._('pinRequired');

PinRequiredOutKindEnum _$pinRequiredOutKindEnumValueOf(String name) {
  switch (name) {
    case 'pinRequired':
      return _$pinRequiredOutKindEnum_pinRequired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PinRequiredOutKindEnum> _$pinRequiredOutKindEnumValues =
    BuiltSet<PinRequiredOutKindEnum>(const <PinRequiredOutKindEnum>[
  _$pinRequiredOutKindEnum_pinRequired,
]);

Serializer<PinRequiredOutKindEnum> _$pinRequiredOutKindEnumSerializer =
    _$PinRequiredOutKindEnumSerializer();

class _$PinRequiredOutKindEnumSerializer
    implements PrimitiveSerializer<PinRequiredOutKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pinRequired': 'pin_required',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pin_required': 'pinRequired',
  };

  @override
  final Iterable<Type> types = const <Type>[PinRequiredOutKindEnum];
  @override
  final String wireName = 'PinRequiredOutKindEnum';

  @override
  Object serialize(Serializers serializers, PinRequiredOutKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PinRequiredOutKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PinRequiredOutKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PinRequiredOut extends PinRequiredOut {
  @override
  final int expiresIn;
  @override
  final PinRequiredOutKindEnum kind;
  @override
  final bool pinSet;
  @override
  final String pinToken;

  factory _$PinRequiredOut([void Function(PinRequiredOutBuilder)? updates]) =>
      (PinRequiredOutBuilder()..update(updates))._build();

  _$PinRequiredOut._(
      {required this.expiresIn,
      required this.kind,
      required this.pinSet,
      required this.pinToken})
      : super._();
  @override
  PinRequiredOut rebuild(void Function(PinRequiredOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PinRequiredOutBuilder toBuilder() => PinRequiredOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PinRequiredOut &&
        expiresIn == other.expiresIn &&
        kind == other.kind &&
        pinSet == other.pinSet &&
        pinToken == other.pinToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, pinSet.hashCode);
    _$hash = $jc(_$hash, pinToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PinRequiredOut')
          ..add('expiresIn', expiresIn)
          ..add('kind', kind)
          ..add('pinSet', pinSet)
          ..add('pinToken', pinToken))
        .toString();
  }
}

class PinRequiredOutBuilder
    implements Builder<PinRequiredOut, PinRequiredOutBuilder> {
  _$PinRequiredOut? _$v;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  PinRequiredOutKindEnum? _kind;
  PinRequiredOutKindEnum? get kind => _$this._kind;
  set kind(PinRequiredOutKindEnum? kind) => _$this._kind = kind;

  bool? _pinSet;
  bool? get pinSet => _$this._pinSet;
  set pinSet(bool? pinSet) => _$this._pinSet = pinSet;

  String? _pinToken;
  String? get pinToken => _$this._pinToken;
  set pinToken(String? pinToken) => _$this._pinToken = pinToken;

  PinRequiredOutBuilder() {
    PinRequiredOut._defaults(this);
  }

  PinRequiredOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresIn = $v.expiresIn;
      _kind = $v.kind;
      _pinSet = $v.pinSet;
      _pinToken = $v.pinToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PinRequiredOut other) {
    _$v = other as _$PinRequiredOut;
  }

  @override
  void update(void Function(PinRequiredOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PinRequiredOut build() => _build();

  _$PinRequiredOut _build() {
    final _$result = _$v ??
        _$PinRequiredOut._(
          expiresIn: BuiltValueNullFieldError.checkNotNull(
              expiresIn, r'PinRequiredOut', 'expiresIn'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PinRequiredOut', 'kind'),
          pinSet: BuiltValueNullFieldError.checkNotNull(
              pinSet, r'PinRequiredOut', 'pinSet'),
          pinToken: BuiltValueNullFieldError.checkNotNull(
              pinToken, r'PinRequiredOut', 'pinToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
