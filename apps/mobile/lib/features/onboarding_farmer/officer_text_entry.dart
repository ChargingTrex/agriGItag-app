// OfficerTextEntry: THE ONLY FREE-TEXT BOX IN THE APP. The field officer (never the farmer) types the farmer's name
//   (step 3) and the optional survey number (step 5, e.g. "245/3B", which a digit keypad cannot enter).
// Requirement: UserFlows §Onboarding a farmer steps 3 and 5 ("the officer ... enters the name"; "the officer adds
//   the survey number"), §Design rules "Tap, never type" (farmers never see a free-text box; officer screens follow
//   the rules where they can). tool/no_textfield_lint.sh checks this folder and allows only this file, by path.
// Callers: who_step.dart (name), land_size_step.dart (survey number).

import 'package:flutter/material.dart';

/// An outlined single-line text box, at least 56 dp tall, that reports every change.
class OfficerTextEntry extends StatefulWidget {
  /// Creates the box.
  ///
  /// [label] is the localised field name shown in the box; [value] the starting text (the box owns the text after
  /// that); [onChanged] receives the text after each edit; [maxLength] matches the API limit (FarmerIn.name 120,
  /// PlotIn.land_record_ref 120); [capitalization] is the keyboard's auto-capitalisation.
  const OfficerTextEntry({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.maxLength = 120,
    this.capitalization = TextCapitalization.words,
  });

  /// Localised field name.
  final String label;

  /// Text when the box is first shown.
  final String value;

  /// Called with the whole text after each edit.
  final ValueChanged<String> onChanged;

  /// Most characters accepted.
  final int maxLength;

  /// Keyboard auto-capitalisation.
  final TextCapitalization capitalization;

  /// Creates the state that owns the text controller. Returns it; throws nothing.
  @override
  State<OfficerTextEntry> createState() => _OfficerTextEntryState();
}

class _OfficerTextEntryState extends State<OfficerTextEntry> {
  late final _controller = TextEditingController(text: widget.value);

  /// Releases the controller. Throws nothing.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the text box. [context] supplies the theme. Returns the widget; throws nothing.
  @override
  Widget build(BuildContext context) => TextField(
    controller: _controller,
    onChanged: widget.onChanged,
    maxLength: widget.maxLength,
    textCapitalization: widget.capitalization,
    style: Theme.of(context).textTheme.titleLarge,
    decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder(), counterText: ''),
  );
}
