import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/app_colors.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

/// 설정 다이얼로그 위젯
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  double _bgmVolume = 0.5; // 기본 BGM 볼륨 (0.0 ~ 1.0)
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadBgmVolume();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  /// 저장된 BGM 볼륨 값 불러오기 (사용자별)
  Future<void> _loadBgmVolume() async {
    final prefs = await SharedPreferences.getInstance();

    // 현재 사용자 ID 가져오기
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = viewModel.currentUser?.id;

    if (userId == null) {
      // 사용자가 없으면 기본값 사용
      return;
    }

    // 사용자별 키 생성: "bgm_volume_${userId}"
    final userBgmKey = '${AppConstants.bgmVolumeKey}_$userId';
    final savedVolume = prefs.getDouble(userBgmKey);

    if (savedVolume != null && mounted) {
      setState(() {
        _bgmVolume = savedVolume;
      });
    }
  }

  /// BGM 볼륨 값 저장하기 (사용자별)
  Future<void> _saveBgmVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();

    // 현재 사용자 ID 가져오기
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = viewModel.currentUser?.id;

    if (userId == null) {
      // 사용자가 없으면 저장하지 않음
      return;
    }

    // 사용자별 키 생성: "bgm_volume_${userId}"
    final userBgmKey = '${AppConstants.bgmVolumeKey}_$userId';
    await prefs.setDouble(userBgmKey, volume);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.glassCardBackground, // 크림색 배경
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentOrange.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SETTINGS',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: AppColors.accentOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'BGM VOLUME',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _bgmVolume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        activeColor: AppColors.accentOrange,
                        inactiveColor: AppColors.accentOrange.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _bgmVolume = value;
                          });
                          // BGM 볼륨 값 저장
                          _saveBgmVolume(value);
                          // TODO: 실제 BGM 볼륨 조정 로직 추가
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(_bgmVolume * 100).toInt()}%',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
