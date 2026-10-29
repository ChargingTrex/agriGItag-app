// FarmerTokens: the size and status tokens every farmer widget reads from the theme.
// Requirement: UserFlows §Design rules "Big targets" (>= 56 dp, full width, wide gaps) and "Colour plus
//   shape"; plan §7.2 (FarmerTokens ThemeExtension, minTarget 56, farmerTarget 64); mobile-design.md §6.
// Callers: app_theme.dart registers it; FarmerButton and the M05 widget kit read it with
//   `Theme.of(context).extension<FarmerTokens>()!`.

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'status_glyphs.dart';

/// Theme extension holding farmer-UI target sizes, spacing and status glyphs.
@immutable
class FarmerTokens extends ThemeExtension<FarmerTokens> {
  /// Creates tokens.
  ///
  /// [minTarget] is the minimum height of any tappable control in dp; [farmerTarget] the height of the
  /// main action on a farmer screen; [gap] the space between controls; [done], [todo] and [attention]
  /// the status glyphs.
  const FarmerTokens({
    required this.minTarget,
    required this.farmerTarget,
    required this.gap,
    required this.done,
    required this.todo,
    required this.attention,
  });

  /// Farmer defaults: 56 dp minimum, 64 dp main action, 16 dp gap, tick / circle / triangle glyphs.
  static const farmer = FarmerTokens(
    minTarget: 56,
    farmerTarget: 64,
    gap: 16,
    done: StatusGlyph.done,
    todo: StatusGlyph.todo,
    attention: StatusGlyph.attention,
  );

  /// Minimum height of a tappable control, in dp (56 for farmers).
  final double minTarget;

  /// Height of the primary action of a farmer screen, in dp (64).
  final double farmerTarget;

  /// Gap between controls, in dp (16), so a thumb does not hit the neighbour.
  final double gap;

  /// Glyph for "done" (green tick).
  final StatusGlyph done;

  /// Glyph for "to do" (orange circle).
  final StatusGlyph todo;

  /// Glyph for "needs attention" (red triangle).
  final StatusGlyph attention;

  /// Returns a copy with the given fields replaced; null arguments keep the current value. Throws nothing.
  @override
  FarmerTokens copyWith({
    double? minTarget,
    double? farmerTarget,
    double? gap,
    StatusGlyph? done,
    StatusGlyph? todo,
    StatusGlyph? attention,
  }) => FarmerTokens(
    minTarget: minTarget ?? this.minTarget,
    farmerTarget: farmerTarget ?? this.farmerTarget,
    gap: gap ?? this.gap,
    done: done ?? this.done,
    todo: todo ?? this.todo,
    attention: attention ?? this.attention,
  );

  /// Interpolates towards [other] at position [t] (0..1) for theme animations.
  ///
  /// Returns this unchanged when [other] is not a [FarmerTokens]. Throws nothing.
  @override
  FarmerTokens lerp(covariant ThemeExtension<FarmerTokens>? other, double t) {
    if (other is! FarmerTokens) return this;
    return FarmerTokens(
      minTarget: lerpDouble(minTarget, other.minTarget, t)!,
      farmerTarget: lerpDouble(farmerTarget, other.farmerTarget, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      done: StatusGlyph.lerp(done, other.done, t),
      todo: StatusGlyph.lerp(todo, other.todo, t),
      attention: StatusGlyph.lerp(attention, other.attention, t),
    );
  }
}
