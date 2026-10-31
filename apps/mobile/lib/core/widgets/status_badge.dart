// StatusBadge: a status shown as glyph + word (done / to do / needs attention).
// Requirement: UserFlows §Design rules "Colour plus shape, never colour alone" (green tick = done, orange
//   circle = to do, red triangle = needs attention); mobile-design.md §6 (contrast >= 4.5:1).
// Callers: farmer home task card (M07), history and money lists (M08), officer flag list (M10); test/widget/kit_*.

import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../theme/status_glyphs.dart';

/// The three statuses a farmer ever sees.
enum FarmerStatus {
  /// Done and confirmed by the server.
  done,

  /// Still to do.
  todo,

  /// Needs attention (a flag, an entry that could not be sent).
  attention,
}

/// Glyph plus localised word for a [FarmerStatus]; not tappable.
class StatusBadge extends StatelessWidget {
  /// Creates the badge for [status]; [label] replaces the status word (M08: "Sent", "Ready to sell") while the glyph
  /// keeps its meaning.
  const StatusBadge({super.key, required this.status, this.label});

  /// Which status to show.
  final FarmerStatus status;

  /// Localised word shown instead of the status word, or null for the status word.
  final String? label;

  /// Builds an icon and a text in the glyph colour. [context] supplies [FarmerTokens] and [AppLocalizations].
  /// Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final (StatusGlyph glyph, String word) = switch (status) {
      FarmerStatus.done => (tokens.done, l10n.statusDone),
      FarmerStatus.todo => (tokens.todo, l10n.statusTodo),
      FarmerStatus.attention => (tokens.attention, l10n.statusAttention),
    };
    // One semantics node: screen readers say the word once, the icon is decoration.
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(glyph.icon, color: glyph.color, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label ?? word, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: glyph.color)),
          ),
        ],
      ),
    );
  }
}
