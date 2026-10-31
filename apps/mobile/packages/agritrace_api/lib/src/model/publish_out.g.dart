// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_out.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PublishOut extends PublishOut {
  @override
  final String batchId;
  @override
  final int buildNo;
  @override
  final String code;
  @override
  final String pageBuildId;
  @override
  final String status;

  factory _$PublishOut([void Function(PublishOutBuilder)? updates]) =>
      (PublishOutBuilder()..update(updates))._build();

  _$PublishOut._(
      {required this.batchId,
      required this.buildNo,
      required this.code,
      required this.pageBuildId,
      required this.status})
      : super._();
  @override
  PublishOut rebuild(void Function(PublishOutBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PublishOutBuilder toBuilder() => PublishOutBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PublishOut &&
        batchId == other.batchId &&
        buildNo == other.buildNo &&
        code == other.code &&
        pageBuildId == other.pageBuildId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, batchId.hashCode);
    _$hash = $jc(_$hash, buildNo.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, pageBuildId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PublishOut')
          ..add('batchId', batchId)
          ..add('buildNo', buildNo)
          ..add('code', code)
          ..add('pageBuildId', pageBuildId)
          ..add('status', status))
        .toString();
  }
}

class PublishOutBuilder implements Builder<PublishOut, PublishOutBuilder> {
  _$PublishOut? _$v;

  String? _batchId;
  String? get batchId => _$this._batchId;
  set batchId(String? batchId) => _$this._batchId = batchId;

  int? _buildNo;
  int? get buildNo => _$this._buildNo;
  set buildNo(int? buildNo) => _$this._buildNo = buildNo;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _pageBuildId;
  String? get pageBuildId => _$this._pageBuildId;
  set pageBuildId(String? pageBuildId) => _$this._pageBuildId = pageBuildId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  PublishOutBuilder() {
    PublishOut._defaults(this);
  }

  PublishOutBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _batchId = $v.batchId;
      _buildNo = $v.buildNo;
      _code = $v.code;
      _pageBuildId = $v.pageBuildId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PublishOut other) {
    _$v = other as _$PublishOut;
  }

  @override
  void update(void Function(PublishOutBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PublishOut build() => _build();

  _$PublishOut _build() {
    final _$result = _$v ??
        _$PublishOut._(
          batchId: BuiltValueNullFieldError.checkNotNull(
              batchId, r'PublishOut', 'batchId'),
          buildNo: BuiltValueNullFieldError.checkNotNull(
              buildNo, r'PublishOut', 'buildNo'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PublishOut', 'code'),
          pageBuildId: BuiltValueNullFieldError.checkNotNull(
              pageBuildId, r'PublishOut', 'pageBuildId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PublishOut', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
