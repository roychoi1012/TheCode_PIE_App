/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'The Code PIE';
  static const String appVersion = '1.0.0';

  // API 설정 (개발 환경)
  static const String baseUrl = 'http://localhost:8000'; // Django 백엔드 URL
  static const String apiVersion = '/api/v1';

  // API 엔드포인트
  static const String googleLoginEndpoint =
      '$baseUrl$apiVersion/auth/google-login/';
  static const String refreshTokenEndpoint =
      '$baseUrl$apiVersion/auth/refresh/';
  static const String logoutEndpoint = '$baseUrl$apiVersion/auth/logout/';

  // 로컬 스토리지 키
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
