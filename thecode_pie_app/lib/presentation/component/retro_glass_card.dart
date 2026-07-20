import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';

class RetroGlassCard extends StatelessWidget {
  const RetroGlassCard({
    super.key,
    required this.child,
    this.width = 420,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
    this.borderColor,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? AppColors.crust.withValues(alpha: 0.62),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55210F20),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
