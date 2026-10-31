// Officer home: the field officer's to-do list. Sync status, "Add farmer", the flags count, today's visits (farmers with
//   an event due) and every farmer, both grouped by village; tapping a farmer starts assist mode for them.
// Requirement: UserFlows §Field officer flows ("a to-do list sorted by village": Today's visits, Flags to clear,
//   Farmers without phones; Assist mode step 1 "Tap the farmer's name"), §Onboarding a farmer ("Add farmer"),
//   §Design rules ("Works with no signal": the cloud icon); mobile-design.md §3 (M02 `strandedCount` for other users'
//   unsent entries on a shared phone, D-029); D-032 (assist mode starts with an `assist_session` entry carrying the
//   officer's GPS).
// Callers: app_router.dart route `/officer` (the field-officer role's home).

import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/capture/gps_fix.dart';
import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/sync_providers.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/cloud_sync_indicator.dart';
import '../../core/widgets/status_badge.dart';
import '../event_log/choose_event_screen.dart' show farmerAppBar;
import '../event_log/event_log_controller.dart';
import '../officer_assist/assist_controller.dart';
import '../officer_flags/flag_actions.dart';
import 'officer_button.dart';

/// Every farmer on the phone (the officer's FPO), by village then name, with whether an open task is due by the end
/// of today ([clockProvider]); re-emitted when farmers or tasks change. The officer home invalidates it when the app
/// comes back to the foreground, so "today" moves on after midnight.
///
/// shortcut: a screen left on, never paused, across midnight keeps yesterday's cut-off until the next resume; add a
///   midnight timer if officers report it.
final officerFarmersProvider = StreamProvider<List<({Farmer farmer, bool visitDue})>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = ref.watch(clockProvider)();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final due = existsQuery(
    db.select(db.tasks)
      ..where((t) => t.farmerId.equalsExp(db.farmers.farmerId) & t.done.not() & t.dueDate.isSmallerThanValue(tomorrow)),
  );
  final query = (db.select(
    db.farmers,
  )..orderBy([(f) => OrderingTerm.asc(f.village), (f) => OrderingTerm.asc(f.name)])).addColumns([due]);
  return query.watch().map((rows) => [for (final r in rows) (farmer: r.readTable(db.farmers), visitDue: r.read(due)!)]);
});

/// Oldest officer fix still used as a session's `started_gps`; an older one may be from another village.
const _fixMaxAge = Duration(minutes: 2);

/// The officer home screen. Listens to the GPS while open, so a tap on a farmer starts assist mode at once with the
/// officer's latest fix (at most [_fixMaxAge] old) as the session's `started_gps`. Opening it ends any assist session
/// still running: assist mode is entered with `go`, so the officer home is never under one (review M10-r1 P3-2).
class OfficerHomeScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const OfficerHomeScreen({super.key});

  /// Creates the state holding the GPS subscription. Returns it; throws nothing.
  @override
  ConsumerState<OfficerHomeScreen> createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends ConsumerState<OfficerHomeScreen> {
  StreamSubscription<LocationFix>? _gps;
  LocationFix? _fix;
  DateTime? _fixAt;
  bool _starting = false;
  late final AppLifecycleListener _life;

  /// Starts listening to the GPS and to app resume, and ends an assist session left running (the not-found Home
  /// button, a hard-coded `/home…` link). Throws nothing; GPS provider errors are ignored (the session then has no
  /// GPS). Side effects: may end assist mode (`POST /assist/end` in the background).
  @override
  void initState() {
    super.initState();
    _gps = ref.read(gpsFixProvider).fixes().listen((fix) {
      _fix = fix;
      _fixAt = ref.read(clockProvider)();
    }, onError: (Object _) {});
    _life = AppLifecycleListener(onResume: () => ref.invalidate(officerFarmersProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(assistProvider.notifier).end();
    });
  }

  /// Stops the GPS and the lifecycle listener. Throws nothing.
  @override
  void dispose() {
    _gps?.cancel();
    _life.dispose();
    super.dispose();
  }

  /// Starts assist mode for [farmer] and opens their home (`/assist/<id>`). A second tap while the first is saving is
  /// ignored. Returns when navigated. Throws nothing; a failed write leaves the officer on this screen.
  /// Side effects: see [AssistNotifier.start].
  Future<void> _assist(Farmer farmer) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final fresh = _fixAt != null && ref.read(clockProvider)().difference(_fixAt!) <= _fixMaxAge;
      await ref.read(assistProvider.notifier).start(farmer, gps: fresh ? _fix : null);
      if (mounted) context.go('/assist/${farmer.farmerId}');
    } on Exception {
      // SqliteException (disk full): nothing was written; the officer taps again.
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Builds the app bar (cloud, settings), the stranded-entries line, Add farmer, Flags and the two farmer lists.
  /// [context] supplies theme and strings. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    final stranded = ref.watch(strandedCountProvider).value ?? 0;
    final flags = ref.watch(officerFlagsProvider).value?.length ?? 0;
    final farmers = ref.watch(officerFarmersProvider).value ?? const [];
    final visits = [
      for (final f in farmers)
        if (f.visitDue) f.farmer,
    ];
    return Scaffold(
      appBar: farmerAppBar(
        context,
        l10n.roleFieldOfficer,
        actions: [
          const CloudSyncIndicator(),
          IconButton(
            style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
            icon: const Icon(Icons.settings),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          if (stranded > 0) ...[
            Text(l10n.officerStranded(stranded), style: Theme.of(context).textTheme.titleMedium),
            gap,
          ],
          OfficerButton(
            icon: Icons.person_add,
            label: l10n.officerAddFarmer,
            onPressed: () => context.push('/officer/onboard'),
          ),
          gap,
          OfficerButton(
            icon: Icons.flag,
            label: l10n.officerFlags(flags),
            onPressed: () => context.push('/officer/flags'),
            tonal: true,
          ),
          gap,
          _Header(l10n.officerVisitsToday),
          if (visits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
              child: Text(l10n.officerNoVisits, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ..._byVillage(visits, visitDue: true),
          gap,
          _Header(l10n.officerAllFarmers),
          ..._byVillage([for (final f in farmers) f.farmer]),
        ],
      ),
    );
  }

  /// Tiles for [farmers] (already sorted by village) with a village heading before each village's first farmer;
  /// [visitDue] adds the orange "to do" badge. Returns the widgets; throws nothing.
  List<Widget> _byVillage(List<Farmer> farmers, {bool visitDue = false}) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    String? village;
    return [
      for (final f in farmers) ...[
        if (f.village != village) _Village(village = f.village),
        ListTile(
          minTileHeight: tokens.minTarget,
          enabled: !_starting,
          leading: Icon(f.hasSmartphone ? Icons.person : Icons.phone_disabled, size: 28),
          title: Text(f.name),
          // Farmers without phones are the ones whose events the officer logs in person (UserFlows).
          subtitle: f.hasSmartphone ? null : Text(l10n.officerNoPhone),
          trailing: visitDue ? const StatusBadge(status: FarmerStatus.todo) : const Icon(Icons.chevron_right),
          onTap: () => _assist(f),
        ),
      ],
    ];
  }
}

/// A section heading of the officer home.
class _Header extends StatelessWidget {
  /// Creates the heading with [text].
  const _Header(this.text);

  /// The heading.
  final String text;

  /// Builds the heading as a semantic header. [context] supplies the theme. Returns it; throws nothing.
  @override
  Widget build(BuildContext context) =>
      Semantics(header: true, child: Text(text, style: Theme.of(context).textTheme.titleLarge));
}

/// A village subheading inside a farmer list.
class _Village extends StatelessWidget {
  /// Creates the subheading for [village].
  const _Village(this.village);

  /// Village name.
  final String village;

  /// Builds the subheading. [context] supplies the theme. Returns it; throws nothing.
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(village, style: Theme.of(context).textTheme.titleSmall),
  );
}
