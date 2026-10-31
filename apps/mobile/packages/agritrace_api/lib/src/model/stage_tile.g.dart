// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage_tile.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StageTile extends StageTile {
  @override
  final int done;
  @override
  final int inProgress;
  @override
  final int notStarted;
  @override
  final String stage;

  factory _$StageTile([void Function(StageTileBuilder)? updates]) =>
      (StageTileBuilder()..update(updates))._build();

  _$StageTile._(
      {required this.done,
      required this.inProgress,
      required this.notStarted,
      required this.stage})
      : super._();
  @override
  StageTile rebuild(void Function(StageTileBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StageTileBuilder toBuilder() => StageTileBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StageTile &&
        done == other.done &&
        inProgress == other.inProgress &&
        notStarted == other.notStarted &&
        stage == other.stage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, done.hashCode);
    _$hash = $jc(_$hash, inProgress.hashCode);
    _$hash = $jc(_$hash, notStarted.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StageTile')
          ..add('done', done)
          ..add('inProgress', inProgress)
          ..add('notStarted', notStarted)
          ..add('stage', stage))
        .toString();
  }
}

class StageTileBuilder implements Builder<StageTile, StageTileBuilder> {
  _$StageTile? _$v;

  int? _done;
  int? get done => _$this._done;
  set done(int? done) => _$this._done = done;

  int? _inProgress;
  int? get inProgress => _$this._inProgress;
  set inProgress(int? inProgress) => _$this._inProgress = inProgress;

  int? _notStarted;
  int? get notStarted => _$this._notStarted;
  set notStarted(int? notStarted) => _$this._notStarted = notStarted;

  String? _stage;
  String? get stage => _$this._stage;
  set stage(String? stage) => _$this._stage = stage;

  StageTileBuilder() {
    StageTile._defaults(this);
  }

  StageTileBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _done = $v.done;
      _inProgress = $v.inProgress;
      _notStarted = $v.notStarted;
      _stage = $v.stage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StageTile other) {
    _$v = other as _$StageTile;
  }

  @override
  void update(void Function(StageTileBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StageTile build() => _build();

  _$StageTile _build() {
    final _$result = _$v ??
        _$StageTile._(
          done:
              BuiltValueNullFieldError.checkNotNull(done, r'StageTile', 'done'),
          inProgress: BuiltValueNullFieldError.checkNotNull(
              inProgress, r'StageTile', 'inProgress'),
          notStarted: BuiltValueNullFieldError.checkNotNull(
              notStarted, r'StageTile', 'notStarted'),
          stage: BuiltValueNullFieldError.checkNotNull(
              stage, r'StageTile', 'stage'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
