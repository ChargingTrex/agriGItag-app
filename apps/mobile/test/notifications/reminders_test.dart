// Tests of the M12 reminders: the Tasks → notification mapping (time, language, field label, skips, cancel and
// reschedule), the privacy scan of every scheduled text and payload, the push flag, and on the real app: the
// permission rationale state, rescheduling on a Tasks change, and a reminder tap (warm and cold start) landing on the
// harvest flow with the lot preselected.
// Requirement: PLAN §7.2 M12 acceptance (reminder tap → F04 harvest preselected; offline reminder scheduled; payload
//   has no phone/ID); FR7; UserFlows §Alerts, help and feature phones; CLAUDE.md §6; D-043, D-046.
// Callers: flutter test (CI mobile job).

import 'dart:convert';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/db/providers.dart';
import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/app_router.dart';
import 'package:agritrace/features/event_log/event_log_controller.dart';
import 'package:agritrace/features/event_log/farm_event.dart';
import 'package:agritrace/features/notifications/push.dart';
import 'package:agritrace/features/notifications/reminders.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

import '../db/db_fixtures.dart';
import '../features/harness.dart';

/// One notification the fake was asked to schedule.
typedef Scheduled = ({int id, DateTime at, String? title, String? body, String? payload});

/// Notifications plugin fake: records schedules (cleared by cancelAll), permission requests and the tap callback;
/// answers [launch] as the app's launch details. Never touches a platform channel or the network.
class FakeNotifications implements FlutterLocalNotificationsPlugin {
  /// Pending notifications, in scheduling order.
  final List<Scheduled> scheduled = [];

  /// Number of cancelAll calls.
  int cancels = 0;

  /// Number of platform-implementation lookups (one per platform per permission request).
  int permissionLookups = 0;

  /// The tap handler registered by initialize.
  DidReceiveNotificationResponseCallback? onTap;

  /// What getNotificationAppLaunchDetails answers (cold start).
  NotificationAppLaunchDetails? launch;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback? onDidReceiveBackgroundNotificationResponse,
  }) async {
    onTap = onDidReceiveNotificationResponse;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async => launch;

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled.clear();
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async => scheduled.add((
    id: id,
    at: DateTime.fromMillisecondsSinceEpoch(scheduledDate.millisecondsSinceEpoch),
    title: title,
    body: body,
    payload: payload,
  ));

  @override
  T? resolvePlatformSpecificImplementation<T extends FlutterLocalNotificationsPlatform>() {
    permissionLookups++;
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Push provider fake that gives [value] as its token and counts the calls.
class FakePush implements PushProvider {
  /// Creates the fake answering [value].
  FakePush(this.value);

  /// Token to give.
  final String? value;

  /// Number of token calls.
  int calls = 0;

  @override
  Future<String?> token() async {
    calls++;
    return value;
  }
}

/// Phone clock of the unit tests: 14 Feb 2026, 09:30 local.
final now = DateTime(2026, 2, 14, 9, 30);

/// Seeds farmer-1 ("Murugan", +919876543210 in the JSON) with plot-1/lot-1 and plot-2/lot-2 in [db]. Returns when
/// written.
Future<void> seedLots(AppDatabase db) async {
  await db
      .into(db.farmers)
      .insert(
        FarmersCompanion.insert(
          farmerId: 'farmer-1',
          fpoId: 'fpo-1',
          name: 'Murugan',
          village: 'Sattur',
          hasSmartphone: true,
          language: 'ta',
          status: 'active',
          json: jsonEncode({'phone': '+919876543210', 'id_document': 'XXXX-1234-5678'}),
        ),
      );
  for (final i in [1, 2]) {
    await db
        .into(db.lots)
        .insert(
          LotsCompanion.insert(
            lotId: 'lot-$i',
            plotId: 'plot-$i',
            farmerId: 'farmer-1',
            cropId: 'crop-chilli',
            season: '2026-rabi',
            status: 'open',
            updatedAt: now,
          ),
        );
  }
}

/// Adds task [id] for [event] due at [due] on [lot] (null = farmer-level) to [db]; [done] marks it logged.
/// Returns when written.
Future<void> addTask(
  AppDatabase db,
  String id,
  String event,
  DateTime due, {
  String? lot = 'lot-2',
  bool done = false,
}) => db
    .into(db.tasks)
    .insert(
      TasksCompanion.insert(
        taskId: id,
        farmerId: 'farmer-1',
        lotId: Value(lot),
        eventType: event,
        dueDate: due,
        promptId: 'taskDryingDone',
        source: 'local',
        done: Value(done),
      ),
    );

void main() {
  group('scheduleReminders', () {
    late AppDatabase db;
    late FakeNotifications plugin;

    setUp(() async {
      db = memoryDb();
      plugin = FakeNotifications();
      await seedLots(db);
    });

    tearDown(() => db.close());

    test('offline: a harvest task is scheduled at its due time with the event, the field and the deep link', () async {
      // No API client exists in this test: scheduling reads only the local database.
      await addTask(db, 't1', 'harvest', DateTime(2026, 2, 16, 8, 0));
      expect(await scheduleReminders(plugin, db, locale: const Locale('en'), now: now), 1);
      final s = plugin.scheduled.single;
      expect(s.at, DateTime(2026, 2, 16, 8, 0));
      expect(s.title, 'Time to log: Harvest');
      expect(s.body, 'Field 2');
      expect(s.payload, '/log/harvest?lot=lot-2');
    });

    test('Tamil locale gives the Tamil title and field label', () async {
      await addTask(db, 't1', 'drying', DateTime(2026, 2, 21, 9, 30), lot: 'lot-1');
      await scheduleReminders(plugin, db, locale: const Locale('ta'), now: now);
      final ta = lookupAppLocalizations(const Locale('ta'));
      final s = plugin.scheduled.single;
      expect(s.title, ta.reminderTitle(FarmEvent.drying.label(ta)));
      expect(s.body, ta.plotNumber(1));
      expect(s.title, isNot(contains('Time to log')));
    });

    test(
      'done, past and unknown tasks are skipped; a due day without a time rings at 07:00; no lot, no body',
      () async {
        await addTask(db, 'done', 'harvest', DateTime(2026, 2, 16, 8), done: true);
        await addTask(db, 'past', 'harvest', DateTime(2026, 2, 14, 9));
        await addTask(db, 'odd', 'irrigation_v9', DateTime(2026, 2, 16, 8));
        await addTask(db, 'day', 'packing', DateTime(2026, 2, 17), lot: null);
        await scheduleReminders(plugin, db, locale: const Locale('en'), now: now);
        final s = plugin.scheduled.single;
        expect(s.at, DateTime(2026, 2, 17, 7));
        expect(s.payload, '/log/packing');
        expect(s.body, isNull);
      },
    );

    test('every run cancels first: completion and the Settings switch remove the reminder', () async {
      await addTask(db, 't1', 'harvest', DateTime(2026, 2, 16, 8));
      await scheduleReminders(plugin, db, locale: const Locale('en'), now: now);
      expect(plugin.scheduled, hasLength(1));
      expect(await scheduleReminders(plugin, db, locale: const Locale('en'), now: now, on: false), 0);
      expect(plugin.scheduled, isEmpty);
      await scheduleReminders(plugin, db, locale: const Locale('en'), now: now);
      await (db.update(db.tasks)..where((t) => t.taskId.equals('t1'))).write(const TasksCompanion(done: Value(true)));
      await scheduleReminders(plugin, db, locale: const Locale('en'), now: now);
      expect(plugin.scheduled, isEmpty);
      expect(plugin.cancels, 4);
    });

    test('no scheduled text or payload carries a phone number, a name, a farmer id or an ID document', () async {
      for (final (i, e) in FarmEvent.values.indexed) {
        await addTask(db, 't$i', e.wireName, DateTime(2026, 2, 16 + i, 8), lot: i.isEven ? 'lot-1' : null);
      }
      for (final locale in const [Locale('en'), Locale('ta')]) {
        await scheduleReminders(plugin, db, locale: locale, now: now);
        expect(plugin.scheduled, hasLength(FarmEvent.values.length));
        for (final s in plugin.scheduled) {
          final text = '${s.title} ${s.body} ${s.payload}';
          expect(text, isNot(matches(RegExp(r'\d{6,}'))), reason: 'digits that could be a phone or ID: $text');
          for (final secret in ['Murugan', 'farmer-1', '9876543210', '1234', 'Sattur']) {
            expect(text, isNot(contains(secret)), reason: text);
          }
          expect(s.payload, matches(RegExp(r'^/log/[a-z_]+(\?lot=lot-\d)?$')));
        }
      }
    });
  });

  group('registerPush', () {
    /// A container on [db] with [push] as the push provider. Returns it (disposed at tear-down).
    ProviderContainer containerOn(AppDatabase db, PushProvider push) => ProviderContainer.test(
      overrides: [appDatabaseProvider.overrideWithValue(db), pushProviderProvider.overrideWithValue(push)],
    );

    /// Stores the `fields` bundle with [features] in [db]. Returns when written.
    Future<void> features(AppDatabase db, Map<String, Object?> features) => db.refBundlesDao.upsert(
      RefBundlesCompanion.insert(
        bundleType: 'fields',
        version: 1,
        etag: 'e',
        fetchedAt: now,
        bodyJson: jsonEncode({'entities': {}, 'features': features}),
      ),
    );

    test('off by default: no bundle or no flag never asks for a token', () async {
      final db = memoryDb();
      final push = FakePush('tok');
      final c = containerOn(db, push);
      expect(await registerPush(c), isFalse);
      await features(db, {'boundary_walk': true});
      expect(await registerPush(c), isFalse);
      expect(push.calls, 0);
      await db.close();
    });

    test('flag on: registers with a token; the console provider of this build gives none', () async {
      final db = memoryDb();
      await features(db, {'push_notifications': true});
      final push = FakePush('tok');
      expect(await registerPush(containerOn(db, push)), isTrue);
      expect(push.calls, 1);
      expect(await registerPush(containerOn(db, ConsolePushProvider())), isFalse);
      await db.close();
    });
  });

  group('on the app', () {
    /// A farmer app (two lots, English) with the fake plugin; reminders started. Returns the harness and the fake.
    Future<(FlowHarness, FakeNotifications)> startApp(
      WidgetTester tester, {
      NotificationAppLaunchDetails? launch,
    }) async {
      final plugin = FakeNotifications()..launch = launch;
      final h = FlowHarness(overrides: [notificationsPluginProvider.overrideWithValue(plugin)]);
      await h.start(tester, lots: 2);
      await startReminders(h.container);
      await tester.pumpAndSettle();
      return (h, plugin);
    }

    /// Lets the Tasks stream and the reschedule queue run (their database reads complete on the real event loop, not
    /// in the fake-async test zone), then settles [tester].
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();
    }

    testWidgets('a new task is scheduled, the rationale is asked once, Yes asks the phone; done cancels it', (
      tester,
    ) async {
      final (h, plugin) = await startApp(tester);
      expect(plugin.scheduled, isEmpty);
      expect(find.text(lookupAppLocalizations(const Locale('en')).remindersRationale), findsNothing);

      await addTask(h.db, 't1', 'harvest', DateTime(2026, 2, 16, 8), lot: 'lot-1');
      await settle(tester);
      expect(plugin.scheduled.single.payload, '/log/harvest?lot=lot-1');
      final rationale = find.text(lookupAppLocalizations(const Locale('en')).remindersRationale);
      expect(rationale, findsOneWidget);
      expect(plugin.permissionLookups, 0, reason: 'the phone is asked only after Yes');

      await tester.tap(find.text('Yes'));
      await settle(tester);
      expect(rationale, findsNothing);
      expect(await h.db.syncStateDao.get(permissionAskedKey), 'yes');
      expect(plugin.permissionLookups, 2, reason: 'Android and iOS implementations looked up');

      await (h.db.update(
        h.db.tasks,
      )..where((t) => t.taskId.equals('t1'))).write(const TasksCompanion(done: Value(true)));
      await settle(tester);
      expect(plugin.scheduled, isEmpty);
      await addTask(h.db, 't2', 'packing', DateTime(2026, 2, 18, 8), lot: 'lot-1');
      await settle(tester);
      expect(plugin.scheduled, hasLength(1));
      expect(rationale, findsNothing, reason: 'asked once');
      await h.dispose(tester);
    });

    testWidgets('No is remembered and the phone is never asked', (tester) async {
      final (h, plugin) = await startApp(tester);
      await addTask(h.db, 't1', 'harvest', DateTime(2026, 2, 16, 8), lot: 'lot-1');
      await settle(tester);
      await tester.tap(find.text('No'));
      await settle(tester);
      expect(await h.db.syncStateDao.get(permissionAskedKey), 'no');
      expect(plugin.permissionLookups, 0);
      expect(plugin.scheduled, hasLength(1), reason: 'scheduled anyway; the phone decides whether it shows');
      await h.dispose(tester);
    });

    testWidgets('warm start: a reminder tap opens F04 harvest with its lot preselected, home underneath', (
      tester,
    ) async {
      final (h, plugin) = await startApp(tester);
      plugin.onTap!(
        const NotificationResponse(
          notificationResponseType: NotificationResponseType.selectedNotification,
          payload: '/log/harvest?lot=lot-1',
        ),
      );
      await tester.pumpAndSettle();
      expect(h.path, '/log/harvest');
      // Two active lots, yet no "Which field?": the reminder's lot is the draft's lot (D-043).
      expect(find.text('Which field?'), findsNothing);
      final draft = h.container.read(eventLogProvider);
      expect((draft.event, draft.lot?.lotId), (FarmEvent.harvest, 'lot-1'));
      expect(h.container.read(routerProvider).canPop(), isTrue);
      await h.dispose(tester);
    });

    testWidgets('cold start: the reminder that launched the app opens the harvest flow on its lot', (tester) async {
      final (h, _) = await startApp(
        tester,
        launch: const NotificationAppLaunchDetails(
          true,
          notificationResponse: NotificationResponse(
            notificationResponseType: NotificationResponseType.selectedNotification,
            payload: '/log/harvest?lot=lot-1',
          ),
        ),
      );
      expect(h.path, '/log/harvest');
      expect(h.container.read(eventLogProvider).lot?.lotId, 'lot-1');
      await h.dispose(tester);
    });

    testWidgets('Settings "Reminders" is on by default and turning it off cancels every reminder', (tester) async {
      final (h, plugin) = await startApp(tester);
      await h.db.syncStateDao.set(permissionAskedKey, 'no');
      await addTask(h.db, 't1', 'harvest', DateTime(2026, 2, 16, 8), lot: 'lot-1');
      await settle(tester);
      expect(plugin.scheduled, hasLength(1));
      h.go('/settings');
      await tester.pumpAndSettle();
      final toggle = find.widgetWithText(SwitchListTile, 'Reminders');
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      await tester.tap(toggle);
      await settle(tester);
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(plugin.scheduled, isEmpty);
      expect(await h.db.syncStateDao.get(remindersKey), 'off');
      await h.dispose(tester);
    });
  });
}
