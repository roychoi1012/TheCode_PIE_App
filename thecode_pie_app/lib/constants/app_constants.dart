import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'The Code PIE';
  static const String appVersion = '1.0.0';

  // Google OAuth 설정 (환경변수에서 읽기)
  // Android 클라이언트 ID: Google Play Services 연결용 (SHA-1 지문으로 인증)
  static String get googleAndroidClientId =>
      dotenv.env['GOOGLE_ANDROID_CLIENT_ID'] ?? '';

  // Web 클라이언트 ID: Django 서버 인증용 (serverClientId로 사용)
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  // Web 클라이언트 Secret: Django 서버에서 ID 토큰 검증용
  static String get googleWebClientSecret =>
      dotenv.env['GOOGLE_WEB_CLIENT_SECRET'] ?? '';

  // 하위 호환성을 위한 getter (Android 클라이언트 ID 반환)
  @Deprecated('Use googleAndroidClientId instead')
  static String get googleClientId => googleAndroidClientId;

  @Deprecated('Use googleWebClientSecret instead')
  static String get googleClientSecret => googleWebClientSecret;

  // API 설정 (환경변수에서 읽기)
  static String get baseUrl =>
      dotenv.env['DJANGO_BASE_URL'] ?? 'http://localhost:8000';
  static const String apiVersion = '/api/v1';

  // API 엔드포인트
  static String get googleLoginEndpoint =>
      '$baseUrl$apiVersion/auth/google/callback/';
  static String get refreshTokenEndpoint => '$baseUrl$apiVersion/auth/refresh/';
  static String get logoutEndpoint => '$baseUrl$apiVersion/auth/logout/';

  // 로컬 스토리지 키
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
