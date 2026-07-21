import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thecode_pie_app/core/constants/app_colors.dart';
import 'package:thecode_pie_app/core/constants/app_fonts.dart';
import 'package:thecode_pie_app/core/purchase/purchase_product.dart';
import 'package:thecode_pie_app/core/services/sound_effects_service.dart';
import 'package:thecode_pie_app/presentation/purchase/purchase_view_model.dart';

export 'package:thecode_pie_app/core/purchase/purchase_product.dart';

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
          child: Consumer<PurchaseViewModel>(
            builder: (context, purchaseViewModel, _) {
              return Column(
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
                          onPressed: SoundEffectsService().withSelect(
                            () => Navigator.of(context).pop(),
                          ),
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
                      product: PurchaseProduct.premium,
                      buttonText: purchaseViewModel.priceLabel(
                        PurchaseProduct.premium,
                      ),
                      emphasized: true,
                      isOwned: purchaseViewModel.isOwned(
                        PurchaseProduct.premium,
                      ),
                      isBusy: purchaseViewModel.isPurchasing,
                      onPressed: () => _handlePurchasePressed(
                        context,
                        purchaseViewModel,
                        PurchaseProduct.premium,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _PurchaseCard(
                    product: product,
                    buttonText: purchaseViewModel.priceLabel(product),
                    emphasized: isPremium,
                    isOwned: purchaseViewModel.isOwned(product),
                    isBusy: purchaseViewModel.isPurchasing,
                    onPressed: () => _handlePurchasePressed(
                      context,
                      purchaseViewModel,
                      product,
                    ),
                  ),
                  if (purchaseViewModel.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      purchaseViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.plum,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: purchaseViewModel.isPurchasing
                        ? null
                        : SoundEffectsService().withSelect(
                            purchaseViewModel.restorePurchases,
                          ),
                    child: const Text(
                      '구매 복원',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchasePressed(
    BuildContext context,
    PurchaseViewModel purchaseViewModel,
    PurchaseProduct product,
  ) async {
    if (!kDebugMode) {
      await purchaseViewModel.buy(product);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 구매'),
        content: Text('${product.title}\n테스트용으로 구매 확정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: SoundEffectsService().withSelect(
              () => Navigator.of(context).pop(false),
            ),
            child: const Text('아니오'),
          ),
          FilledButton(
            onPressed: SoundEffectsService().withSelect(
              () => Navigator.of(context).pop(true),
            ),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      purchaseViewModel.applyDebugPurchase(product);
    }
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard({
    required this.product,
    required this.buttonText,
    required this.isOwned,
    required this.isBusy,
    required this.onPressed,
    this.emphasized = false,
  });

  final PurchaseProduct product;
  final String buttonText;
  final bool isOwned;
  final bool isBusy;
  final VoidCallback onPressed;
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
                product.icon,
                color: emphasized ? gold : AppColors.textTertiary,
                size: 22,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  product.title,
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
          for (final benefit in product.benefits) ...[
            _PremiumBenefit(text: benefit),
            if (benefit != product.benefits.last) const SizedBox(height: 5),
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: emphasized ? 46 : 40,
            child: ElevatedButton(
              onPressed: isOwned || isBusy
                  ? null
                  : SoundEffectsService().withSelect(onPressed),
              style: ElevatedButton.styleFrom(
                backgroundColor: emphasized ? gold : AppColors.crust,
                disabledBackgroundColor: AppColors.textTertiary.withValues(
                  alpha: 0.28,
                ),
                foregroundColor: AppColors.textOnPumpkin,
                disabledForegroundColor: AppColors.textOnPumpkin.withValues(
                  alpha: 0.72,
                ),
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
              child: Text(isOwned ? '구매 완료' : buttonText),
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
