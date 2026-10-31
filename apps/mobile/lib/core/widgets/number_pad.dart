// NumberPad: on-screen 0-9 keys (+ optional point) and backspace with a large read-out; the only way a farmer
//   enters a number that does not suit a stepper.
// Requirement: UserFlows §Design rules "Tap, never type" (quantities use + / − or a number pad; never a
//   free-text box), "Big targets", "Language first" (Indian grouping); plan §7.2 (no free-text lint, tool/no_textfield_lint.sh).
// Callers: farmer and QC numeric screens (M07 sale weight, M10 moisture reading, M11 grading); test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';

/// A controlled number entry: shows [value] (Indian grouping, with [unit]) above a 3 x 4 grid of 64 dp keys.
///
/// [value] is the raw typed text (`"120000"`, `"12.5"`); the pad never parses it beyond display, so callers
/// own validation and conversion.
class NumberPad extends StatelessWidget {
  /// Creates the pad.
  ///
  /// [value] is the current raw text (empty shows 0); [onChanged] receives the new raw text after each key;
  /// [allowDecimal] adds a point key; [maxDigits] caps the digits typed (default 7, so a value stays well
  /// inside an int); [unit] is the localised unit shown after the value, or null when there is none.
  const NumberPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowDecimal = false,
    this.maxDigits = 7,
    this.unit,
  });

  /// Current raw text: digits with at most one '.'.
  final String value;

  /// Called with the new raw text after a key changes it.
  final ValueChanged<String> onChanged;

  /// Whether the point key is shown.
  final bool allowDecimal;

  /// Most digits accepted (the point does not count).
  final int maxDigits;

  /// Localised unit label shown after the value, e.g. "kg"; null shows none.
  final String? unit;

  /// Applies one key to [value]: a digit `'0'`..`'9'`, `'.'` or `'del'`.
  ///
  /// Returns the new raw text (unchanged when the key is not allowed: too many digits, a second point).
  /// Throws nothing.
  String _apply(String key) {
    if (key == 'del') return value.isEmpty ? value : value.substring(0, value.length - 1);
    if (key == '.') {
      if (!allowDecimal || value.contains('.')) return value;
      return value.isEmpty ? '0.' : '$value.';
    }
    if (value.replaceAll('.', '').length >= maxDigits) return value;
    return value == '0' ? key : value + key;
  }

  /// Formats [value] for display: Indian grouping on the whole part, the fraction as typed, "0" when empty.
  /// Returns the text; throws nothing (the pad only ever produces digits and one point).
  String _display() {
    if (value.isEmpty) return '0';
    final parts = value.split('.');
    final whole = NumberFormat.decimalPattern('en_IN').format(int.parse(parts.first));
    return parts.length == 1 ? whole : '$whole.${parts[1]}';
  }

  /// Builds one key filling its grid cell. [key] is the value passed to [_apply]; [child] its face;
  /// [label] the spoken name for keys without text; [height] the key height. Returns the widget.
  Widget _key(String key, Widget child, double height, {String? label}) {
    final button = FilledButton.tonal(
      onPressed: () {
        final next = _apply(key);
        if (next != value) onChanged(next);
      },
      style: FilledButton.styleFrom(minimumSize: Size.fromHeight(height), padding: EdgeInsets.zero),
      child: child,
    );
    return Expanded(
      child: label == null
          ? button
          : MergeSemantics(
              child: Semantics(label: label, child: button),
            ),
    );
  }

  /// Builds the read-out and the key grid. [context] supplies theme, tokens and strings. Returns the widget;
  /// throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    // DECISION D-002: keys are Material 3 FilledButton.tonal sized by the FarmerTokens main-action height.
    //   ADV: ripple, focus, disabled and semantics come from Material; 64 dp keys suit a field thumb.
    //   COMPROMISE: the 4-row pad needs about 350 dp of height, so a pad screen holds little else.
    final height = tokens.farmerTarget;
    final digitStyle = theme.textTheme.headlineMedium;
    Widget digit(String d) => _key(d, Text(d, style: digitStyle), height);
    Widget row(List<Widget> keys) => Padding(
      padding: EdgeInsets.only(top: tokens.gap),
      child: Row(
        children: [
          keys[0],
          SizedBox(width: tokens.gap),
          keys[1],
          SizedBox(width: tokens.gap),
          keys[2],
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            unit == null ? _display() : '${_display()} $unit',
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        row([
          allowDecimal
              ? _key('.', Text('.', style: digitStyle), height, label: l10n.numberPadPoint)
              : const Expanded(child: SizedBox()),
          digit('0'),
          _key('del', const Icon(Icons.backspace_outlined, size: 32), height, label: l10n.numberPadDelete),
        ]),
      ],
    );
  }
}
