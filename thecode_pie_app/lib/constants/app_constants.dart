import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'The Code PIE';
  static const String appVersion = '1.0.0';

  // Google OAuth 설정 (환경변수에서 읽기)
  static String get googleServerClientId =>
      dotenv.env['SERVER_CLIENT_ID'] ?? '';

  // API 설정 (환경변수에서 읽기)
  static String get baseUrl =>
      dotenv.env['DJANGO_BASE_URL'] ?? 'http://localhost:8000';
  static const String apiVersion = '/api/v1';

  // API 엔드포인트
  static String get googleLoginEndpoint =>
      '$baseUrl$apiVersion/auth/google/login/';
  // refresh / logout 역시 auth prefix 포함 (백엔드 URL: /api/v1/auth/...)
  static String get refreshTokenEndpoint => '$baseUrl$apiVersion/auth/refresh/';
  static String get logoutEndpoint => '$baseUrl$apiVersion/auth/logout/';
  static String get meEndpoint => '$baseUrl$apiVersion/auth/me/';

  // 로컬 스토리지 키
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String bgmVolumeKey = 'bgm_volume';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
