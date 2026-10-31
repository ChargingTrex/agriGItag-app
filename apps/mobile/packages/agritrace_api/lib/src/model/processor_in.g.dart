// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processor_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProcessorIn extends ProcessorIn {
  @override
  final Address? address;
  @override
  final String? fssaiNo;
  @override
  final String? giAuthorisedUserNo;
  @override
  final OrgKind? kind;
  @override
  final String name;

  factory _$ProcessorIn([void Function(ProcessorInBuilder)? updates]) =>
      (ProcessorInBuilder()..update(updates))._build();

  _$ProcessorIn._(
      {this.address,
      this.fssaiNo,
      this.giAuthorisedUserNo,
      this.kind,
      required this.name})
      : super._();
  @override
  ProcessorIn rebuild(void Function(ProcessorInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProcessorInBuilder toBuilder() => ProcessorInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProcessorIn &&
        address == other.address &&
        fssaiNo == other.fssaiNo &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        kind == other.kind &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, fssaiNo.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProcessorIn')
          ..add('address', address)
          ..add('fssaiNo', fssaiNo)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('kind', kind)
          ..add('name', name))
        .toString();
  }
}

class ProcessorInBuilder implements Builder<ProcessorIn, ProcessorInBuilder> {
  _$ProcessorIn? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _fssaiNo;
  String? get fssaiNo => _$this._fssaiNo;
  set fssaiNo(String? fssaiNo) => _$this._fssaiNo = fssaiNo;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  OrgKind? _kind;
  OrgKind? get kind => _$this._kind;
  set kind(OrgKind? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ProcessorInBuilder() {
    ProcessorIn._defaults(this);
  }

  ProcessorInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _fssaiNo = $v.fssaiNo;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _kind = $v.kind;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProcessorIn other) {
    _$v = other as _$ProcessorIn;
  }

  @override
  void update(void Function(ProcessorInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProcessorIn build() => _build();

  _$ProcessorIn _build() {
    _$ProcessorIn _$result;
    try {
      _$result = _$v ??
          _$ProcessorIn._(
            address: _address?.build(),
            fssaiNo: fssaiNo,
            giAuthorisedUserNo: giAuthorisedUserNo,
            kind: kind,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ProcessorIn', 'name'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProcessorIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
