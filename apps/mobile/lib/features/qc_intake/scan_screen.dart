// Q-scan: the QC officer scans the lot QR the farmer shows; the code is looked up on the phone and the intake check
//   opens with the lot card. Fallback when the camera cannot read it: pick the lot from the lots ready to sell.
// Requirement: UserFlows §Selling to the FPO step 2 ("scans the QR with the QC app. The lot, farmer and packed
//   quantity appear"), §Design rules ("Tap, never type", "Works with no signal"), PLAN §7.2 M11 ("scan → lot"; M08's
//   QR is `{lotId, farmerId, packedKg, sig}`), D-036.
// Callers: qc_home/qc_home_screen.dart ("Receive lot"); test/features/qc/*.

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/voice_prompt_bar.dart';
import '../qc_home/qc_common.dart';
import 'intake_screen.dart';
import 'sell_qr.dart';

/// Builds the camera view that reports every decoded code to the callback; tests replace it with a fake.
typedef QrScannerBuilder = Widget Function(ValueChanged<String> onCode);

/// The QR camera (mobile_scanner: CameraX + ML Kit on Android, AVFoundation + Vision on iOS).
final qrScannerProvider = Provider<QrScannerBuilder>(
  (ref) =>
      (onCode) => MobileScanner(
        onDetect: (capture) {
          final raw = capture.barcodes.firstOrNull?.rawValue;
          if (raw != null) onCode(raw);
        },
      ),
);

/// Lots on this phone that are ready to sell, newest first, as lot cards. Throws what Drift throws.
final readyLotsProvider = FutureProvider.autoDispose<List<QcLot>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final lots =
      await (db.select(db.lots)
            ..where((l) => l.status.equals('ready_for_sale'))
            ..orderBy([(l) => OrderingTerm.desc(l.updatedAt)]))
          .get();
  return [for (final l in lots) await _cardOf(db, l.lotId, l.farmerId, l.kgPacked, l.cropId)];
});

/// Resolves a scanned code [raw] to a lot, using the local Lots table of [db] first.
///
/// [raw] is M08's Sell QR (`decodeSellQr`: JSON with a checksum) or a bare lot id. A lot on the phone gives its own
/// farmer, packed kg and crop. A lot not pulled yet is shown from the QR's fields but marked unverified: the
/// checksum only catches typos, so the farmer and packed weight are not trusted until sync. Returns null for a JSON
/// payload whose checksum fails (forged or mistyped), and for a code that names no lot this phone knows (e.g. a lot
/// code `LOT0EF81415`, which the local Lots table does not hold). Throws what Drift throws.
Future<QcLot?> resolveLot(AppDatabase db, String raw) async {
  final qr = decodeSellQr(raw);
  final looksJson = raw.trimLeft().startsWith('{');
  if (looksJson && qr == null) return null;
  final lotId = qr?.lotId ?? raw.trim();
  if (lotId.isEmpty) return null;
  final lot = await (db.select(db.lots)..where((l) => l.lotId.equals(lotId))).getSingleOrNull();
  if (lot != null) return _cardOf(db, lot.lotId, lot.farmerId, lot.kgPacked, lot.cropId);
  if (qr == null) return null;
  return _cardOf(db, lotId, qr.farmerId, qr.packedKg, null, unverified: true);
}

/// The lot card for [lotId] of [farmerId] with [packedKg] kg and crop [cropId], with the farmer's name from [db]
/// when the farmer is stored on this phone; [unverified] marks a card built from the QR alone. Returns it; throws
/// what Drift throws.
Future<QcLot> _cardOf(
  AppDatabase db,
  String lotId,
  String farmerId,
  double packedKg,
  String? cropId, {
  bool unverified = false,
}) async {
  final farmer = await (db.select(db.farmers)..where((f) => f.farmerId.equals(farmerId))).getSingleOrNull();
  return QcLot(
    lotId: lotId,
    farmerId: farmerId,
    farmerName: farmer?.name,
    packedKg: packedKg,
    cropId: cropId,
    unverified: unverified,
  );
}

/// The scanner screen with the "Pick lot" fallback.
class ScanScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ScanScreen({super.key});

  /// Creates the state holding the lookup in flight and the fallback mode. Returns it; throws nothing.
  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  bool _busy = false;
  // The camera is unmounted while the intake check is open, so Back with the QR still in view does not reopen it.
  bool _paused = false;
  bool _notFound = false;
  bool _picking = false;

  /// Looks up [raw] and opens the intake check, or shows "not on this phone". Codes arriving while a lookup or the
  /// intake screen is open are ignored (the camera reports the same QR many times a second). Returns when the intake
  /// screen closes; throws what Drift throws.
  Future<void> _onCode(String raw) async {
    if (_busy) return;
    _busy = true;
    final lot = await resolveLot(ref.read(appDatabaseProvider), raw);
    if (!mounted) return;
    setState(() => _notFound = lot == null);
    if (lot != null) {
      setState(() => _paused = true);
      await _open(lot);
    }
    _busy = false;
  }

  /// Opens the intake check for [lot]. Returns when it closes; throws nothing.
  Future<void> _open(QcLot lot) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => IntakeScreen(lot: lot)));

  /// Builds the camera (or the ready-lot list) with its prompt. [context] supplies tokens and strings. Returns the
  /// screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    return qcScaffold(
      context,
      l10n.qcReceiveLot,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VoicePromptBar(
            key: ValueKey(_picking),
            promptId: _picking ? 'qcPickLotPrompt' : 'qcScanPrompt',
            text: _picking ? l10n.qcPickLotPrompt : l10n.qcScanPrompt,
          ),
          gap,
          if (_notFound) CheckLine(check: (glyph: tokens.todo, text: l10n.qcLotNotFound)),
          if (_picking)
            _ReadyLots(onPick: _open)
          else ...[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _paused
                    ? Center(
                        child: IconButton.filledTonal(
                          style: IconButton.styleFrom(minimumSize: const Size.square(96)),
                          iconSize: 56,
                          tooltip: l10n.qcScanPrompt,
                          icon: const Icon(Icons.qr_code_scanner),
                          onPressed: () => setState(() => _paused = false),
                        ),
                      )
                    : ref.watch(qrScannerProvider)(_onCode),
              ),
            ),
            gap,
            // DECISION D-036: the fallback is a list of the lots ready to sell, not a typed lot code.
            //   ADV: no typing; works offline; the local Lots table has no lot-code column to match a typed code.
            //   COMPROMISE: a lot not pulled to this phone yet cannot be picked (its QR still works).
            FarmerButton(
              icon: Icons.list,
              label: l10n.qcPickLot,
              onPressed: () => setState(() => _picking = true),
              onSpeak: () => playPrompt(ref, context, 'qcPickLot'),
            ),
          ],
        ],
      ),
    );
  }
}

/// The ready-to-sell lots as tappable cards.
class _ReadyLots extends ConsumerWidget {
  /// Creates the list; [onPick] opens the intake check for the tapped lot. Throws nothing.
  const _ReadyLots({required this.onPick});

  /// Opens the intake check for a lot.
  final ValueChanged<QcLot> onPick;

  /// Builds the list, the empty sentence or a spinner. [context] supplies strings; [ref] watches the lots. Returns
  /// the widget; throws nothing (a database error shows the generic sentence).
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    return ref
        .watch(readyLotsProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => CheckLine(check: (glyph: tokens.attention, text: l10n.errorUnknown)),
          data: (lots) => lots.isEmpty
              ? CheckLine(check: (glyph: tokens.todo, text: l10n.qcNoReadyLots))
              : Column(
                  children: [
                    for (final lot in lots)
                      Card.outlined(
                        child: ListTile(
                          minTileHeight: 56,
                          leading: const Icon(Icons.inventory_2, size: 32),
                          title: Text(lot.farmerName ?? shortId(lot.farmerId)),
                          subtitle: Text('${l10n.qcPacked}: ${kgText(lot.packedKg)} ${l10n.unitKg}'),
                          onTap: () => onPick(lot),
                        ),
                      ),
                  ],
                ),
        );
  }
}
