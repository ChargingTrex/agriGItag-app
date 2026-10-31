// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assist_end_in.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AssistEndIn extends AssistEndIn {
  @override
  final String assistSessionId;

  factory _$AssistEndIn([void Function(AssistEndInBuilder)? updates]) =>
      (AssistEndInBuilder()..update(updates))._build();

  _$AssistEndIn._({required this.assistSessionId}) : super._();
  @override
  AssistEndIn rebuild(void Function(AssistEndInBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AssistEndInBuilder toBuilder() => AssistEndInBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AssistEndIn && assistSessionId == other.assistSessionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assistSessionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AssistEndIn')
          ..add('assistSessionId', assistSessionId))
        .toString();
  }
}

class AssistEndInBuilder implements Builder<AssistEndIn, AssistEndInBuilder> {
  _$AssistEndIn? _$v;

  String? _assistSessionId;
  String? get assistSessionId => _$this._assistSessionId;
  set assistSessionId(String? assistSessionId) =>
      _$this._assistSessionId = assistSessionId;

  AssistEndInBuilder() {
    AssistEndIn._defaults(this);
  }

  AssistEndInBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assistSessionId = $v.assistSessionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AssistEndIn other) {
    _$v = other as _$AssistEndIn;
  }

  @override
  void update(void Function(AssistEndInBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AssistEndIn build() => _build();

  _$AssistEndIn _build() {
    final _$result = _$v ??
        _$AssistEndIn._(
          assistSessionId: BuiltValueNullFieldError.checkNotNull(
              assistSessionId, r'AssistEndIn', 'assistSessionId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
