// CloudSyncIndicator: small grey cloud with the number of entries waiting to send; green tick when none.
// Requirement: UserFlows §Design rules "Works with no signal" (a small cloud icon shows "waiting to send")
//   and §When things go wrong (No signal: green tick and a small grey cloud); mobile-design.md §3 ("Cloud
//   icon = count(Outbox status != confirmed) as a stream"); plan §13 A2.
// Callers: ConfirmScaffold (this folder); farmer home app bar (M07); test/widget/kit_*.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/farmer_tokens.dart';

/// Number of entries saved on the phone and not yet confirmed by the server.
///
/// shortcut: emits 0 until M02 overrides it with the Drift Outbox count stream (M01 `pendingCount`).
final pendingSendCountProvider = StreamProvider<int>((ref) => Stream.value(0));

/// Grey cloud + count while entries wait to send, the "done" tick when nothing waits; not tappable.
///
/// Shows nothing until the first count arrives, so it never claims "all sent" before it knows.
class CloudSyncIndicator extends ConsumerWidget {
  /// Creates the indicator; the count comes from [pendingSendCountProvider].
  const CloudSyncIndicator({super.key});

  /// Builds the icon (and count). [context] supplies theme and strings; [ref] watches the count stream.
  /// Returns the widget; throws nothing (a stream error shows as nothing, like loading).
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingSendCountProvider).value;
    if (count == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final done = Theme.of(context).extension<FarmerTokens>()!.done;
    if (count == 0) {
      return Semantics(
        label: l10n.cloudAllSent,
        child: ExcludeSemantics(child: Icon(done.icon, color: done.color, size: 28)),
      );
    }
    // Grey with a number: shape (cloud) and count carry the meaning, not the colour.
    final grey = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      label: l10n.cloudPending(count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, color: grey, size: 28),
            const SizedBox(width: 4),
            Text('$count', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: grey)),
          ],
        ),
      ),
    );
  }
}
