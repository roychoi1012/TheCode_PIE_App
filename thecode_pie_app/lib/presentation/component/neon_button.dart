import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';

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
    return ElevatedButton.icon(
      onPressed: SoundEffectsService().withSelect(onPressed),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pumpkin,
        foregroundColor: AppColors.textOnPumpkin,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      icon: Icon(icon, color: AppColors.textOnPumpkin),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
