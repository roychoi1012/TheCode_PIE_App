import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/core/services/background_music_service.dart';

/// 설정 다이얼로그 위젯
class SettingsDialog extends StatefulWidget {
  final int? userId;

  const SettingsDialog({super.key, this.userId});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  double _bgmVolume = 0.5; // 기본 BGM 볼륨 (0.0 ~ 1.0)
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final BackgroundMusicService _musicService = BackgroundMusicService();

  @override
  void initState() {
    super.initState();
    debugPrint('SettingsDialog initState 시작, 초기 _bgmVolume: $_bgmVolume');
    debugPrint('SettingsDialog userId: ${widget.userId}');

    // 먼저 서비스의 현재 볼륨으로 초기화 시도
    _bgmVolume = _musicService.currentVolume;
    debugPrint('서비스에서 가져온 볼륨: $_bgmVolume');

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
    _loadBgmVolume();
  }

  /// 저장된 BGM 볼륨 값 불러오기 (사용자별 또는 전역)
  Future<void> _loadBgmVolume() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // 전달받은 사용자 ID 사용
    final userId = widget.userId;
    debugPrint('볼륨 불러오기 - userId: $userId');

    String volumeKey;
    if (userId != null && userId.toString().isNotEmpty) {
      // 사용자별 키 생성: "bgm_volume_${userId}"
      volumeKey = '${AppConstants.bgmVolumeKey}_$userId';
      debugPrint('사용자별 볼륨 키 사용: $volumeKey');
    } else {
      // 사용자가 없으면 전역 키 사용
      volumeKey = AppConstants.bgmVolumeKey;
      debugPrint('전역 볼륨 키 사용: $volumeKey');
    }

    final savedVolume = prefs.getDouble(volumeKey);
    debugPrint(
      '볼륨 불러오기 - 키: $volumeKey, 값: $savedVolume, 현재 _bgmVolume: $_bgmVolume',
    );

    if (mounted) {
      final volumeToUse = savedVolume ?? 0.5;
      debugPrint('볼륨 설정 예정: $volumeToUse');
      setState(() {
        _bgmVolume = volumeToUse;
      });
      debugPrint('볼륨 설정 완료: $_bgmVolume');

      // 저장된 볼륨 값으로 서비스 볼륨 설정 (이미 설정되어 있을 수 있으므로)
      if (savedVolume != null) {
        _musicService.setVolume(volumeToUse);
      }
    }
  }

  /// BGM 볼륨 값 저장하기 (사용자별 또는 전역)
  Future<void> _saveBgmVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();

    // 전달받은 사용자 ID 사용
    final userId = widget.userId;
    debugPrint('볼륨 저장 - userId: $userId');

    String volumeKey;
    if (userId != null && userId.toString().isNotEmpty) {
      // 사용자별 키 생성: "bgm_volume_${userId}"
      volumeKey = '${AppConstants.bgmVolumeKey}_$userId';
      debugPrint('사용자별 볼륨 키 사용: $volumeKey');
    } else {
      // 사용자가 없으면 전역 키 사용
      volumeKey = AppConstants.bgmVolumeKey;
      debugPrint('전역 볼륨 키 사용: $volumeKey');
    }

    await prefs.setDouble(volumeKey, volume);
    debugPrint('볼륨 저장 - 키: $volumeKey, 값: $volume');

    // 저장 확인: 실제로 저장되었는지 확인
    final savedValue = prefs.getDouble(volumeKey);
    debugPrint('볼륨 저장 확인 - 키: $volumeKey, 저장된 값: $savedValue');

    // 모든 볼륨 키 확인 (디버깅용)
    final allKeys = prefs.getKeys();
    final volumeKeys = allKeys
        .where((key) => key.startsWith('bgm_volume'))
        .toList();
    debugPrint('모든 볼륨 키: $volumeKeys');
    for (final key in volumeKeys) {
      debugPrint('  - $key: ${prefs.getDouble(key)}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build 호출 - 현재 _bgmVolume: $_bgmVolume');
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
              mainAxisSize: .min,
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  'SETTINGS',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: AppColors.accentOrange,
                  ),
                  textAlign: .center,
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
                          // 실제 BGM 볼륨 조정
                          _musicService.setVolume(value);
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
