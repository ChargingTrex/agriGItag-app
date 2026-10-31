// Q-home: the QC officer's home (route /qc, reachable only by the qc_officer role through the router's redirect):
//   "Receive lot" opens the lot scanner (intake), "Grade batch" the batch list (grading, final packing).
// Requirement: UserFlows §Who uses what (QC / grading officer: "Record intake moisture, grading readings and lab
//   results"), §Selling to the FPO, §Grade a batch, §Design rules (one job per screen, voice before words, 56 dp),
//   mobile-design.md §4 QC screens, PLAN §7.2 M11, D-013 (role routing).
// Callers: core/router/app_router.dart (/qc); test/features/qc/*, test/widget/router_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../qc_grading/batch_list_screen.dart';
import '../qc_intake/scan_screen.dart';

/// The QC home: spoken prompt, two big buttons, and the gear to /settings.
class QcHomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const QcHomeScreen({super.key});

  /// Builds the screen. [context] supplies tokens, strings and navigation; [ref] plays the button prompts. Returns
  /// the [Scaffold]; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    // The QC screens push each other with Navigator (one GoRoute, /qc): their arguments are objects, not URL parts.
    void open(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
    return Scaffold(
      appBar: AppBar(
        // The role's home: there is nothing behind it (and the default back arrow is a 48 dp target).
        automaticallyImplyLeading: false,
        title: Text(l10n.roleQc),
        actions: [
          IconButton(
            // 56 dp: the farmer minimum (Material's default is 48 dp).
            style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(tokens.gap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VoicePromptBar(promptId: 'qcHomePrompt', text: l10n.qcHomePrompt),
              gap,
              FarmerButton(
                icon: Icons.qr_code_scanner,
                label: l10n.qcReceiveLot,
                onPressed: () => open(const ScanScreen()),
                onSpeak: () => playPrompt(ref, context, 'qcReceiveLot'),
                prominent: true,
              ),
              gap,
              FarmerButton(
                icon: Icons.grading,
                label: l10n.qcGradeBatch,
                onPressed: () => open(const BatchListScreen()),
                onSpeak: () => playPrompt(ref, context, 'qcGradeBatch'),
                prominent: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
