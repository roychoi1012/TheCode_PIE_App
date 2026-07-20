import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      elevation: 3,
      shadowColor: const Color(0x332F2330),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 232,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE7E1DB)),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.pumpkin,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GoogleMark(),
                    SizedBox(width: 10),
                    Text(
                      '시작하기',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnLight,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: Color(0xFFE1D9D0))),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: const Size(18, 18),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.55, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.25, 1.25, false, paint);
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(rect, 2.4, 1.3, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.55, 1.4, false, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.5),
      Offset(size.width - 2, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
