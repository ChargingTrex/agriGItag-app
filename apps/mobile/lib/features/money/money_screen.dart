// F11 Money: one card per lot of the farmer with its status (glyph + word), the field it grew on and the packed
// kilograms; also the farmer's lot list that the Sell screen reads.
// Requirement: UserFlows §Selling to the FPO (step 5 "Payment status appears later on the farmer's Money screen"),
//   §Design rules ("Colour plus shape", Indian number grouping); plan §7.2 M08 (Money: lot status, packed kg, batch
//   share % only from what the pull holds; no price unless field config enables it, D-017); FR58 (units).
// Callers: app_router.dart route `/home/money`; sell_screen.dart ([farmerLotsProvider], [lotStatusBadge]).

import 'dart:convert';

import 'package:drift/drift.dart' show Constant, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/widgets/call_officer_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../event_log/choose_event_screen.dart' show farmerAppBar;
import '../event_log/event_log_controller.dart';
import '../event_log/farm_event.dart';

/// One lot as the farmer sees it: the [lot] row, the [field] number of its plot (1 = first plot by id) and the packed
/// kilograms [packedKg].
typedef FarmerLot = ({Lot lot, int field, double packedKg});

/// The farmer's lots (the assisted farmer's in assist mode), ordered by plot then season, re-emitted when a lot row
/// changes.
///
/// The packed kilograms are the server's (`Lots.kgPacked`); while that is still 0 (packing logged offline, not pulled
/// yet) they are the sum of the lot's standing packing entries on this phone. Errors are database errors.
final farmerLotsProvider = StreamProvider<List<FarmerLot>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final assist = ref.watch(assistFarmerProvider);
  final query = db.select(db.lots)
    ..where((l) => assist == null ? const Constant(true) : l.farmerId.equals(assist.farmerId))
    ..orderBy([(l) => OrderingTerm.asc(l.plotId), (l) => OrderingTerm.asc(l.season)]);
  return query.watch().asyncMap((lots) async {
    final plots = {for (final l in lots) l.plotId}.toList();
    return [
      for (final l in lots)
        (
          lot: l,
          field: plots.indexOf(l.plotId) + 1,
          packedKg: l.kgPacked > 0 ? l.kgPacked : await _localPackedKg(db, l.lotId),
        ),
    ];
  });
});

/// Kilograms of the standing (not undone, not superseded) packing entries of [lotId] in [db]. Returns 0 when there
/// are none; throws [FormatException] when a stored payload is not JSON.
Future<double> _localPackedKg(AppDatabase db, String lotId) async {
  var kg = 0.0;
  for (final e in await db.entriesDao.latestVersions(lotId)) {
    if (e.entryType != FarmEvent.packing.wireName) continue;
    final q = (jsonDecode(e.payloadJson) as Map<String, dynamic>)['quantity'];
    // A pulled Decimal arrives as a JSON string, a phone-made one as a number.
    if (q is Map && q['unit'] == 'kg') kg += num.tryParse('${q['value']}') ?? 0;
  }
  return kg;
}

/// [kg] with Indian digit grouping and at most one decimal ("1,20,000", "12.5"). Throws nothing.
String formatKg(double kg) => NumberFormat('#,##,##0.#', 'en_IN').format(kg);

/// The badge for a server lot [status] (`LotStatus`): an orange circle while the crop grows or dries, a green tick from
/// "ready to sell" on, each with its own word from [l10n]. An unknown status shows the plain "to do" badge.
/// Returns the badge; throws nothing.
StatusBadge lotStatusBadge(String status, AppLocalizations l10n) => switch (status) {
  'open' => StatusBadge(status: FarmerStatus.todo, label: l10n.lotStatusOpen),
  'drying' => StatusBadge(status: FarmerStatus.todo, label: l10n.lotStatusDrying),
  readyForSale => StatusBadge(status: FarmerStatus.done, label: l10n.lotStatusReady),
  'received' => StatusBadge(status: FarmerStatus.done, label: l10n.lotStatusReceived),
  'batched' => StatusBadge(status: FarmerStatus.done, label: l10n.lotStatusBatched),
  'closed' => StatusBadge(status: FarmerStatus.done, label: l10n.lotStatusClosed),
  _ => const StatusBadge(status: FarmerStatus.todo),
};

/// The Money screen.
class MoneyScreen extends ConsumerWidget {
  /// Creates the screen.
  const MoneyScreen({super.key});

  /// Builds the spoken sentence, one card per lot (or the "no crop" sentence) and Call officer. [context] supplies
  /// theme and strings; [ref] watches [farmerLotsProvider]. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final lots = ref.watch(farmerLotsProvider).value;
    final gap = SizedBox(height: tokens.gap);
    return Scaffold(
      appBar: farmerAppBar(context, l10n.homeMoney),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          if (lots != null && lots.isEmpty)
            VoicePromptBar(key: const ValueKey('noLot'), promptId: 'noLot', text: l10n.noLot)
          else
            VoicePromptBar(key: const ValueKey('moneyPrompt'), promptId: 'moneyPrompt', text: l10n.moneyPrompt),
          // shortcut: no batch share % and no price: the pull carries neither yet (TODO B07: lot `batch_share_pct`,
          //   and `price_per_kg` only when the tenant's field config makes it farmer-visible, D-017).
          for (final l in lots ?? const <FarmerLot>[]) ...[
            gap,
            Card.outlined(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(tokens.gap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.plotNumber(l.field), style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: tokens.gap / 2),
                    lotStatusBadge(l.lot.status, l10n),
                    if (l.packedKg > 0) ...[
                      SizedBox(height: tokens.gap / 2),
                      Text(l10n.moneyPacked(formatKg(l.packedKg)), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ],
                ),
              ),
            ),
          ],
          gap,
          const CallFieldOfficerButton(),
        ],
      ),
    );
  }
}
