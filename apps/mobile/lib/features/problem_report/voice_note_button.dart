// Problem report voice note: one button that records up to 30 seconds (stopped by the farmer or by the cap) and
// attaches the note to the problem entry as a `voice` media row.
// Requirement: UserFlows §Each farm event ("Problem (pest, disease, rain damage) | Photo plus a 30-second voice note |
//   alert to the field officer"), §When things go wrong (one sentence + one button, never an error code); FR3.
// Callers: ConfirmScreen (event_log/confirm_screen.dart) for the problem event.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/capture/voice_note_recorder.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../event_log/event_log_controller.dart';
import '../event_log/farmer_sheet.dart';

/// "Voice note" → "Stop" → "Voice added": records into the media folder and stores the note in the draft.
class VoiceNoteButton extends ConsumerStatefulWidget {
  /// Creates the button.
  const VoiceNoteButton({super.key});

  /// Creates the state owning the recorder. Returns it; throws nothing.
  @override
  ConsumerState<VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

/// State of [VoiceNoteButton]: the recorder and the flow it reports to.
class _VoiceNoteButtonState extends ConsumerState<VoiceNoteButton> {
  /// The recorder, made on the first tap and kept for re-recording.
  VoiceNoteRecorder? _recorder;

  /// The flow's notifier, kept so the recording result can still reach it after this widget is gone.
  late final EventLogNotifier _flow = ref.read(eventLogProvider.notifier);

  /// Stops a running recording (its result is then discarded, see [_toggle]) and releases the microphone.
  /// Side effect: the recorded file of an unfinished note is deleted. Throws nothing.
  @override
  void dispose() {
    final recorder = _recorder;
    if (recorder != null) {
      unawaited(recorder.stop().then((_) {}, onError: (Object _) {}).whenComplete(recorder.dispose));
    }
    super.dispose();
  }

  /// Starts recording, or stops a running one. While it records, the draft's `recording` flag keeps the confirm tick
  /// off, so a note is never dropped by an early tick. A refused microphone or a failed recording opens its one-button
  /// sheet. Side effects: microphone, a file in the media folder, the draft's voice note. Throws nothing.
  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    final recorder = _recorder ??= ref.read(voiceRecorderFactoryProvider)();
    if (ref.read(eventLogProvider).recording) {
      // The result listener below stores the note; a failed stop reaches it as RecorderFailed.
      await recorder.stop().then((_) {}, onError: (Object _) {});
      return;
    }
    final dir = (await ref.read(mediaDirProvider.future))..createSync(recursive: true);
    final started = await recorder.start(dir.path, const Uuid().v7());
    if (!mounted) return;
    if (started == VoiceStart.micDenied) {
      return showFarmerSheet(
        context,
        icon: Icons.mic_off,
        sentence: l10n.micOff,
        promptId: 'micOff',
        actionIcon: Icons.check,
        actionLabel: l10n.okay,
        actionPromptId: 'okay',
      );
    }
    _flow.update((d) => d.recording = true);
    recorder.result.then(
      (note) {
        // Screen left while recording (Retake): the note belongs to no photo any more.
        if (!mounted) return deleteQuietly(note.file.path);
        _flow
          ..setVoice(note)
          ..update((d) => d.recording = false);
      },
      onError: (Object _) {
        if (!mounted) return;
        _flow.update((d) => d.recording = false);
        showFarmerSheet(
          context,
          icon: Icons.mic_off,
          sentence: l10n.recordFailed,
          promptId: 'recordFailed',
          actionIcon: Icons.mic,
          actionLabel: l10n.recordAgain,
          actionPromptId: 'recordAgain',
          onAction: _toggle,
        );
      },
    );
  }

  /// Builds the button for the current state. [context] supplies strings. Returns it; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasNote = ref.watch(eventLogProvider.select((d) => d.voice != null));
    final recording = ref.watch(eventLogProvider.select((d) => d.recording));
    final (icon, label, prompt) = recording
        ? (Icons.stop, l10n.voiceStop, 'voiceStop')
        : hasNote
        ? (Icons.check_circle, l10n.voiceAdded, 'voiceAdded')
        : (Icons.mic, l10n.voiceNote, 'voiceNote');
    return FarmerButton(icon: icon, label: label, onPressed: _toggle, onSpeak: () => playPrompt(ref, context, prompt));
  }
}
