// F03 Farmer home: the next task as one big card, four buttons (Log / Sell / Money / My farm), History (M08, where the
// 24-hour Undo lives), Call officer, the cloud icon, and the assist bar while a field officer logs for the farmer.
// Requirement: UserFlows §Farmer home screen ("the card at the top always holds the single most useful next step, and
//   the four buttons cover everything else"), §Design rules (one job, pictures + voice, "Works with no signal": cloud
//   icon, "Help is a person"), §Field officer flows (assist bar "Logging for: [farmer name]"); FR7 (next event);
//   CLAUDE.md §6 (assist mode always visible).
// Callers: app_router.dart route `/home` (the farmer role's home).

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/assist_bar.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/cloud_sync_indicator.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/choose_event_screen.dart';
import '../event_log/event_log_controller.dart';
import '../event_log/farm_event.dart';

/// The farmer's open task due first (Tasks DAO), re-emitted when tasks change; null when there is none.
///
/// The farmer is the assisted one in assist mode, else the farmer row on this phone (a farmer's phone holds only its
/// owner), else the owner of the first lot.
final nextTaskProvider = StreamProvider<FarmTask?>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final farmerId =
      ref.watch(assistFarmerProvider)?.farmerId ??
      (await (db.select(db.farmers)..limit(1)).getSingleOrNull())?.farmerId ??
      (await (db.select(db.lots)
                ..orderBy([(l) => OrderingTerm.asc(l.plotId)])
                ..limit(1))
              .getSingleOrNull())
          ?.farmerId;
  if (farmerId == null) {
    yield null;
    return;
  }
  yield* db.tasksDao.nextForFarmer(farmerId);
});

/// The farmer home screen.
class FarmerHomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const FarmerHomeScreen({super.key});

  /// Builds the app bar (cloud, settings), the assist bar, the task card and the buttons. [context] supplies theme
  /// and strings; [ref] watches the task and the assist state. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final assist = ref.watch(assistFarmerProvider);
    final gap = SizedBox(height: tokens.gap);
    FarmerButton button(IconData icon, String label, String promptId, String path) => FarmerButton(
      icon: icon,
      label: label,
      onPressed: () => context.push(path),
      onSpeak: () => playPrompt(ref, context, promptId),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          const CloudSyncIndicator(),
          IconButton(
            // 56 dp: the farmer minimum (Material's default is 48 dp).
            style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (assist != null) AssistBar(farmerName: assist.name),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(tokens.gap),
              children: [
                _TaskCard(task: ref.watch(nextTaskProvider).value),
                gap,
                button(Icons.add_a_photo, l10n.homeLog, 'homeLog', '/log'),
                gap,
                button(Icons.qr_code, l10n.homeSell, 'homeSell', '/home/sell'),
                gap,
                button(Icons.currency_rupee, l10n.homeMoney, 'homeMoney', '/home/money'),
                gap,
                button(Icons.agriculture, l10n.homeMyFarm, 'homeMyFarm', '/home/farm'),
                gap,
                button(Icons.history, l10n.homeHistory, 'homeHistory', '/home/history'),
                gap,
                const CallFieldOfficerButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The big next-task card: picture, the spoken sentence, an orange "to do" badge and the button that opens the event
/// (`/log/<event>`, preselected). Without a task it offers "Log an event".
class _TaskCard extends ConsumerWidget {
  /// Creates the card for [task], or the fallback card when null.
  const _TaskCard({required this.task});

  /// The open task due first, or null.
  final FarmTask? task;

  /// Builds the card. [context] supplies theme, strings and the locale (dates read "14 Feb"); [ref] plays prompts.
  /// Returns the card; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final event = FarmEvent.fromWire(task?.eventType);
    final gap = SizedBox(height: tokens.gap);
    final String sentence;
    final String promptId;
    if (task == null || event == null) {
      (sentence, promptId) = (l10n.homeNoTask, 'homeNoTask');
    } else {
      final due = DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag()).format(task!.dueDate);
      // The server's prompt id carries the recorded reminder; the text is ours, with the date.
      (sentence, promptId) = (l10n.homeNextTask(event.label(l10n), due), task!.promptId);
    }
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event != null) eventPicture(event) else const Icon(Icons.add_a_photo, size: 72),
            gap,
            VoicePromptBar(key: ValueKey(promptId), promptId: promptId, text: sentence),
            if (event != null) ...[
              gap,
              const Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: FarmerStatus.todo),
              ),
            ],
            gap,
            FarmerButton(
              icon: Icons.arrow_forward,
              label: event?.label(l10n) ?? l10n.homeLogEvent,
              // The task's lot rides along (D-043), so a farmer with two fields skips the field picker.
              onPressed: () => context.push(switch ((event, task?.lotId)) {
                (null, _) => '/log',
                (final e?, null) => '/log/${e.wireName}',
                (final e?, final lot?) => '/log/${e.wireName}?lot=$lot',
              }),
              onSpeak: () => playPrompt(ref, context, event?.promptId ?? 'homeLogEvent'),
              prominent: true,
            ),
          ],
        ),
      ),
    );
  }
}
