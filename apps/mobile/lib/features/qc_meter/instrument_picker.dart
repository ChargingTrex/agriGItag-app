// Instrument choice of the QC forms: the FPO's registered meters (an expired calibration cannot be picked, with the
//   reason), "Visual" where the standard allows it, and the Bluetooth meter option shown disabled ("Coming soon").
// Requirement: FR42 (instrument id and calibration on every reading), FR44 (visual readings), FR50 ("instruments past
//   their calibration due date cannot be selected"), FR52 (Bluetooth meters: later phase), UserFlows §Grade a batch
//   ("or pair the moisture meter by Bluetooth"), PLAN §7.2 M11 (BLE stub).
// Callers: qc_intake/intake_screen.dart (moisture meters), qc_grading/grading_screen.dart (all instruments + visual);
//   test/features/qc/*.

import 'package:flutter/material.dart';

import '../../core/db/database.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/theme/farmer_tokens.dart';
import '../qc_home/qc_common.dart';

/// Picker value of a visual reading (no instrument, source `visual`).
const visualSource = 'visual';

/// Whether [instrument]'s calibration has expired on [today]: readings measured after the due day are refused by the
/// server (FR50), so the phone refuses to pick it. The due day itself still counts as calibrated. Throws nothing.
bool calibrationExpired(Instrument instrument, DateTime today) =>
    DateUtils.dateOnly(today).isAfter(DateUtils.dateOnly(instrument.calibrationDueDate));

/// The instrument list: one row per meter, optional "Visual", and the disabled Bluetooth row.
class InstrumentPicker extends StatelessWidget {
  /// Creates the picker. [instruments] are the meters to offer; [selected] is the picked instrument id or
  /// [visualSource] (null: nothing picked); [onSelected] receives a new choice; [allowVisual] adds "Visual"; [today]
  /// decides which calibrations have expired. Throws nothing.
  const InstrumentPicker({
    super.key,
    required this.instruments,
    required this.selected,
    required this.onSelected,
    required this.today,
    this.allowVisual = false,
  });

  /// Meters offered.
  final List<Instrument> instruments;

  /// Picked instrument id, [visualSource], or null.
  final String? selected;

  /// Called with the id (or [visualSource]) of a tapped, pickable row.
  final ValueChanged<String> onSelected;

  /// The day calibrations are checked against.
  final DateTime today;

  /// Whether "Visual" is offered.
  final bool allowVisual;

  /// Builds the heading and rows. [context] supplies theme, tokens and strings. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<FarmerTokens>()!;
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.qcMeter, style: Theme.of(context).textTheme.titleMedium),
        if (instruments.isEmpty) CheckLine(check: (glyph: tokens.todo, text: l10n.qcNoMeter)),
        for (final i in instruments)
          if (calibrationExpired(i, today)) ...[
            _row(context, Icons.speed, i.label, null, null),
            CheckLine(
              check: (glyph: tokens.attention, text: l10n.qcCalibrationExpired(dayText(i.calibrationDueDate, locale))),
            ),
          ] else
            _row(
              context,
              Icons.speed,
              i.label,
              l10n.qcCalibrationDue(dayText(i.calibrationDueDate, locale)),
              i.instrumentId,
            ),
        if (allowVisual) _row(context, Icons.visibility, l10n.qcVisual, null, visualSource),
        // shortcut: Bluetooth meters (FR52) are a later phase; the row only tells the QC officer it is coming. Wire a
        //   BLE plugin here (and a LIBRARIES.md row) when the FPO buys a BLE meter.
        _row(context, Icons.bluetooth, l10n.qcBluetoothMeter, l10n.qcComingSoon, null),
      ],
    );
  }

  /// One row: [icon], [title], optional [subtitle]. [value] is what a tap picks; null makes the row unpickable (shown
  /// with a block sign instead of a radio mark, so it reads without colour). [context] supplies the theme. Returns
  /// the widget; throws nothing.
  Widget _row(BuildContext context, IconData icon, String title, String? subtitle, String? value) {
    final isSelected = value != null && value == selected;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: 56,
      leading: Icon(icon, size: 32),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      selected: isSelected,
      trailing: Icon(
        value == null ? Icons.block : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
      ),
      onTap: value == null ? null : () => onSelected(value),
    );
  }
}
