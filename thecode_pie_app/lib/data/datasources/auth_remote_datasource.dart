import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../constants/app_constants.dart';
import '../../domain/entities/auth_response_model.dart';
import '../../domain/entities/user_model.dart';
import '../exceptions/auth_exception.dart';

/// 인증 원격 데이터 소스 (API 호출)
abstract class AuthRemoteDataSource {
  Future<String?> getIdToken();
  Future<AuthResponseModel> signInWithGoogle(String idToken);
  Future<void> signOut(String refreshToken);
  Future<String> refreshAccessToken(String refreshToken);
  Future<UserModel> getCurrentUser(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: AppConstants.googleServerClientId,
  );

  /// Google 로그인으로 ID Token 가져오기
  @override
  Future<String?> getIdToken() async {
    // 다른 계정으로 로그인할 수 있도록 이전 세션 정리
    // signIn() 전에 signOut()을 호출하면 계정 선택 화면이 나타남
    try {
      await _googleSignIn.signOut();
      debugPrint('이전 Google Sign-In 세션 정리 완료');
    } catch (e) {
      debugPrint('Google Sign-In 세션 정리 중 오류 (무시): $e');
      // signOut 실패해도 계속 진행
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('Google 로그인 취소됨');
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final idToken = googleAuth.idToken;
    if (idToken == null) {
      debugPrint('ID Token을 가져올 수 없습니다.');
      throw Exception('ID Token을 가져올 수 없습니다.');
    }

    debugPrint('ID Token 획득 성공 (길이: ${idToken.length})');
    return idToken;
  }

  @override
  Future<AuthResponseModel> signInWithGoogle(String idToken) async {
    // ID Token 유효성 검사
    if (idToken.isEmpty) {
      throw Exception('ID Token이 비어있습니다.');
    }

    final requestBody = jsonEncode({'id_token': idToken});
    debugPrint('로그인 요청 URL: ${AppConstants.googleLoginEndpoint}');
    debugPrint('요청 본문: $requestBody');

    final response = await http
        .post(
          Uri.parse(AppConstants.googleLoginEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(AppConstants.connectTimeout);

    debugPrint('서버 응답 상태 코드: ${response.statusCode}');
    debugPrint('서버 응답 본문: ${response.body}');

    if (response.statusCode != 200) {
      // 400 에러의 경우 상세 메시지 출력
      String errorMessage = '서버 응답 오류 (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        if (errorData != null) {
          final message =
              errorData['message'] as String? ??
              errorData['data']?['message'] as String? ??
              errorData['data']?['global'] as String?;
          if (message != null) {
            errorMessage = message;
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시 원본 응답 본문 사용
        errorMessage = '서버 응답 오류 (${response.statusCode}): ${response.body}';
      }
      throw Exception(errorMessage);
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData['success'] != true || responseData['data'] == null) {
      throw Exception(responseData['data']?['global'] ?? '로그인에 실패했습니다.');
    }

    return AuthResponseModel.fromJson(responseData);
  }

  @override
  Future<void> signOut(String refreshToken) async {
    await _googleSignIn.signOut();

    try {
      await http
          .post(
            Uri.parse(AppConstants.logoutEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(AppConstants.connectTimeout);
    } catch (e) {
      // 서버 로그아웃 실패는 클라이언트 로그아웃을 막지 않음
      debugPrint('서버 로그아웃 호출 실패: $e');
    }
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    debugPrint('refreshAccessToken 호출: ${AppConstants.refreshTokenEndpoint}');
    debugPrint('Refresh Token 길이: ${refreshToken.length}');

    final requestBody = jsonEncode({'refresh_token': refreshToken});
    debugPrint('요청 본문: $requestBody');

    final response = await http
        .post(
          Uri.parse(AppConstants.refreshTokenEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(AppConstants.connectTimeout);

    debugPrint('refreshAccessToken 응답 상태 코드: ${response.statusCode}');
    debugPrint('refreshAccessToken 응답 본문: ${response.body}');

    if (response.statusCode != 200) {
      String errorMessage = '서버 응답 오류 (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        if (errorData != null) {
          errorMessage =
              errorData['message'] as String? ??
              errorData['data']?['message'] as String? ??
              errorMessage;
        }
      } catch (e) {
        errorMessage = '서버 응답 오류 (${response.statusCode}): ${response.body}';
      }

      // 400 에러인 경우 (Refresh Token 만료 등) 명확하게 표시
      if (response.statusCode == 400) {
        debugPrint('❌ Refresh Token 갱신 실패 (400): $errorMessage');
        debugPrint('⚠️ Refresh Token이 만료되었거나 유효하지 않습니다.');
      }

      throw AuthException(errorMessage, response.statusCode);
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;

      if (accessToken != null) {
        debugPrint('새로운 Access Token 획득 성공 (길이: ${accessToken.length})');
        return accessToken;
      } else {
        throw AuthException(data['message'] ?? 'Access Token을 받을 수 없습니다.');
      }
    } else {
      final data = responseData['data'] as Map<String, dynamic>?;
      final message = data?['message'] ?? '토큰 갱신에 실패했습니다.';
      throw AuthException(message);
    }
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    debugPrint('getCurrentUser 호출: ${AppConstants.meEndpoint}');

    final response = await http
        .get(
          Uri.parse(AppConstants.meEndpoint),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        )
        .timeout(AppConstants.connectTimeout);

    debugPrint('getCurrentUser 응답 상태 코드: ${response.statusCode}');
    debugPrint('getCurrentUser 응답 본문: ${response.body}');

    // 401 에러는 명확하게 처리
    if (response.statusCode == 401) {
      String errorMessage = '인증이 필요합니다.';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        if (errorData != null) {
          errorMessage =
              errorData['message'] as String? ??
              errorData['data']?['message'] as String? ??
              'Access Token이 만료되었거나 유효하지 않습니다.';
        }
      } catch (e) {
        errorMessage = response.body;
      }
      throw AuthException(errorMessage, 401);
    }

    if (response.statusCode != 200) {
      String errorMessage = '서버 응답 오류 (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        if (errorData != null) {
          errorMessage =
              errorData['message'] as String? ??
              errorData['data']?['message'] as String? ??
              errorMessage;
        }
      } catch (e) {
        errorMessage = '서버 응답 오류 (${response.statusCode}): ${response.body}';
      }
      throw AuthException(errorMessage, response.statusCode);
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'] as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>?;

      if (userData == null) {
        throw AuthException('사용자 정보가 없습니다.');
      }

      return UserModel.fromJson(userData);
    } else {
      final message =
          responseData['message'] as String? ??
          responseData['data']?['message'] as String? ??
          '사용자 정보를 가져올 수 없습니다.';
      throw AuthException(message);
    }
  }
}
