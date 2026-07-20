import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/presentation/component/google_login_button.dart';
import 'package:thecode_pie_app/presentation/component/retro_background.dart';
import 'package:thecode_pie_app/presentation/component/settings_button.dart';

import '../../../providers/app_providers.dart';
import '../quiz/quiz_screen_root.dart';
import '../quiz/quiz_view_model.dart';
import '../stage_select/stage_select_screen.dart';
import 'auth_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const RetroBackground(),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 14,
                  left: 20,
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textOnPumpkin.withValues(alpha: 0.68),
                    ),
                  ),
                ),
                Positioned(top: 10, right: 10, child: const SettingsButton()),
                Positioned(
                  right: 20,
                  bottom: 14,
                  child: Text(
                    '© 2026 Clavis',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textOnPumpkin.withValues(alpha: 0.68),
                    ),
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'PIE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppFonts.title,
                              fontSize: 72,
                              fontWeight: FontWeight.w700,
                              height: 0.92,
                              color: AppColors.textOnPumpkin,
                              shadows: [
                                Shadow(
                                  color: Color(0x55FFF8EC),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'THE CODE',
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 4,
                              color: AppColors.textOnPumpkin,
                            ),
                          ),
                          const SizedBox(height: 126),
                          Consumer<AuthViewModel>(
                            builder: (context, viewModel, child) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!viewModel.isAuthenticated) ...[
                                    GoogleLoginButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _handleGoogleLogin(
                                              context,
                                              viewModel,
                                            ),
                                      isLoading: viewModel.isLoading,
                                    ),
                                  ],
                                  if (viewModel.isAuthenticated) ...[
                                    _HomeButton(
                                      label: 'START',
                                      icon: Icons.play_arrow_rounded,
                                      filled: true,
                                      isBusy: viewModel.isLoading,
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _handleStartButton(
                                              context,
                                              viewModel,
                                            ),
                                    ),
                                    const SizedBox(height: 12),
                                    _HomeButton(
                                      label: 'STAGE SELECT',
                                      icon: Icons.grid_view_rounded,
                                      onPressed: () =>
                                          _handleStageSelectButton(context),
                                    ),
                                  ],
                                  if (viewModel.errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                      ),
                                      child: Text(
                                        viewModel.errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: AppFonts.body,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textOnPumpkin,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    await viewModel.signInWithGoogle();
  }

  Future<void> _handleStartButton(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    try {
      final quizViewModel = Provider.of<QuizViewModel>(context, listen: false);
      final start = await quizViewModel.resolveStartProgress();
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => ChangeNotifierProvider<QuizViewModel>(
            create: (_) => DependencyInjection.createQuizViewModel(),
            child: QuizScreenRoot(
              episodeId: start.episodeId,
              episodeCode: start.episodeCode,
              stageNo: start.stageNo,
            ),
          ),
        ),
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _handleStageSelectButton(BuildContext context) async {
    try {
      final quizViewModel = Provider.of<QuizViewModel>(context, listen: false);
      final start = await quizViewModel.resolveStartProgress();
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StageSelectScreen(
            episodeId: start.episodeId,
            episodeCode: start.episodeCode,
            currentStageNo: start.stageNo,
            highestStageNo: start.highestStageNo ?? start.stageNo,
          ),
        ),
      );
    } catch (_) {
      return;
    }
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.isBusy = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final child = isBusy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.textOnPumpkin,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 21),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final textStyle = TextStyle(
      fontFamily: filled ? AppFonts.title : AppFonts.body,
      fontSize: filled ? 22 : 14,
      fontWeight: FontWeight.w800,
      letterSpacing: filled ? 1.2 : 1,
    );

    if (filled) {
      return SizedBox(
        width: 232,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.84),
            foregroundColor: AppColors.textOnLight,
            elevation: 3,
            shadowColor: const Color(0x332F2330),
            textStyle: textStyle,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: 232,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textOnPumpkin,
          textStyle: textStyle,
          side: BorderSide(
            color: AppColors.textOnPumpkin.withValues(alpha: 0.48),
            width: 1.4,
          ),
          backgroundColor: AppColors.textOnPumpkin.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: child,
      ),
    );
  }
}
