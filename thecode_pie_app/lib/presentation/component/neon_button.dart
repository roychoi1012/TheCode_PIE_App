import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thecode_pie_app/constants/app_colors.dart';

/// 네온 효과 버튼 위젯
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentOrange, AppColors.accentOrangeDark],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrangeShadow,
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, color: Colors.black87),
        label: Text(
          label,
          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }
}
