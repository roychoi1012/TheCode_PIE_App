import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/ad_config.g.dart';

class AdManagerService {
  RewardedAd? _rewardedAd;

  /// 리워드 광고 단위 ID: local.properties의 admob.reward.unit.id → .env fallback
  static String get _rewardUnitId =>
      admobAndroidRewardUnitId.isNotEmpty
          ? admobAndroidRewardUnitId
          : (dotenv.env['ADMOB_ANDROID_REWARD_UNIT_ID'] ?? '');

  void loadAd({
    required String userId,
    required String episodeCode,
    required int stageNo,
  }) {
    print('--- 광고 로드 시도 시작 ---');
    print('광고 ID: $userId, Ep: $episodeCode, Stage: $stageNo');
    RewardedAd.load(
      adUnitId: _rewardUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print('--- onAdLoaded 콜백 진입 성공 ---');
          try {
            (ad as dynamic).setServerSideOptions(
              ServerSideVerificationOptions(
                userId: userId,
                customData: "$episodeCode|$stageNo",
              ),
            );
            _rewardedAd = ad;
            print('광고 로드 성공 (SSV 설정 완료): $episodeCode|$stageNo');
          } catch (e) {
            print('광고 SSV 설정 실패 (에러내용): $e');
            _rewardedAd = ad; // 광고는 일단 보여주기 위해 할당
            print('광고 로드 성공 (단, SSV는 실패): $episodeCode|$stageNo');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          print('광고 로드 실패: ${error.message}');
        },
      ),
    );
  }

  void showAd({required Function onRewardEarned}) {
    if (_rewardedAd == null) {
      print('광고가 준비되지 않았습니다.');
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