import 'package:flutter/material.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';

enum PurchaseProduct {
  premium,
  stageUnlock,
  adRemoval;

  String get title {
    switch (this) {
      case PurchaseProduct.premium:
        return '프리미엄 패키지';
      case PurchaseProduct.stageUnlock:
        return 'STAGE 해금';
      case PurchaseProduct.adRemoval:
        return '광고 제거만 구매';
    }
  }

  String get buttonText {
    switch (this) {
      case PurchaseProduct.premium:
        return '₩ 3,990원';
      case PurchaseProduct.stageUnlock:
        return '₩ 2,990원';
      case PurchaseProduct.adRemoval:
        return '₩ 1,490원';
    }
  }

  IconData get icon {
    switch (this) {
      case PurchaseProduct.premium:
        return Icons.workspace_premium_rounded;
      case PurchaseProduct.stageUnlock:
        return Icons.lock_open_rounded;
      case PurchaseProduct.adRemoval:
        return Icons.block_rounded;
    }
  }

  List<String> get benefits {
    switch (this) {
      case PurchaseProduct.premium:
        return const ['힌트 무제한 제공', '광고 제거', 'STAGE 21-50 추가 해금'];
      case PurchaseProduct.stageUnlock:
        return const ['STAGE 21-50 추가 해금'];
      case PurchaseProduct.adRemoval:
        return const ['광고 제거'];
    }
  }
}

class PremiumPurchaseDialog extends StatelessWidget {
  const PremiumPurchaseDialog({
    super.key,
    this.product = PurchaseProduct.premium,
  });

  final PurchaseProduct product;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD6A84F);
    final isPremium = product == PurchaseProduct.premium;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.glassCardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: gold.withValues(alpha: 0.58), width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55210F20),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const SizedBox(width: 34),
                  const Expanded(
                    child: Text(
                      '구매하기',
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
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: AppColors.crust,
                      tooltip: '닫기',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!isPremium) ...[
                _PurchaseCard(
                  title: PurchaseProduct.premium.title,
                  buttonText: PurchaseProduct.premium.buttonText,
                  icon: PurchaseProduct.premium.icon,
                  benefits: PurchaseProduct.premium.benefits,
                  emphasized: true,
                ),
                const SizedBox(height: 12),
              ],
              _PurchaseCard(
                title: product.title,
                buttonText: product.buttonText,
                icon: product.icon,
                benefits: product.benefits,
                emphasized: isPremium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.title,
    required this.buttonText,
    required this.icon,
    required this.benefits,
    this.emphasized = false,
  });

  final String title;
  final String buttonText;
  final IconData icon;
  final List<String> benefits;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD6A84F);
    final borderColor = emphasized
        ? gold.withValues(alpha: 0.86)
        : AppColors.textTertiary.withValues(alpha: 0.18);
    final backgroundColor = emphasized
        ? gold.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.28);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: emphasized ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: emphasized ? gold : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: emphasized ? 15 : 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (emphasized)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '추천',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textOnPumpkin,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          for (final benefit in benefits) ...[
            _PremiumBenefit(text: benefit),
            if (benefit != benefits.last) const SizedBox(height: 5),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: emphasized ? 46 : 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: emphasized ? gold : AppColors.crust,
                foregroundColor: AppColors.textOnPumpkin,
                elevation: 0,
                textStyle: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBenefit extends StatelessWidget {
  const _PremiumBenefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.sage),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
