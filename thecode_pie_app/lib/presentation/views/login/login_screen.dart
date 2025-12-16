import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../widgets/retro_background.dart';
import '../../../widgets/retro_glass_card.dart';
import '../../../widgets/google_login_button.dart';
import '../../../widgets/settings_dialog.dart';
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
                            shadows: [
                              Shadow(
                                color: AppColors.accentOrange,
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
                                  // 로그인 전 UI
                                  if (!viewModel.isAuthenticated) ...[
                                    Text(
                                      'GOOGLE LOGIN',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 14,
                                        color: AppColors.accentOrange,
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
                                      'CLICK GOOGLE ICON TO LOGIN',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 9,
                                        color: AppColors.accentOrange,
                                        height: 1.6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  // 로그인 후 UI
                                  if (viewModel.isAuthenticated &&
                                      viewModel.currentUser != null) ...[
                                    // 사용자 이름과 버튼들
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            viewModel.currentUser!.username ??
                                                viewModel.currentUser!.name ??
                                                viewModel.currentUser!.email,
                                            style: GoogleFonts.pressStart2p(
                                              fontSize: 12,
                                              color: AppColors.accentOrange,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                await viewModel.signOut();
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        '로그아웃되었습니다.',
                                                      ),
                                                      backgroundColor: AppColors
                                                          .accentOrange,
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.logout,
                                                color: AppColors.accentOrange,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              tooltip: '로그아웃',
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              onPressed: () =>
                                                  _showSettingsDialog(context),
                                              icon: const Icon(
                                                Icons.settings,
                                                color: AppColors.accentOrange,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              tooltip: '설정',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () => _handleStartButton(
                                              context,
                                              viewModel,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentOrange,
                                        foregroundColor: AppColors.textPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 8,
                                        shadowColor:
                                            AppColors.accentOrangeShadow,
                                      ),
                                      child: Text(
                                        'START',
                                        style: GoogleFonts.pressStart2p(
                                          fontSize: 16,
                                          letterSpacing: 2,
                                        ),
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
                                          color: Colors.red.shade300,
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
        SnackBar(
          content: const Text('로그인 성공!'),
          backgroundColor: AppColors.accentOrange,
        ),
      );
    } else if (viewModel.errorMessage == null) {
      // 사용자가 로그인 취소
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었습니다.')));
    }
  }

  /// START 버튼 처리 (auth/me 호출하여 Access Token 유효성 확인)
  Future<void> _handleStartButton(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    try {
      // auth/me를 호출하여 Access Token 유효성 확인
      // 만료된 경우 자동으로 Refresh Token으로 재발급 후 재시도
      await viewModel.loadCurrentUser();

      if (!context.mounted) return;

      if (viewModel.currentUser != null) {
        // Access Token이 유효한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Access Token 유효성 확인 완료!\n사용자: ${viewModel.currentUser!.email}',
            ),
            backgroundColor: AppColors.accentOrange,
            duration: const Duration(seconds: 2),
          ),
        );
        // TODO: 메인 화면으로 이동
      } else {
        // Refresh Token도 만료되어 로그인 화면으로 돌아온 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('토큰이 만료되었습니다. 다시 로그인해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // 에러 발생 시 (Refresh Token 만료 등)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류 발생: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 설정 다이얼로그 표시
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext dialogContext) {
        return const SettingsDialog();
      },
    );
  }
}
