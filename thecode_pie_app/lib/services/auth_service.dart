import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// 인증 서비스 (Google 로그인 + Django API 연동)
class AuthService {
  // 단일 인스턴스 유지로 세션 상태 보존
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: AppConstants.googleServerClientId, // WEB client_id
  );

  // Flutter Secure Storage 인스턴스 (토큰 저장용)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Google 로그인 + 서버 인증
  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      // 1. Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      // 2. 인증 정보
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('ID Token을 가져올 수 없습니다.');
      }

      // 3. Django API 호출 (id_token만 전송)
      final response = await http
          .post(
            Uri.parse(AppConstants.googleLoginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(AppConstants.connectTimeout);

      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류 (${response.statusCode})');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] != true || responseData['data'] == null) {
        throw Exception(responseData['data']?['global'] ?? '로그인에 실패했습니다.');
      }

      final authResponse = AuthResponseModel.fromJson(responseData);

      await _saveAccessToken(authResponse.accessToken);
      await _saveRefreshToken(authResponse.refreshToken);
      await _saveUserData(authResponse.user);

      return authResponse;
    } catch (e) {
      throw Exception('구글 로그인 오류: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();

      // 서버 로그아웃 (refresh_token 전달)
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
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

      // Secure Storage에서 토큰 삭제
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);

      // SharedPreferences에서 유저 데이터 삭제 (민감하지 않은 정보)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      throw Exception('로그아웃 오류: $e');
    }
  }

  /// 토큰 / 유저 조회
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  /// Refresh Token을 사용하여 Access Token 재발급
  ///
  /// 성공 시: {"success": true, "data": {"message": "...", "access_token": "..."}}
  /// 실패 시: {"success": false, "data": {"message": "..."}}
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('Refresh Token이 없습니다.');
      }

      // Django API 호출 (refresh_token 전송)
      final response = await http
          .post(
            Uri.parse(AppConstants.refreshTokenEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(AppConstants.connectTimeout);

      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류 (${response.statusCode})');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // 성공 응답 처리
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;

        if (accessToken != null) {
          // 새로운 access token 저장
          await _saveAccessToken(accessToken);
          return accessToken;
        } else {
          throw Exception(data['message'] ?? 'Access Token을 받을 수 없습니다.');
        }
      } else {
        // 실패 응답 처리
        final data = responseData['data'] as Map<String, dynamic>?;
        final message = data?['message'] ?? '토큰 갱신에 실패했습니다.';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('토큰 갱신 오류: $e');
    }
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.userDataKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  /// 현재 사용자 정보를 서버에서 가져오기 (auth/me 엔드포인트)
  /// 401 에러 발생 시 자동으로 토큰 갱신 후 재시도
  Future<UserModel?> getCurrentUser() async {
    try {
      // Access token 가져오기
      String? accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('Access Token이 없습니다. 로그인이 필요합니다.');
      }

      // 첫 번째 요청 시도
      http.Response response = await http
          .get(
            Uri.parse(AppConstants.meEndpoint),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(AppConstants.connectTimeout);

      // 401 에러 발생 시 토큰 갱신 후 재시도
      if (response.statusCode == 401) {
        debugPrint('Access Token 만료 감지. 토큰 갱신 시도...');

        try {
          // Refresh token으로 새로운 access token 발급
          final newAccessToken = await refreshAccessToken();
          if (newAccessToken == null) {
            throw Exception('토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
          }

          debugPrint('토큰 갱신 성공. 원래 요청 재시도...');

          // 새로운 access token으로 재시도
          response = await http
              .get(
                Uri.parse(AppConstants.meEndpoint),
                headers: {
                  'Authorization': 'Bearer $newAccessToken',
                  'Content-Type': 'application/json',
                },
              )
              .timeout(AppConstants.connectTimeout);
        } catch (refreshError) {
          throw Exception('토큰 갱신 실패: $refreshError. 다시 로그인해주세요.');
        }
      }

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
        await _saveUserData(user);
        return user;
      } else {
        // 실패 응답 처리
        // 에러 메시지는 최상위 레벨 또는 data 내부에 있을 수 있음
        final message =
            responseData['message'] as String? ??
            responseData['data']?['message'] as String? ??
            '사용자 정보를 가져올 수 없습니다.';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('사용자 정보 조회 오류: $e');
    }
  }

  /// 내부 저장 메서드
  Future<void> _saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }
}
