import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/core/services/background_music_service.dart';
import 'package:thecode_pie_app/presentation/component/google_login_button.dart';
import 'package:thecode_pie_app/presentation/component/premium_purchase_dialog.dart';
import 'package:thecode_pie_app/presentation/screen/auth/auth_view_model.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, this.userId});

  final int? userId;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  static const String _vibrationKey = 'sound_vibration_enabled';
  static const String _effectSoundKey = 'sound_effect_enabled';

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  final BackgroundMusicService _musicService = BackgroundMusicService();

  bool _vibrationEnabled = true;
  bool _bgmEnabled = true;
  bool _effectSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 240),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;
    final effectSoundEnabled = prefs.getBool(_effectSoundKey) ?? true;
    if (!prefs.containsKey(_vibrationKey)) {
      await prefs.setBool(_vibrationKey, true);
    }
    if (!prefs.containsKey(_effectSoundKey)) {
      await prefs.setBool(_effectSoundKey, true);
    }
    final bgmEnabled = await _musicService.isBgmEnabled();
    if (!mounted) return;
    setState(() {
      _vibrationEnabled = vibrationEnabled;
      _bgmEnabled = bgmEnabled;
      _effectSoundEnabled = effectSoundEnabled;
    });
  }

  Future<void> _setVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, enabled);
    if (!mounted) return;
    setState(() => _vibrationEnabled = enabled);
  }

  Future<void> _setBgmEnabled(bool enabled) async {
    setState(() => _bgmEnabled = enabled);
    await _musicService.setBgmEnabled(enabled);
  }

  Future<void> _setEffectSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_effectSoundKey, enabled);
    if (!mounted) return;
    setState(() => _effectSoundEnabled = enabled);
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.glassCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.crust.withValues(alpha: 0.5),
                  width: 1.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55210F20),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DialogHeader(onClose: () => Navigator.of(context).pop()),
                    const SizedBox(height: 15),
                    const _SectionLabel(label: 'SOUND'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _SoundToggleTile(
                            icon: Icons.vibration_rounded,
                            label: '진동',
                            value: _vibrationEnabled,
                            onTap: () =>
                                _setVibrationEnabled(!_vibrationEnabled),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SoundToggleTile(
                            icon: Icons.music_note_rounded,
                            label: 'BGM',
                            value: _bgmEnabled,
                            onTap: () => _setBgmEnabled(!_bgmEnabled),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SoundToggleTile(
                            icon: Icons.volume_up_rounded,
                            label: '효과음',
                            value: _effectSoundEnabled,
                            onTap: () =>
                                _setEffectSoundEnabled(!_effectSoundEnabled),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 8),
                    Consumer<AuthViewModel>(
                      builder: (context, viewModel, _) {
                        final user = viewModel.currentUser;
                        if (user == null) {
                          return _GoogleLinkButton(
                            isLoading: viewModel.isLoading,
                            onTap: viewModel.isLoading
                                ? null
                                : () =>
                                      _connectGoogleAccount(context, viewModel),
                          );
                        }
                        final displayName =
                            user.name ?? user.username ?? 'Google';
                        return _LinkedAccountCard(
                          name: displayName,
                          email: user.email,
                          pictureUrl: user.picture,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    const _SectionLabel(label: 'PURCHASE'),
                    const SizedBox(height: 8),
                    _PurchaseOption(
                      icon: Icons.workspace_premium_rounded,
                      title: '프리미엄 패키지',
                      subtitle: 'STAGE 해금 + 광고 제거',
                      emphasized: true,
                      onTap: () =>
                          _openPurchase(context, PurchaseProduct.premium),
                    ),
                    const SizedBox(height: 8),
                    _PurchaseOption(
                      icon: Icons.lock_open_rounded,
                      title: 'STAGE 해금',
                      subtitle: '30개의 추가 STAGE 해금',
                      onTap: () =>
                          _openPurchase(context, PurchaseProduct.stageUnlock),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            _openPurchase(context, PurchaseProduct.adRemoval),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textTertiary.withValues(
                            alpha: 0.68,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: const Text('광고 제거만 구매'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _connectGoogleAccount(
    BuildContext context,
    AuthViewModel viewModel,
  ) async {
    await viewModel.signInWithGoogle();
  }

  void _openPurchase(BuildContext context, PurchaseProduct product) {
    final navigator = Navigator.of(context);
    final overlayContext = navigator.overlay?.context;
    navigator.pop();

    if (overlayContext == null) return;
    showDialog(
      context: overlayContext,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useRootNavigator: false,
      builder: (_) => PremiumPurchaseDialog(product: product),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 34),
        const Expanded(
          child: Text(
            '설정',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.title,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.crust,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(8, 0),
          child: IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 22),
            color: AppColors.crust,
            tooltip: '닫기',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _GoogleLinkButton extends StatelessWidget {
  const _GoogleLinkButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      elevation: 2,
      shadowColor: const Color(0x332F2330),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE7E1DB)),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.pumpkin,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GoogleMark(),
                    SizedBox(width: 10),
                    Text(
                      'Google 계정 연결',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textOnLight,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LinkedAccountCard extends StatelessWidget {
  const _LinkedAccountCard({
    required this.name,
    required this.email,
    required this.pictureUrl,
  });

  final String name;
  final String email;
  final String? pictureUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          _AccountAvatar(pictureUrl: pictureUrl, fallbackText: name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.pictureUrl, required this.fallbackText});

  final String? pictureUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final url = pictureUrl?.trim();
    final initial = _initialFrom(fallbackText);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: AppColors.crust.withValues(alpha: 0.45)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? _InitialAvatar(initial: initial)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _InitialAvatar(initial: initial);
              },
            ),
    );
  }

  String _initialFrom(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.crust.withValues(alpha: 0.28),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.pumpkin,
          ),
        ),
      ),
    );
  }
}

class _SoundToggleTile extends StatelessWidget {
  const _SoundToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = value ? AppColors.textPrimary : AppColors.textTertiary;

    return Material(
      color: value
          ? AppColors.pumpkin.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: value
                  ? AppColors.pumpkin.withValues(alpha: 0.42)
                  : AppColors.lavender.withValues(alpha: 0.18),
              width: value ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: value ? AppColors.pumpkin : AppColors.textTertiary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 6),
              IgnorePointer(
                child: SizedBox(
                  height: 18,
                  child: Transform.scale(
                    scale: 0.52,
                    child: Switch(
                      value: value,
                      onChanged: (_) {},
                      activeThumbColor: AppColors.pumpkin,
                      activeTrackColor: AppColors.pumpkin.withValues(
                        alpha: 0.32,
                      ),
                      inactiveThumbColor: AppColors.lavender.withValues(
                        alpha: 0.72,
                      ),
                      inactiveTrackColor: AppColors.textOnLight.withValues(
                        alpha: 0.28,
                      ),
                      trackOutlineColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.pumpkin.withValues(alpha: 0.5);
                        }
                        return AppColors.lavender.withValues(alpha: 0.24);
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseOption extends StatelessWidget {
  const _PurchaseOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: emphasized
          ? AppColors.pumpkin.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: emphasized
                  ? AppColors.pumpkin.withValues(alpha: 0.58)
                  : AppColors.crust.withValues(alpha: 0.24),
              width: emphasized ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: emphasized ? AppColors.pumpkin : AppColors.crust,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: emphasized ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: emphasized ? AppColors.pumpkin : AppColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
