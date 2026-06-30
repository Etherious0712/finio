import 'package:flutter/animation.dart';

/// Motion tokens for consistent micro-interactions. Keep durations short —
/// motion is feedback, not decoration.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Default easing for entering/settling elements.
  static const Curve curve = Curves.easeOutCubic;

  /// Slight overshoot for playful affordances (FAB, selection pops).
  static const Curve emphasized = Curves.easeOutBack;
}
