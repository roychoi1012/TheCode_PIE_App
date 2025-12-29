import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

/// 레트로 스타일 배경 위젯
class RetroBackground extends StatelessWidget {
  const RetroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBackground,
                AppColors.darkBackgroundSecondary,
                AppColors.darkBackgroundTertiary,
              ],
            ),
          ),
        ),
        Opacity(
          opacity: 0.16,
          child: ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.transparent],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: CustomPaint(painter: _GridPainter()),
          ),
        ),
        Positioned(
          top: 80,
          left: -40,
          child: _GlowCircle(color: AppColors.glowOrange),
        ),
        Positioned(
          bottom: 120,
          right: -50,
          child: _GlowCircle(color: AppColors.glowCream),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.02)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gridColor
      ..strokeWidth = 0.6;
    const gridSize = 26.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
