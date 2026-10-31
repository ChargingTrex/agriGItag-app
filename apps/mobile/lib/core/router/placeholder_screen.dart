// Placeholder screens: each role home shows its title, a spoken "coming soon" and the language switch; /settings shows
// the language switch and the sign-out button; unknown routes show a farmer-friendly "not here" page.
// Requirement: plan §7.2 M00 (placeholder screens showing the role name; locale switch re-renders the
//   sample screen in Tamil), UserFlows §Design rules "Language first" (switched with one button); M06 sign-out
//   (UserFlows §Who uses what: shared family phones; §When things go wrong: unsent entries stay, the cloud reminds).
//   UserFlows §When things go wrong (never an error code: one picture, one sentence read aloud, one button).
// Callers: app_router.dart routes /qc, /home/{sell,money,farm} (also under /assist/:farmerId), /settings and its
//   errorBuilder (NotFoundScreen). Replaced by the real feature screens in M08 (sell, money, settings), M09 (my farm),
//   M11 (QC); M10 replaced the officer and assist placeholders.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../db/providers.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';
import '../widgets/call_officer_button.dart';
import '../widgets/farmer_button.dart';
import '../widgets/voice_prompt_bar.dart';
import 'session.dart';

/// A one-job screen: the [title] in large type, a spoken "coming soon" and one language-switch [FarmerButton]; a gear
/// opens /settings.
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
        // Pushed from the farmer home (Sell, Money, My farm): a 56 dp back button, not Material's 48 dp one.
        leading: Navigator.of(context).canPop()
            ? BackButton(style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)))
            : null,
        automaticallyImplyLeading: false,
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
      body: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: tokens.gap),
            VoicePromptBar(promptId: 'comingSoon', text: l10n.comingSoon),
            SizedBox(height: tokens.gap),
            FarmerButton(
              icon: Icons.translate,
              label: l10n.switchLanguage,
              onPressed: () => ref.read(sessionProvider.notifier).setLocale(session.locale == tamil ? english : tamil),
              onSpeak: () => playPrompt(ref, context, 'switchLanguage'),
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
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        // 56 dp back button (Material's implied one is 48 dp, below the farmer minimum).
        leading: BackButton(style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget))),
      ),
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
              icon: Icons.translate,
              label: l10n.switchLanguage,
              onPressed: () {
                final notifier = ref.read(sessionProvider.notifier);
                notifier.setLocale(ref.read(sessionProvider).locale == tamil ? english : tamil);
              },
              onSpeak: () => playPrompt(ref, context, 'switchLanguage'),
            ),
            SizedBox(height: tokens.gap),
            FarmerButton(
              icon: Icons.logout,
              label: l10n.signOut,
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await ref.read(sessionProvider.notifier).signOut();
                      } finally {
                        // On success the router has already left this screen; on a failure the button works again.
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              onSpeak: () => playPrompt(ref, context, 'signOut'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Farmer-friendly page for a route that does not exist: one picture, one sentence read aloud, one Home button
/// (the role redirect sends `/` to the caller's home). Never go_router's English "Page Not Found".
class NotFoundScreen extends ConsumerWidget {
  /// Creates the page.
  const NotFoundScreen({super.key});

  /// Builds the page. [context] supplies theme and strings; [ref] plays the button prompt. Returns it; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle), automaticallyImplyLeading: false),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          Icon(Icons.wrong_location, size: 96, color: tokens.attention.color),
          gap,
          VoicePromptBar(promptId: 'notFound', text: l10n.notFound),
          gap,
          FarmerButton(
            icon: Icons.home,
            label: l10n.goHome,
            onPressed: () => context.go('/'),
            onSpeak: () => playPrompt(ref, context, 'goHome'),
            prominent: true,
          ),
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}
