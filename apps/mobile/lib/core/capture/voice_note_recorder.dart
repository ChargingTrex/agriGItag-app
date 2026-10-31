// Records one problem-report voice note: mono, low bit rate, stopped automatically at 30 s.
// Requirement: UserFlows §Farming events ("Problem (pest, disease, rain damage)": photo plus a 30-second voice
//   note; alert to the field officer), UserFlows §Officer flags (reason as a voice note), FR3.
// Callers: M07 problem report (F09) and officer flag reasons; test/capture/voice_note_recorder_test.dart.

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:record/record.dart';

import 'capture_constants.dart';

/// Outcome of [VoiceNoteRecorder.start]. M07 maps [micDenied] to its one-sentence, one-button sheet.
enum VoiceStart {
  /// Recording has started.
  recording,

  /// The user refused microphone access; nothing is recorded.
  micDenied,
}

/// A finished voice note, ready for the Media table (kind `voice`, width/height 0).
class VoiceNote {
  /// Creates the result from the audio [file], its [duration] and the [sha256] of its bytes.
  const VoiceNote({required this.file, required this.duration, required this.sha256});

  /// The recorded file: `.ogg` (Opus) or `.m4a` (AAC-LC).
  final File file;

  /// Recorded length, at most [kVoiceNoteMax].
  final Duration duration;

  /// SHA-256 of the file bytes, lowercase hex; sent with the upload.
  final String sha256;
}

/// One voice note at a time: [start], then [stop] (or the 30 s cap stops it; [result] completes either way).
class VoiceNoteRecorder {
  /// Creates the recorder. [recorder] defaults to the record plugin; [now] is the phone clock. Both are
  /// injectable so tests can fake the plugin and the clock. Throws nothing.
  VoiceNoteRecorder({AudioRecorder? recorder, DateTime Function() now = DateTime.now})
    : _rec = recorder ?? AudioRecorder(),
      _now = now;

  final AudioRecorder _rec;
  final DateTime Function() _now;
  Completer<VoiceNote>? _result;
  Timer? _cap;
  DateTime? _startedAt;
  bool _stopping = false;

  /// Completes with the note when recording stops, by [stop] or by the 30 s cap. Throws [StateError] before
  /// [start] succeeded.
  Future<VoiceNote> get result => (_result ?? (throw StateError('not recording'))).future;

  /// Asks for the microphone if needed and starts recording into [dirPath]/[name] plus the extension.
  ///
  /// Format: Opus/OGG mono 24 kbps where the platform encodes it (Android 10+), else AAC-LC/M4A mono 32 kbps
  /// (iOS records Opus only into CAF; Android 8–9 has no Opus encoder). About 90–120 KB per 30 s note; the
  /// server must accept both `audio/ogg` and `audio/mp4`.
  /// Returns [VoiceStart.micDenied] when access is refused, else [VoiceStart.recording].
  /// Side effects: microphone on; a 30 s timer that calls [stop]. Throws: [StateError] if already recording;
  /// plugin exceptions pass through.
  Future<VoiceStart> start(String dirPath, String name) async {
    if (_result != null && !_result!.isCompleted) throw StateError('already recording');
    if (!await _rec.hasPermission()) return VoiceStart.micDenied;
    final opus = !Platform.isIOS && await _rec.isEncoderSupported(AudioEncoder.opus);
    await _rec.start(
      RecordConfig(
        encoder: opus ? AudioEncoder.opus : AudioEncoder.aacLc,
        bitRate: opus ? kOpusBitRate : kAacBitRate,
        sampleRate: kVoiceSampleRate,
        numChannels: 1,
      ),
      path: '$dirPath/$name.${opus ? 'ogg' : 'm4a'}',
    );
    _startedAt = _now();
    _stopping = false;
    _result = Completer<VoiceNote>();
    _cap = Timer(kVoiceNoteMax, stop);
    return VoiceStart.recording;
  }

  /// Stops recording and completes [result]; a second call (or the cap after a manual stop) returns the same
  /// note. Returns the [VoiceNote]. Side effects: microphone off, timer cancelled, file read for the hash.
  /// Throws: [StateError] before [start] succeeded or if the plugin returned no file.
  Future<VoiceNote> stop() async {
    final done = _result ?? (throw StateError('not recording'));
    if (_stopping) return done.future;
    _stopping = true;
    _cap?.cancel();
    final path = await _rec.stop();
    if (path == null) {
      done.completeError(StateError('recorder returned no file'));
      return done.future;
    }
    final elapsed = _now().difference(_startedAt!);
    final file = File(path);
    done.complete(
      VoiceNote(
        file: file,
        duration: elapsed > kVoiceNoteMax ? kVoiceNoteMax : elapsed,
        sha256: sha256.convert(file.readAsBytesSync()).toString(),
      ),
    );
    return done.future;
  }
}
