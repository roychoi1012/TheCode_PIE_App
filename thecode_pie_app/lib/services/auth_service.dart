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
    // Web 클라이언트 ID를 serverClientId로 사용
    // 이렇게 하면 Android에서 Web 클라이언트용 ID 토큰을 발급받을 수 있습니다
    // Django 서버에서 이 ID 토큰을 Web 클라이언트 ID와 Secret으로 검증합니다
    final webClientId = AppConstants.googleWebClientId;

    if (webClientId.isNotEmpty) {
      return GoogleSignIn(
        scopes: ['email', 'profile'],
        // serverClientId: Web 클라이언트 ID 사용 (Django 백엔드로 ID 토큰 전송용)
        // Android에서는 이 값을 사용하여 Web 클라이언트용 ID 토큰을 발급받습니다
        // iOS: 자동으로 Info.plist에서 읽어옵니다
        serverClientId: webClientId,
      );
    }

    // Web 클라이언트 ID가 없으면 기본 설정 사용
    // (Android 클라이언트 ID가 자동으로 감지되지만, ID 토큰을 받을 수 없을 수 있음)
    debugPrint('⚠️ 경고: GOOGLE_WEB_CLIENT_ID가 설정되지 않았습니다.');
    return GoogleSignIn(scopes: ['email', 'profile']);
  }

  /// 구글 로그인 수행
  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      debugPrint('[1/8] === signInWithGoogle() 시작 ===');
      debugPrint('[1/8] GoogleSignIn 인스턴스 생성 중...');

      // GoogleSignIn 인스턴스 생성 확인
      final googleSignInInstance = _googleSignIn;
      final androidClientId = AppConstants.googleAndroidClientId;
      final webClientId = AppConstants.googleWebClientId;

      debugPrint(
        '[1/8] Android Client ID: ${androidClientId.isEmpty ? "없음" : "${androidClientId.substring(0, 20)}..."}',
      );
      debugPrint(
        '[1/8] Web Client ID (serverClientId): ${webClientId.isEmpty ? "없음 - ID 토큰을 받을 수 없을 수 있습니다!" : "${webClientId.substring(0, 20)}..."}',
      );
      debugPrint('[1/8] GoogleSignIn 인스턴스 생성 완료');

      debugPrint('[2/8] Google Sign-In 화면 표시 중...');
      // 1. Google 로그인
      final GoogleSignInAccount? googleUser = await googleSignInInstance
          .signIn();
      debugPrint(
        '[2/8] Google Sign-In 결과: ${googleUser == null ? "취소됨" : "성공"}',
      );

      if (googleUser == null) {
        debugPrint('[2/8] 사용자가 로그인을 취소했습니다.');
        return null; // 사용자가 로그인 취소
      }

      debugPrint('[2/8] Google User ID: ${googleUser.id}');
      debugPrint('[2/8] Google User Email: ${googleUser.email}');

      debugPrint('[3/8] 인증 정보 가져오는 중...');
      // 2. 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint('[3/8] 인증 정보 가져오기 완료');
      debugPrint('[3/8] Access Token 존재: ${googleAuth.accessToken != null}');
      debugPrint('[3/8] ID Token 존재: ${googleAuth.idToken != null}');

      debugPrint('[4/8] ID 토큰 확인 중...');
      // 3. ID 토큰 가져오기
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint('[4/8] ❌ ID 토큰이 null입니다!');
        throw Exception('ID 토큰을 가져올 수 없습니다.');
      }
      debugPrint('[4/8] ID 토큰 확인 완료 (길이: ${idToken.length})');

      debugPrint('[5/8] 구글 사용자 정보 수집 중...');
      // 4. 구글 사용자 정보 수집
      final googleUserInfo = {
        'id': googleUser.id,
        'email': googleUser.email,
        'display_name': googleUser.displayName,
        'photo_url': googleUser.photoUrl,
        'id_token': idToken,
      };

      // 디버그: 수집된 구글 사용자 정보 출력
      debugPrint('[5/8] === 구글 로그인 데이터 수집 완료 ===');
      debugPrint('[5/8] Google User ID: ${googleUser.id}');
      debugPrint('[5/8] Email: ${googleUser.email}');
      debugPrint('[5/8] Display Name: ${googleUser.displayName}');
      debugPrint('[5/8] Photo URL: ${googleUser.photoUrl}');
      debugPrint(
        '[5/8] ID Token (처음 50자): ${idToken.substring(0, idToken.length > 50 ? 50 : idToken.length)}...',
      );
      debugPrint('[5/8] --- 전송할 JSON 데이터 ---');
      debugPrint(
        '[5/8] ${const JsonEncoder.withIndent('  ').convert(googleUserInfo)}',
      );
      debugPrint('[5/8] --- API 엔드포인트 ---');
      debugPrint('[5/8] ${AppConstants.googleLoginEndpoint}');
      debugPrint('[5/8] ================================');

      debugPrint('[6/8] Django 백엔드로 API 요청 전송 중...');
      debugPrint('[6/8] URL: ${AppConstants.googleLoginEndpoint}');
      debugPrint('[6/8] Timeout: ${AppConstants.connectTimeout.inSeconds}초');

      // 5. Django 백엔드로 구글 정보 전송
      final response = await http
          .post(
            Uri.parse(AppConstants.googleLoginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(googleUserInfo),
          )
          .timeout(AppConstants.connectTimeout);

      debugPrint('[6/8] API 요청 완료');
      // 디버그: API 응답 상태 출력
      debugPrint('[6/8] === Django API 응답 ===');
      debugPrint('[6/8] Status Code: ${response.statusCode}');
      debugPrint('[6/8] Response Body: ${response.body}');
      debugPrint('[6/8] ====================');

      debugPrint('[7/8] 응답 처리 중...');
      if (response.statusCode == 200) {
        debugPrint('[7/8] HTTP 200 OK 응답 받음');
        debugPrint('[7/8] JSON 파싱 시작...');

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('[7/8] JSON 파싱 완료');

        // Django 응답 형식 체크
        debugPrint('[7/8] 응답 형식 검증 중...');
        debugPrint('[7/8] success: ${responseData['success']}');
        debugPrint('[7/8] data 존재: ${responseData['data'] != null}');

        if (responseData['success'] == true && responseData['data'] != null) {
          debugPrint('[7/8] 응답 형식 검증 통과');
          debugPrint('[7/8] AuthResponseModel 생성 중...');

          final authResponse = AuthResponseModel.fromJson(responseData);
          debugPrint('[7/8] AuthResponseModel 생성 완료');

          debugPrint('[8/8] 토큰 저장 중...');
          // 6. 토큰 저장 (access_token과 refresh_token 모두 저장)
          await _saveToken(authResponse.accessToken);
          debugPrint('[8/8] Access Token 저장 완료');

          await _saveRefreshToken(authResponse.refreshToken);
          debugPrint('[8/8] Refresh Token 저장 완료');

          await _saveUserData(authResponse.user);
          debugPrint('[8/8] User Data 저장 완료');

          debugPrint('[8/8] ✅ 로그인 성공!');
          return authResponse;
        } else {
          debugPrint('[7/8] ❌ 응답 형식이 올바르지 않습니다.');
          debugPrint('[7/8] responseData: $responseData');
          throw Exception('로그인 실패: 응답 형식이 올바르지 않습니다.');
        }
      } else {
        debugPrint('[7/8] ❌ HTTP 에러: ${response.statusCode}');
        debugPrint('[7/8] 응답 본문: ${response.body}');
        throw Exception('로그인 실패: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ ========== 구글 로그인 오류 발생 ==========');
      debugPrint('❌ 오류 타입: ${e.runtimeType}');
      debugPrint('❌ 오류 메시지: $e');
      debugPrint('❌ 스택 트레이스:');
      debugPrint(stackTrace.toString());
      debugPrint('❌ ===========================================');
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
}
