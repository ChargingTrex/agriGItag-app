// Placeholder screen for every M00 route: shows the screen's title (role name) and the language switch.
// Requirement: plan §7.2 M00 (placeholder screens showing the role name; locale switch re-renders the
//   sample screen in Tamil), UserFlows §Design rules "Language first" (switched with one button).
// Callers: app_router.dart routes /auth, /home, /officer, /qc, /assist/:farmerId. Replaced by the real
//   feature screens in M06 (auth), M07 (farmer home), M10 (officer, assist), M11 (QC).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../widgets/farmer_button.dart';
import 'session.dart';

/// A one-job screen: the [title] in large type and one language-switch [FarmerButton].
class PlaceholderScreen extends ConsumerWidget {
  /// Creates the screen. [title] is the already-localised screen name (e.g. the role name).
  const PlaceholderScreen({super.key, required this.title});

  /// Localised title shown in the body.
  final String title;

  /// Builds the screen. [context] supplies theme and strings; [ref] reads and updates the session.
  /// Returns the widget tree; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final session = ref.watch(sessionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: tokens.gap),
            FarmerButton(
              icon: Icons.translate,
              label: l10n.switchLanguage,
              onPressed: () => ref.read(sessionProvider.notifier).setLocale(session.locale == tamil ? english : tamil),
              // shortcut: no voice clip yet, so the speaker slot is disabled; M05 wires the prompt player.
              onSpeak: null,
            ),
          ],
        ),
      ),
    );
  }
}
