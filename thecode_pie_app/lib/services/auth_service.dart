import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// 인증 서비스 (API 호출 담당)
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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

      // 4. Django 백엔드로 ID 토큰 전송
      final response = await http
          .post(
            Uri.parse(AppConstants.googleLoginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id_token': idToken}),
          )
          .timeout(AppConstants.connectTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponseModel.fromJson(data);

        // 5. 토큰 저장
        await _saveToken(authResponse.token);
        await _saveUserData(authResponse.user);

        return authResponse;
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
      await prefs.remove(AppConstants.userDataKey);
    } catch (e) {
      throw Exception('로그아웃 오류: $e');
    }
  }

  /// 저장된 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  /// 사용자 데이터 저장
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }
}
