import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../widgets/retro_background.dart';
import '../../widgets/retro_glass_card.dart';
import '../../widgets/google_login_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// 로그인 화면 (View)
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
                // 버전 표시 (우상단)
                Positioned(
                  top: 16,
                  right: 24,
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: AppColors.textTertiary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                // 메인 컨텐츠
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PIE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 50,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                            shadows: const [
                              Shadow(
                                color: AppColors.neonPurple,
                                blurRadius: 12,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'THE CODE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 20,
                            color: AppColors.textSecondary,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Consumer<AuthViewModel>(
                          builder: (context, viewModel, child) {
                            return RetroGlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '로그인',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  Center(
                                    child: GoogleLoginButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _handleGoogleLogin(
                                              context,
                                              viewModel,
                                            ),
                                      isLoading: viewModel.isLoading,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    '구글 아이콘을 눌러\n로그인하세요',
                                    style: GoogleFonts.pressStart2p(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (viewModel.errorMessage != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        viewModel.errorMessage!,
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 8,
                                          color: Colors.redAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
    final success = await viewModel.signInWithGoogle();

    if (context.mounted) {
      if (success) {
        // 로그인 성공 시 홈 화면으로 이동 (추후 구현)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pushReplacement(...) 홈 화면으로 이동
      } else if (viewModel.errorMessage == null) {
        // 사용자가 취소한 경우
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었습니다.')));
      } else {
        // 에러가 발생한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: ${viewModel.errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
