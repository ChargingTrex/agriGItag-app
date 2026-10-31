// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lot_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LotIn extends LotIn {
  @override
  final String clientId;
  @override
  final String cropId;
  @override
  final String plotId;
  @override
  final BuiltList<PracticeTag>? practiceTagsDeclared;
  @override
  final String? seasonLabel;

  factory _$LotIn([void Function(LotInBuilder)? updates]) =>
      (LotInBuilder()..update(updates))._build();

  _$LotIn._(
      {required this.clientId,
      required this.cropId,
      required this.plotId,
      this.practiceTagsDeclared,
      this.seasonLabel})
      : super._();
  @override
  LotIn rebuild(void Function(LotInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LotInBuilder toBuilder() => LotInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LotIn &&
        clientId == other.clientId &&
        cropId == other.cropId &&
        plotId == other.plotId &&
        practiceTagsDeclared == other.practiceTagsDeclared &&
        seasonLabel == other.seasonLabel;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientId.hashCode);
    _$hash = $jc(_$hash, cropId.hashCode);
    _$hash = $jc(_$hash, plotId.hashCode);
    _$hash = $jc(_$hash, practiceTagsDeclared.hashCode);
    _$hash = $jc(_$hash, seasonLabel.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LotIn')
          ..add('clientId', clientId)
          ..add('cropId', cropId)
          ..add('plotId', plotId)
          ..add('practiceTagsDeclared', practiceTagsDeclared)
          ..add('seasonLabel', seasonLabel))
        .toString();
  }
}

class LotInBuilder implements Builder<LotIn, LotInBuilder> {
  _$LotIn? _$v;

  String? _clientId;
  String? get clientId => _$this._clientId;
  set clientId(String? clientId) => _$this._clientId = clientId;

  String? _cropId;
  String? get cropId => _$this._cropId;
  set cropId(String? cropId) => _$this._cropId = cropId;

  String? _plotId;
  String? get plotId => _$this._plotId;
  set plotId(String? plotId) => _$this._plotId = plotId;

  ListBuilder<PracticeTag>? _practiceTagsDeclared;
  ListBuilder<PracticeTag> get practiceTagsDeclared =>
      _$this._practiceTagsDeclared ??= ListBuilder<PracticeTag>();
  set practiceTagsDeclared(ListBuilder<PracticeTag>? practiceTagsDeclared) =>
      _$this._practiceTagsDeclared = practiceTagsDeclared;

  String? _seasonLabel;
  String? get seasonLabel => _$this._seasonLabel;
  set seasonLabel(String? seasonLabel) => _$this._seasonLabel = seasonLabel;

  LotInBuilder() {
    LotIn._defaults(this);
  }

  LotInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientId = $v.clientId;
      _cropId = $v.cropId;
      _plotId = $v.plotId;
      _practiceTagsDeclared = $v.practiceTagsDeclared?.toBuilder();
      _seasonLabel = $v.seasonLabel;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LotIn other) {
    _$v = other as _$LotIn;
  }

  @override
  void update(void Function(LotInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LotIn build() => _build();

  _$LotIn _build() {
    _$LotIn _$result;
    try {
      _$result = _$v ??
          _$LotIn._(
            clientId: BuiltValueNullFieldError.checkNotNull(
                clientId, r'LotIn', 'clientId'),
            cropId: BuiltValueNullFieldError.checkNotNull(
                cropId, r'LotIn', 'cropId'),
            plotId: BuiltValueNullFieldError.checkNotNull(
                plotId, r'LotIn', 'plotId'),
            practiceTagsDeclared: _practiceTagsDeclared?.build(),
            seasonLabel: seasonLabel,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'practiceTagsDeclared';
        _practiceTagsDeclared?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'LotIn', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
