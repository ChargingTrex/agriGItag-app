// F14 Settings (every role): the unsent-entries reminder with "Send now" (a red triangle once entries waited 7 days),
// the language button, "Photos on Wi-Fi only" (default off), "Reminders" (default on, M12), the voice tour replay and
// sign-out.
// Requirement: UserFlows §Design rules ("Language first ... switched with one button"; "Works with no signal"),
//   §Alerts, help and feature phones ("A 60-second voice tour can be replayed from the menu"), §When things go wrong
//   (unsent entries on a lost phone are lost, "so the cloud icon reminds farmers to get signal"); PLAN §13 B5 ("Send
//   photos on Wi-Fi only", default OFF); mobile-design.md §3 ("after 7 days unsent → red triangle + voice prompt");
//   M06 sign-out (D-029: unsent entries stay on the phone); plan §7.2 M08 (language toggle flips strings + next prompt);
//   FR7 and plan §7.2 M12 (reminders switch, D-046).
// Callers: app_router.dart route `/settings` (gear on the farmer home and on the placeholder homes).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/session.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/event_log_controller.dart' show afterSaveProvider, clockProvider;
import '../notifications/reminders.dart' show notificationsPluginProvider, remindersKey, setRemindersOn;

/// How long entries may wait unsent before Settings shows the red "needs attention" warning (mobile-design.md §3).
const unsentWarnAfter = Duration(days: 7);

/// The Settings screen.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  /// Creates the state that tracks a running sign-out. Returns it; throws nothing.
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// State of [SettingsScreen]: the sign-out in progress and the database streams it shows.
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// True while signing out (the button is off, so it cannot run twice).
  bool _busy = false;

  /// The signed-in user's unconfirmed outbox rows.
  late final Stream<int> _pending = ref.read(appDatabaseProvider).outboxDao.pendingCount();

  /// When the oldest of them was queued (null when none).
  late final Stream<DateTime?> _oldest = ref.read(appDatabaseProvider).outboxDao.oldestPending();

  /// Whether the Reminders switch shows: only a farmer gets reminders (startReminders); other roles would see a switch
  /// that does nothing. Read once: the role only changes at sign-out, when this screen leaves (and re-reading it then
  /// would drop the switch's stream a frame early).
  late final bool _farmer = ref.read(sessionProvider).role == Role.farmer;

  /// The stored Reminders switch (`off` when off; null = never set = on).
  late final Stream<String?> _reminders = ref.read(appDatabaseProvider).syncStateDao.watch(remindersKey);

  /// The session row (for the Wi-Fi-only switch).
  late final Stream<SessionRow?> _session = ref.read(appDatabaseProvider).sessionDao.watch();

  /// Signs out through M06's SessionNotifier. Side effects: tokens and the Session row gone, the router leaves for
  /// /auth; unsent entries stay (D-029). Throws nothing: on a failure the button works again.
  Future<void> _signOut() async {
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).signOut();
    } finally {
      // On success the router has already left this screen; on a failure the button works again.
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Builds the reminder, the buttons and the switches. [context] supplies theme and strings. Returns the screen;
  /// throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        // 56 dp back button (Material's implied one is 48 dp, below the farmer minimum).
        leading: BackButton(style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget))),
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          // Unsent entries stay on the phone after sign-out (never deleted); say so before the user leaves.
          StreamBuilder<int>(
            stream: _pending,
            builder: (context, pending) => (pending.data ?? 0) == 0
                ? const SizedBox.shrink()
                : StreamBuilder<DateTime?>(
                    stream: _oldest,
                    builder: (context, oldest) => _unsent(context, pending.data!, oldest.data),
                  ),
          ),
          FarmerButton(
            icon: Icons.translate,
            label: l10n.switchLanguage,
            // The strings re-render at once, and every later prompt plays in the new language: VoicePlayer takes the
            // language from the screen's locale at each play.
            onPressed: () {
              final notifier = ref.read(sessionProvider.notifier);
              notifier.setLocale(ref.read(sessionProvider).locale == tamil ? english : tamil);
            },
            onSpeak: () => playPrompt(ref, context, 'switchLanguage'),
          ),
          gap,
          StreamBuilder<SessionRow?>(
            stream: _session,
            builder: (context, row) => SwitchListTile(
              title: Text(l10n.wifiOnlyPhotos),
              // PLAN §13 B5: default off, so photos never wait for a Wi-Fi most farmers do not have.
              value: row.data?.wifiOnlyPhotos ?? false,
              onChanged: row.data == null
                  ? null
                  : (on) => ref.read(appDatabaseProvider).sessionDao.setWifiOnlyPhotos(on),
              secondary: IconButton(
                style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
                tooltip: l10n.playVoice,
                icon: const Icon(Icons.volume_up),
                onPressed: () => playPrompt(ref, context, 'wifiOnlyPhotos'),
              ),
            ),
          ),
          gap,
          if (_farmer) ...[
            StreamBuilder<String?>(
              stream: _reminders,
              builder: (context, stored) => SwitchListTile(
                title: Text(l10n.remindersToggle),
                // FR7: on by default; turning it off cancels every scheduled reminder (startReminders reschedules).
                value: stored.data != 'off',
                onChanged: (on) =>
                    setRemindersOn(ref.read(appDatabaseProvider), ref.read(notificationsPluginProvider), on),
                secondary: IconButton(
                  style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
                  tooltip: l10n.playVoice,
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => playPrompt(ref, context, 'remindersToggle'),
                ),
              ),
            ),
            gap,
          ],
          FarmerButton(
            icon: Icons.record_voice_over,
            label: l10n.onboardVoiceTour,
            onPressed: () => playPrompt(ref, context, 'onboardTour'),
            onSpeak: () => playPrompt(ref, context, 'onboardVoiceTour'),
          ),
          gap,
          FarmerButton(
            icon: Icons.logout,
            label: l10n.signOut,
            onPressed: _busy ? null : _signOut,
            onSpeak: () => playPrompt(ref, context, 'signOut'),
          ),
        ],
      ),
    );
  }

  /// The unsent reminder for [count] waiting rows, the oldest queued at [oldest]: the plain sentence, or the red
  /// triangle and the spoken warning once [oldest] is [unsentWarnAfter] old; then "Send now". [context] supplies theme
  /// and strings. Returns the block; throws nothing.
  Widget _unsent(BuildContext context, int count, DateTime? oldest) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final old = oldest != null && !ref.read(clockProvider)().isBefore(oldest.add(unsentWarnAfter));
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (old) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(status: FarmerStatus.attention),
            ),
            SizedBox(height: tokens.gap / 2),
            VoicePromptBar(promptId: 'unsentOld', text: l10n.unsentOld),
          ] else
            Text(l10n.unsentReminder(count), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.gap),
          FarmerButton(
            icon: Icons.cloud_upload,
            label: l10n.sendNow,
            onPressed: () => ref.read(afterSaveProvider)(),
            onSpeak: () => playPrompt(ref, context, 'sendNow'),
          ),
        ],
      ),
    );
  }
}
