import 'package:flutter/services.dart';

class ScreenSecurityService {
  static const MethodChannel _channel = MethodChannel(
    'com.clavis.thecodearc/screen_security',
  );

  /// 스크린샷/화면 녹화 차단 (프리미엄 문제 화면 진입 시 호출)
  static Future<void> enableSecureMode() async {
    try {
      await _channel.invokeMethod('enableSecureMode');
    } on PlatformException catch (_) {
      // iOS 등 미지원 플랫폼에서는 무시
    }
  }

  /// 캡처 방지 해제 (프리미엄 문제 화면 나갈 때 호출)
  static Future<void> disableSecureMode() async {
    try {
      await _channel.invokeMethod('disableSecureMode');
    } on PlatformException catch (_) {
      // 무시
    }
  }
}
