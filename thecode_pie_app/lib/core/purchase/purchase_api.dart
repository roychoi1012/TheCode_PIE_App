import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/auth/data/repository/auth_repository.dart';
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/core/purchase/purchase_product.dart';

class PurchaseEntitlements {
  const PurchaseEntitlements({
    required this.hintAdRemoved,
    required this.bannerAdRemoved,
    required this.stageUnlocked,
  });

  final bool hintAdRemoved;
  final bool bannerAdRemoved;
  final bool stageUnlocked;

  factory PurchaseEntitlements.empty() {
    return const PurchaseEntitlements(
      hintAdRemoved: false,
      bannerAdRemoved: false,
      stageUnlocked: false,
    );
  }

  factory PurchaseEntitlements.fromJson(Map<String, dynamic> json) {
    return PurchaseEntitlements(
      hintAdRemoved: json['hint_ad_removed'] == true,
      bannerAdRemoved: json['banner_ad_removed'] == true,
      stageUnlocked: json['stage_unlocked'] == true,
    );
  }

  PurchaseEntitlements copyWith({
    bool? hintAdRemoved,
    bool? bannerAdRemoved,
    bool? stageUnlocked,
  }) {
    return PurchaseEntitlements(
      hintAdRemoved: hintAdRemoved ?? this.hintAdRemoved,
      bannerAdRemoved: bannerAdRemoved ?? this.bannerAdRemoved,
      stageUnlocked: stageUnlocked ?? this.stageUnlocked,
    );
  }
}

class PurchaseApi {
  PurchaseApi(this._authRepository);

  final AuthRepository _authRepository;

  Future<PurchaseEntitlements> fetchEntitlements() async {
    final response = await _authRepository.makeAuthenticatedRequest(
      (accessToken) => http.get(
        Uri.parse(AppConstants.entitlementStatusEndpoint),
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return _parseEntitlements(response);
  }

  Future<PurchaseEntitlements> verifyGooglePlayPurchase({
    required PurchaseProduct product,
    required String purchaseToken,
  }) async {
    final response = await _authRepository.makeAuthenticatedRequest(
      (accessToken) => http.post(
        Uri.parse(AppConstants.googlePlayPurchaseVerifyEndpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': product.productId,
          'purchase_token': purchaseToken,
        }),
      ),
    );
    return _parseEntitlements(response);
  }

  PurchaseEntitlements _parseEntitlements(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Purchase request failed.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid purchase response.');
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Purchase response data is missing.');
    }

    return PurchaseEntitlements.fromJson(data);
  }
}
