// O03e Land size: acres or cents on two cards, a big + / − stepper in that unit, and the optional survey number.
// Requirement: UserFlows §Onboarding a farmer step 5 ("a large + / − stepper in acres or cents (100 cents = 1 acre),
//   whichever the farmer uses. The officer adds the survey number if the farmer has it"), FR65, CLAUDE.md §5.6
//   (quantities carry units: the plot entry sends `{value, unit}` in the farmer's unit), D-017
//   (`plot.land_record_ref` disabled hides the box; required blocks Next).
// Callers: onboarding_wizard.dart (OnboardingStep.landSize).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/widgets/big_stepper.dart';
import '../../core/widgets/picture_card_grid.dart';
import 'boundary_area.dart';
import 'officer_text_entry.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// Largest declared size accepted, in acres (a smallholder plot; anything bigger is a typing slip).
const _maxAcres = 100;

/// Unit cards, stepper, survey number, Next.
class LandSizeStep extends ConsumerWidget {
  /// Creates the step.
  const LandSizeStep({super.key});

  /// Builds the step. [context] supplies strings; [ref] reads and edits the draft. Returns the widget; throws
  /// nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(onboardingProvider).requireValue;
    final notifier = ref.read(onboardingProvider.notifier);
    final cents = d.areaUnit == 'cent';
    return stepColumn(context, [
      PictureCardGrid<String>(
        selected: d.areaUnit,
        // Switching keeps the same land: 2 acres become 200 cents; 150 cents become 2 acres (nearest whole acre).
        onSelected: (unit) => notifier.edit((d) {
          if (unit == d.areaUnit) return;
          d.areaValue = unit == 'cent'
              ? d.areaValue * centsPerAcre
              : (d.areaValue / centsPerAcre).round().clamp(1, _maxAcres);
          d.areaUnit = unit;
        }),
        choices: [
          PictureChoice(value: 'acre', picture: const Icon(Icons.crop_square, size: 56), label: l10n.unitAcres),
          PictureChoice(value: 'cent', picture: const Icon(Icons.grid_on, size: 56), label: l10n.unitCents),
        ],
      ),
      BigStepper(
        value: d.areaValue,
        min: 1,
        max: cents ? _maxAcres * centsPerAcre : _maxAcres,
        unit: cents ? l10n.unitCents : l10n.unitAcres,
        onChanged: (v) => notifier.edit((d) => d.areaValue = v),
      ),
      if (d.rules.enabled('plot', 'land_record_ref'))
        OfficerTextEntry(
          label: l10n.onboardSurveyLabel,
          value: d.surveyNo,
          onChanged: (v) => notifier.edit((d) => d.surveyNo = v),
          capitalization: TextCapitalization.characters,
        ),
      const NextButton(),
    ]);
  }
}
