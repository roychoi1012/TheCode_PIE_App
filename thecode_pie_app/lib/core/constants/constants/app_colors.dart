import 'package:flutter/material.dart';

/// 앱 색상 상수
class AppColors {
  // 배경 색상 (오렌지 테마)
  static const Color darkBackground = Color(0xFFE0852B); // 메인 오렌지
  static const Color darkBackgroundSecondary = Color(0xFFD67A20); // 약간 어두운 오렌지
  static const Color darkBackgroundTertiary = Color(0xFFCC6F15); // 더 어두운 오렌지

  // 글래스모피즘 카드
  static const Color glassCardBackground = Color(0xCCF8F5E5); // 크림색 반투명
  static const Color glassCardBorder = Color(0xFFE0852B); // 오렌지 테두리

  // 액센트 색상
  static const Color accentOrange = Color(0xFFE0852B);
  static const Color accentOrangeDark = Color(0xFFCC6F15);
  static const Color accentOrangeShadow = Color(0x80E0852B);

  // 텍스트 색상 (크림색)
  static const Color textPrimary = Color(0xFFF8F5E5); // 크림색
  static const Color textSecondary = Color(0xE6F8F5E5); // 크림색 90%
  static const Color textTertiary = Color(0xB3F8F5E5); // 크림색 70%

  // 그리드 색상
  static const Color gridColor = Color(0x40F8F5E5); // 크림색 반투명

  // 글로우 원 색상 (투명도 포함)
  static Color glowOrange = accentOrange.withOpacity(0.3);
  static Color glowCream = textPrimary.withOpacity(0.2);
}
