// F10 Sell: the farmer taps Sell and the phone shows a large QR of the lot that is ready to sell, with the field, the
// packed kilograms in large type, and a spoken "show this code"; with several ready lots the farmer
// picks the field first; with none the screen says to log packing first.
// Requirement: UserFlows §Selling to the FPO (step 1 "taps the green Sell button ... a large QR code for the lot that
//   is ready to sell"; "the farmer does nothing else"), §Design rules (pictures and voice, big targets); plan §7.2 M08
//   (QR `{lotId, farmerId, packedKg, sig}` scanned by M11); FR58 (units).
// Callers: app_router.dart route `/home/sell` (farmer home "Sell" button).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/choose_event_screen.dart' show farmerAppBar;
import '../event_log/event_log_controller.dart' show readyForSale;
import '../money/money_screen.dart';
import 'sell_qr.dart';

/// The Sell screen.
class SellScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SellScreen({super.key});

  /// Creates the state that remembers the picked lot. Returns it; throws nothing.
  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

/// State of [SellScreen]: the lot picked when several are ready.
class _SellScreenState extends ConsumerState<SellScreen> {
  /// Id of the lot the farmer picked, or null before a pick.
  String? _picked;

  /// Builds the QR of the single (or picked) ready lot, the field picker, or the "nothing ready" sentence. [context]
  /// supplies theme and strings. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final lots = ref.watch(farmerLotsProvider).value;
    final ready = [
      for (final l in lots ?? const <FarmerLot>[])
        if (l.lot.status == readyForSale) l,
    ];
    final shown = ready.length == 1 ? ready.single : ready.where((l) => l.lot.lotId == _picked).firstOrNull;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: farmerAppBar(context, l10n.homeSell),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          if (lots == null)
            const SizedBox.shrink()
          else if (shown != null)
            ..._qr(context, shown)
          else if (ready.isEmpty)
            VoicePromptBar(key: const ValueKey('sellNoLot'), promptId: 'sellNoLot', text: l10n.sellNoLot)
          else ...[
            VoicePromptBar(key: const ValueKey('sellPick'), promptId: 'sellPick', text: l10n.sellPick),
            for (final l in ready) ...[
              gap,
              FarmerButton(
                icon: Icons.qr_code,
                label: l10n.plotNumber(l.field),
                onPressed: () => setState(() => _picked = l.lot.lotId),
                onSpeak: () => playPrompt(ref, context, 'sellPick'),
              ),
            ],
          ],
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }

  /// The spoken sentence, the QR filling the screen width, then field and packed kg of [l] in large type.
  /// [context] supplies theme and strings. Returns the widgets; throws nothing.
  List<Widget> _qr(BuildContext context, FarmerLot l) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final qr = SellQr(lotId: l.lot.lotId, farmerId: l.lot.farmerId, packedKg: l.packedKg).encode();
    return [
      VoicePromptBar(key: const ValueKey('sellPrompt'), promptId: 'sellPrompt', text: l10n.sellPrompt),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, box) => Center(
          child: QrImageView(
            // Keyed by its content so tests (and M11's contract test) can read the exact payload.
            key: ValueKey(qr),
            data: qr,
            size: box.maxWidth,
            // White quiet zone and background: scanners need dark-on-light whatever the theme.
            backgroundColor: Colors.white,
            semanticsLabel: l10n.sellQrLabel(l10n.plotNumber(l.field)),
          ),
        ),
      ),
      Text(l10n.plotNumber(l.field), style: text.headlineMedium, textAlign: TextAlign.center),
      Text(l10n.kgAmount(formatKg(l.packedKg)), style: text.displaySmall, textAlign: TextAlign.center),
      // shortcut: no lot code line: the server's `lots.code` is pulled but not stored (Drift schema outside M08);
      //   add it under the kg once M01/M02 mirror `code` (a made-up code would match nothing in the portal).
    ];
  }
}
