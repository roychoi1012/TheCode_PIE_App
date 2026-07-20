import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

class RetroBackground extends StatelessWidget {
  const RetroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(
        color: AppColors.pumpkin,
        child: CustomPaint(
          painter: _PumpkinPiePatternPainter(),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PumpkinPiePatternPainter extends CustomPainter {
  const _PumpkinPiePatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final crustPaint = Paint()
      ..color = AppColors.crust.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;
    final fillingPaint = Paint()
      ..color = const Color(0xFFB86D24).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    for (final pie in <({Offset center, double radius, double start})>[
      (
        center: Offset(size.width * 0.14, size.height * 0.16),
        radius: size.width * 0.62,
        start: 0.28,
      ),
      (
        center: Offset(size.width * 0.86, size.height * 0.88),
        radius: size.width * 0.72,
        start: 3.82,
      ),
    ]) {
      _drawPieSlice(
        canvas,
        center: pie.center,
        radius: pie.radius,
        startAngle: pie.start,
        sweepAngle: 0.88,
        crustPaint: crustPaint,
        fillingPaint: fillingPaint,
        linePaint: linePaint,
      );
    }

    final seedPaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    for (final seed in <Offset>[
      Offset(size.width * 0.08, size.height * 0.08),
      Offset(size.width * 0.36, size.height * 0.08),
      Offset(size.width * 0.72, size.height * 0.2),
      Offset(size.width * 0.12, size.height * 0.38),
      Offset(size.width * 0.52, size.height * 0.42),
      Offset(size.width * 0.72, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.66),
      Offset(size.width * 0.68, size.height * 0.82),
      Offset(size.width * 0.16, size.height * 0.86),
      Offset(size.width * 0.78, size.height * 0.94),
    ]) {
      canvas.save();
      canvas.translate(seed.dx, seed.dy);
      canvas.rotate(-0.55);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 18, height: 8),
        seedPaint,
      );
      canvas.restore();
    }
  }

  void _drawPieSlice(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required Paint crustPaint,
    required Paint fillingPaint,
    required Paint linePaint,
  }) {
    final outer = Rect.fromCircle(center: center, radius: radius);
    final inner = Rect.fromCircle(center: center, radius: radius * 0.82);
    canvas.drawArc(outer, startAngle, sweepAngle, true, crustPaint);
    canvas.drawArc(
      inner,
      startAngle + 0.04,
      sweepAngle - 0.08,
      true,
      fillingPaint,
    );

    final crustRect = Rect.fromCircle(center: center, radius: radius * 0.96);
    canvas.drawArc(
      crustRect,
      startAngle + 0.06,
      sweepAngle - 0.12,
      false,
      linePaint,
    );

    for (final angle in <double>[
      startAngle + 0.18,
      startAngle + sweepAngle * 0.5,
      startAngle + sweepAngle - 0.18,
    ]) {
      canvas.drawLine(
        center,
        center + Offset.fromDirection(angle, radius * 0.72),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
