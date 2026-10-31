// OfficerButton: the full-width 56 dp action button of the field-officer screens, without the farmer speaker.
// Requirement: UserFlows §Design rules ("the field officer and FPO screens follow them where they can": big targets,
//   icon + word) and §Field officer flows; mobile-design.md §6 (56 dp targets).
// Callers: officer_home_screen.dart, officer_flags (flag detail and action), officer_moisture/moisture_screen.dart,
//   farmer_home_screen.dart (Moisture and End assist in assist mode).

import 'package:flutter/material.dart';

import '../../core/theme/farmer_tokens.dart';

/// A full-width icon + label button at the farmer minimum height; [tonal] for secondary actions.
class OfficerButton extends StatelessWidget {
  /// Creates the button: [icon] and [label] say what it does, [onPressed] runs it (null disables it), [tonal] picks
  /// the quieter style so it never competes with the screen's main action.
  const OfficerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.tonal = false,
  });

  /// Picture of the action.
  final IconData icon;

  /// Localised label.
  final String label;

  /// The action; null renders the button disabled.
  final VoidCallback? onPressed;

  /// Whether to use the tonal (secondary) style.
  final bool tonal;

  /// Builds the button. [context] supplies the [FarmerTokens]. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: Size.fromHeight(Theme.of(context).extension<FarmerTokens>()!.minTarget),
    );
    final iconWidget = Icon(icon, size: 28);
    return tonal
        ? FilledButton.tonalIcon(onPressed: onPressed, icon: iconWidget, label: Text(label), style: style)
        : FilledButton.icon(onPressed: onPressed, icon: iconWidget, label: Text(label), style: style);
  }
}
