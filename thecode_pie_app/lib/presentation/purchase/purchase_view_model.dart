import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:thecode_pie_app/core/purchase/purchase_api.dart';
import 'package:thecode_pie_app/core/purchase/purchase_product.dart';

class PurchaseViewModel extends ChangeNotifier {
  PurchaseViewModel({
    required PurchaseApi purchaseApi,
    InAppPurchase? inAppPurchase,
  }) : _purchaseApi = purchaseApi,
       _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final PurchaseApi _purchaseApi;
  final InAppPurchase _inAppPurchase;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  final Map<String, ProductDetails> _storeProducts = {};
  PurchaseEntitlements _entitlements = PurchaseEntitlements.empty();

  bool _isAvailable = false;
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;

  bool get skipsHintAds => _entitlements.hintAdRemoved;
  bool get removesAds =>
      _entitlements.hintAdRemoved && _entitlements.bannerAdRemoved;
  bool get unlocksPremiumStages => _entitlements.stageUnlocked;
  bool get hasAnyEntitlement =>
      skipsHintAds || removesAds || unlocksPremiumStages;

  bool isOwned(PurchaseProduct product) {
    switch (product) {
      case PurchaseProduct.premium:
        return skipsHintAds && removesAds && unlocksPremiumStages;
      case PurchaseProduct.stageUnlock:
        return unlocksPremiumStages;
      case PurchaseProduct.adRemoval:
        return removesAds;
    }
  }

  String priceLabel(PurchaseProduct product) {
    return _storeProducts[product.productId]?.price ?? product.fallbackPrice;
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _purchaseSubscription ??= _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _isPurchasing = false;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );

    await syncEntitlements();
    await loadProducts();
  }

  Future<void> syncEntitlements() async {
    try {
      _entitlements = await _purchaseApi.fetchEntitlements();
    } catch (e) {
      debugPrint('[Purchase] entitlement sync failed: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        _isLoading = false;
        _errorMessage = '결제를 사용할 수 없습니다.';
        notifyListeners();
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(
        PurchaseProduct.values.map((product) => product.productId).toSet(),
      );

      _storeProducts
        ..clear()
        ..addEntries(
          response.productDetails.map(
            (details) => MapEntry(details.id, details),
          ),
        );

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[Purchase] products not found: ${response.notFoundIDs}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> buy(PurchaseProduct product) async {
    final details = _storeProducts[product.productId];
    if (details == null) {
      _errorMessage = '상품 정보를 불러오지 못했습니다.';
      notifyListeners();
      await loadProducts();
      return;
    }

    _isPurchasing = true;
    _errorMessage = null;
    notifyListeners();

    final param = PurchaseParam(productDetails: details);
    await _inAppPurchase.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    _isPurchasing = true;
    _errorMessage = null;
    notifyListeners();
    await _inAppPurchase.restorePurchases();
  }

  void applyDebugPurchase(PurchaseProduct product) {
    if (!kDebugMode) return;

    switch (product) {
      case PurchaseProduct.premium:
        _entitlements = _entitlements.copyWith(
          hintAdRemoved: true,
          bannerAdRemoved: true,
          stageUnlocked: true,
        );
      case PurchaseProduct.stageUnlock:
        _entitlements = _entitlements.copyWith(stageUnlocked: true);
      case PurchaseProduct.adRemoval:
        _entitlements = _entitlements.copyWith(
          hintAdRemoved: true,
          bannerAdRemoved: true,
        );
    }

    _errorMessage = null;
    notifyListeners();
  }

  void resetDebugPurchases() {
    if (!kDebugMode) return;

    _entitlements = PurchaseEntitlements.empty();
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      var shouldComplete = false;
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          shouldComplete = await _verifyAndSyncEntitlements(purchaseDetails);
          _isPurchasing = false;
          break;
        case PurchaseStatus.error:
          _isPurchasing = false;
          _errorMessage = purchaseDetails.error?.message ?? '결제에 실패했습니다.';
          shouldComplete = true;
          break;
        case PurchaseStatus.canceled:
          _isPurchasing = false;
          shouldComplete = true;
          break;
      }

      if (shouldComplete && purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    notifyListeners();
  }

  Future<bool> _verifyAndSyncEntitlements(
    PurchaseDetails purchaseDetails,
  ) async {
    final product = PurchaseProduct.fromProductId(purchaseDetails.productID);
    if (product == null) return false;

    try {
      _entitlements = await _purchaseApi.verifyGooglePlayPurchase(
        product: product,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
