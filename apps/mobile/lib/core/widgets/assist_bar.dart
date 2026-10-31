// AssistBar: coloured top bar "Logging for: <name>" shown while a field officer enters data for a farmer.
// Requirement: UserFlows §Design rules "Help is a person" (the field officer can do anything on the farmer's
//   behalf); CLAUDE.md §6 (assist mode recorded on every entry, so the officer must always see it is on);
//   plan §7.2 M10 ("assist bar on every screen").
// Callers: assist-mode screens under /assist/:farmerId (M10); test/widget/kit_*.

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';

/// Full-width tertiary-coloured strip with an officer icon and "Logging for: [farmerName]"; not tappable.
class AssistBar extends StatelessWidget {
  /// Creates the bar for the farmer called [farmerName].
  const AssistBar({super.key, required this.farmerName});

  /// Name of the farmer the officer is logging for.
  final String farmerName;

  /// Builds the strip. [context] supplies theme, tokens and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final onColor = theme.colorScheme.onTertiaryContainer;
    // Colour plus icon: the strip is recognisable without colour vision.
    return Material(
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.gap, vertical: 12),
        child: MergeSemantics(
          child: Row(
            children: [
              Icon(Icons.support_agent, color: onColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).loggingFor(farmerName),
                  style: theme.textTheme.titleMedium?.copyWith(color: onColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
