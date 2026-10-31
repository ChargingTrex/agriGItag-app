// F04 Choose event: eight picture cards, the first of the three taps of every routine event.
// Requirement: UserFlows §Logging a farm event ("Three taps: choose the event, take the photo, confirm"), §Each farm
//   event (the eight events), §Design rules (one job, pictures and voice, call officer on every screen); FR3.
// Callers: app_router.dart routes `/log` and `/assist/:farmerId/log` (farmer home "Log" button).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import 'event_log_controller.dart';
import 'farm_event.dart';

/// The event grid; a tap opens `/log/<event>`, where the lot, the extra choice and the camera follow.
class ChooseEventScreen extends ConsumerWidget {
  /// Creates the screen.
  const ChooseEventScreen({super.key});

  /// Builds the prompt, the eight cards and the call button. [context] supplies theme and strings; [ref] is unused
  /// beyond the kit widgets. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    return Scaffold(
      appBar: farmerAppBar(context, l10n.chooseEventTitle),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          VoicePromptBar(promptId: 'chooseEventPrompt', text: l10n.chooseEventPrompt),
          SizedBox(height: tokens.gap),
          PictureCardGrid<FarmEvent>(
            selected: null,
            onSelected: (e) => context.push(farmerPath(ref, '/log/${e.wireName}')),
            choices: [
              for (final e in FarmEvent.values)
                PictureChoice(value: e, picture: eventPicture(e), label: e.label(l10n), promptId: e.promptId),
            ],
          ),
          SizedBox(height: tokens.gap),
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}

/// The bundled placeholder picture of [event], 72 dp tall; decoration for screen readers (the card label speaks).
/// Returns the image; a missing asset shows the generic photo icon. Throws nothing.
///
/// DECISION D-016: the event pictures ship inside the app (assets/images/events/*.webp, ≤ 20 KB each).
///   ADV: the first event can be logged offline on day one, with pictures before words.
///   COMPROMISE: every picture adds to the APK; today they are ~2 KB placeholders until drawn art replaces them.
Widget eventPicture(FarmEvent event) => ExcludeSemantics(
  child: Image.asset(event.asset, height: 72, errorBuilder: (_, _, _) => const Icon(Icons.photo, size: 56)),
);

/// App bar for farmer flow screens: [title], optional [actions] and a 56 dp back button (Material's implied one is 48 dp, below the
/// farmer minimum). [context] supplies the tokens. Returns the bar; throws nothing.
PreferredSizeWidget farmerAppBar(BuildContext context, String title, {List<Widget>? actions}) {
  final tokens = Theme.of(context).extension<FarmerTokens>()!;
  return AppBar(
    title: Text(title),
    leading: Navigator.of(context).canPop()
        ? BackButton(style: IconButton.styleFrom(minimumSize: Size.square(tokens.minTarget)))
        : null,
    automaticallyImplyLeading: false,
    actions: actions,
  );
}
