// The app's single Material 3 theme.
// Requirement: mobile-design.md §6 (useMaterial3, ColorScheme.fromSeed green, dynamic colour off,
//   materialTapTargetSize padded, FarmerTokens); UserFlows §Design rules "Big targets", "Language first".
// Callers: AgriTraceApp (lib/app.dart); widget and golden tests.

import 'package:flutter/material.dart';

import 'farmer_tokens.dart';

/// Builds the light Material 3 theme used by every role.
///
/// The colour scheme is derived from a fixed green seed. Tamil glyphs fall back to the bundled
/// `NotoSansTamil` subset. Returns the [ThemeData]; throws nothing.
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    // Dynamic colour (Android 12 wallpaper colours) is deliberately not used: status colours and
    // contrast must look the same on every phone so field officers can describe screens over the phone.
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    fontFamilyFallback: const ['NotoSansTamil'],
    extensions: const [FarmerTokens.farmer],
  );
}
