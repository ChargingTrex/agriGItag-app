// Widget-kit behaviour and accessibility (runs on every platform; pixels are in kit_golden_test.dart).
// Requirement: plan §7.2 M05 acceptance (every control >= 56 dp, Semantics on icon controls); UserFlows
//   §Design rules "Big targets" (>= 56 dp, full width), "Tap, never type", "Colour plus shape", "Help is a
//   person"; §When things go wrong (weak GPS: green at <= 20 m, "Save anyway" after 60 s; no signal: cloud).
// Callers: flutter test (CI mobile job).

import 'dart:async';

import 'package:agritrace/core/l10n/gen/app_localizations.dart';
import 'package:agritrace/core/router/session.dart';
import 'package:agritrace/core/theme/status_glyphs.dart';
import 'package:agritrace/core/widgets/big_stepper.dart';
import 'package:agritrace/core/widgets/call_officer_button.dart';
import 'package:agritrace/core/widgets/cloud_sync_indicator.dart';
import 'package:agritrace/core/widgets/farmer_button.dart';
import 'package:agritrace/core/widgets/gps_ring.dart';
import 'package:agritrace/core/widgets/number_pad.dart';
import 'package:agritrace/core/widgets/picture_card_grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'kit_harness.dart';

/// Farmer minimum tap target (FarmerTokens.minTarget), checked on every semantics tap target.
const _farmerTapTarget = MinimumTapTargetGuideline(
  size: Size.square(56),
  link: 'docs/source/AgriTrace — User Flows.md §Design rules "Big targets"',
);

/// Strings of [locale] for expectations. Returns the generated localisations; throws nothing.
AppLocalizations _l10n(Locale locale) => lookupAppLocalizations(locale);

/// Sizes of the [FilledButton]s whose text is [label]. Returns the list (empty when none).
List<Size> _buttonSizes(WidgetTester tester, String label) => find
    .ancestor(of: find.text(label), matching: find.bySubtype<FilledButton>())
    .evaluate()
    .map((e) => e.size!)
    .toList();

/// A stateful host for controlled widgets: [build] gets the current value and a setter.
class _Host<T> extends StatefulWidget {
  /// Creates the host starting at [initial]; [build] renders the controlled widget.
  const _Host({required this.initial, required this.build});

  /// Starting value.
  final T initial;

  /// Builds the hosted widget from the value and a setter that rebuilds.
  final Widget Function(T value, ValueChanged<T> set) build;

  /// Creates the state holding the value. Returns it; throws nothing.
  @override
  State<_Host<T>> createState() => _HostState<T>();
}

class _HostState<T> extends State<_Host<T>> {
  late T _value = widget.initial;

  /// Builds the hosted widget with the current value. Returns it; throws nothing.
  @override
  Widget build(BuildContext context) => widget.build(_value, (v) => setState(() => _value = v));
}

/// Runs the accessibility sweep over every sample, then the per-widget behaviour tests.
void main() {
  group('accessibility sweep', () {
    for (final sample in kitSamples) {
      for (final locale in [tamil, english]) {
        for (final textScale in textScales) {
          testWidgets('${sample.name} ${locale.languageCode} x$textScale: 56 dp targets, labels, contrast', (
            tester,
          ) async {
            final semantics = tester.ensureSemantics();
            // Smallest screen, pushed as a route so app-bar chrome (an implied back arrow) is measured too; an
            // overflow at 1.5x text throws and fails the test here.
            await pumpSample(
              tester,
              sample,
              locale: locale,
              size: screenSizes.first,
              textScale: textScale,
              pushed: true,
            );
            await expectLater(tester, meetsGuideline(_farmerTapTarget));
            await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            semantics.dispose();
          });
        }
      }
    }
  });

  group('primary actions are 64 dp and full width', () {
    for (final locale in [tamil, english]) {
      final l10n = _l10n(locale);
      testWidgets('ConfirmScaffold ${locale.languageCode}', (tester) async {
        await pumpSample(
          tester,
          kitSamples.firstWhere((s) => s.name == 'confirm_scaffold'),
          locale: locale,
          size: screenSizes.first,
          textScale: 1.0,
        );
        // Button + 16 dp gap + speaker spans 360 - 2 x 16 dp padding.
        expect(
          tester.getSize(find.ancestor(of: find.text(l10n.confirmCorrect), matching: find.byType(FarmerButton))),
          const Size(328, 64),
        );
        expect(
          tester.getSize(find.ancestor(of: find.text(l10n.retake), matching: find.byType(FarmerButton))).width,
          328,
        );
        expect(tester.getSize(find.byType(CallFieldOfficerButton)).width, 328);
        // 3 button speakers; the sample summary has no recorded clip, so its bar says "No voice".
        expect(find.bySemanticsLabel(l10n.playVoice), findsNWidgets(3));
        expect(find.bySemanticsLabel(l10n.voiceMissing), findsOneWidget);
      });

      testWidgets('ErrorSheet ${locale.languageCode}', (tester) async {
        await pumpSample(
          tester,
          kitSamples.firstWhere((s) => s.name == 'error_sheet'),
          locale: locale,
          size: screenSizes.first,
          textScale: 1.0,
        );
        expect(_buttonSizes(tester, l10n.retake).single.height, 64);
        expect(tester.getSize(find.byType(FarmerButton)).width, 328);
        expect(find.byType(FarmerButton), findsOneWidget); // one button
      });
    }

    testWidgets('NumberPad keys and BigStepper buttons are 64 dp', (tester) async {
      await pumpKit(tester, NumberPad(value: '', onChanged: (_) {}));
      for (final d in '0123456789'.split('')) {
        expect(_buttonSizes(tester, d).single.height, 64);
      }
      await pumpKit(tester, BigStepper(value: 1, min: 0, max: 9, unit: 'kg', onChanged: (_) {}));
      for (final icon in [Icons.add, Icons.remove]) {
        expect(
          tester.getSize(find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton))),
          const Size(64, 64),
        );
      }
    });
  });

  testWidgets('NumberPad enters digits, groups them the Indian way, deletes, takes one point', (tester) async {
    final l10n = _l10n(tamil);
    String? last;
    await pumpKit(
      tester,
      _Host<String>(
        initial: '',
        build: (value, set) => NumberPad(value: value, onChanged: (v) => set(last = v), allowDecimal: true, unit: 'kg'),
      ),
    );
    expect(find.text('0 kg'), findsOneWidget);
    for (final d in '120000'.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(last, '120000');
    expect(find.text('1,20,000 kg'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(l10n.numberPadDelete));
    await tester.pump();
    expect(find.text('12,000 kg'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(l10n.numberPadPoint));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10n.numberPadPoint));
    await tester.tap(find.text('5').last);
    await tester.pump();
    expect(last, '12000.5');
    expect(find.text('12,000.5 kg'), findsOneWidget);
  });

  testWidgets('NumberPad stops at maxDigits and replaces a lone 0', (tester) async {
    await pumpKit(
      tester,
      _Host<String>(
        initial: '0',
        build: (v, set) => NumberPad(value: v, onChanged: set, maxDigits: 3),
      ),
    );
    for (final d in '7891'.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump();
    }
    expect(find.text('789'), findsOneWidget);
  });

  testWidgets('BigStepper respects min and max, disables at the bounds, repeats on long press', (tester) async {
    final l10n = _l10n(tamil);
    int? last;
    await pumpKit(
      tester,
      _Host<int>(
        initial: 1,
        build: (value, set) => BigStepper(value: value, min: 0, max: 5, unit: 'bags', onChanged: (v) => set(last = v)),
      ),
    );
    IconButton button(IconData icon) =>
        tester.widget<IconButton>(find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)));

    await tester.tap(find.bySemanticsLabel(l10n.stepperLess));
    await tester.pump();
    expect(last, 0);
    expect(button(Icons.remove).onPressed, isNull);
    await tester.tap(find.byIcon(Icons.remove), warnIfMissed: false);
    await tester.pump();
    expect(find.text('0'), findsOneWidget);

    // Hold +: one step at the long-press timeout, then one per 150 ms, stopping at max (5).
    final gesture = await tester.startGesture(tester.getCenter(find.byIcon(Icons.add)));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 10));
    expect(last, 1);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await gesture.up();
    await tester.pump();
    expect(last, 5);
    expect(find.text('5'), findsOneWidget);
    expect(button(Icons.add).onPressed, isNull);
  });

  testWidgets('BigStepper shows Indian grouping with its unit', (tester) async {
    await pumpKit(tester, BigStepper(value: 120000, min: 0, max: 999999, unit: 'kg', onChanged: (_) {}));
    expect(find.text('1,20,000'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
  });

  group('GpsRing', () {
    final l10n = _l10n(tamil);

    testWidgets('turns green with a tick at 15 m', (tester) async {
      await pumpKit(tester, GpsRing(accuracyMetres: 15, onSaveAnyway: () {}));
      final ring = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(ring.value, 1.0);
      expect(ring.color, StatusGlyph.done.color);
      expect(find.byIcon(StatusGlyph.done.icon), findsOneWidget);
      expect(find.text(l10n.gpsFound), findsOneWidget);
      expect(find.text(l10n.gpsAccuracy(15)), findsOneWidget);
    });

    testWidgets('is part-filled and not green at 35 m', (tester) async {
      await pumpKit(tester, GpsRing(accuracyMetres: 35, onSaveAnyway: () {}));
      final ring = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
      expect(ring.value, closeTo(65 / 80, 1e-9));
      expect(ring.color, StatusGlyph.todo.color); // orange "to do" until good
      expect(find.text(l10n.gpsHold), findsOneWidget);
    });

    testWidgets('offers "Save anyway" only after 60 s of a weak fix', (tester) async {
      var saved = 0;
      await pumpKit(tester, GpsRing(accuracyMetres: null, onSaveAnyway: () => saved++));
      expect(tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator)).value, 0);
      await tester.pump(const Duration(seconds: 59));
      expect(find.text(l10n.saveAnyway), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text(l10n.saveAnyway), findsOneWidget);
      expect(tester.getSize(find.byType(FarmerButton)).width, 328);
      await tester.tap(find.text(l10n.saveAnyway));
      expect(saved, 1);
    });

    testWidgets('does not offer "Save anyway" once the fix is good', (tester) async {
      await pumpKit(tester, GpsRing(accuracyMetres: 12, onSaveAnyway: () {}));
      await tester.pump(GpsRing.saveAnywayAfter);
      expect(find.text(l10n.saveAnyway), findsNothing);
    });
  });

  testWidgets('CloudSyncIndicator follows the pending-count stream', (tester) async {
    final l10n = _l10n(tamil);
    final counts = StreamController<int>();
    addTearDown(counts.close);
    await pumpKit(tester, const CloudSyncIndicator(), pending: counts.stream);
    expect(find.byType(Icon), findsNothing); // no claim before the first count

    counts.add(3);
    await tester.pump(); // stream event reaches the provider
    await tester.pump(); // dependent widget rebuilds
    expect(find.text('3'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.cloudPending(3)), findsOneWidget);

    counts.add(0);
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
    final tick = tester.widget<Icon>(find.byIcon(StatusGlyph.done.icon));
    expect(tick.color, StatusGlyph.done.color);
    expect(find.bySemanticsLabel(l10n.cloudAllSent), findsOneWidget);
  });

  testWidgets('PictureCardGrid selects with border + tick, two cards per row', (tester) async {
    int? picked;
    await pumpKit(
      tester,
      _Host<int?>(
        initial: null,
        build: (value, set) => PictureCardGrid<int>(
          selected: value,
          onSelected: (v) => set(picked = v),
          choices: [
            for (final i in [0, 1, 2]) PictureChoice(value: i, picture: const Icon(Icons.grass), label: 'C$i'),
          ],
        ),
      ),
    );
    expect(find.byIcon(Icons.check_circle), findsNothing);
    // Two columns: card 1 sits right of card 0, card 2 starts the second row.
    expect(tester.getTopLeft(find.text('C1')).dy, tester.getTopLeft(find.text('C0')).dy);
    expect(tester.getTopLeft(find.text('C2')).dy, greaterThan(tester.getTopLeft(find.text('C0')).dy));
    expect(tester.getSize(find.byType(Card).first).width, (328 - 16) / 2);

    await tester.tap(find.text('C2'));
    await tester.pump();
    expect(picked, 2);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(
      tester.getSemantics(find.text('C2')),
      containsSemantics(isSelected: true, isButton: true, hasTapAction: true),
    );
    expect(tester.getSemantics(find.text('C0')), containsSemantics(isSelected: false));
  });

  for (final phone in [null, '']) {
    testWidgets('CallFieldOfficerButton is disabled with officer number ${phone == null ? 'null' : 'empty'}', (
      tester,
    ) async {
      await pumpKit(tester, const CallFieldOfficerButton(), phone: phone);
      final button = tester.widget<FilledButton>(
        find.ancestor(of: find.text(_l10n(tamil).callOfficer), matching: find.bySubtype<FilledButton>()),
      );
      expect(button.onPressed, isNull);
    });
  }

  testWidgets('CallFieldOfficerButton dials tel: with the officer number', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        calls.add(call);
        return true;
      },
    );
    await pumpKit(tester, const CallFieldOfficerButton());
    await tester.tap(find.text(_l10n(tamil).callOfficer));
    await tester.pump();
    expect(calls.single.method, 'launch');
    expect((calls.single.arguments as Map<Object?, Object?>)['url'], 'tel:$officerPhone');
  });
}
