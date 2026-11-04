// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_erase.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FarmerEraseConfirmEnum _$farmerEraseConfirmEnum_true_ =
    const FarmerEraseConfirmEnum._('true_');

FarmerEraseConfirmEnum _$farmerEraseConfirmEnumValueOf(String name) {
  switch (name) {
    case 'true_':
      return _$farmerEraseConfirmEnum_true_;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FarmerEraseConfirmEnum> _$farmerEraseConfirmEnumValues =
    BuiltSet<FarmerEraseConfirmEnum>(const <FarmerEraseConfirmEnum>[
  _$farmerEraseConfirmEnum_true_,
]);

Serializer<FarmerEraseConfirmEnum> _$farmerEraseConfirmEnumSerializer =
    _$FarmerEraseConfirmEnumSerializer();

class _$FarmerEraseConfirmEnumSerializer
    implements PrimitiveSerializer<FarmerEraseConfirmEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'true_': 'true',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'true': 'true_',
  };

  @override
  final Iterable<Type> types = const <Type>[FarmerEraseConfirmEnum];
  @override
  final String wireName = 'FarmerEraseConfirmEnum';

  @override
  Object serialize(Serializers serializers, FarmerEraseConfirmEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FarmerEraseConfirmEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FarmerEraseConfirmEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FarmerErase extends FarmerErase {
  @override
  final FarmerEraseConfirmEnum confirm;
  @override
  final String reason;

  factory _$FarmerErase([void Function(FarmerEraseBuilder)? updates]) =>
      (FarmerEraseBuilder()..update(updates))._build();

  _$FarmerErase._({required this.confirm, required this.reason}) : super._();
  @override
  FarmerErase rebuild(void Function(FarmerEraseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FarmerEraseBuilder toBuilder() => FarmerEraseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FarmerErase &&
        confirm == other.confirm &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, confirm.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FarmerErase')
          ..add('confirm', confirm)
          ..add('reason', reason))
        .toString();
  }
}

class FarmerEraseBuilder implements Builder<FarmerErase, FarmerEraseBuilder> {
  _$FarmerErase? _$v;

  FarmerEraseConfirmEnum? _confirm;
  FarmerEraseConfirmEnum? get confirm => _$this._confirm;
  set confirm(FarmerEraseConfirmEnum? confirm) => _$this._confirm = confirm;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  FarmerEraseBuilder() {
    FarmerErase._defaults(this);
  }

  FarmerEraseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _confirm = $v.confirm;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FarmerErase other) {
    _$v = other as _$FarmerErase;
  }

  @override
  void update(void Function(FarmerEraseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FarmerErase build() => _build();

  _$FarmerErase _build() {
    final _$result = _$v ??
        _$FarmerErase._(
          confirm: BuiltValueNullFieldError.checkNotNull(
              confirm, r'FarmerErase', 'confirm'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'FarmerErase', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
