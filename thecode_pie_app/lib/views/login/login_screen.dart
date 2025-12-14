import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/retro_background.dart';
import '../../widgets/retro_glass_card.dart';
import '../../widgets/google_login_button.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// 로그인 화면 (최종본)
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
                                          : () =>
                                              _handleGoogleLogin(context, viewModel),
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
                                  if (viewModel.isAuthenticated && viewModel.currentUser != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.neonPurple.withOpacity(0.6),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'LOGIN RESULT',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'ID: ${viewModel.currentUser!.id}',
                                            style: const TextStyle(color: Colors.greenAccent),
                                          ),
                                          Text(
                                            'EMAIL: ${viewModel.currentUser!.email}',
                                            style: const TextStyle(color: Colors.greenAccent),
                                          ),
                                          Text(
                                            'USERNAME: ${viewModel.currentUser!.username}',
                                            style: const TextStyle(color: Colors.greenAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (viewModel.isAuthenticated) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.neonPurple.withOpacity(0.6),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'TOKEN DEBUG',
                                            style: GoogleFonts.pressStart2p(
                                              fontSize: 8,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          FutureBuilder<String?>(
                                            future: AuthService().getAccessToken(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Text(
                                                  'ACCESS TOKEN: (loading)',
                                                  style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                                                );
                                              }
                                              return Text(
                                                'ACCESS TOKEN:\n${snapshot.data}',
                                                style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          FutureBuilder<String?>(
                                            future: AuthService().getRefreshToken(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return const Text(
                                                  'REFRESH TOKEN: (loading)',
                                                  style: TextStyle(color: Colors.greenAccent, fontSize: 10),
                                                );
                                              }
                                              return Text(
                                                'REFRESH TOKEN:\n${snapshot.data}',
                                                style: const TextStyle(
                                                  color: Colors.greenAccent,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // 에러 메시지
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

  /// 실제 Google 로그인 처리
  Future<void> _handleGoogleLogin(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    final success = await viewModel.signInWithGoogle();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 성공!'),
          backgroundColor: Colors.green,
        ),
      );

    } else if (viewModel.errorMessage == null) {
      // 사용자가 로그인 취소
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 취소되었습니다.')),
      );
    }
  }
}
