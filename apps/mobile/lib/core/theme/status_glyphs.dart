// Status glyphs: icon + colour pairs for done / to do / needs attention.
// Requirement: UserFlows §Design rules "Colour plus shape, never colour alone" (green tick = done,
//   orange circle = to do, red triangle = needs attention); mobile-design.md §6 (contrast >= 4.5:1).
// Callers: FarmerTokens (core/theme/farmer_tokens.dart); StatusBadge and history lists from M05 on.

import 'package:flutter/material.dart';

/// One status shown as a distinct shape and a colour, so it reads without colour vision.
///
/// The label text comes from the l10n file at the call site; this type carries only the visuals.
@immutable
class StatusGlyph {
  /// Creates a glyph.
  ///
  /// [icon] is the shape that must stay distinguishable in greyscale; [color] is its foreground colour
  /// and must keep a contrast of at least 4.5:1 on the light theme surface.
  const StatusGlyph({required this.icon, required this.color});

  /// Shape of the status (tick, circle, triangle).
  final IconData icon;

  /// Foreground colour of [icon].
  final Color color;

  /// Green filled tick: the task or entry is done (server confirmed).
  /// Colour 0xFF2E7D32 has contrast 4.9:1 on the M3 green-seed surface.
  static const done = StatusGlyph(icon: Icons.check_circle, color: Color(0xFF2E7D32));

  /// Orange open circle: still to do. Colour 0xFFB45309 has contrast 4.8:1 on the surface.
  static const todo = StatusGlyph(icon: Icons.radio_button_unchecked, color: Color(0xFFB45309));

  /// Red triangle: needs attention. Colour 0xFFC62828 has contrast 5.4:1 on the surface.
  static const attention = StatusGlyph(icon: Icons.warning_rounded, color: Color(0xFFC62828));

  /// Interpolates between two glyphs for theme animations.
  ///
  /// [a] and [b] are the start and end glyphs and [t] the position (0..1). Returns a glyph whose colour is
  /// interpolated and whose icon switches at the midpoint (icons cannot blend). Throws nothing.
  static StatusGlyph lerp(StatusGlyph a, StatusGlyph b, double t) =>
      StatusGlyph(icon: t < 0.5 ? a.icon : b.icon, color: Color.lerp(a.color, b.color, t)!);

  /// Value equality: true when [other] is a [StatusGlyph] with the same icon and colour. Throws nothing.
  @override
  bool operator ==(Object other) => other is StatusGlyph && other.icon == icon && other.color == color;

  /// Hash of icon and colour, consistent with [operator ==]. Throws nothing.
  @override
  int get hashCode => Object.hash(icon, color);
}
