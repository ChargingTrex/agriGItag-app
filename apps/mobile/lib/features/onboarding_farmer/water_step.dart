// O03g Water and practice: farming type (irrigated / rainfed) and water source (well, borewell, canal, tank, rain
//   only) as picture cards; plus the soil step, shown only when the FPO captures `plot.soil_type`.
// Requirement: UserFlows §Onboarding a farmer step 7 ("picture cards — well, borewell, canal, tank, rain only"),
//   FR54 (farming type separate from irrigation source; server enums FarmingType / IrrigationSource), Dataflow
//   Stage 0 (soil type optional), PLAN §7.2 field-config note (disabling `plot.soil_type` removes that step), D-017.
// Callers: onboarding_wizard.dart (OnboardingStep.water, OnboardingStep.soil); crop_step.dart (assetPicture).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/widgets/picture_card_grid.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// The bundled picture at [asset] (64 dp tall), or the [fallback] icon when the file is missing or undecodable.
///
/// Returns the widget; throws nothing.
Widget assetPicture(String asset, IconData fallback) =>
    Image.asset(asset, height: 64, errorBuilder: (_, _, _) => Icon(fallback, size: 56));

/// Farming-type cards and water-source cards (each group hidden when its field is disabled), then Next.
class WaterStep extends ConsumerWidget {
  /// Creates the step.
  const WaterStep({super.key});

  /// Builds the step. [context] supplies strings; [ref] reads and edits the draft. Returns the widget; throws
  /// nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(onboardingProvider).requireValue;
    final notifier = ref.read(onboardingProvider.notifier);
    PictureChoice<String> card(String dir, String value, IconData icon, String label) =>
        PictureChoice(value: value, picture: assetPicture('assets/images/$dir/$value.webp', icon), label: label);
    return stepColumn(context, [
      if (d.rules.enabled('plot', 'farming_type'))
        PictureCardGrid<String>(
          selected: d.farmingType,
          onSelected: (v) => notifier.edit((d) => d.farmingType = v),
          choices: [
            card('practice', 'irrigated', Icons.water_drop, l10n.farmingIrrigated),
            card('practice', 'rainfed', Icons.cloud, l10n.farmingRainfed),
          ],
        ),
      if (d.rules.enabled('plot', 'irrigation_source'))
        PictureCardGrid<String>(
          selected: d.irrigationSource,
          onSelected: (v) => notifier.edit((d) => d.irrigationSource = v),
          choices: [
            card('water', 'well', Icons.circle_outlined, l10n.waterWell),
            card('water', 'borewell', Icons.vertical_align_bottom, l10n.waterBorewell),
            card('water', 'canal', Icons.waves, l10n.waterCanal),
            card('water', 'tank', Icons.water, l10n.waterTank),
            card('water', 'rain', Icons.thunderstorm_outlined, l10n.waterRain),
          ],
        ),
      const NextButton(),
    ]);
  }
}

/// Soil cards (red, black, sandy, alluvial: the soils of the pilot district), then Next.
class SoilStep extends ConsumerWidget {
  /// Creates the step.
  const SoilStep({super.key});

  /// Builds the step. [context] supplies strings; [ref] reads and edits the draft. Returns the widget; throws
  /// nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final soil = ref.watch(onboardingProvider.select((d) => d.requireValue.soilType));
    // The colour swatch is the picture; the label carries the meaning too (colour plus words, never colour alone).
    PictureChoice<String> card(String value, Color color, String label) => PictureChoice(
      value: value,
      picture: Icon(Icons.landscape, size: 56, color: color),
      label: label,
    );
    return stepColumn(context, [
      PictureCardGrid<String>(
        selected: soil,
        onSelected: (v) => ref.read(onboardingProvider.notifier).edit((d) => d.soilType = v),
        choices: [
          card('red', const Color(0xFFA0442A), l10n.soilRed),
          card('black', const Color(0xFF2B2B2B), l10n.soilBlack),
          card('sandy', const Color(0xFFC8A165), l10n.soilSandy),
          card('alluvial', const Color(0xFF7A6248), l10n.soilAlluvial),
        ],
      ),
      const NextButton(),
    ]);
  }
}
