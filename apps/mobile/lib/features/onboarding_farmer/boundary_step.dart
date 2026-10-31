// O03f Walk the boundary (optional): "Start walking" records GPS points, "Stop" closes the shape; the app draws it
//   on a blank canvas (no map) and shows the walked area next to the declared size, with a note when they differ by
//   more than 20 %.
// Requirement: UserFlows §Onboarding a farmer step 6, FR66 (walked boundary, area, gap flagged above a tolerance),
//   Dataflow Stage 0 (System Action: mismatch flagged), D-017 (`plot.walked_boundary` and `features.boundary_walk`
//   decide whether this step exists; the server recomputes the area and raises the flag).
// Callers: onboarding_wizard.dart (OnboardingStep.boundary).

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capture/gps_fix.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/models/reference.dart' show LonLat;
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'boundary_area.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// Start / Stop / Walk again, the drawn shape, the two areas, the mismatch note and Next (Next skips the walk).
class BoundaryStep extends ConsumerStatefulWidget {
  /// Creates the step.
  const BoundaryStep({super.key});

  /// Creates the state holding the GPS subscription. Returns it; throws nothing.
  @override
  ConsumerState<BoundaryStep> createState() => _BoundaryStepState();
}

class _BoundaryStepState extends ConsumerState<BoundaryStep> {
  StreamSubscription<LocationFix>? _sub;

  /// Stops recording when the step closes mid-walk (the points so far stay in the draft). Throws nothing.
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Clears earlier points and records every new fix as a boundary point. Side effect: GPS on. Throws nothing.
  ///
  /// shortcut: every fix is kept, with no accuracy filter or thinning; a walk whose shape crosses itself (GPS jitter
  ///   while standing at Start or Stop) is not repaired: the boundary is left out of the plot (pin and size are kept)
  ///   and the officer is asked to walk again. Q01 tunes thinning on real walks.
  void _startWalking() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.edit((d) => d.walked = []);
    _sub = ref
        .read(gpsFixProvider)
        .fixes()
        .listen((fix) => notifier.edit((d) => d.walked = [...d.walked, (fix.lng, fix.lat)]), onError: (Object _) {});
    setState(() {});
  }

  /// Stops recording; the ring closes back to the first point. Side effect: GPS off. Throws nothing.
  void _stop() {
    _sub?.cancel();
    setState(() => _sub = null);
  }

  /// Builds the step. [context] supplies theme, tokens and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(onboardingProvider).requireValue;
    final walked = d.walkedAcres, walking = _sub != null;
    String acres(double a) => a.toStringAsFixed(2);
    return stepColumn(context, [
      if (d.walked.isNotEmpty)
        ExcludeSemantics(
          child: SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _ShapePainter(d.walked, closed: !walking, color: theme.colorScheme.primary),
            ),
          ),
        ),
      if (walking)
        FarmerButton(
          icon: Icons.stop_circle_outlined,
          label: l10n.onboardStop,
          onPressed: _stop,
          onSpeak: () => playPrompt(ref, context, 'onboardStop'),
          prominent: true,
        )
      else ...[
        FarmerButton(
          icon: Icons.directions_walk,
          label: d.walked.isEmpty ? l10n.onboardStartWalking : l10n.onboardWalkAgain,
          onPressed: _startWalking,
          onSpeak: () => playPrompt(ref, context, d.walked.isEmpty ? 'onboardStartWalking' : 'onboardWalkAgain'),
        ),
        if (d.walkCrosses)
          VoicePromptBar(promptId: 'onboardBoundaryCrosses', text: l10n.onboardBoundaryCrosses)
        else if (d.walked.isNotEmpty && walked == null)
          Text(l10n.onboardTooFewPoints, style: theme.textTheme.titleMedium),
        if (walked != null) ...[
          Text(l10n.onboardDeclared(acres(d.declaredAcres)), style: theme.textTheme.titleLarge),
          Text(l10n.onboardWalked(acres(walked)), style: theme.textTheme.titleLarge),
          if (areaMismatch(d.declaredAcres, walked))
            MergeSemantics(
              child: Row(
                children: [
                  Icon(tokens.todo.icon, color: tokens.todo.color),
                  SizedBox(width: tokens.gap / 2),
                  Expanded(child: Text(l10n.onboardAreaMismatch, style: theme.textTheme.titleMedium)),
                ],
              ),
            ),
        ],
        const NextButton(),
      ],
    ]);
  }
}

/// Draws the walked points as a polyline scaled to fit, closed back to the start once the walk stopped.
class _ShapePainter extends CustomPainter {
  /// Creates the painter for [points] (lon/lat degrees); [closed] joins the last point to the first; [color] is
  /// the line colour.
  _ShapePainter(this.points, {required this.closed, required this.color});

  final List<LonLat> points;
  final bool closed;
  final Color color;

  /// Paints the shape into [size] on [canvas], keeping its aspect ratio (equirectangular at the shape's latitude,
  /// enough for a field). Side effect: draws. Throws nothing.
  @override
  void paint(Canvas canvas, Size size) {
    final kx = cos(points.first.$2 * pi / 180);
    final xs = [for (final p in points) p.$1 * kx], ys = [for (final p in points) p.$2];
    final minX = xs.reduce(min), minY = ys.reduce(min);
    final span = max(max(xs.reduce(max) - minX, ys.reduce(max) - minY), 1e-9);
    final scale = min(size.width, size.height) / span;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      // North up: larger latitude is higher on the screen.
      final o = Offset((xs[i] - minX) * scale, size.height - (ys[i] - minY) * scale);
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    if (closed) path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  /// Repaints when the points, closure or colour changed ([old] is the previous painter). Throws nothing.
  @override
  bool shouldRepaint(_ShapePainter old) => old.points != points || old.closed != closed || old.color != color;
}
