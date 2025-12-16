import 'dart:async';
import 'package:http/http.dart' as http;
import '../entities/user_model.dart';
import '../entities/auth_response_model.dart';

/// 인증 Repository 인터페이스 (Domain Layer)
abstract class AuthRepository {
  /// Google 로그인 + 서버 인증
  Future<AuthResponseModel?> signInWithGoogle();

  /// 로그아웃
  Future<void> signOut();

  /// Access Token 조회
  Future<String?> getAccessToken();

  /// Refresh Token 조회
  Future<String?> getRefreshToken();

  /// Refresh Token을 사용하여 Access Token 재발급
  Future<String?> refreshAccessToken();

  /// 로컬에 저장된 사용자 정보 조회
  Future<UserModel?> getStoredUser();

  /// 현재 사용자 정보를 서버에서 가져오기 (auth/me 엔드포인트)
  /// 401 에러 발생 시 자동으로 토큰 갱신 후 재시도
  Future<UserModel?> getCurrentUser();

  /// 인증이 필요한 API 요청을 실행
  /// 401 에러 발생 시 자동으로 토큰 갱신 후 재시도
  ///
  /// [requestFn]은 Access Token을 받아서 HTTP 요청을 수행하는 함수
  /// 예: (token) => http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
  Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String accessToken) requestFn,
  );
}
