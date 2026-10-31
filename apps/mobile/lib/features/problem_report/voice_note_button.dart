// Problem report voice note: one button that records up to 30 seconds (stopped by the farmer or by the cap) and
// attaches the note to the problem entry as a `voice` media row.
// Requirement: UserFlows §Each farm event ("Problem (pest, disease, rain damage) | Photo plus a 30-second voice note |
//   alert to the field officer"), §When things go wrong (one sentence + one button, never an error code); FR3.
// Callers: ConfirmScreen (event_log/confirm_screen.dart) for the problem event.

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

class _VoiceNoteButtonState extends ConsumerState<VoiceNoteButton> {
  VoiceNoteRecorder? _recorder;
  bool _recording = false;

  /// Releases the microphone. Throws nothing.
  @override
  void dispose() {
    _recorder?.dispose();
    super.dispose();
  }

  /// Starts recording, or stops a running one. A refused microphone or a failed recording opens its one-button
  /// sheet. Side effects: microphone, a file in the media folder, the draft's voice note. Throws nothing.
  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    final recorder = _recorder ??= ref.read(voiceRecorderFactoryProvider)();
    if (_recording) {
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
    setState(() => _recording = true);
    recorder.result.then(
      (note) {
        ref.read(eventLogProvider.notifier).setVoice(note);
        if (mounted) setState(() => _recording = false);
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() => _recording = false);
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
    final (icon, label, prompt) = _recording
        ? (Icons.stop, l10n.voiceStop, 'voiceStop')
        : hasNote
        ? (Icons.check_circle, l10n.voiceAdded, 'voiceAdded')
        : (Icons.mic, l10n.voiceNote, 'voiceNote');
    return FarmerButton(icon: icon, label: label, onPressed: _toggle, onSpeak: () => playPrompt(ref, context, prompt));
  }
}
