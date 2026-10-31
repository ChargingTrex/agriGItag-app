// Placeholder screens: each role home shows its title and the language switch; /settings shows the sign-out button.
// Requirement: plan §7.2 M00 (placeholder screens showing the role name; locale switch re-renders the
//   sample screen in Tamil), UserFlows §Design rules "Language first" (switched with one button); M06 sign-out
//   (UserFlows §Who uses what: shared family phones; §When things go wrong: unsent entries stay, the cloud reminds).
// Callers: app_router.dart routes /home, /officer, /qc, /assist/:farmerId and /settings. Replaced by the real
//   feature screens in M07 (farmer home), M08 (settings), M10 (officer, assist), M11 (QC).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../db/providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../widgets/farmer_button.dart';
import 'session.dart';

/// A one-job screen: the [title] in large type and one language-switch [FarmerButton]; a gear opens /settings.
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
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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

/// Minimal settings screen: the unsent-entries reminder and the sign-out button (M08 builds the real one).
class SettingsPlaceholder extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SettingsPlaceholder({super.key});

  /// Creates the state that tracks a running sign-out. Returns it; throws nothing.
  @override
  ConsumerState<SettingsPlaceholder> createState() => _SettingsPlaceholderState();
}

class _SettingsPlaceholderState extends ConsumerState<SettingsPlaceholder> {
  bool _busy = false;
  late final Stream<int> _pending = ref.read(appDatabaseProvider).outboxDao.pendingCount();

  /// Builds the reminder and the button. [context] supplies theme and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Unsent entries stay on the phone after sign-out (never deleted); say so before the user leaves.
            // Hook for M02/M05: swap this sentence for the cloud indicator once both are merged.
            StreamBuilder<int>(
              stream: _pending,
              builder: (context, snapshot) => (snapshot.data ?? 0) == 0
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(bottom: tokens.gap),
                      child: Text(l10n.unsentReminder(snapshot.data!), style: Theme.of(context).textTheme.titleMedium),
                    ),
            ),
            FarmerButton(
              icon: Icons.logout,
              label: l10n.signOut,
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await ref.read(sessionProvider.notifier).signOut();
                    },
              // shortcut: no voice clip yet, so the speaker slot is disabled; M05 wires the prompt player.
              onSpeak: null,
            ),
          ],
        ),
      ),
    );
  }
}
