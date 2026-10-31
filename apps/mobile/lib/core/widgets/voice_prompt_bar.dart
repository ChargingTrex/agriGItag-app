// VoicePromptBar: the screen's one spoken sentence, played on entry, with a speaker to hear it again.
// Requirement: UserFlows §Design rules "Pictures and voice before words" (speaker icon plays a recorded
//   prompt) and §When things go wrong ("one short sentence read aloud"); mobile-design.md §5 (prompt id =
//   string key; missing clip -> text only + counter, no TTS).
// Callers: ConfirmScaffold, ErrorSheet (this folder); farmer screens from M07 on; test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';

/// Speaker button plus the prompt's text. Plays [promptId] once when first shown if autoplay is on.
///
/// The text is always visible (people who read, screen readers). When the clip is missing or fails, the
/// speaker turns into a crossed-out speaker labelled "No voice" and the text is all the farmer gets; the miss
/// is counted by [VoicePlayer.missingClips].
class VoicePromptBar extends ConsumerStatefulWidget {
  /// Creates the bar.
  ///
  /// [promptId] is the ARB key of the sentence (and the clip name); [text] is that sentence, already
  /// localised by the caller (it may carry placeholders such as a bag count).
  const VoicePromptBar({super.key, required this.promptId, required this.text});

  /// Voice prompt id: the ARB key, clip `assets/audio/<lang>/<promptId>.ogg`.
  final String promptId;

  /// Localised sentence shown next to the speaker.
  final String text;

  /// Creates the state that remembers whether the clip was missing. Returns it; throws nothing.
  @override
  ConsumerState<VoicePromptBar> createState() => _VoicePromptBarState();
}

class _VoicePromptBarState extends ConsumerState<VoicePromptBar> {
  bool _missing = false;

  /// Schedules the autoplay after the first frame (the locale is only readable once mounted).
  /// Side effect: plays audio when [voiceAutoplayProvider] is true. Throws nothing.
  @override
  void initState() {
    super.initState();
    if (ref.read(voiceAutoplayProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  /// Plays the prompt and records whether it was missing. Side effect: audio, and a rebuild when the
  /// missing state changes. Throws what [VoicePlayer.play] throws for a broken manifest.
  Future<void> _play() async {
    if (!mounted) return;
    final played = await playPrompt(ref, context, widget.promptId);
    if (mounted && played == _missing) setState(() => _missing = !played);
  }

  /// Builds the speaker and the sentence. [context] supplies theme, tokens and strings. Returns the bar;
  /// throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            MergeSemantics(
              child: Semantics(
                label: _missing ? l10n.voiceMissing : l10n.playVoice,
                child: IconButton.filledTonal(
                  // Still tappable when missing: a clip that failed once may play on retry.
                  onPressed: _play,
                  icon: Icon(_missing ? Icons.volume_off : Icons.volume_up, size: 28),
                  style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
                ),
              ),
            ),
            SizedBox(width: tokens.gap),
            Expanded(child: Text(widget.text, style: theme.textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }
}
