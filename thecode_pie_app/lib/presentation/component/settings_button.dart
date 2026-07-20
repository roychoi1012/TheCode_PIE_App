import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/presentation/component/settings_dialog.dart';
import 'package:thecode_pie_app/presentation/screen/auth/auth_view_model.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    this.color = AppColors.textOnPumpkin,
    this.borderAlpha = 0.24,
  });

  final Color color;
  final double borderAlpha;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () => _showSettingsDialog(context),
      icon: const Icon(Icons.settings_rounded, size: 21),
      color: color,
      tooltip: 'Settings',
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: color.withValues(alpha: borderAlpha),
          width: 1.2,
        ),
        minimumSize: const Size(42, 42),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = viewModel.currentUser?.id;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useRootNavigator: false,
      builder: (BuildContext dialogContext) {
        return SettingsDialog(userId: userId);
      },
    );
  }
}
