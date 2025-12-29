import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/auth/data/repository/auth_repository.dart';
import 'package:thecode_pie_app/auth/domain/model/auth_response_model.dart';
import 'package:thecode_pie_app/auth/domain/model/user_model.dart';
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/core/api/auth_api.dart';
import 'package:thecode_pie_app/core/exceptions/auth_exception.dart';
import 'package:thecode_pie_app/core/storage/auth_storage.dart';

/// 인증 Repository 구현체
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      // 1. Google 로그인으로 ID Token 가져오기
      final idToken = await _remoteDataSource.getIdToken();
      if (idToken == null) {
        return null; // 사용자가 로그인 취소
      }

      // 2. 서버 인증
      final authResponse = await _remoteDataSource.signInWithGoogle(idToken);

      // 3. 토큰 및 사용자 정보 로컬 저장
      debugPrint(
        '로그인 성공 - Access Token 길이: ${authResponse.accessToken.length}',
      );
      debugPrint(
        '로그인 성공 - Refresh Token 길이: ${authResponse.refreshToken.length}',
      );
      debugPrint(
        '로그인 성공 - Refresh Token (처음 20자): ${authResponse.refreshToken.substring(0, authResponse.refreshToken.length > 20 ? 20 : authResponse.refreshToken.length)}...',
      );

      await _localDataSource.saveAccessToken(authResponse.accessToken);
      await _localDataSource.saveRefreshToken(authResponse.refreshToken);
      await _localDataSource.saveUserData(authResponse.user);

      // 저장 확인
      final savedRefreshToken = await _localDataSource.getRefreshToken();
      debugPrint(
        'Refresh Token 저장 확인 - 저장된 값: ${savedRefreshToken != null ? "있음 (길이: ${savedRefreshToken.length})" : "없음"}',
      );

      return authResponse;
    } catch (e) {
      throw Exception('구글 로그인 오류: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('signOut 시작');

      // Refresh Token 가져오기
      final refreshToken = await _localDataSource.getRefreshToken();
      debugPrint('signOut - Refresh Token 존재 여부: ${refreshToken != null}');

      // 서버 로그아웃
      if (refreshToken != null) {
        debugPrint('서버 로그아웃 호출 중...');
        await _remoteDataSource.signOut(refreshToken);
        debugPrint('서버 로그아웃 완료');
      } else {
        debugPrint('Refresh Token이 없어 서버 로그아웃 건너뜀');
      }

      // 로컬 데이터 삭제
      debugPrint('로컬 데이터 삭제 시작...');
      await _localDataSource.deleteAccessToken();
      await _localDataSource.deleteRefreshToken();
      await _localDataSource.deleteUserData();
      debugPrint('signOut 완료');
    } catch (e) {
      debugPrint('signOut 오류: $e');
      throw Exception('로그아웃 오류: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _localDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _localDataSource.getRefreshToken();
  }

  @override
  Future<String?> refreshAccessToken() async {
    try {
      debugPrint('refreshAccessToken 시작');

      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('Refresh Token이 없습니다.');
        throw Exception('Refresh Token이 없습니다.');
      }

      if (refreshToken.isEmpty) {
        debugPrint('Refresh Token이 비어있습니다.');
        throw Exception('Refresh Token이 비어있습니다.');
      }

      debugPrint('Refresh Token 획득 성공 (길이: ${refreshToken.length})');
      debugPrint(
        'Refresh Token (처음 20자): ${refreshToken.substring(0, refreshToken.length > 20 ? 20 : refreshToken.length)}...',
      );

      // 새로운 Access Token 발급
      final newAccessToken = await _remoteDataSource.refreshAccessToken(
        refreshToken,
      );

      // 새로운 Access Token 저장
      await _localDataSource.saveAccessToken(newAccessToken);

      debugPrint('refreshAccessToken 완료');
      return newAccessToken;
    } on AuthException catch (e) {
      // Remote datasource에서 온 구조화된 예외(statusCode 등)를 보존한다.
      debugPrint('refreshAccessToken AuthException: $e');
      rethrow;
    } catch (e) {
      debugPrint('refreshAccessToken 오류: $e');
      throw Exception('토큰 갱신 오류: $e');
    }
  }

  @override
  Future<UserModel?> getStoredUser() async {
    return await _localDataSource.getUserData();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      debugPrint('getCurrentUser 시작');

      // makeAuthenticatedRequest를 사용하여 자동 토큰 갱신 처리
      final response = await makeAuthenticatedRequest((accessToken) async {
        return await http.get(
          Uri.parse('${AppConstants.meEndpoint}'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      });

      // 응답 처리
      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류 (${response.statusCode})');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // 성공 응답 처리
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>?;

        if (userData == null) {
          return null;
        }

        final user = UserModel.fromJson(userData);
        // 최신 사용자 정보를 로컬에 저장
        await _localDataSource.saveUserData(user);
        debugPrint('getCurrentUser 성공');
        return user;
      } else {
        final message =
            responseData['message'] as String? ??
            responseData['data']?['message'] as String? ??
            '사용자 정보를 가져올 수 없습니다.';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('getCurrentUser 최종 오류: $e');
      throw Exception('사용자 정보 조회 오류: $e');
    }
  }

  @override
  Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String accessToken) requestFn,
  ) async {
    try {
      debugPrint('=== makeAuthenticatedRequest 시작 ===');

      // Access token 가져오기
      String? accessToken = await _localDataSource.getAccessToken();
      if (accessToken == null) {
        debugPrint('Access Token이 없습니다. 로그인이 필요합니다.');
        throw Exception('Access Token이 없습니다. 로그인이 필요합니다.');
      }

      debugPrint('Access Token 획득 성공 (길이: ${accessToken.length})');
      debugPrint(
        'Access Token (처음 20자): ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
      );

      // 첫 번째 요청 시도
      debugPrint('첫 번째 요청 시도 중...');
      http.Response response = await requestFn(accessToken);

      debugPrint('첫 번째 요청 응답 상태 코드: ${response.statusCode}');
      debugPrint('첫 번째 요청 응답 본문: ${response.body}');
      debugPrint('첫 번째 요청 응답 헤더: ${response.headers}');

      // 401 에러인 경우 토큰 갱신 후 재시도
      if (response.statusCode == 401) {
        debugPrint('⚠️ 401 에러 감지 - Access Token이 만료되었거나 유효하지 않습니다.');
        debugPrint('토큰 갱신 시도...');

        try {
          // Refresh token으로 새로운 access token 발급
          final newAccessToken = await refreshAccessToken();
          if (newAccessToken == null) {
            throw Exception('토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
          }

          debugPrint(
            '✅ 토큰 갱신 성공 - 새로운 Access Token 획득 (길이: ${newAccessToken.length})',
          );
          debugPrint(
            '새로운 Access Token (처음 20자): ${newAccessToken.substring(0, newAccessToken.length > 20 ? 20 : newAccessToken.length)}...',
          );
          debugPrint('원래 요청 재시도 중...');

          // 새로운 access token으로 재시도
          response = await requestFn(newAccessToken);
          debugPrint('✅ 재시도 성공 (상태 코드: ${response.statusCode})');
          debugPrint('재시도 응답 본문: ${response.body}');
        } catch (refreshError) {
          debugPrint('❌ 토큰 갱신 실패: $refreshError');

          // Refresh Token이 만료/유효하지 않은 경우(일반적으로 400) 로컬 토큰 삭제
          final isRefreshTokenExpired =
              refreshError is AuthException && refreshError.statusCode == 400;

          if (isRefreshTokenExpired) {
            debugPrint('⚠️ Refresh Token이 만료되었습니다. 로컬 토큰 삭제 중...');
            try {
              await _localDataSource.deleteAccessToken();
              await _localDataSource.deleteRefreshToken();
              await _localDataSource.deleteUserData();
              debugPrint('✅ 만료된 토큰 삭제 완료');
            } catch (deleteError) {
              debugPrint('토큰 삭제 중 오류: $deleteError');
            }

            // Refresh Token 만료를 명확히 표시하는 예외 던지기
            throw AuthException(
              'REFRESH_TOKEN_EXPIRED: Refresh Token이 만료되었습니다. 다시 로그인해주세요.',
              400,
            );
          }

          throw Exception('토큰 갱신 실패: $refreshError. 다시 로그인해주세요.');
        }
      } else {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('✅ 요청 성공 (상태 코드: ${response.statusCode})');
        } else {
          debugPrint('⚠️ 요청 실패/에러 응답 (상태 코드: ${response.statusCode})');
        }
      }

      debugPrint('=== makeAuthenticatedRequest 완료 ===');
      return response;
    } catch (e) {
      debugPrint('❌ makeAuthenticatedRequest 최종 오류: $e');
      rethrow;
    }
  }
}
