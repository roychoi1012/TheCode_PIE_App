import 'package:flutter/material.dart';

enum PurchaseProduct {
  premium(
    productId: 'premium_package',
    title: '프리미엄 패키지',
    fallbackPrice: '₩3,990',
    icon: Icons.workspace_premium_rounded,
    benefits: ['힌트 광고 제거', '배너 광고 제거', 'STAGE 21-50 추가 해금'],
  ),
  stageUnlock(
    productId: 'stage_unlock',
    title: 'STAGE 해금',
    fallbackPrice: '₩2,990',
    icon: Icons.lock_open_rounded,
    benefits: ['STAGE 21-50 추가 해금'],
  ),
  adRemoval(
    productId: 'remove_ads',
    title: '광고 제거',
    fallbackPrice: '₩1,490',
    icon: Icons.block_rounded,
    benefits: ['힌트 광고 제거', '배너 광고 제거'],
  );

  const PurchaseProduct({
    required this.productId,
    required this.title,
    required this.fallbackPrice,
    required this.icon,
    required this.benefits,
  });

  final String productId;
  final String title;
  final String fallbackPrice;
  final IconData icon;
  final List<String> benefits;

  static PurchaseProduct? fromProductId(String productId) {
    for (final product in values) {
      if (product.productId == productId) return product;
    }
    return null;
  }
}
