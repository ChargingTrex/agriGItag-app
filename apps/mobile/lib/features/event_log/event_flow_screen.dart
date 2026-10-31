// `/log/<event>`: everything between choosing the event and the confirm screen — the lot (picked by itself when the
// farmer has one active lot), the out-of-order question (F09), the extra choice (F05) and the camera (F06).
// Also the deep-link target F17: `/log/harvest` opens here with harvest preselected (reminders, M12).
// Requirement: UserFlows §Logging a farm event (three taps), §Each farm event, "When a farmer opens an event out of
//   order ... asks once by voice 'Did you already sow?' with Yes / No buttons, and flags the gap"; FR3, FR55; D-006.
// Callers: app_router.dart route `/log/:eventType` (ChooseEventScreen cards, farmer home task card, deep links).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'camera_step.dart';
import 'choose_event_screen.dart';
import 'event_log_controller.dart';
import 'extra_choice.dart';
import 'farm_event.dart';

/// Where the flow screen is.
enum _Step {
  /// Lots, draft and out-of-order question loading.
  loading,

  /// The farmer has no active lot.
  noLot,

  /// More than one active lot: the field picker.
  pickLot,

  /// The event's extra choice (F05).
  extra,

  /// The camera (F06).
  camera,
}

/// The flow screen for [event].
class EventFlowScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [event] (from the route's `eventType`); [lotId] (the `?lot=` query of the home task card)
  /// starts on that lot when it is active.
  const EventFlowScreen({super.key, required this.event, this.lotId});

  /// Event being logged.
  final FarmEvent event;

  /// Lot named by the task that opened the flow, or null to pick it here.
  final String? lotId;

  /// Creates the state that walks the steps. Returns it; throws nothing.
  @override
  ConsumerState<EventFlowScreen> createState() => _EventFlowScreenState();
}

/// State of [EventFlowScreen]: which step is on screen and the lots to pick from.
class _EventFlowScreenState extends ConsumerState<EventFlowScreen> {
  /// The step on screen.
  _Step _step = _Step.loading;

  /// The farmer's active lots, for the field picker.
  List<Lot> _lots = const [];

  /// Loads the farmer's active lots and starts the draft. Side effect: replaces the draft. Throws nothing.
  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Starts on the task's lot ([EventFlowScreen.lotId]) when it is active, else on the only active lot, else shows the
  /// lot picker. Throws nothing beyond database errors.
  ///
  /// D-043 (Architect-Gate ruling 2026-10-31b §4): the next-task card must stay 3 (+1) taps for a farmer with two or
  /// more lots, so the card's lot skips the field picker; an inactive or unknown lot falls back to the picker.
  Future<void> _load() async {
    final lots = await ref.read(eventLogProvider.notifier).activeLots();
    if (!mounted) return;
    final pick = lots.where((l) => l.lotId == widget.lotId).firstOrNull ?? (lots.length == 1 ? lots.single : null);
    if (pick != null) return _begin(pick);
    setState(() {
      _lots = lots;
      _step = lots.isEmpty ? _Step.noLot : _Step.pickLot;
    });
  }

  /// Starts the draft on [lot], asks the out-of-order question once when needed, then shows the extra choice or the
  /// camera. Side effects: draft, maybe the phone-only "already asked" marker. Throws nothing beyond database errors.
  Future<void> _begin(Lot lot) async {
    final n = ref.read(eventLogProvider.notifier);
    setState(() => _step = _Step.loading);
    await n.start(widget.event, lot);
    final question = await n.orderQuestion();
    if (question != null && mounted) {
      final didIt = await _ask(question.ask);
      await n.answerOrder(question.gaps, didIt: didIt);
    }
    if (mounted) setState(() => _step = n.hasExtraChoice ? _Step.extra : _Step.camera);
  }

  /// F09: asks "Did you already sow?" (or the step of [missing]) with Yes / No; the sheet cannot be swiped away, so the
  /// answer is always recorded and the question never repeats. Returns the answer; throws nothing.
  Future<bool> _ask(FarmEvent missing) async {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final answer = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      // Scroll-controlled and scrollable: at 1.5x text on a small phone the sheet is taller than half the screen.
      isScrollControlled: true,
      // PopScope: Android Back must not close the sheet with no answer and record it as "No".
      builder: (sheet) => PopScope(
        canPop: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                eventPicture(missing),
                SizedBox(height: tokens.gap),
                VoicePromptBar(promptId: missing.askPromptId, text: missing.askedAlready(l10n)),
                SizedBox(height: tokens.gap),
                FarmerButton(
                  icon: Icons.check,
                  label: l10n.yes,
                  onPressed: () => Navigator.of(sheet).pop(true),
                  onSpeak: () => playPrompt(ref, sheet, 'yes'),
                  prominent: true,
                ),
                SizedBox(height: tokens.gap),
                FarmerButton(
                  icon: Icons.close,
                  label: l10n.no,
                  onPressed: () => Navigator.of(sheet).pop(false),
                  onSpeak: () => playPrompt(ref, sheet, 'no'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return answer ?? false;
  }

  /// Builds the current step under the event's app bar. Back from the camera returns to the extra choice.
  /// [context] supplies theme and strings. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final backToExtra = _step == _Step.camera && ref.read(eventLogProvider.notifier).hasExtraChoice;
    final body = switch (_step) {
      // Loading takes milliseconds (local database); a spinner would only flash, and would keep animating under the
      // out-of-order sheet.
      _Step.loading => const SizedBox.shrink(),
      _Step.camera => CameraStep(onAccepted: () => context.push('/log/${widget.event.wireName}/confirm')),
      _Step.noLot => _list(tokens, [
        Icon(Icons.grass, size: 96, color: tokens.attention.color),
        VoicePromptBar(promptId: 'noLot', text: l10n.noLot),
        FarmerButton(
          icon: Icons.home,
          label: l10n.goHome,
          onPressed: () => context.go('/home'),
          onSpeak: () => playPrompt(ref, context, 'goHome'),
          prominent: true,
        ),
      ]),
      _Step.pickLot => _list(tokens, [
        VoicePromptBar(promptId: 'choosePlotPrompt', text: l10n.choosePlotPrompt),
        PictureCardGrid<Lot>(
          selected: null,
          onSelected: _begin,
          choices: [
            for (final (i, lot) in _lots.indexed)
              PictureChoice(value: lot, picture: const Icon(Icons.grass, size: 56), label: l10n.plotNumber(i + 1)),
          ],
        ),
      ]),
      _Step.extra => _list(tokens, [ExtraChoice(onDone: () => setState(() => _step = _Step.camera))]),
    };
    return PopScope(
      canPop: !backToExtra,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = _Step.extra);
      },
      child: Scaffold(appBar: farmerAppBar(context, widget.event.label(l10n)), body: body),
    );
  }

  /// A padded scroll view of [children] with gaps and the call button last ([tokens] spacing). Throws nothing.
  Widget _list(FarmerTokens tokens, List<Widget> children) => ListView(
    padding: EdgeInsets.all(tokens.gap),
    children: [
      for (final c in children) ...[c, SizedBox(height: tokens.gap)],
      const CallFieldOfficerButton(),
    ],
  );
}
