import '../../domain/model/auth_response_model.dart';
import '../../domain/model/user_model.dart';

/// 인증 데이터 소스 인터페이스
abstract class AuthDataSource {
  // Remote
  Future<String?> getIdToken();
  Future<AuthResponseModel> signInWithGoogle(String idToken);
  Future<void> signOut(String refreshToken);
  Future<String> refreshAccessToken(String refreshToken);
  Future<UserModel> getCurrentUser(String accessToken);

  // Local
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String refreshToken);
  Future<void> saveUserData(UserModel user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getUserData();
  Future<void> deleteAccessToken();
  Future<void> deleteRefreshToken();
  Future<void> deleteUserData();
}
