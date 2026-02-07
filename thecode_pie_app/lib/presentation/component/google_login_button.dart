import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 구글 로그인 아이콘 버튼 위젯
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
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)], // 구글 브랜드 색상 유지
            begin: .topLeft,
            end: .bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x804B2DFA), // 구글 브랜드 그림자 색상
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(60, 60),
                    painter: _GoogleLogoPainter(),
                  ),
                ),
              ),
      ),
    );
  }
}

/// 구글 로고를 그리는 CustomPainter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 구글 컬러
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFFBBC04), // Yellow
      const Color(0xFFEA4335), // Red
    ];

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // 구글 로고는 G 글자 형태로 4개의 컬러를 사용
    // 간단하게 원형 그라데이션으로 표현
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 파란색 (우측 상단)
    paint.color = colors[0];
    canvas.drawArc(
      rect,
      -3.14159 / 2, // -90도
      3.14159 / 2, // 90도
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // 초록색 (우측 하단)
    paint.color = colors[1];
    canvas.drawArc(
      rect,
      0, // 0도
      3.14159 / 2, // 90도
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // 노란색 (좌측 하단)
    paint.color = colors[2];
    canvas.drawArc(
      rect,
      3.14159 / 2, // 90도
      3.14159 / 2, // 90도
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // 빨간색 (좌측 상단 일부)
    paint.color = colors[3];
    canvas.drawArc(
      rect,
      3.14159, // 180도
      3.14159 / 2, // 90도
      false,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    // 중앙에 G 글자
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'G',
        style: GoogleFonts.roboto(
          fontSize: size.width * 0.5,
          fontWeight: .w500,
          color: const Color(0xFF4285F4),
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: .center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
