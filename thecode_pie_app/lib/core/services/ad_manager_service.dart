import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.g.dart';

class AdManagerService {
  RewardedAd? _rewardedAd;
  bool _isLoadingRewardedAd = false;
  String? _lastUserId;
  String? _lastEpisodeCode;
  int? _lastStageNo;

  bool get isRewardedAdReady => _rewardedAd != null;

  static String get _rewardUnitId {
    return admobAndroidRewardUnitId.isNotEmpty
        ? admobAndroidRewardUnitId
        : (dotenv.env['ADMOB_ANDROID_REWARD_UNIT_ID'] ?? '');
  }

  void loadAd({
    required String userId,
    required String episodeCode,
    required int stageNo,
  }) {
    _lastUserId = userId;
    _lastEpisodeCode = episodeCode;
    _lastStageNo = stageNo;

    if (_isLoadingRewardedAd || _rewardedAd != null) {
      return;
    }

    final adUnitId = _rewardUnitId;
    if (adUnitId.isEmpty) {
      debugPrint('[AdManager] rewarded ad unit id is empty');
      return;
    }

    _isLoadingRewardedAd = true;
    debugPrint(
      '[AdManager] loading rewarded ad episode=$episodeCode stage=$stageNo',
    );
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isLoadingRewardedAd = false;
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
          _isLoadingRewardedAd = false;
          _rewardedAd = null;
          debugPrint(
            '[AdManager] rewarded ad load failed: '
            'code=${error.code} domain=${error.domain} '
            'message=${error.message}',
          );
        },
      ),
    );
  }

  bool showAd({required VoidCallback onRewardEarned}) {
    final ad = _rewardedAd;
    if (ad == null) {
      debugPrint('[AdManager] rewarded ad is not ready');
      _reloadLastRewardedAd();
      return false;
    }

    _rewardedAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _reloadLastRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          '[AdManager] rewarded ad failed to show: '
          'code=${error.code} domain=${error.domain} '
          'message=${error.message}',
        );
        ad.dispose();
        _reloadLastRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewardEarned();
      },
    );
    return true;
  }

  Future<bool> showAdWhenReady({
    required VoidCallback onRewardEarned,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (_rewardedAd == null) {
      _reloadLastRewardedAd();
    }

    final deadline = DateTime.now().add(timeout);
    while (_rewardedAd == null &&
        _isLoadingRewardedAd &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return showAd(onRewardEarned: onRewardEarned);
  }

  void _reloadLastRewardedAd() {
    final userId = _lastUserId;
    final episodeCode = _lastEpisodeCode;
    final stageNo = _lastStageNo;
    if (userId == null || episodeCode == null || stageNo == null) {
      return;
    }

    loadAd(userId: userId, episodeCode: episodeCode, stageNo: stageNo);
  }
}
