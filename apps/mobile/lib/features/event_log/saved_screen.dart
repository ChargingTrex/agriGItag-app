// F08 Saved: green tick, and a grey cloud with "Saved. Will send when signal comes." while the entry waits to send;
// Undo for 24 hours; "Again" for a second sowing round; "Keep drying" when packing did not make the lot ready.
// Requirement: UserFlows §When things go wrong (No signal: "Entry saves with a green tick and a small grey cloud";
//   Wrong entry: "Undo" for 24 hours), §Each farm event (sowing "Again" button; packing → "Ready to sell"), Dataflow
//   Stages 5–6 (lot stays in Drying above the moisture limit, farmer prompted to continue drying); FR6.
// Callers: app_router.dart route `/home/saved` (ConfirmScreen after the save). History and the entry detail with its
//   own Undo are M08.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/cloud_sync_indicator.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'event_log_controller.dart';
import 'farm_event.dart';
import 'farmer_sheet.dart';

/// The saved screen of the draft just saved.
class SavedScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SavedScreen({super.key});

  /// Creates the state that shows the "keep drying" sheet once. Returns it; throws nothing.
  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

/// State of [SavedScreen]: the undo in progress and the one-time keep-drying sheet.
class _SavedScreenState extends ConsumerState<SavedScreen> {
  /// True while the undo runs (the Undo button is off, so it cannot run twice).
  bool _undoing = false;

  /// After the first frame, tells the farmer to keep drying when the packing save left the lot not ready.
  /// Side effect: a bottom sheet. Throws nothing.
  @override
  void initState() {
    super.initState();
    final d = ref.read(eventLogProvider);
    if (d.event == FarmEvent.packing && !d.lotNowReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        showFarmerSheet(
          context,
          icon: Icons.wb_sunny,
          sentence: l10n.keepDrying,
          promptId: 'keepDrying',
          actionIcon: Icons.check,
          actionLabel: l10n.okay,
          actionPromptId: 'okay',
        );
      });
    }
  }

  /// Undoes the entry and goes home. Side effects: see [EventLogNotifier.undo]. Throws nothing; a closed window
  /// (StateError) just goes home, because the button is only shown inside it.
  Future<void> _undo() async {
    setState(() => _undoing = true);
    try {
      await ref.read(eventLogProvider.notifier).undo();
    } on StateError {
      // Window closed or entry changed meanwhile: nothing to undo here any more.
    }
    if (mounted) context.go('/home');
  }

  /// Builds tick (+ cloud while waiting), sentence, Home, Undo, Again (sowing) and Call officer. [context] supplies
  /// theme and strings. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final d = ref.watch(eventLogProvider);
    final waiting = (ref.watch(pendingSendCountProvider).value ?? 0) > 0;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.savedTitle),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: tokens.gap),
            child: const CloudSyncIndicator(),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          // Green tick, plus the grey cloud while the entry waits to send: shapes, not colour alone.
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tokens.done.icon, color: tokens.done.color, size: 96),
                if (waiting) ...[
                  SizedBox(width: tokens.gap),
                  Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 64),
                ],
              ],
            ),
          ),
          gap,
          VoicePromptBar(
            key: ValueKey(waiting),
            promptId: waiting ? 'savedOffline' : 'savedOnline',
            text: waiting ? l10n.savedOffline : l10n.savedOnline,
          ),
          if (d.lotNowReady) ...[gap, VoicePromptBar(promptId: 'lotReady', text: l10n.lotReady)],
          gap,
          FarmerButton(
            icon: Icons.home,
            label: l10n.goHome,
            onPressed: () => context.go('/home'),
            onSpeak: () => playPrompt(ref, context, 'goHome'),
            prominent: true,
          ),
          if (d.savedEntryId != null) ...[
            gap,
            FarmerButton(
              icon: Icons.undo,
              label: l10n.undo,
              onPressed: _undoing ? null : _undo,
              onSpeak: () => playPrompt(ref, context, 'undo'),
            ),
          ],
          if (d.event == FarmEvent.sowing) ...[
            gap,
            FarmerButton(
              icon: Icons.replay,
              label: l10n.logAgain,
              onPressed: () => context.go('/log/${FarmEvent.sowing.wireName}'),
              onSpeak: () => playPrompt(ref, context, 'logAgain'),
            ),
          ],
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}
