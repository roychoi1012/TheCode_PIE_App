import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';
import 'package:thecode_pie_app/presentation/component/premium_purchase_dialog.dart';
import 'package:thecode_pie_app/presentation/component/retro_background.dart';
import 'package:thecode_pie_app/presentation/purchase/purchase_view_model.dart';
import 'package:thecode_pie_app/presentation/screen/quiz/quiz_screen_root.dart';
import 'package:thecode_pie_app/presentation/screen/quiz/quiz_view_model.dart';
import 'package:thecode_pie_app/providers/app_providers.dart';

class StageSelectScreen extends StatelessWidget {
  const StageSelectScreen({
    super.key,
    required this.episodeId,
    required this.episodeCode,
    required this.currentStageNo,
    required this.highestStageNo,
  });

  final int episodeId;
  final String episodeCode;
  final int currentStageNo;
  final int highestStageNo;

  static const int _freeStageCount = 20;
  static const int _premiumStageCount = 30;
  static const int _totalStageCount = _freeStageCount + _premiumStageCount;

  @override
  Widget build(BuildContext context) {
    final rawUnlockedThrough = highestStageNo < currentStageNo
        ? currentStageNo
        : highestStageNo;
    final unlockedThrough = rawUnlockedThrough > _totalStageCount
        ? _totalStageCount
        : rawUnlockedThrough;
    final purchaseViewModel = context.watch<PurchaseViewModel>();
    final hasPremiumAccess =
        unlockedThrough > _freeStageCount ||
        purchaseViewModel.unlocksPremiumStages;

    return Scaffold(
      body: Stack(
        children: [
          const RetroBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: SoundEffectsService().withSelect(
                          () => Navigator.of(context).maybePop(),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textOnPumpkin,
                        tooltip: 'Back',
                      ),
                      const Expanded(
                        child: Text(
                          'STAGE SELECT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.title,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnPumpkin,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _PremiumBanner(
                    hasPremiumAccess: hasPremiumAccess,
                    onTap: hasPremiumAccess
                        ? null
                        : () => _openPremiumPurchase(context),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 520
                            ? 5
                            : 4;
                        final gridDelegate =
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              childAspectRatio: 1,
                            );

                        return CustomScrollView(
                          slivers: [
                            const SliverToBoxAdapter(
                              child: _StageSectionHeader(
                                label: 'FREE STAGES',
                                value: '1-20',
                              ),
                            ),
                            SliverGrid(
                              gridDelegate: gridDelegate,
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final stageNo = index + 1;
                                return _buildStageTile(
                                  context,
                                  stageNo: stageNo,
                                  unlockedThrough: unlockedThrough,
                                  hasPremiumAccess: hasPremiumAccess,
                                );
                              }, childCount: _freeStageCount),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 24),
                            ),
                            const SliverToBoxAdapter(
                              child: _StageSectionHeader(
                                label: 'PREMIUM STAGES',
                                value: '21-50',
                              ),
                            ),
                            SliverGrid(
                              gridDelegate: gridDelegate,
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final stageNo = _freeStageCount + index + 1;
                                return _buildStageTile(
                                  context,
                                  stageNo: stageNo,
                                  unlockedThrough: unlockedThrough,
                                  hasPremiumAccess: hasPremiumAccess,
                                );
                              }, childCount: _premiumStageCount),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 4),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageTile(
    BuildContext context, {
    required int stageNo,
    required int unlockedThrough,
    required bool hasPremiumAccess,
  }) {
    final isPremium = stageNo > _freeStageCount;
    final clearedThrough = currentStageNo > 1 ? currentStageNo - 1 : 0;
    final isCleared = stageNo <= clearedThrough;
    final isProgressUnlocked = stageNo <= unlockedThrough;
    final isPremiumLocked = isPremium && !hasPremiumAccess;
    final isUnlocked = isProgressUnlocked && !isPremiumLocked;

    return _StageTile(
      stageNo: stageNo,
      isUnlocked: isUnlocked,
      isCleared: isCleared,
      isPremium: isPremium,
      isPremiumLocked: isPremiumLocked,
      onTap: isUnlocked
          ? () => _openStage(context, stageNo)
          : isPremiumLocked
          ? () => _openPremiumPurchase(context)
          : null,
    );
  }

  void _openStage(BuildContext context, int stageNo) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<QuizViewModel>(
          create: (_) => DependencyInjection.createQuizViewModel(),
          child: QuizScreenRoot(
            episodeId: episodeId,
            episodeCode: episodeCode,
            stageNo: stageNo,
          ),
        ),
      ),
    );
  }

  void _openPremiumPurchase(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useRootNavigator: false,
      builder: (BuildContext dialogContext) {
        return const PremiumPurchaseDialog();
      },
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  const _PremiumBanner({required this.hasPremiumAccess, required this.onTap});

  final bool hasPremiumAccess;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const paleGold = Color(0xFFFFF1C9);
    const deepGold = Color(0xFF9E6B18);
    const premiumGold = Color(0xFFEBC96B);
    final background = hasPremiumAccess
        ? const Color(0xFFB7E3EE).withValues(alpha: 0.78)
        : premiumGold.withValues(alpha: 0.86);
    final border = hasPremiumAccess
        ? const Color(0xFFB7E3EE).withValues(alpha: 0.9)
        : deepGold.withValues(alpha: 0.72);
    final icon = hasPremiumAccess
        ? Icons.workspace_premium_rounded
        : Icons.lock_open_rounded;
    final title = hasPremiumAccess ? '구매 항목 적용됨' : '프리미엄 패키지 구매하기';
    final subtitle = hasPremiumAccess
        ? '구매한 기능으로 플레이 중입니다'
        : '힌트 광고 제거 + 배너 광고 제거 + STAGE 21-50 해금';

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: SoundEffectsService().withSelect(onTap),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: border,
              width: hasPremiumAccess ? 1.2 : 2,
            ),
            boxShadow: hasPremiumAccess
                ? null
                : [
                    BoxShadow(
                      color: paleGold.withValues(alpha: 0.42),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.34),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: deepGold.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: hasPremiumAccess ? AppColors.textOnPumpkin : deepGold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textOnPumpkin,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPumpkin.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasPremiumAccess)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: deepGold.withValues(alpha: 0.9),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageSectionHeader extends StatelessWidget {
  const _StageSectionHeader({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textOnPumpkin.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textOnPumpkin.withValues(alpha: 0.48),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Divider(height: 1, thickness: 1, color: Color(0x3324160D)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({
    required this.stageNo,
    required this.isUnlocked,
    required this.isCleared,
    required this.isPremium,
    required this.isPremiumLocked,
    required this.onTap,
  });

  final int stageNo;
  final bool isUnlocked;
  final bool isCleared;
  final bool isPremium;
  final bool isPremiumLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const premiumUnlockedColor = Color(0xFFB7E3EE);
    final background = isPremiumLocked
        ? AppColors.plum.withValues(alpha: 0.24)
        : isPremium && isUnlocked
        ? premiumUnlockedColor.withValues(alpha: isCleared ? 0.94 : 0.82)
        : isUnlocked
        ? Colors.white.withValues(alpha: isCleared ? 0.9 : 0.72)
        : AppColors.textOnPumpkin.withValues(alpha: 0.16);
    final foreground = isPremiumLocked
        ? AppColors.textOnPumpkin.withValues(alpha: 0.42)
        : isUnlocked
        ? AppColors.textOnLight
        : AppColors.textOnPumpkin.withValues(alpha: 0.3);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      elevation: isUnlocked ? 2 : 0,
      shadowColor: const Color(0x332F2330),
      child: InkWell(
        onTap: SoundEffectsService().withSelect(onTap),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPremiumLocked
                  ? AppColors.plum.withValues(alpha: 0.32)
                  : isUnlocked
                  ? AppColors.textOnPumpkin.withValues(alpha: 0.2)
                  : AppColors.textOnPumpkin.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '$stageNo',
                  style: TextStyle(
                    fontFamily: AppFonts.title,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ),
              if (isPremium)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    size: 15,
                    color: isPremiumLocked
                        ? AppColors.plum.withValues(alpha: 0.72)
                        : AppColors.pumpkin,
                  ),
                ),
              if (isCleared)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.sage.withValues(alpha: 0.95),
                  ),
                ),
              if (!isUnlocked)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Icon(Icons.lock_rounded, size: 16, color: foreground),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
