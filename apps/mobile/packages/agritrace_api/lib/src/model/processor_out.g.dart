// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'processor_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProcessorOut extends ProcessorOut {
  @override
  final Address? address;
  @override
  final String addressLine;
  @override
  final String? fpoId;
  @override
  final String? fssaiNo;
  @override
  final String? giAuthorisedUserNo;
  @override
  final String id;
  @override
  final OrgKind kind;
  @override
  final String name;

  factory _$ProcessorOut([void Function(ProcessorOutBuilder)? updates]) =>
      (ProcessorOutBuilder()..update(updates))._build();

  _$ProcessorOut._(
      {this.address,
      required this.addressLine,
      this.fpoId,
      this.fssaiNo,
      this.giAuthorisedUserNo,
      required this.id,
      required this.kind,
      required this.name})
      : super._();
  @override
  ProcessorOut rebuild(void Function(ProcessorOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProcessorOutBuilder toBuilder() => ProcessorOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProcessorOut &&
        address == other.address &&
        addressLine == other.addressLine &&
        fpoId == other.fpoId &&
        fssaiNo == other.fssaiNo &&
        giAuthorisedUserNo == other.giAuthorisedUserNo &&
        id == other.id &&
        kind == other.kind &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, addressLine.hashCode);
    _$hash = $jc(_$hash, fpoId.hashCode);
    _$hash = $jc(_$hash, fssaiNo.hashCode);
    _$hash = $jc(_$hash, giAuthorisedUserNo.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProcessorOut')
          ..add('address', address)
          ..add('addressLine', addressLine)
          ..add('fpoId', fpoId)
          ..add('fssaiNo', fssaiNo)
          ..add('giAuthorisedUserNo', giAuthorisedUserNo)
          ..add('id', id)
          ..add('kind', kind)
          ..add('name', name))
        .toString();
  }
}

class ProcessorOutBuilder
    implements Builder<ProcessorOut, ProcessorOutBuilder> {
  _$ProcessorOut? _$v;

  AddressBuilder? _address;
  AddressBuilder get address => _$this._address ??= AddressBuilder();
  set address(AddressBuilder? address) => _$this._address = address;

  String? _addressLine;
  String? get addressLine => _$this._addressLine;
  set addressLine(String? addressLine) => _$this._addressLine = addressLine;

  String? _fpoId;
  String? get fpoId => _$this._fpoId;
  set fpoId(String? fpoId) => _$this._fpoId = fpoId;

  String? _fssaiNo;
  String? get fssaiNo => _$this._fssaiNo;
  set fssaiNo(String? fssaiNo) => _$this._fssaiNo = fssaiNo;

  String? _giAuthorisedUserNo;
  String? get giAuthorisedUserNo => _$this._giAuthorisedUserNo;
  set giAuthorisedUserNo(String? giAuthorisedUserNo) =>
      _$this._giAuthorisedUserNo = giAuthorisedUserNo;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OrgKind? _kind;
  OrgKind? get kind => _$this._kind;
  set kind(OrgKind? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ProcessorOutBuilder() {
    ProcessorOut._defaults(this);
  }

  ProcessorOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _address = $v.address?.toBuilder();
      _addressLine = $v.addressLine;
      _fpoId = $v.fpoId;
      _fssaiNo = $v.fssaiNo;
      _giAuthorisedUserNo = $v.giAuthorisedUserNo;
      _id = $v.id;
      _kind = $v.kind;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProcessorOut other) {
    _$v = other as _$ProcessorOut;
  }

  @override
  void update(void Function(ProcessorOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProcessorOut build() => _build();

  _$ProcessorOut _build() {
    _$ProcessorOut _$result;
    try {
      _$result = _$v ??
          _$ProcessorOut._(
            address: _address?.build(),
            addressLine: BuiltValueNullFieldError.checkNotNull(
                addressLine, r'ProcessorOut', 'addressLine'),
            fpoId: fpoId,
            fssaiNo: fssaiNo,
            giAuthorisedUserNo: giAuthorisedUserNo,
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ProcessorOut', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'ProcessorOut', 'kind'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'ProcessorOut', 'name'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'address';
        _address?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ProcessorOut', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
