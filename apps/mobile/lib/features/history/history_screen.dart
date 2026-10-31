// F12 History and F13 entry detail: the farmer's entries newest first, each with its picture, "14 Feb" date and a
// status glyph (icon + colour + word); tapping one opens it with Undo while its 24-hour undo window is open.
// Requirement: UserFlows §Design rules ("Mistakes are easy to undo ... farmers can undo an entry for 24 hours. Farmers
//   cannot delete"; "Colour plus shape"; dates read "14 Feb"), §When things go wrong (Wrong entry: "Undo" button on
//   the entry for 24 hours; after that only the field officer can correct); plan §7.2 M08 acceptance (undo at
//   24 h − 1 min works, + 1 min absent); CLAUDE.md §6 (undo adds a version, nothing is deleted); FR6.
//   M10 assist mode: the same screens under `/assist/:farmerId/history`, listing the assisted farmer's entries, with no
//   Undo (the server lets only the farmer who entered an event undo it; officers correct, FR6).
// Callers: app_router.dart routes `/home/history` and `/home/history/:entryId` and their assist copies (farmer home
//   "History" button).

import 'package:drift/drift.dart'
    show BooleanExpressionOperators, ComparableExpr, Constant, OrderingTerm, Value, notExistsQuery;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/placeholder_screen.dart' show NotFoundScreen;
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/choose_event_screen.dart' show eventPicture, farmerAppBar;
import '../event_log/event_log_controller.dart';
import '../event_log/farm_event.dart';

/// The signed-in user's farm-event entries that stand: the latest version of each entry chain, newest first; an undone
/// entry drops out because its `undo` row supersedes it (and undo rows are not farm events), or because the pull marked
/// it `undone`. Re-emitted on every Entries change.
///
/// Only entries entered by the signed-in user are listed (D-029): on a shared phone the next user must not undo the
/// previous user's entry, because the undo row would be sent under that user's identity.
///
/// While an officer assists (M10), only the assisted farmer's entries that this officer entered are listed.
final historyProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final assist = ref.watch(assistFarmerProvider);
  final newer = db.alias(db.entries, 'newer');
  final query = db.select(db.entries)
    ..where(
      (e) =>
          e.entryType.isIn([for (final f in FarmEvent.values) f.wireName]) &
          e.status.equalsValue(EntryStatus.undone).not() &
          e.enteredByUserId.isInQuery(db.selectOnly(db.sessionTable)..addColumns([db.sessionTable.userId])) &
          (assist == null ? const Constant(true) : e.farmerId.equals(assist.farmerId)) &
          notExistsQuery(
            db.select(newer)..where((n) => n.rootId.equalsExp(e.rootId) & n.version.isBiggerThan(e.version)),
          ),
    )
    // Same device time (a batch of pulled entries): UUIDv7 ids sort by creation, so the last logged comes first.
    ..orderBy([(e) => OrderingTerm.desc(e.deviceTime), (e) => OrderingTerm.desc(e.entryId)]);
  return query.watch();
});

/// The badge of entry [e]: a green tick "Sent" once the server confirmed it, an orange circle "Not sent" while it
/// waits on the phone, a red triangle "Needs attention" when the server refused it. Uses [l10n] for the words.
/// Returns the badge; throws nothing.
StatusBadge entryBadge(Entry e, AppLocalizations l10n) => switch (e.status) {
  EntryStatus.confirmed => StatusBadge(status: FarmerStatus.done, label: l10n.entrySent),
  EntryStatus.rejected => const StatusBadge(status: FarmerStatus.attention),
  _ => StatusBadge(status: FarmerStatus.todo, label: l10n.entryWaiting),
};

/// [t] as the farmer reads a date ("14 Feb") in [context]'s language. Throws nothing.
String farmerDate(BuildContext context, DateTime t) =>
    DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag()).format(t);

/// The History list.
class HistoryScreen extends ConsumerWidget {
  /// Creates the screen.
  const HistoryScreen({super.key});

  /// Builds the spoken sentence and one tappable row per entry (or "nothing logged yet"). [context] supplies theme
  /// and strings; [ref] watches [historyProvider]. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final entries = ref.watch(historyProvider).value;
    return Scaffold(
      appBar: farmerAppBar(context, l10n.homeHistory),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          if (entries != null && entries.isEmpty)
            VoicePromptBar(key: const ValueKey('historyEmpty'), promptId: 'historyEmpty', text: l10n.historyEmpty)
          else
            VoicePromptBar(key: const ValueKey('historyPrompt'), promptId: 'historyPrompt', text: l10n.historyPrompt),
          for (final e in entries ?? const <Entry>[]) ...[
            SizedBox(height: tokens.gap / 2),
            Card.outlined(
              margin: EdgeInsets.zero,
              child: ListTile(
                minTileHeight: tokens.minTarget,
                leading: SizedBox.square(
                  dimension: tokens.minTarget,
                  child: eventPicture(FarmEvent.fromWire(e.entryType)!),
                ),
                title: Text(FarmEvent.fromWire(e.entryType)!.label(l10n)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(farmerDate(context, e.deviceTime)), entryBadge(e, l10n)],
                ),
                onTap: () => context.push(farmerPath(ref, '/home/history/${e.entryId}')),
              ),
            ),
          ],
          SizedBox(height: tokens.gap),
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}

/// One entry: picture, spoken "Harvest, 14 Feb.", its status, and Undo while the undo window is open (else the
/// sentence that only the field officer can correct it now).
class HistoryDetailScreen extends ConsumerStatefulWidget {
  /// Creates the screen for entry [entryId].
  const HistoryDetailScreen({super.key, required this.entryId});

  /// Client id (UUIDv7) of the entry shown.
  final String entryId;

  /// Creates the state that tracks a running undo. Returns it; throws nothing.
  @override
  ConsumerState<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

/// State of [HistoryDetailScreen]: whether the undo is running.
class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  /// True while the undo runs (the button is off, so it cannot run twice).
  bool _undoing = false;

  /// Undoes [e] (EntriesDao.undo, the same path as the Saved screen's Undo), kicks a send and returns to the list.
  ///
  /// Side effects: an `undo` version queued; a lot that this packing made "ready to sell" goes back to `open` (a
  /// preview; the next pull brings the server's status). Throws nothing: a window that closed meanwhile (StateError)
  /// only returns to the list.
  Future<void> _undo(Entry e) async {
    setState(() => _undoing = true);
    final db = ref.read(appDatabaseProvider);
    try {
      await db.transaction(() async {
        await db.entriesDao.undo(e.entryId, now: ref.read(clockProvider)());
        // shortcut: tasks the entry completed stay done and the lot goes to `open` (not its status before the
        //   packing, which History does not know) until the next pull; the Saved screen's Undo restores both from its
        //   draft. Upgrade when Entries or the pull carry the previous lot status.
        if (e.entryType == FarmEvent.packing.wireName && e.lotId != null) {
          await (db.update(db.lots)..where((l) => l.lotId.equals(e.lotId!) & l.status.equals(readyForSale))).write(
            const LotsCompanion(status: Value('open')),
          );
        }
      });
      ref.read(afterSaveProvider)();
    } on StateError {
      // Window closed or the entry changed meanwhile: nothing to undo any more.
    }
    if (mounted) context.go(farmerPath(ref, '/home/history'));
  }

  /// Builds picture, sentence, badge, Undo (or the "officer corrects" sentence) and Call officer. [context] supplies
  /// theme and strings. Returns the screen, or the "not here" page for an unknown or undone entry; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final entries = ref.watch(historyProvider).value;
    if (entries == null) return const Scaffold();
    final e = entries.where((x) => x.entryId == widget.entryId).firstOrNull;
    if (e == null) return const NotFoundScreen();
    final event = FarmEvent.fromWire(e.entryType)!;
    // The window is checked when the screen builds; EntriesDao.undo checks it again at the tap.
    final canUndo = e.status != EntryStatus.rejected && ref.read(clockProvider)().isBefore(e.undoDeadline);
    // Assist mode: no Undo and no "only the officer corrects" line; the officer corrects through the flags (FR6).
    final assisting = ref.watch(assistFarmerProvider) != null;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: farmerAppBar(context, event.label(l10n)),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          eventPicture(event),
          gap,
          VoicePromptBar(
            promptId: 'historyDetail',
            text: l10n.historyDetail(event.label(l10n), farmerDate(context, e.deviceTime)),
          ),
          gap,
          Align(alignment: Alignment.centerLeft, child: entryBadge(e, l10n)),
          gap,
          if (assisting)
            const SizedBox.shrink()
          else if (canUndo)
            FarmerButton(
              icon: Icons.undo,
              label: l10n.undo,
              onPressed: _undoing ? null : () => _undo(e),
              onSpeak: () => playPrompt(ref, context, 'undo'),
            )
          else
            VoicePromptBar(promptId: 'undoClosed', text: l10n.undoClosed),
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}
