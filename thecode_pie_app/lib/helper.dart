import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    const bool isTestMode = true; // 개발 중엔 true, 출시 땐 false

    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Android 테스트 ID
          : 'ca-app-pub-actual-number/actual-number';
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/2934735716' // iOS 테스트 ID
          : 'ca-app-pub-actual-number/actual-number'; // 실제 번호로 변경
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    const bool isTestMode = true; // 개발 중엔 true, 출시 땐 false

    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트 ID
          : 'ca-app-pub-actual-number/actual-number';
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/4411468940' // iOS 테스트 ID
          : 'ca-app-pub-actual-number/actual-number'; // 실제 번호로 변경
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    const bool isTestMode = true; // 개발 중엔 true, 출시 땐 false

    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Android 테스트 ID
          : 'ca-app-pub-actual-number/actual-number';
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/1712485313' // iOS 테스트 ID
          : 'ca-app-pub-actual-number/actual-number'; // 실제 번호로 변경
    }
    throw UnsupportedError('Unsupported platform');
  }
}
