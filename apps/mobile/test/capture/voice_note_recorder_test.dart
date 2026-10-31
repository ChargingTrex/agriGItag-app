// Tests for VoiceNoteRecorder with a fake record plugin and fake_async's clock: 30 s cap, manual stop,
//   microphone refusal as a typed result, stop failure as RecorderFailed, the AAC-LC branch, dispose.
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
  /// Creates the fake; [allowed] is the microphone permission answer, [opus] the Opus encoder support,
  /// [failStop] makes [stop] throw like the plugin after an audio interruption.
  FakeRecorder({this.allowed = true, this.opus = true, this.failStop = false});

  /// Microphone permission answer.
  final bool allowed;

  /// Whether the Opus encoder is reported as supported.
  final bool opus;

  /// Whether [stop] throws.
  final bool failStop;

  /// Whether [dispose] ran.
  bool disposed = false;

  /// Config passed to [start].
  RecordConfig? config;

  /// Path passed to [start].
  String? path;

  /// Number of [stop] calls.
  int stops = 0;

  @override
  Future<bool> hasPermission({bool request = true}) async => allowed;

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async => opus;

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    this.config = config;
    this.path = path;
  }

  @override
  Future<String?> stop() async {
    stops++;
    if (failStop) throw Exception('PlatformException(record, interrupted)');
    File(path!).writeAsBytesSync(List.filled(1000, 7));
    return path;
  }

  @override
  Future<void> dispose() async => disposed = true;

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

  test('plugin stop failure completes result with RecorderFailed (cap path and manual path)', () {
    fakeAsync((fa) {
      final rec = VoiceNoteRecorder(recorder: FakeRecorder(failStop: true));
      rec.start(dir.path, 'n3');
      fa.flushMicrotasks();
      Object? err;
      rec.result.then<void>(
        (_) {},
        onError: (Object e) {
          err = e;
        },
      );
      fa.elapse(const Duration(seconds: 30));
      expect(err, isA<RecorderFailed>());
      Object? again;
      rec.stop().then<void>(
        (_) {},
        onError: (Object e) {
          again = e;
        },
      );
      fa.flushMicrotasks();
      expect(again, isA<RecorderFailed>(), reason: 'later stop returns the same failure, never hangs');
    });
  });

  test('without Opus support records AAC-LC into .m4a; dispose releases the plugin', () async {
    final fake = FakeRecorder(opus: false);
    final rec = VoiceNoteRecorder(recorder: fake);
    expect(await rec.start(dir.path, 'n4'), VoiceStart.recording);
    expect(fake.config!.encoder, AudioEncoder.aacLc);
    expect(fake.config!.bitRate, 32000);
    expect(fake.path, endsWith('n4.m4a'));
    await rec.stop();
    await rec.dispose();
    expect(fake.disposed, isTrue);
  });

  test('microphone refused → micDenied, nothing recorded', () async {
    final fake = FakeRecorder(allowed: false);
    expect(await VoiceNoteRecorder(recorder: fake).start(dir.path, 'x'), VoiceStart.micDenied);
    expect(fake.config, isNull);
  });
}
