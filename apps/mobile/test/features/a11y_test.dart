// Accessibility sweep over every new M07 screen state, reached through the real router: 56 dp tap targets, labelled
// tap targets, text contrast, and no overflow, on the smallest phone (360 x 640) in Tamil and English at 1.0x and 1.5x.
// Requirement: UserFlows §Design rules ("Big targets ... at least 56 dp", "Pictures and voice before words");
//   mobile-design.md §6 (textScaler 1.0–1.5, Semantics on icon controls, contrast ≥ 4.5:1); M05 sweep (kit_test.dart).
// Callers: flutter test (CI mobile job).

import 'package:agritrace/core/capture/photo_quality_check.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// Farmer minimum tap target (FarmerTokens.minTarget), as in the M05 sweep.
const _farmerTapTarget = MinimumTapTargetGuideline(
  size: Size.square(56),
  link: 'docs/source/AgriTrace — User Flows.md §Design rules "Big targets"',
);

/// One screen state: its [name], a harness factory [make], where to [start] (with [lots] and [withHistory]) and the
/// English taps that [drive] the app there.
typedef ScreenState = ({
  String name,
  FlowHarness Function() make,
  String start,
  int lots,
  bool withHistory,
  Future<void> Function(WidgetTester tester, FlowHarness h)? drive,
});

/// Taps the English [label] and settles. Returns when settled; fails when [label] is not on screen.
Future<void> _tap(WidgetTester tester, FlowHarness h, String label) => h.tap(tester, find.text(label));

/// Every new screen and sheet of M07.
final List<ScreenState> screens = [
  (name: 'F03 home', make: FlowHarness.new, start: '/home', lots: 1, withHistory: true, drive: null),
  (name: 'F04 choose event', make: FlowHarness.new, start: '/log', lots: 1, withHistory: true, drive: null),
  (name: 'lot picker', make: FlowHarness.new, start: '/log/harvest', lots: 2, withHistory: true, drive: null),
  (name: 'no lot', make: FlowHarness.new, start: '/log/harvest', lots: 0, withHistory: true, drive: null),
  (name: 'F09 order sheet', make: FlowHarness.new, start: '/log/harvest', lots: 1, withHistory: false, drive: null),
  for (final e in ['nursery', 'input_application', 'harvest', 'drying', 'problem'])
    (name: 'F05 $e', make: FlowHarness.new, start: '/log/$e', lots: 1, withHistory: true, drive: null),
  (name: 'F06 camera', make: FlowHarness.new, start: '/log/sowing', lots: 1, withHistory: true, drive: null),
  (
    name: 'F06 camera off',
    make: () => FlowHarness(cameraDenied: true),
    start: '/log/sowing',
    lots: 1,
    withHistory: true,
    drive: null,
  ),
  (
    name: 'F06 weak GPS ring',
    make: () => FlowHarness(fixes: [fixOf(50)]),
    start: '/log/sowing',
    lots: 1,
    withHistory: true,
    drive: (tester, h) async {
      await _tap(tester, h, 'Take photo');
      await tester.pump(const Duration(seconds: 60));
      await tester.pumpAndSettle();
    },
  ),
  (
    name: 'F16 photo not clear',
    make: () => FlowHarness(verdicts: [PhotoQuality.tooDark]),
    start: '/log/sowing',
    lots: 1,
    withHistory: true,
    drive: (tester, h) => _tap(tester, h, 'Take photo'),
  ),
  (
    name: 'F07 confirm (problem, voice note)',
    make: FlowHarness.new,
    start: '/log/problem',
    lots: 1,
    withHistory: true,
    drive: (tester, h) async {
      await _tap(tester, h, 'Pest');
      await _tap(tester, h, 'Take photo');
    },
  ),
  (
    name: 'F08 saved offline',
    make: () => FlowHarness(pending: 2),
    start: '/log/sowing',
    lots: 1,
    withHistory: true,
    drive: (tester, h) async {
      await _tap(tester, h, 'Take photo');
      await _tap(tester, h, 'Correct');
    },
  ),
  (
    name: 'F08 keep drying sheet',
    make: FlowHarness.new,
    start: '/log/packing',
    lots: 1,
    withHistory: true,
    drive: (tester, h) async {
      await _tap(tester, h, 'Next');
      await _tap(tester, h, 'Take photo');
      await _tap(tester, h, 'Correct');
    },
  ),
  (name: 'not found', make: FlowHarness.new, start: '/home/nowhere', lots: 1, withHistory: true, drive: null),
  (name: 'placeholder (Sell)', make: FlowHarness.new, start: '/home/sell', lots: 1, withHistory: true, drive: null),
  (name: 'settings', make: FlowHarness.new, start: '/settings', lots: 1, withHistory: true, drive: null),
];

void main() {
  for (final s in screens) {
    for (final locale in [tamil, english]) {
      for (final scale in [1.0, 1.5]) {
        testWidgets('${s.name} ${locale.languageCode} x$scale: 56 dp targets, labels, contrast', (tester) async {
          final semantics = tester.ensureSemantics();
          final h = s.make();
          // Driven in English (the taps name English labels), then switched to the language under test.
          await h.start(tester, location: s.start, lots: s.lots, withHistory: s.withHistory);
          await s.drive?.call(tester, h);
          tester.view.physicalSize = const Size(360, 640);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          h.container.read(sessionProvider.notifier).setLocale(locale);
          // An overflow at 1.5x on 360 x 640 throws here and fails the test.
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(_farmerTapTarget));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await h.dispose(tester);
          semantics.dispose();
        });
      }
    }
  }
}
