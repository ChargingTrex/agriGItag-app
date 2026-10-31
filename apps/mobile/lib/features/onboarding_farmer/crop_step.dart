// O03h Crop: picture cards of the FPO's crops with an instant GI-region preview of the pin, then the save: "Farmer's
//   phone" (go on to step 9) or "No smartphone" (stop after step 8; the farmer gets voice calls and SMS instead).
// Requirement: UserFlows §Onboarding a farmer step 8 ("picture cards of the crops the FPO handles. The GI-region
//   check runs instantly and shows a green tick or an orange 'needs review' circle") and the no-smartphone exit,
//   FR67, FR70, D-006 (phone preview, server authority), D-019 (approximate outline), D-017 (`plot.gi_tag_id`).
// Callers: onboarding_wizard.dart (OnboardingStep.crop).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/models/reference.dart';
import '../../core/rules/gi_check.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/theme/status_glyphs.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/picture_card_grid.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';
import 'water_step.dart' show assetPicture;

/// Whether the pin of [d] passes the GI preview for [d]'s crop against [region] (null before the outline arrived).
///
/// DECISION D-006: the phone runs M03's `giCheck` on the pin only as a preview; the server re-runs the PostGIS check
///   when the plot syncs and its answer is the one stored.
///   ADV: the officer sees at once whether to expect a review, with no signal.
///   COMPROMISE: the preview can disagree with the server (older outline, pin moved); the server wins silently.
/// DECISION D-019: the outline is an approximation from open boundaries, so a pin within the buffer outside it
///   (`nearEdge`) previews as a tick like the server's near-edge status; the server still reviews it (FR70).
///   ADV: no false alarm on the edge.  COMPROMISE: a pin just outside the true border previews green.
/// Returns null when the crop has no GI tag (no preview), true for a tick, false for "needs review". Throws nothing.
bool? giPreview(OnboardingDraft d, GiRegion? region) {
  final pin = d.pin;
  if (d.crop?.giTagId == null || pin == null) return null;
  if (region == null) return false;
  return giCheck(region, pin.lat, pin.lng).status != GiStatus.outside;
}

/// Crop cards, the GI preview, a save-failure sentence, and the save buttons.
class CropStep extends ConsumerWidget {
  /// Creates the step.
  const CropStep({super.key});

  /// Builds the step. [context] supplies theme, tokens and strings; [ref] reads the crops, the outline and the
  /// draft. Returns the widget; throws nothing (a malformed bundle shows like "not downloaded").
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<FarmerTokens>()!;
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(onboardingProvider).requireValue;
    final notifier = ref.read(onboardingProvider.notifier);
    final crops = ref.watch(onboardingCropsProvider).value ?? const <Crop>[];
    final preview = giPreview(d, ref.watch(onboardingGiRegionProvider).value);
    final tamil = Localizations.localeOf(context).languageCode == 'ta';
    Widget status(StatusGlyph glyph, String text) => MergeSemantics(
      child: Row(
        children: [
          Icon(glyph.icon, color: glyph.color, size: 36),
          SizedBox(width: tokens.gap / 2),
          Expanded(
            child: Text(text, style: theme.textTheme.titleLarge?.copyWith(color: glyph.color)),
          ),
        ],
      ),
    );
    final error = d.error;
    final canSave = d.canLeave(OnboardingStep.crop);
    return stepColumn(context, [
      if (crops.isEmpty)
        Text(l10n.onboardNoCrops, style: theme.textTheme.titleMedium)
      else
        PictureCardGrid<String>(
          selected: d.crop?.id,
          onSelected: (id) => notifier.edit((d) => d.crop = crops.firstWhere((c) => c.id == id)),
          choices: [
            for (final c in crops)
              PictureChoice(
                value: c.id,
                picture: assetPicture('assets/images/crops/${c.code.toLowerCase()}.webp', Icons.grass),
                label: tamil ? c.nameLocal ?? c.nameEn : c.nameEn,
              ),
          ],
        ),
      if (preview != null)
        status(preview ? tokens.done : tokens.todo, preview ? l10n.onboardGiInside : l10n.onboardGiReview),
      if (error != null)
        status(tokens.attention, switch (error) {
          'farmer_phone_taken' => l10n.onboardPhoneTaken,
          'network' => l10n.errorNetwork,
          _ => l10n.errorUnknown,
        }),
      if (d.farmerSaved)
        FarmerButton(
          icon: Icons.save,
          label: l10n.onboardSave,
          onPressed: canSave ? () => notifier.save(hasSmartphone: true) : null,
          onSpeak: () => playPrompt(ref, context, 'onboardSave'),
          prominent: true,
        )
      else ...[
        if (d.phone != null)
          FarmerButton(
            icon: Icons.smartphone,
            label: l10n.onboardFarmerPhone,
            onPressed: canSave ? () => notifier.save(hasSmartphone: true) : null,
            onSpeak: () => playPrompt(ref, context, 'onboardFarmerPhone'),
            prominent: true,
          ),
        FarmerButton(
          icon: Icons.phone_disabled,
          label: l10n.onboardNoSmartphone,
          onPressed: canSave ? () => notifier.save(hasSmartphone: false) : null,
          onSpeak: () => playPrompt(ref, context, 'onboardNoSmartphone'),
        ),
      ],
    ]);
  }
}
