// Tests for VoiceNoteRecorder with a fake record plugin and fake_async's clock: 30 s cap, manual stop,
//   microphone refusal as a typed result.
// Requirement: UserFlows §Problem (30-second voice note), M04 brief item 6.
// Callers: `flutter test test/capture`.

import 'dart:io';

import 'package:agritrace/core/capture/voice_note_recorder.dart';
import 'package:crypto/crypto.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

/// Fake plugin: records the config, writes a small file on stop. Unused members fall to noSuchMethod.
class FakeRecorder implements AudioRecorder {
  /// Creates the fake; [allowed] is the microphone permission answer.
  FakeRecorder({this.allowed = true});

  /// Microphone permission answer.
  final bool allowed;

  /// Config passed to [start].
  RecordConfig? config;

  /// Path passed to [start].
  String? path;

  /// Number of [stop] calls.
  int stops = 0;

  @override
  Future<bool> hasPermission({bool request = true}) async => allowed;

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async => true;

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    this.config = config;
    this.path = path;
  }

  @override
  Future<String?> stop() async {
    stops++;
    File(path!).writeAsBytesSync(List.filled(1000, 7));
    return path;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('m04_voice'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('caps at 30 s: stops by itself and reports 30 s', () {
    fakeAsync((fa) {
      final fake = FakeRecorder();
      final t0 = DateTime(2026, 2, 14, 9);
      final rec = VoiceNoteRecorder(recorder: fake, now: () => t0.add(fa.elapsed));
      VoiceStart? started;
      rec.start(dir.path, 'note1').then((s) => started = s);
      fa.flushMicrotasks();
      expect(started, VoiceStart.recording);
      expect(fake.config!.numChannels, 1);
      expect(fake.config!.encoder, AudioEncoder.opus);
      expect(fake.path, endsWith('note1.ogg'));

      VoiceNote? note;
      rec.result.then((n) => note = n);
      fa.elapse(const Duration(seconds: 29));
      expect(note, isNull);
      fa.elapse(const Duration(seconds: 1));
      expect(note!.duration, const Duration(seconds: 30));
      expect(note!.sha256, sha256.convert(List.filled(1000, 7)).toString());
      expect(fake.stops, 1);

      rec.stop();
      fa.flushMicrotasks();
      expect(fake.stops, 1, reason: 'a later stop returns the same note');
    });
  });

  test('manual stop before the cap reports the real length', () {
    fakeAsync((fa) {
      final t0 = DateTime(2026, 2, 14, 9);
      final rec = VoiceNoteRecorder(recorder: FakeRecorder(), now: () => t0.add(fa.elapsed));
      rec.start(dir.path, 'note2');
      fa.elapse(const Duration(seconds: 12));
      VoiceNote? note;
      rec.stop().then((n) => note = n);
      fa.flushMicrotasks();
      expect(note!.duration, const Duration(seconds: 12));
    });
  });

  test('microphone refused → micDenied, nothing recorded', () async {
    final fake = FakeRecorder(allowed: false);
    expect(await VoiceNoteRecorder(recorder: fake).start(dir.path, 'x'), VoiceStart.micDenied);
    expect(fake.config, isNull);
  });
}
