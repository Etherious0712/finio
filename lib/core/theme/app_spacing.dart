import 'package:flutter/material.dart';

/// Spacing scale. Use these instead of raw magic numbers so layout stays
/// consistent across screens.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radius scale.
abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(xxl));
}

/// Soft elevation shadows tuned for a calm finance UI (lower contrast than
/// Material's default dark drop shadows).
abstract final class Shadows {
  static List<BoxShadow> soft(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> subtle(Color tint) => [
        BoxShadow(
          color: tint.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
}
