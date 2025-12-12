import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// 인증 서비스 (API 호출 담당)
class AuthService {
  GoogleSignIn get _googleSignIn {
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: AppConstants.googleServerClientId, // 🔥 이것만
    );
  }

  /// 구글 로그인 수행
  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      // 1. Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // 사용자가 로그인 취소
      }

      // 2. 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. ID 토큰 가져오기
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ID 토큰을 가져올 수 없습니다.');
      }

      // 4. 구글 사용자 정보 수집
      final googleUserInfo = {
        'id': googleUser.id,
        'email': googleUser.email,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
        'id_token': idToken,
      };

      // 디버그: 수집된 구글 사용자 정보 출력
      debugPrint('=== 구글 로그인 데이터 수집 완료 ===');
      debugPrint('Google User ID: ${googleUser.id}');
      debugPrint('Email: ${googleUser.email}');
      debugPrint('Display Name: ${googleUser.displayName}');
      debugPrint('Photo URL: ${googleUser.photoUrl}');
      debugPrint(
        'ID Token (처음 50자): ${idToken.substring(0, idToken.length > 50 ? 50 : idToken.length)}...',
      );
      debugPrint('--- 전송할 JSON 데이터 ---');
      debugPrint(const JsonEncoder.withIndent('  ').convert(googleUserInfo));
      debugPrint('--- API 엔드포인트 ---');
      debugPrint(AppConstants.googleLoginEndpoint);
      debugPrint('================================');

      // 5. Django 백엔드로 구글 정보 전송
      final response = await http
          .post(
            Uri.parse(AppConstants.googleLoginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(googleUserInfo),
          )
          .timeout(AppConstants.connectTimeout);

      // 디버그: API 응답 상태 출력
      debugPrint('=== Django API 응답 ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('====================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        // Django 응답 형식 체크
        if (responseData['success'] == true && responseData['data'] != null) {
          final authResponse = AuthResponseModel.fromJson(responseData);

          // 6. 토큰 저장 (access_token과 refresh_token 모두 저장)
          await _saveToken(authResponse.accessToken);
          await _saveRefreshToken(authResponse.refreshToken);
          await _saveUserData(authResponse.user);

          return authResponse;
        } else {
          throw Exception('로그인 실패: 응답 형식이 올바르지 않습니다.');
        }
      } else {
        throw Exception('로그인 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('구글 로그인 오류: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      // Google 로그아웃
      await _googleSignIn.signOut();

      // 저장된 토큰 및 사용자 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      throw Exception('로그아웃 오류: $e');
    }
  }

  /// 저장된 Access Token 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// 저장된 Refresh Token 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  /// Access Token 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  /// Refresh Token 저장
  Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }

  /// 사용자 데이터 저장
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }


  Future<String?> getGoogleIdTokenOnly() async {
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('ID Token을 가져오지 못했습니다.');
    }

    return idToken;
  }
}
