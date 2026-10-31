// PictureCardGrid: two-column picture cards for choices (crop, product, water source), one selectable.
// Requirement: UserFlows §Design rules "Tap, never type" (choices are picture cards), "Pictures and voice
//   before words" (picture, short word, speaker), "Colour plus shape" (selection = thick border + tick, not
//   colour alone), "Big targets"; §Onboarding steps 7-8; §Each farm event (seed variety, product).
// Callers: event choices (M07), onboarding water/crop (M09); test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';
import '../voice/voice_player.dart';

/// One choice in a [PictureCardGrid].
@immutable
class PictureChoice<T> {
  /// Creates a choice.
  ///
  /// [value] is returned when the card is tapped; [picture] is the image (an `Image.asset` of the bundled
  /// webp, or an `Icon`); [label] is the localised word(s), at most two; [promptId] is the voice prompt
  /// played by the card's speaker, or null for a card without a speaker.
  const PictureChoice({required this.value, required this.picture, required this.label, this.promptId});

  /// Value handed to [PictureCardGrid.onSelected].
  final T value;

  /// The picture that carries the meaning.
  final Widget picture;

  /// Localised label, at most two words.
  final String label;

  /// Voice prompt id for the speaker, or null for no speaker.
  final String? promptId;
}

/// Cards laid out two per row, each at least 56 dp; the [selected] card gets a thick border and a tick.
class PictureCardGrid<T> extends ConsumerWidget {
  /// Creates the grid.
  ///
  /// [choices] are the cards in reading order; [selected] is the chosen value or null; [onSelected] is
  /// called with a card's value when it is tapped.
  const PictureCardGrid({super.key, required this.choices, required this.selected, required this.onSelected});

  /// Cards in reading order.
  final List<PictureChoice<T>> choices;

  /// Currently selected value, or null.
  final T? selected;

  /// Called with the tapped card's value.
  final ValueChanged<T> onSelected;

  /// Builds the two-column grid. [context] supplies theme, tokens and strings; [ref] plays card prompts.
  /// Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    // Wrap rather than GridView: cards grow with the text scale instead of overflowing a fixed aspect ratio.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - tokens.gap) / 2;
        return Wrap(
          spacing: tokens.gap,
          runSpacing: tokens.gap,
          children: [
            for (final choice in choices)
              SizedBox(width: width, child: _card(context, ref, tokens, choice, choice.value == selected)),
          ],
        );
      },
    );
  }

  /// Builds one card for [choice]; [isSelected] draws the 3 dp primary border and tick badge.
  /// [context], [ref] and [tokens] as in [build]. Returns the card; throws nothing.
  Widget _card(BuildContext context, WidgetRef ref, FarmerTokens tokens, PictureChoice<T> choice, bool isSelected) {
    final scheme = Theme.of(context).colorScheme;
    final promptId = choice.promptId;
    return Card.outlined(
      margin: EdgeInsets.zero,
      color: isSelected ? scheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? BorderSide(color: scheme.primary, width: 3) : BorderSide(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      // Card is the semantics container: one node per card carrying label, tap and the selected state;
      // the speaker stays its own node.
      child: Semantics(
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () => onSelected(choice.value),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.minTarget),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(height: 72, child: Center(child: choice.picture)),
                      if (isSelected)
                        Positioned(top: 0, right: 0, child: Icon(Icons.check_circle, color: scheme.primary, size: 28)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Label on the full card width: beside a 56 dp speaker a long Tamil word would break mid-word
                  // at 1.5x text, so the speaker sits under it.
                  Text(choice.label, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                  if (promptId != null)
                    MergeSemantics(
                      child: Semantics(
                        label: AppLocalizations.of(context).playVoice,
                        child: IconButton(
                          onPressed: () => playPrompt(ref, context, promptId),
                          icon: const Icon(Icons.volume_up, size: 28),
                          style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
