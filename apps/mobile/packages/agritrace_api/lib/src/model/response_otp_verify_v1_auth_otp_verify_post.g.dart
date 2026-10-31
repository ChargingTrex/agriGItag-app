// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_otp_verify_v1_auth_otp_verify_post.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum
    _$responseOtpVerifyV1AuthOtpVerifyPostKindEnum_pinRequired =
    const ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum._('pinRequired');

ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum
    _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumValueOf(String name) {
  switch (name) {
    case 'pinRequired':
      return _$responseOtpVerifyV1AuthOtpVerifyPostKindEnum_pinRequired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum>
    _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumValues = BuiltSet<
        ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum>(const <ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum>[
  _$responseOtpVerifyV1AuthOtpVerifyPostKindEnum_pinRequired,
]);

Serializer<ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum>
    _$responseOtpVerifyV1AuthOtpVerifyPostKindEnumSerializer =
    _$ResponseOtpVerifyV1AuthOtpVerifyPostKindEnumSerializer();

class _$ResponseOtpVerifyV1AuthOtpVerifyPostKindEnumSerializer
    implements
        PrimitiveSerializer<ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pinRequired': 'pin_required',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pin_required': 'pinRequired',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum
  ];
  @override
  final String wireName = 'ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum';

  @override
  Object serialize(Serializers serializers,
          ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ResponseOtpVerifyV1AuthOtpVerifyPostKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ResponseOtpVerifyV1AuthOtpVerifyPost
    extends ResponseOtpVerifyV1AuthOtpVerifyPost {
  @override
  final OneOf oneOf;

  factory _$ResponseOtpVerifyV1AuthOtpVerifyPost(
          [void Function(ResponseOtpVerifyV1AuthOtpVerifyPostBuilder)?
              updates]) =>
      (ResponseOtpVerifyV1AuthOtpVerifyPostBuilder()..update(updates))._build();

  _$ResponseOtpVerifyV1AuthOtpVerifyPost._({required this.oneOf}) : super._();
  @override
  ResponseOtpVerifyV1AuthOtpVerifyPost rebuild(
          void Function(ResponseOtpVerifyV1AuthOtpVerifyPostBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResponseOtpVerifyV1AuthOtpVerifyPostBuilder toBuilder() =>
      ResponseOtpVerifyV1AuthOtpVerifyPostBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResponseOtpVerifyV1AuthOtpVerifyPost &&
        oneOf == other.oneOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oneOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResponseOtpVerifyV1AuthOtpVerifyPost')
          ..add('oneOf', oneOf))
        .toString();
  }
}

class ResponseOtpVerifyV1AuthOtpVerifyPostBuilder
    implements
        Builder<ResponseOtpVerifyV1AuthOtpVerifyPost,
            ResponseOtpVerifyV1AuthOtpVerifyPostBuilder> {
  _$ResponseOtpVerifyV1AuthOtpVerifyPost? _$v;

  OneOf? _oneOf;
  OneOf? get oneOf => _$this._oneOf;
  set oneOf(OneOf? oneOf) => _$this._oneOf = oneOf;

  ResponseOtpVerifyV1AuthOtpVerifyPostBuilder() {
    ResponseOtpVerifyV1AuthOtpVerifyPost._defaults(this);
  }

  ResponseOtpVerifyV1AuthOtpVerifyPostBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oneOf = $v.oneOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResponseOtpVerifyV1AuthOtpVerifyPost other) {
    _$v = other as _$ResponseOtpVerifyV1AuthOtpVerifyPost;
  }

  @override
  void update(
      void Function(ResponseOtpVerifyV1AuthOtpVerifyPostBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResponseOtpVerifyV1AuthOtpVerifyPost build() => _build();

  _$ResponseOtpVerifyV1AuthOtpVerifyPost _build() {
    final _$result = _$v ??
        _$ResponseOtpVerifyV1AuthOtpVerifyPost._(
          oneOf: BuiltValueNullFieldError.checkNotNull(
              oneOf, r'ResponseOtpVerifyV1AuthOtpVerifyPost', 'oneOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
