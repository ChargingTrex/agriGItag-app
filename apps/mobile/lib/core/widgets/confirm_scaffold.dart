// ConfirmScaffold: the third tap of every routine event — photo/summary, the entry read aloud, a big tick
//   and Retake.
// Requirement: UserFlows §Logging a farm event ("the confirm screen reads the entry aloud ... and offers only
//   a big tick or Retake"), §Design rules "Three taps", "Mistakes are easy to undo" (confirm shows the photo
//   before saving), "Help is a person" (call button on every screen), "Works with no signal" (cloud icon);
//   mobile-design.md §4 (required fields block the confirm tick, D-017).
// Callers: every event flow's confirm step (M07), problem report (M07), onboarding summary (M09);
//   test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';
import 'call_officer_button.dart';
import 'cloud_sync_indicator.dart';
import 'farmer_button.dart';
import 'voice_prompt_bar.dart';

/// Full confirm screen: app bar (title, optional cloud), spoken summary, preview, tick, Retake, call officer.
class ConfirmScaffold extends ConsumerWidget {
  /// Creates the screen.
  ///
  /// [title] names the event (e.g. "Harvest"); [preview] is the photo or summary picture and fills the free
  /// height; [summary] is the localised sentence shown and spoken ("Harvest, 6 bags, today — correct?");
  /// [promptId] is its recorded clip; [onConfirm] saves the entry, null disables the tick (a required field
  /// is missing); [onRetake] goes back to the camera; [showCloud] adds the [CloudSyncIndicator] to the bar.
  const ConfirmScaffold({
    super.key,
    required this.title,
    required this.preview,
    required this.summary,
    required this.promptId,
    required this.onConfirm,
    required this.onRetake,
    this.showCloud = false,
  });

  /// Localised event name shown in the app bar.
  final String title;

  /// Photo or summary picture.
  final Widget preview;

  /// Localised sentence read aloud and shown above the preview.
  final String summary;

  /// Voice prompt id of [summary].
  final String promptId;

  /// Saves the entry; null disables the tick.
  final VoidCallback? onConfirm;

  /// Discards the photo and reopens the camera.
  final VoidCallback onRetake;

  /// Whether the app bar shows the pending-send cloud.
  final bool showCloud;

  /// Builds the screen. [context] supplies theme, tokens and strings; [ref] plays the button prompts.
  /// Returns the [Scaffold]; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (showCloud)
            Padding(
              padding: EdgeInsets.only(right: tokens.gap),
              child: const CloudSyncIndicator(),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VoicePromptBar(promptId: promptId, text: summary),
              gap,
              Expanded(
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: preview),
              ),
              gap,
              FarmerButton(
                icon: tokens.done.icon,
                label: l10n.confirmCorrect,
                onPressed: onConfirm,
                onSpeak: () => playPrompt(ref, context, 'confirmCorrect'),
                prominent: true,
              ),
              gap,
              FarmerButton(
                icon: Icons.photo_camera,
                label: l10n.retake,
                onPressed: onRetake,
                onSpeak: () => playPrompt(ref, context, 'retake'),
              ),
              gap,
              const CallFieldOfficerButton(),
            ],
          ),
        ),
      ),
    );
  }
}
