// F05: the one extra choice some events need between "choose the event" and "take the photo" — seed variety, product
// and bags, harvest/packing bags with the yield preview, drying start or done, problem kind.
// Requirement: UserFlows §Each farm event (extra choice column; kg = bags × bag size; yield check), §Logging a farm
//   event ("one picture or + / − screen between the first two taps"), §Design rules "Tap, never type"; FR55, FR56,
//   FR57, FR68; D-006 (yield preview), D-017 (fields the tenant disabled are hidden, labels from the YAML).
// Callers: EventFlowScreen (event_flow_screen.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/refdata/models/reference.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/big_stepper.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'event_log_controller.dart';
import 'farm_event.dart';

/// The extra choice of the current draft's event. Every forward tap (a card, Start/Done, Next) calls [onDone].
class ExtraChoice extends ConsumerWidget {
  /// Creates the choice; [onDone] moves on to the camera.
  const ExtraChoice({super.key, required this.onDone});

  /// Opens the camera step once the choice is made.
  final VoidCallback onDone;

  /// Builds the event's choice widgets. [context] supplies theme and strings; [ref] reads and updates the draft.
  /// Returns a [Column] for the flow screen's scroll view; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(eventLogProvider);
    final n = ref.read(eventLogProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final lang = Localizations.localeOf(context).languageCode;
    final gap = SizedBox(height: tokens.gap);
    // YAML label of the field (D-017), else the ARB word.
    String label(String field, String fallback) => d.rules.label(field, lang) ?? fallback;
    void pick(void Function(EventDraft d) change) {
      n.update(change);
      onDone();
    }

    final stepper = BigStepper(
      value: d.bags,
      min: 1,
      max: 999,
      unit: label('bags', l10n.bagsUnit),
      onChanged: (v) => n.update((d) => d.bags = v),
    );
    final next = FarmerButton(
      icon: Icons.photo_camera,
      label: l10n.next,
      onPressed: onDone,
      onSpeak: () => playPrompt(ref, context, 'next'),
      prominent: true,
    );
    final children = switch (d.event!) {
      FarmEvent.nursery => [
        VoicePromptBar(promptId: 'nurseryPrompt', text: l10n.nurseryPrompt),
        gap,
        PictureCardGrid<String>(
          selected: null,
          // '' is the seed-packet card (no variety); a null value would match `selected: null` and look chosen.
          onSelected: (v) => pick((d) => d.seedVariety = v.isEmpty ? null : v),
          choices: [
            for (final v in kSeedVarieties)
              PictureChoice(value: v, picture: const Icon(Icons.grain, size: 56), label: v),
            // "Photograph the seed packet" leaves the variety empty; hidden when the tenant requires it (D-017).
            if (!d.rules.required('seed_variety'))
              PictureChoice(
                value: '',
                picture: const Icon(Icons.inventory_2, size: 56),
                label: l10n.seedPacket,
                promptId: 'seedPacket',
              ),
          ],
        ),
      ],
      FarmEvent.inputApplication => [
        VoicePromptBar(promptId: 'inputPrompt', text: l10n.inputPrompt),
        if (d.rules.enabled('quantity')) ...[gap, stepper],
        gap,
        if (d.rules.enabled('input_id')) _Products(onPicked: onDone, next: next) else next,
      ],
      FarmEvent.harvest || FarmEvent.packing => [
        VoicePromptBar(promptId: 'bagsPrompt', text: l10n.bagsPrompt),
        gap,
        stepper,
        if (d.event == FarmEvent.harvest) ..._yieldNote(context, n.yieldPreview(), l10n, tokens),
        gap,
        next,
      ],
      FarmEvent.drying => [
        VoicePromptBar(promptId: 'dryingPrompt', text: l10n.dryingPrompt),
        for (final (phase, icon, text, prompt) in [
          ('start', Icons.wb_sunny, l10n.dryingStart, 'dryingStart'),
          ('end', Icons.check_circle, l10n.dryingDone, 'dryingDone'),
        ]) ...[
          gap,
          FarmerButton(
            icon: icon,
            label: text,
            onPressed: () => pick((d) => d.dryingPhase = phase),
            onSpeak: () => playPrompt(ref, context, prompt),
            // The step the lot is at is the big one.
            prominent: d.suggestedDryingPhase == phase,
          ),
        ],
      ],
      FarmEvent.problem => [
        VoicePromptBar(promptId: 'problemPrompt', text: l10n.problemPrompt),
        gap,
        PictureCardGrid<String>(
          selected: null,
          onSelected: (v) => pick((d) => d.problemType = v),
          choices: [
            for (final type in kProblemTypes)
              PictureChoice(
                value: type,
                picture: Icon(_problemIcons[type], size: 56),
                label: problemLabel(l10n, type),
                promptId: problemPromptId(type),
              ),
          ],
        ),
      ],
      // No extra choice: EventFlowScreen goes straight to the camera.
      FarmEvent.landPreparation || FarmEvent.sowing => const <Widget>[],
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  /// The yield preview under the harvest stepper (D-006): nothing for `pass` or no data, an orange note for `warn`,
  /// an orange "will be reviewed" for `hold` (the farmer is never blocked). [outcome] is [EventLogNotifier.yieldPreview];
  /// [l10n] and [tokens] style it. Returns zero or two widgets; throws nothing.
  List<Widget> _yieldNote(BuildContext context, String? outcome, AppLocalizations l10n, FarmerTokens tokens) {
    if (outcome != 'warn' && outcome != 'hold') return const [];
    final text = outcome == 'warn' ? l10n.yieldWarn : l10n.yieldHold;
    return [
      SizedBox(height: tokens.gap),
      // Orange circle + sentence: colour plus shape (UserFlows §Design rules).
      MergeSemantics(
        child: Row(
          children: [
            Icon(tokens.todo.icon, color: tokens.todo.color, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
          ],
        ),
      ),
    ];
  }
}

/// Picture of each problem kind of [kProblemTypes].
const _problemIcons = {
  'pest': Icons.bug_report,
  'disease': Icons.coronavirus,
  'weather': Icons.thunderstorm,
  'other': Icons.help,
};

/// The input master as picture cards (FR56); a tap takes the product with the stepper's bags and moves on. With no
/// products downloaded yet it shows [next], so the farmer still logs the bags (saved as `{bags, "bag"}`).
class _Products extends ConsumerStatefulWidget {
  /// Creates the grid; [onPicked] runs after a product is stored in the draft; [next] replaces an empty grid.
  const _Products({required this.onPicked, required this.next});

  /// Moves on to the camera.
  final VoidCallback onPicked;

  /// The "Next" button shown when the input master is empty (before the first pull, or no list imported).
  final Widget next;

  /// Creates the state holding the loaded master. Returns it; throws nothing.
  @override
  ConsumerState<_Products> createState() => _ProductsState();
}

/// State of [_Products]: the master loaded once.
class _ProductsState extends ConsumerState<_Products> {
  /// The input master with pack sizes, loaded once.
  late final Future<List<(InputItem, num?)>> _items = ref.read(eventLogProvider.notifier).inputs();

  /// Builds the grid once the master is loaded (nothing before), or [_Products.next] when it is empty. [context]
  /// supplies the locale. Returns the widget; throws nothing (a broken bundle shows no cards; the officer re-syncs it).
  @override
  Widget build(BuildContext context) {
    final ta = Localizations.localeOf(context).languageCode == 'ta';
    return FutureBuilder(
      future: _items,
      builder: (context, snap) {
        // The master is local; nothing to show for the few milliseconds it loads.
        if (!snap.hasData) return const SizedBox.shrink();
        if (snap.data!.isEmpty) return widget.next;
        return PictureCardGrid<(InputItem, num?)>(
          selected: null,
          onSelected: (item) {
            ref.read(eventLogProvider.notifier).update((d) {
              d
                ..input = item.$1
                ..packSize = item.$2;
            });
            widget.onPicked();
          },
          choices: [
            for (final item in snap.data!)
              PictureChoice(
                value: item,
                picture: ExcludeSemantics(child: Image.asset('assets/images/events/product.webp', height: 72)),
                // Product names are FPO master data, shown as the FPO wrote them.
                label: ta ? item.$1.nameLocal ?? item.$1.nameEn : item.$1.nameEn,
              ),
          ],
        );
      },
    );
  }
}

/// The localised word for problem [type] (one of [kProblemTypes]) from [l10n]. Throws nothing.
String problemLabel(AppLocalizations l10n, String type) => switch (type) {
  'pest' => l10n.problemPest,
  'disease' => l10n.problemDisease,
  'weather' => l10n.problemWeather,
  _ => l10n.problemOther,
};

/// Voice prompt id (ARB key) of problem [type]'s word. Throws nothing.
String problemPromptId(String type) => 'problem${type[0].toUpperCase()}${type.substring(1)}';
