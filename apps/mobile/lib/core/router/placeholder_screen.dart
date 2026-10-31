// Placeholder screens: each role home shows its title, a spoken "coming soon" and the language switch; unknown routes
// show a farmer-friendly "not here" page.
// Requirement: plan §7.2 M00 (placeholder screens showing the role name; locale switch re-renders the
//   sample screen in Tamil), UserFlows §Design rules "Language first" (switched with one button);
//   UserFlows §When things go wrong (never an error code: one picture, one sentence read aloud, one button).
// Callers: app_router.dart routes /officer, /qc, /assist/:farmerId, /home/farm and its errorBuilder (NotFoundScreen,
//   also M08 history detail for an unknown entry). M08 replaced the Sell, Money and settings placeholders
//   (features/sell, money, settings); M09 (my farm), M10 (officer, assist) and M11 (QC) replace the rest.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
