import 'package:flutter/material.dart';

/// 앱 색상 상수
class AppColors {
  // 배경 색상
  static const Color darkBackground = Color(0xFF070814);
  static const Color darkBackgroundSecondary = Color(0xFF0C1230);
  static const Color darkBackgroundTertiary = Color(0xFF0A1030);

  // 글래스모피즘 카드
  static const Color glassCardBackground = Color(0xCC0B0F24);
  static const Color glassCardBorder = Color(0xFF22D3EE);

  // 네온/그라데이션 색상
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color neonPurpleShadow = Color(0x804B2DFA);

  // 텍스트 색상
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  static const Color textTertiary = Color(0x61FFFFFF); // white38

  // 그리드 색상
  static const Color gridColor = Color(0xFF1F2B4D);

  // 글로우 원 색상 (투명도 포함)
  static Color glowPurple = neonPurple.withOpacity(0.36);
  static Color glowCyan = neonCyan.withOpacity(0.36);
}
