import 'package:flutter/material.dart';

const _cardTheme = CardThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  ),
);

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D52)),
    cardTheme: _cardTheme,
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D52),
      brightness: Brightness.dark,
    ),
    cardTheme: _cardTheme,
  );

  static final ThemeData highContrast = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.highContrastLight().copyWith(
      primary: Colors.black,
      secondary: Colors.black,
    ),
    cardTheme: _cardTheme,
  );
}
