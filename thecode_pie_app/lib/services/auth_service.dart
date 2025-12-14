import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// 인증 서비스 (Google 로그인 + Django API 연동)
class AuthService {
  GoogleSignIn get _googleSignIn {
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: AppConstants.googleServerClientId, // WEB client_id
    );
  }

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
      final response = await http.post(
        Uri.parse(
          '${AppConstants.baseUrl}/api/v1/auth/google/login/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_token': idToken,
        }),
      ).timeout(AppConstants.connectTimeout);

      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류 (${response.statusCode})');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['success'] != true || responseData['data'] == null) {
        throw Exception(
          responseData['data']?['global'] ?? '로그인에 실패했습니다.',
        );
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      throw Exception('로그아웃 오류: $e');
    }
  }

  /// 토큰 / 유저 조회
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.userDataKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  /// 내부 저장 메서드
  Future<void> _saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.userDataKey,
      jsonEncode(user.toJson()),
    );
  }
}
