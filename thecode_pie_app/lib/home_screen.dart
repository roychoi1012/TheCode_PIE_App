import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:thecode_pie_app/helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _points = 0; // 포인트 상태

  @override
  void initState() {
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
    super.initState();
  }

  void _loadBannerAd() {
    BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: ${error.message}');
          ad.dispose();
        },
      ),
      request: AdRequest(),
    ).load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // 1. 광고 로드 성공 시 변수에 저장
          _interstitialAd = ad;

          // 2. 풀스크린 이벤트 콜백 설정 (로드된 이후에 설정해야 함)
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  print('전면 광고 노출 시작');
                },
                onAdDismissedFullScreenContent: (ad) {
                  // 사용자가 광고를 닫으면 리소스 해제 및 다음 광고 미리 로드
                  print('전면 광고가 닫혔습니다.');
                  ad.dispose();
                  _interstitialAd = null; // 초기화 필수
                  _loadInterstitialAd(); // 재로드
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  // 광고 노출 실패 시 처리
                  print('전면 광고 노출 실패: ${error.message}');
                  ad.dispose();
                  _interstitialAd = null;
                  _loadInterstitialAd();
                },
              );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('전면 광고 로드 실패: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
          });
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('리워드 광고 노출 시작');
            },
            onAdDismissedFullScreenContent: (ad) {
              // 광고가 닫힌 후에만 dispose
              print('리워드 광고가 닫혔습니다.');
              ad.dispose();
              setState(() {
                _rewardedAd = null;
              });
              _loadRewardedAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('리워드 광고 노출 실패: ${error.message}');
              ad.dispose();
              setState(() {
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: ${error.message}');
          setState(() {
            _rewardedAd = null;
          });
        },
      ),
      request: AdRequest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admob Test'),
        actions: [
          // 우상단에 포인트 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_points',
                    style: const TextStyle(fontSize: 18, fontWeight: .bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            // 배너 광고 (null 체크 추가)
            if (_bannerAd != null)
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            else
              const SizedBox(
                width: 320,
                height: 50,
                child: Center(child: Text('광고 로딩 중...')),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _rewardedAd == null
                  ? null
                  : () {
                      _rewardedAd?.show(
                        onUserEarnedReward: (ad, reward) {
                          // 리워드 광고를 보면 포인트 증가
                          print(
                            '리워드 획득! amount: ${reward.amount}, type: ${reward.type}',
                          );
                          setState(() {
                            _points += reward.amount.toInt();
                          });
                          print('현재 포인트: $_points');
                        },
                      );
                    },
              child: Text(
                _rewardedAd == null ? '광고 로딩 중...' : 'Show Rewarded Ad',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _interstitialAd?.show();
        },
        child: Icon(Icons.tv),
      ),
    );
  }
}
