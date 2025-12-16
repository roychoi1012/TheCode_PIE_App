import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 레트로 스타일 글래스모피즘 카드 위젯
class RetroGlassCard extends StatelessWidget {
  const RetroGlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.glassCardBorder.withOpacity(0.45),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrangeShadow,
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
