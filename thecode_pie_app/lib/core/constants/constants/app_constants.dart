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
  static String get s3Region => dotenv.env['S3_REGION'] ?? 'ap-northeast-2';
  static const String apiVersion = '/api/v1';

  // API 엔드포인트
  static String get googleLoginEndpoint =>
      '$baseUrl$apiVersion/auth/google/login/';
  // refresh / logout 역시 auth prefix 포함 (백엔드 URL: /api/v1/auth/...)
  static String get refreshTokenEndpoint => '$baseUrl$apiVersion/auth/refresh/';
  static String get logoutEndpoint => '$baseUrl$apiVersion/auth/logout/';
  static String get meEndpoint => '$baseUrl$apiVersion/auth/me/';

  // Contents(Quiz) API 엔드포인트
  static String stageEndpoint(int episodeId, int stageNo) =>
      '$baseUrl$apiVersion/contents/$episodeId/$stageNo/';

  static String answerEndpoint(int episodeId, int stageNo) =>
      '$baseUrl$apiVersion/contents/$episodeId/$stageNo/answer/';

  static String hintEndpoint(int episodeId, int stageNo) =>
      '$baseUrl$apiVersion/contents/$episodeId/$stageNo/hint/';

  /// s3://bucket/key 형태를 HTTPS public URL로 변환
  /// - 이미 http/https 이면 그대로 반환
  /// - 변환 실패 시 원문 반환
  static String resolveImageUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (!trimmed.startsWith('s3://')) return trimmed;

    final withoutScheme = trimmed.substring('s3://'.length);
    final firstSlash = withoutScheme.indexOf('/');
    if (firstSlash <= 0 || firstSlash == withoutScheme.length - 1) {
      return trimmed;
    }

    final bucket = withoutScheme.substring(0, firstSlash);
    final key = withoutScheme.substring(firstSlash + 1);
    return 'https://$bucket.s3.$s3Region.amazonaws.com/$key';
  }

  // 로컬 스토리지 키
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String bgmVolumeKey = 'bgm_volume';
  static const String lastEpisodeIdKey = 'last_episode_id';
  static const String lastStageNoKey = 'last_stage_no';
  static const String lastClearedStageNoKey = 'last_cleared_stage_no';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
