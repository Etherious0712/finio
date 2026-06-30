import 'package:flutter/material.dart';

/// Bundled font (see pubspec `fonts:`). Variable weights are honored via
/// [TextStyle.fontWeight].
const String kFontFamily = 'Inter';

/// Tabular figures keep money columns aligned (every digit the same width).
const List<FontFeature> kTabularFigures = [FontFeature.tabularFigures()];

/// A distinctive type scale built on Inter. Slightly tighter letter spacing on
/// large text and bolder display weights than the Material default give the app
/// a more crafted, less "default-Flutter" feel.
TextTheme buildTextTheme(ColorScheme scheme) {
  final body = scheme.onSurface;
  final muted = scheme.onSurfaceVariant;

  return TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
      color: body,
    ),
    displayMedium: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: body,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: body,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: body,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: body,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: body,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: body),
    bodyMedium: TextStyle(fontSize: 14, color: body),
    bodySmall: TextStyle(fontSize: 12, color: muted),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: body,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: muted,
    ),
  );
}

/// Helper for money displays: applies tabular figures to any style.
extension MoneyTextStyle on TextStyle {
  TextStyle get tabular => copyWith(fontFeatures: kTabularFigures);
}
