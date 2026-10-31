// BigStepper: large − / + buttons around a big value with its unit (bags, acres, cents).
// Requirement: UserFlows §Design rules "Tap, never type" (quantities use large + / − buttons), "Big targets",
//   "Language first" (Indian grouping 1,20,000); §Each farm event (number of bags with + / −); §Onboarding
//   step 5 (land size stepper in acres or cents); CLAUDE.md §5.6 (quantities carry units).
// Callers: fertiliser, harvest and packing events (M07), onboarding land size (M09); test/widget/kit_*.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';

/// A controlled integer stepper: 64 dp − and + buttons, the value in large type and the unit under it.
///
/// Holding a button repeats the step every 150 ms until released or a bound is reached.
class BigStepper extends StatefulWidget {
  /// Creates the stepper.
  ///
  /// [value] is the current value, kept between [min] and [max] (asserted, `min <= max`); [unit] the
  /// localised unit word shown under it; [onChanged] receives every new value; [step] the change per tap.
  const BigStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
    this.step = 1,
  }) : assert(min <= value && value <= max, 'BigStepper value must lie in [min, max]');

  /// Current value.
  final int value;

  /// Lowest allowed value; − is disabled there.
  final int min;

  /// Highest allowed value; + is disabled there.
  final int max;

  /// Localised unit label, e.g. "bags".
  final String unit;

  /// Called with the new value after each step.
  final ValueChanged<int> onChanged;

  /// Amount added or removed per step.
  final int step;

  /// Creates the state holding the long-press repeat timer. Returns it; throws nothing.
  @override
  State<BigStepper> createState() => _BigStepperState();
}

class _BigStepperState extends State<BigStepper> {
  Timer? _repeat;
  // Own copy so repeated steps between parent rebuilds do not reuse a stale value.
  late int _value = widget.value;

  /// Takes the parent's [BigStepper.value] as the new starting point. [oldWidget] is unused. Throws nothing.
  @override
  void didUpdateWidget(BigStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  /// Cancels a running repeat timer. Throws nothing.
  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  /// Moves the value one step in [direction] (−1 or +1), clamped to the bounds.
  ///
  /// Returns false when already at the bound (nothing changes). Side effect: calls [BigStepper.onChanged].
  bool _step(int direction) {
    final next = (_value + direction * widget.step).clamp(widget.min, widget.max);
    if (next == _value) return false;
    widget.onChanged(_value = next);
    return true;
  }

  /// Steps once in [direction] and keeps stepping every 150 ms until [_stopRepeat] or a bound.
  /// Side effect: starts a periodic timer. Throws nothing.
  void _startRepeat(int direction) {
    _repeat?.cancel();
    if (!_step(direction)) return;
    _repeat = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!_step(direction)) _stopRepeat();
    });
  }

  /// Stops the long-press repeat. Throws nothing.
  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  /// Builds one button for [direction] (−1 or +1) with [icon] and spoken [label], [size] dp square.
  /// Returns the widget; throws nothing.
  Widget _button(int direction, IconData icon, String label, double size) {
    final enabled = direction < 0 ? widget.value > widget.min : widget.value < widget.max;
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: GestureDetector(
          // Screen-reader users tap repeatedly; the long-press repeat is a sighted-thumb shortcut.
          excludeFromSemantics: true,
          onLongPressStart: (_) => _startRepeat(direction),
          onLongPressEnd: (_) => _stopRepeat(),
          onLongPressCancel: _stopRepeat,
          child: IconButton.filled(
            onPressed: enabled ? () => _step(direction) : null,
            icon: Icon(icon, size: 36),
            style: IconButton.styleFrom(minimumSize: Size.square(size)),
          ),
        ),
      ),
    );
  }

  /// Builds − value + in a row. [context] supplies theme, tokens and strings. Returns the widget;
  /// throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // DECISION D-002: − and + are Material 3 filled icon buttons at the 64 dp FarmerTokens main-action size.
        //   ADV: same look and semantics as every other button; large enough for a gloved or wet thumb.
        //   COMPROMISE: 128 dp of buttons leaves about 200 dp for the value on a 360 dp phone at 1.5x text.
        _button(-1, Icons.remove, l10n.stepperLess, tokens.farmerTarget),
        Expanded(
          child: MergeSemantics(
            child: Semantics(
              liveRegion: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indian grouping in both languages (1,20,000), as the farmer reads it on bills.
                  // Shrinks instead of breaking the number across lines at 1.5x text on a 360 dp phone.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      NumberFormat.decimalPattern('en_IN').format(widget.value),
                      style: theme.textTheme.displaySmall,
                    ),
                  ),
                  Text(widget.unit, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        _button(1, Icons.add, l10n.stepperMore, tokens.farmerTarget),
      ],
    );
  }
}
