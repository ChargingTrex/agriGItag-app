// Local reminders and the tap that opens the event: every open task in the Tasks table becomes one phone notification
// at its due time, in the app language, naming the event and the farmer's field; a tap opens `/log/<event>?lot=<id>`
// on top of the farmer home. Also the one-time permission rationale (Android 13+, iOS) and the Settings "Reminders"
// switch state.
// Requirement: FR7 (reminders for the expected next event); UserFlows §Alerts, help and feature phones ("Reminders:
//   'Time to log your harvest' ... One tap on the notification opens the right event"), §Logging a farm event (drying
//   "reminder to finish"); PLAN §7.2 M12 (reminder tap → F04 harvest preselected; offline reminder scheduled; payload
//   has no phone/ID); CLAUDE.md §6 (no phone numbers or ID documents in payloads); D-043 (the task's lot rides along);
//   D-046 (reminders scheduled on the phone from Tasks).
// Callers: bootstrap.dart (startReminders); features/settings/settings_screen.dart (setRemindersOn, notificationsPluginProvider);
//   test/notifications/reminders_test.dart.

import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../core/router/session.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/event_log_controller.dart' show clockProvider;
import '../event_log/farm_event.dart';

/// SyncState key of the Settings switch: `off` once the farmer turned reminders off (absent = on).
const remindersKey = 'reminders';

/// SyncState key set once the permission rationale was answered (`yes` / `no`), so it is asked only once.
const permissionAskedKey = 'reminders_permission_asked';

/// The scheduled time as an absolute instant: a fixed UTC zone needs no time-zone database in the app.
final _utc = tz.Location('UTC', [tz.minTime], [0], [tz.TimeZone.UTC]);

/// The notifications plugin (one per process); tests override it with a fake.
final notificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => FlutterLocalNotificationsPlugin(),
);

/// Every open task on this phone, re-emitted when tasks change; [startReminders] reschedules on each emission.
final openTasksProvider = StreamProvider<List<FarmTask>>((ref) => ref.watch(appDatabaseProvider).tasksDao.watchOpen());

/// The Settings "Reminders" switch, on by default (FR7), re-emitted when it changes (SyncState [remindersKey]).
final remindersOnProvider = StreamProvider<bool>(
  (ref) => ref.watch(appDatabaseProvider).syncStateDao.watch(remindersKey).map((v) => v != 'off'),
);

/// Turns reminders [on] or off in [db]. Turning them on after the farmer said No to the rationale asks [plugin]'s
/// platform permission (Android 13+, iOS) and records Yes. Returns when stored. Side effects: the SyncState rows, maybe
/// the phone's prompt; [startReminders] reschedules. Throws nothing beyond database and platform errors.
Future<void> setRemindersOn(AppDatabase db, FlutterLocalNotificationsPlugin plugin, bool on) async {
  await db.syncStateDao.set(remindersKey, on ? 'on' : 'off');
  if (on && await db.syncStateDao.get(permissionAskedKey) == 'no') {
    await db.syncStateDao.set(permissionAskedKey, 'yes');
    await _requestOsPermission(plugin);
  }
}

/// Replaces every scheduled reminder with one per open task of [db] whose time is after [now].
///
/// The title is "Time to log: Harvest" (the task's event) in [locale]; the body names the farmer's field ("Field 2",
/// the plot's place among the farmer's plots by id, as Money and Sell number them) when the task has a lot. The payload is the route
/// `/log/<event>` plus `?lot=<lot id>` (D-043). Nothing else is put in a notification: no name, phone number or ID
/// document (CLAUDE.md §6). A task due at midnight (a due day without a time) rings at 07:00 that day. Tasks of an
/// unknown event type, or due within the next minute or earlier, are skipped. Needs no network (offline-first).
/// While [on], only pending reminders are cancelled, so a reminder already shown stays in the tray; [on] false
/// cancels shown ones too (sign-out, switch off) and schedules nothing. A reminder the plugin refuses is skipped and
/// the rest are still scheduled (one log line). Returns the number scheduled. Throws what the plugin's cancel throws.
/// Side effects: the phone's pending notifications are replaced.
Future<int> scheduleReminders(
  FlutterLocalNotificationsPlugin plugin,
  AppDatabase db, {
  required Locale locale,
  required DateTime now,
  bool on = true,
}) async {
  // DECISION D-046: cancel everything and schedule every open task again on each change.
  //   ADV: completion, undo, a language switch and the Settings switch need no bookkeeping of notification ids.
  //   COMPROMISE: a few dozen plugin calls per change instead of one; fine for the handful of tasks a farmer has. The
  //   plugin needs desugar_jdk_libs (GPL-2.0 with the Classpath Exception), accepted by the D-018 amendment 2026-10-31.
  if (!on) {
    await plugin.cancelAll();
    return 0;
  }
  await plugin.cancelAllPendingNotifications();
  final l10n = lookupAppLocalizations(locale);
  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      l10n.remindersToggle,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(),
  );
  final lots = await (db.select(db.lots)..orderBy([(l) => OrderingTerm.asc(l.plotId)])).get();
  var id = 0;
  Object? failure;
  for (final t in await db.tasksDao.watchOpen().first) {
    final event = FarmEvent.fromWire(t.eventType);
    final due = t.dueDate.toLocal();
    final at = due.hour == 0 && due.minute == 0 ? due.add(const Duration(hours: 7)) : due;
    // The plugin refuses a time already past when it checks; a minute's margin keeps the run clean.
    if (event == null || !at.isAfter(now.add(const Duration(minutes: 1)))) continue;
    final lot = lots.where((l) => l.lotId == t.lotId).firstOrNull;
    final plots = {
      for (final l in lots)
        if (l.farmerId == lot?.farmerId) l.plotId,
    }.toList();
    try {
      await plugin.zonedSchedule(
        id: id,
        scheduledDate: tz.TZDateTime.from(at, _utc),
        notificationDetails: details,
        // Inexact: no exact-alarm permission (Android 14 asks the user for it); a reminder minutes late is fine.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: l10n.reminderTitle(event.label(l10n)),
        body: lot == null ? null : l10n.plotNumber(plots.indexOf(lot.plotId) + 1),
        payload: lot == null ? '/log/${event.wireName}' : '/log/${event.wireName}?lot=${lot.lotId}',
      );
      id++;
    } catch (e) {
      failure ??= e;
    }
  }
  if (failure != null) developer.log('reminders: some not scheduled ($failure)', name: 'agritrace.reminders');
  return id;
}

/// Opens the event a reminder [payload] names (`/log/<event>?lot=<id>`) on top of the farmer home, so Back returns
/// home, through [router]; the route preselects the event and its lot (F04, D-043). Any other payload (null, another
/// path) is ignored. The router's role redirect still applies. Returns nothing; throws nothing.
void openReminder(GoRouter router, String? payload) {
  if (payload == null || !payload.startsWith('/log/')) return;
  router
    ..go('/home')
    ..push(payload);
}

/// Asks the farmer once whether reminders may ring (the rationale): Yes asks the phone's own permission (Android 13+,
/// iOS); No turns the Settings "Reminders" switch off, so no reminder rings on any Android version (turning it back
/// on asks the phone, [setRemindersOn]).
///
/// [context] shows the dialog; [c] is the app's container (database, plugin, switch). The answer is kept under
/// [permissionAskedKey] so the rationale never repeats. Returns when answered, or at once when asked before. Throws
/// nothing beyond database and platform errors. Side effects: a dialog, SyncState rows, the phone's prompt or the
/// switch off (which cancels every reminder).
Future<void> askReminderPermission(BuildContext context, ProviderContainer c) async {
  final db = c.read(appDatabaseProvider);
  if (await db.syncStateDao.get(permissionAskedKey) != null || !context.mounted) return;
  final yes =
      await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => const _Rationale()) ?? false;
  await db.syncStateDao.set(permissionAskedKey, yes ? 'yes' : 'no');
  final plugin = c.read(notificationsPluginProvider);
  await (yes ? _requestOsPermission(plugin) : setRemindersOn(db, plugin, false));
}

/// Asks [plugin]'s platform for notification permission: the Android 13+ prompt or the iOS prompt. Android below 13
/// and an iOS answer already given return without a prompt; each platform resolves only its own implementation.
/// Returns when answered. Throws platform errors.
Future<void> _requestOsPermission(FlutterLocalNotificationsPlugin plugin) async {
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
    alert: true,
    sound: true,
  );
}

/// The rationale dialog: the spoken sentence and Yes / No (farmer-size buttons). Pops true for Yes.
class _Rationale extends ConsumerWidget {
  /// Creates the dialog.
  const _Rationale();

  /// Builds the dialog. [context] supplies theme and strings; [ref] plays prompts. Returns it; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gap = SizedBox(height: Theme.of(context).extension<FarmerTokens>()!.gap);
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoicePromptBar(promptId: 'remindersRationale', text: l10n.remindersRationale),
            gap,
            FarmerButton(
              icon: Icons.check,
              label: l10n.yes,
              onPressed: () => Navigator.of(context).pop(true),
              onSpeak: () => playPrompt(ref, context, 'yes'),
              prominent: true,
            ),
            gap,
            FarmerButton(
              icon: Icons.close,
              label: l10n.no,
              onPressed: () => Navigator.of(context).pop(false),
              onSpeak: () => playPrompt(ref, context, 'no'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Starts reminders on the app's container [c]: initialises the plugin with the tap handler (warm start), opens the
/// reminder that launched the app (cold start), and reschedules on every change of the open tasks (a save, an undo, a
/// pull that writes Tasks), the session (role, language) and the Settings switch. Only a farmer gets reminders. The
/// first time a reminder is scheduled the permission rationale is shown.
///
/// Returns once the plugin is ready. Throws what the plugin's initialisation throws; a failed reschedule is logged
/// and the next change tries again. Side effects: the phone's pending notifications, navigation, maybe a dialog.
Future<void> startReminders(ProviderContainer c) async {
  final plugin = c.read(notificationsPluginProvider);
  final router = c.read(routerProvider);
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // No prompt at start: the rationale comes first (askReminderPermission).
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (r) => openReminder(router, r.payload),
  );
  final launch = await plugin.getNotificationAppLaunchDetails();
  if (launch?.didNotificationLaunchApp ?? false) openReminder(router, launch!.notificationResponse?.payload);

  var queue = Future<void>.value();
  var asking = false;
  Future<void> run() async {
    final session = c.read(sessionProvider);
    final db = c.read(appDatabaseProvider);
    final on = session.role == Role.farmer && await c.read(remindersOnProvider.future);
    final count = await scheduleReminders(plugin, db, locale: session.locale, now: c.read(clockProvider)(), on: on);
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (count > 0 && !asking && context != null && context.mounted) {
      asking = true;
      unawaited(askReminderPermission(context, c));
    }
  }

  // One run at a time, in order, so a cancelAll never lands between another run's schedules.
  void reschedule() => queue = queue
      .then((_) => run())
      .catchError((Object e) => developer.log('reminders: reschedule failed ($e)', name: 'agritrace.reminders'));
  c.listen(openTasksProvider, (_, _) => reschedule());
  c.listen(sessionProvider, (_, _) => reschedule());
  c.listen(remindersOnProvider, (_, _) => reschedule());
}
