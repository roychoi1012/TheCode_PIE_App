import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.g.dart';

class AdManagerService {
  RewardedAd? _rewardedAd;

  static String get _rewardUnitId => admobAndroidRewardUnitId.isNotEmpty
      ? admobAndroidRewardUnitId
      : (dotenv.env['ADMOB_ANDROID_REWARD_UNIT_ID'] ?? '');

  void loadAd({
    required String userId,
    required String episodeCode,
    required int stageNo,
  }) {
    debugPrint(
      '[AdManager] loading rewarded ad episode=$episodeCode stage=$stageNo',
    );
    RewardedAd.load(
      adUnitId: _rewardUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          try {
            (ad as dynamic).setServerSideOptions(
              ServerSideVerificationOptions(
                userId: userId,
                customData: '$episodeCode|$stageNo',
              ),
            );
            _rewardedAd = ad;
            debugPrint('[AdManager] rewarded ad loaded with SSV');
          } catch (e) {
            _rewardedAd = ad;
            debugPrint('[AdManager] SSV setup failed: $e');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          debugPrint('[AdManager] rewarded ad load failed: ${error.message}');
        },
      ),
    );
  }

  void showAd({required Function onRewardEarned}) {
    if (_rewardedAd == null) {
      debugPrint('[AdManager] rewarded ad is not ready');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewardEarned();
      },
    );
  }
}
