import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_typography.dart';

/// Animated circular budget gauge. Color shifts safe → warning → danger as the
/// spent ratio climbs. Replaces the old flat [LinearProgressIndicator] bars.
class BudgetRing extends StatelessWidget {
  const BudgetRing({
    super.key,
    required this.spent,
    required this.budget,
    this.size = 64,
    this.stroke = 7,
    this.centerLabel,
  });

  final double spent;
  final double budget;
  final double size;
  final double stroke;

  /// Optional small label drawn in the middle (e.g. category name).
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final finio = context.finio;
    final ratio = budget > 0 ? spent / budget : 0.0;
    final color = ratio >= 1.0
        ? finio.budgetDanger
        : ratio >= 0.8
            ? finio.budgetWarning
            : finio.budgetSafe;
    final pct = (ratio * 100).round();

    return TweenAnimationBuilder<double>(
      duration: Motion.slow,
      curve: Motion.curve,
      tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value,
              color: color,
              track: color.withValues(alpha: 0.15),
              stroke: stroke,
            ),
            child: Center(
              child: Text(
                centerLabel ?? '$pct%',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.w700)
                    .tabular,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
