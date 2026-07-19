import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/auth/domain/model/auth_response_model.dart';
import 'package:thecode_pie_app/auth/domain/model/user_model.dart';

import '../../core/exceptions/auth_exception.dart';
import '../constants/app_constants.dart';

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

  Future<http.Response> _postGoogleLogin(String requestBody) {
    return http
        .post(
          Uri.parse(AppConstants.googleLoginEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(AppConstants.connectTimeout);
  }

  @override
  Future<String?> getIdToken() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('[AuthRemote] cleared previous Google Sign-In session');
    } catch (e) {
      debugPrint('[AuthRemote] Google Sign-In session cleanup ignored: $e');
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('[AuthRemote] Google Sign-In cancelled');
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw Exception('ID Token is not available.');
    }

    return idToken;
  }

  @override
  Future<AuthResponseModel> signInWithGoogle(String idToken) async {
    if (idToken.isEmpty) {
      throw Exception('ID Token is empty.');
    }

    final requestBody = jsonEncode({'id_token': idToken});
    debugPrint('[AuthRemote] POST ${AppConstants.googleLoginEndpoint}');

    var response = await _postGoogleLogin(requestBody);
    debugPrint('[AuthRemote] google login status=${response.statusCode}');

    if (response.statusCode == 400 &&
        response.body.toLowerCase().contains('token used too early')) {
      debugPrint('[AuthRemote] token used too early; retrying once');
      await Future.delayed(const Duration(seconds: 2));
      response = await _postGoogleLogin(requestBody);
      debugPrint(
        '[AuthRemote] google login retry status=${response.statusCode}',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData['success'] != true || responseData['data'] == null) {
      throw Exception(responseData['data']?['global'] ?? 'Login failed.');
    }

    return AuthResponseModel.fromJson(responseData);
  }

  @override
  Future<void> signOut(String refreshToken) async {
    await _googleSignIn.signOut();

    try {
      final response = await http
          .post(
            Uri.parse(AppConstants.logoutEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(AppConstants.connectTimeout);
      debugPrint('[AuthRemote] logout status=${response.statusCode}');
    } catch (e) {
      debugPrint(
        '[AuthRemote] server logout failed; local sign-out continues: $e',
      );
    }
  }

  @override
  Future<String> refreshAccessToken(String refreshToken) async {
    debugPrint('[AuthRemote] POST ${AppConstants.refreshTokenEndpoint}');

    final response = await http
        .post(
          Uri.parse(AppConstants.refreshTokenEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(AppConstants.connectTimeout);

    debugPrint('[AuthRemote] refresh status=${response.statusCode}');

    if (response.statusCode != 200) {
      final errorMessage = _extractErrorMessage(response);
      if (response.statusCode == 400) {
        debugPrint('[AuthRemote] refresh token rejected');
      }
      throw AuthException(errorMessage, response.statusCode);
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String?;
      if (accessToken != null) {
        return accessToken;
      }
      throw AuthException(data['message'] ?? 'Access Token is missing.');
    }

    final data = responseData['data'] as Map<String, dynamic>?;
    throw AuthException(data?['message'] ?? 'Token refresh failed.');
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    debugPrint('[AuthRemote] GET ${AppConstants.meEndpoint}');

    final response = await http
        .get(
          Uri.parse(AppConstants.meEndpoint),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        )
        .timeout(AppConstants.connectTimeout);

    debugPrint('[AuthRemote] me status=${response.statusCode}');

    if (response.statusCode == 401) {
      throw AuthException(
        _extractErrorMessage(response, fallback: 'Authentication is required.'),
        401,
      );
    }

    if (response.statusCode != 200) {
      throw AuthException(_extractErrorMessage(response), response.statusCode);
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'] as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw AuthException('User data is missing.');
      }
      return UserModel.fromJson(userData);
    }

    final message =
        responseData['message'] as String? ??
        responseData['data']?['message'] as String? ??
        'Failed to load user data.';
    throw AuthException(message);
  }

  String _extractErrorMessage(
    http.Response response, {
    String fallback = 'Server response error',
  }) {
    var errorMessage = '$fallback (${response.statusCode})';
    try {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
      if (errorData != null) {
        errorMessage =
            errorData['message'] as String? ??
            errorData['data']?['message'] as String? ??
            errorData['data']?['global'] as String? ??
            errorMessage;
      }
    } catch (_) {
      // Keep the status-only fallback; response bodies can include tokens.
    }
    return errorMessage;
  }
}
