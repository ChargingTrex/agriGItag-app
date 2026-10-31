// Officer flag screens: the list of flags to clear, one flag's detail (what triggered it, the rule details, the three
//   outcomes) and the outcome screen (the corrected bag count for "Fix it", the reason picture cards, Save).
// Requirement: UserFlows §Field officer flows "Flags to clear" (orange and red items) and "Clearing a flag" (open the
//   flag, see what triggered it; "Looks fine", "Fix it" or "Escalate to FPO admin"; a reason from a short picture
//   list), §Design rules ("Colour plus shape, never colour alone": severity as glyph + colour + word); FR56, FR70.
// Callers: app_router.dart routes `/officer/flags`, `/officer/flags/:flagId`, `/officer/flags/:flagId/:action`
//   (officer home "Flags" button).

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../core/db/providers.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../../core/theme/status_glyphs.dart';
import '../../core/widgets/big_stepper.dart';
import '../../core/widgets/picture_card_grid.dart';
import '../event_log/choose_event_screen.dart' show farmerAppBar;
import '../event_log/event_log_controller.dart' show afterSaveProvider, clockProvider;
import '../event_log/farm_event.dart';
import '../officer_home/officer_button.dart';
import 'flag_actions.dart';

/// The glyph and word of a flag [severity]: hold = red triangle "Hold", warn = orange circle "Check", anything else =
/// grey info "Note". [context] supplies the tokens, theme and strings. Returns the pair; throws nothing.
(StatusGlyph, String) severityGlyph(BuildContext context, String severity) {
  final tokens = Theme.of(context).extension<FarmerTokens>()!;
  final glyph = switch (severity) {
    'hold' => tokens.attention,
    'warn' => tokens.todo,
    _ => StatusGlyph(icon: Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
  };
  return (glyph, AppLocalizations.of(context).flagSeverity(severity));
}

/// One flag row from the list provider, or null once it is gone (resolved here, or closed by the pull).
/// [ref] watches the list; [flagId] is the flag. Throws nothing.
OfficerFlag? _flagOf(WidgetRef ref, String flagId) =>
    ref.watch(officerFlagsProvider).value?.where((f) => f.flag.flagId == flagId).firstOrNull;

/// The severity glyph + word, in the glyph colour, as one semantics node. [severity] as in [severityGlyph].
class _SeverityBadge extends StatelessWidget {
  /// Creates the badge for [severity].
  const _SeverityBadge(this.severity);

  /// Flag severity (`hold`, `warn`, `info`).
  final String severity;

  /// Builds icon and word. [context] supplies theme and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final (glyph, label) = severityGlyph(context, severity);
    return MergeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(glyph.icon, color: glyph.color, size: 28),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: glyph.color)),
        ],
      ),
    );
  }
}

/// The flags to clear: one tile per flag (severity glyph, what triggered it, the farmer), holds first.
class FlagsScreen extends ConsumerWidget {
  /// Creates the screen.
  const FlagsScreen({super.key});

  /// Builds the list, or the "nothing to clear" line. [context] supplies theme and strings; [ref] watches the flags.
  /// Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final flags = ref.watch(officerFlagsProvider).value ?? const [];
    return Scaffold(
      appBar: farmerAppBar(context, l10n.flagsTitle),
      body: flags.isEmpty
          ? Padding(
              padding: EdgeInsets.all(tokens.gap),
              child: Row(
                children: [
                  Icon(tokens.done.icon, color: tokens.done.color, size: 28),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.flagsNone, style: Theme.of(context).textTheme.titleMedium)),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.symmetric(vertical: tokens.gap / 2),
              children: [
                for (final f in flags)
                  ListTile(
                    minTileHeight: tokens.minTarget,
                    leading: Icon(
                      severityGlyph(context, f.flag.severity).$1.icon,
                      color: severityGlyph(context, f.flag.severity).$1.color,
                      size: 28,
                    ),
                    title: Text(l10n.flagRule(f.flag.type)),
                    subtitle: Text('${severityGlyph(context, f.flag.severity).$2} · ${f.farmerName ?? '—'}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/officer/flags/${f.flag.flagId}'),
                  ),
              ],
            ),
    );
  }
}

/// One flag: what triggered it, its rule details, and the outcomes the officer may choose.
///
/// "Fix it" needs the flagged entry on this phone; "Looks fine" and "Escalate" only an open warn/info flag (holds and
/// escalated flags are the FPO admin's, and the screen says so).
class FlagDetailScreen extends ConsumerWidget {
  /// Creates the screen for [flagId].
  const FlagDetailScreen({super.key, required this.flagId});

  /// The flag shown.
  final String flagId;

  /// Builds the detail. [context] supplies theme and strings; [ref] watches the flag and its entry.
  /// Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final row = _flagOf(ref, flagId);
    final gap = SizedBox(height: tokens.gap);
    final text = Theme.of(context).textTheme;
    if (row == null) {
      return Scaffold(
        appBar: farmerAppBar(context, l10n.flagsTitle),
        body: Padding(
          padding: EdgeInsets.all(tokens.gap),
          child: Text(l10n.flagsNone, style: text.titleMedium),
        ),
      );
    }
    final flag = row.flag;
    final entryId = flag.entryId;
    final entry = entryId == null ? null : ref.watch(flaggedEntryProvider(entryId)).value;
    final event = FarmEvent.fromWire(entry?.entryType);
    final details = (jsonDecode(flag.detailJson) as Map).cast<String, Object?>();
    final mayResolve = officerMayResolve(flag);
    return Scaffold(
      appBar: farmerAppBar(context, l10n.flagsTitle),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          Align(alignment: Alignment.centerLeft, child: _SeverityBadge(flag.severity)),
          gap,
          Text(l10n.flagRule(flag.type), style: text.headlineSmall),
          Text([row.farmerName ?? '—', if (event != null) event.label(l10n)].join(' · '), style: text.titleMedium),
          gap,
          // Officer-facing rule inputs and limits; a quantity reads "195 kg".
          for (final MapEntry(:key, :value) in details.entries)
            Text('$key: ${value is Map && value.containsKey('value') ? '${value['value']} ${value['unit']}' : value}'),
          gap,
          OfficerButton(
            icon: Icons.build,
            label: l10n.flagFixIt,
            onPressed: entry == null ? null : () => context.push('/officer/flags/$flagId/${FlagAction.fix.name}'),
          ),
          if (entry == null) Text(l10n.flagNotOnPhone, style: text.bodyLarge),
          gap,
          if (mayResolve) ...[
            OfficerButton(
              icon: Icons.check,
              label: l10n.flagLooksFine,
              onPressed: () => context.push('/officer/flags/$flagId/${FlagAction.fine.name}'),
              tonal: true,
            ),
            gap,
            OfficerButton(
              icon: Icons.forward,
              label: l10n.flagEscalate,
              onPressed: () => context.push('/officer/flags/$flagId/${FlagAction.escalate.name}'),
              tonal: true,
            ),
          ] else
            Text(l10n.flagAdminOnly, style: text.bodyLarge),
        ],
      ),
    );
  }
}

/// The outcome screen: for "Fix it" on a harvest or packing entry the corrected bag count, then the mandatory reason
/// cards and Save. Saving writes the correction and/or the `flag_resolution` entry ([saveFlagAction]) and returns to
/// the flag list.
class FlagActionScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [action] on [flagId].
  const FlagActionScreen({super.key, required this.flagId, required this.action});

  /// The flag being cleared.
  final String flagId;

  /// The outcome chosen on the detail screen.
  final FlagAction action;

  /// Creates the state holding the reason and bag count. Returns it; throws nothing.
  @override
  ConsumerState<FlagActionScreen> createState() => _FlagActionScreenState();
}

class _FlagActionScreenState extends ConsumerState<FlagActionScreen> {
  String? _reason;
  int? _bags;
  bool _saving = false;

  /// Saves the outcome once, then opens the flag list with "Saved.". [flag] is the flag, [entry] the flagged entry
  /// (fix only). Throws nothing; a failed write keeps the screen so the officer can tap Save again.
  Future<void> _save(Flag flag, Entry? entry) async {
    setState(() => _saving = true);
    try {
      await saveFlagAction(
        ref.read(appDatabaseProvider),
        flag: flag,
        action: widget.action,
        reasonCode: _reason!,
        now: ref.read(clockProvider)(),
        entry: entry,
        bags: _bags,
      );
      ref.read(afterSaveProvider)();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go('/officer/flags');
      messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).savedOnline)));
    } on Exception {
      // SqliteException: nothing was written (one transaction).
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Builds the stepper (fix on a bagged event), the reason cards and Save. [context] supplies theme and strings.
  /// Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final gap = SizedBox(height: tokens.gap);
    final row = _flagOf(ref, widget.flagId);
    final entryId = row?.flag.entryId;
    final entry = entryId == null ? null : ref.watch(flaggedEntryProvider(entryId)).value;
    final fix = widget.action == FlagAction.fix;
    // shortcut: "Fix it" corrects only the bag count (harvest, packing); other payload fields keep their value and the
    //   correction records the reason. Add picture cards per field when officers ask to fix varieties or products.
    final bags = fix ? (entry == null ? null : jsonDecode(entry.payloadJson)['bags']) : null;
    final title = switch (widget.action) {
      FlagAction.fix => l10n.flagFixIt,
      FlagAction.fine => l10n.flagLooksFine,
      FlagAction.escalate => l10n.flagEscalate,
    };
    final ready = row != null && _reason != null && (!fix || entry != null) && !_saving;
    return Scaffold(
      appBar: farmerAppBar(context, title),
      body: ListView(
        padding: EdgeInsets.all(tokens.gap),
        children: [
          if (row != null) Text(l10n.flagRule(row.flag.type), style: Theme.of(context).textTheme.titleMedium),
          gap,
          if (bags is int) ...[
            BigStepper(value: _bags ?? bags, min: 1, max: 999, unit: l10n.bagsUnit, onChanged: (v) => _bags = v),
            gap,
          ],
          Text(l10n.flagReasonPrompt, style: Theme.of(context).textTheme.titleMedium),
          gap,
          PictureCardGrid<String>(
            selected: _reason,
            onSelected: (r) => setState(() => _reason = r),
            choices: [
              for (final (code, icon) in [
                ('field_visit', Icons.directions_walk),
                ('farmer_confirmed', Icons.record_voice_over),
                ('photo_checked', Icons.photo_camera),
                ('entry_mistake', Icons.edit_note),
              ])
                PictureChoice(value: code, picture: Icon(icon, size: 56), label: l10n.flagReason(code)),
            ],
          ),
          gap,
          OfficerButton(
            icon: Icons.save,
            label: l10n.onboardSave,
            onPressed: ready ? () => _save(row.flag, entry) : null,
          ),
        ],
      ),
    );
  }
}
