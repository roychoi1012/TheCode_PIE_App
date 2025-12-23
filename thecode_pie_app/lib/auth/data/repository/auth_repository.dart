import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/auth/domain/model/auth_response_model.dart';
import 'package:thecode_pie_app/auth/domain/model/user_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel?> signInWithGoogle();
  Future<UserModel?> getStoredUser();
  Future<UserModel?> getCurrentUser();
  Future<String?> refreshAccessToken();
  Future<void> signOut();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String accessToken) requestFn,
  );
}
