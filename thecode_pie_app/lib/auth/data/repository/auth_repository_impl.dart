import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/auth/data/repository/auth_repository.dart';
import 'package:thecode_pie_app/auth/domain/model/auth_response_model.dart';
import 'package:thecode_pie_app/auth/domain/model/user_model.dart';
import 'package:thecode_pie_app/core/api/auth_api.dart';
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/core/exceptions/auth_exception.dart';
import 'package:thecode_pie_app/core/storage/auth_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<AuthResponseModel?> signInWithGoogle() async {
    try {
      final idToken = await _remoteDataSource.getIdToken();
      if (idToken == null) {
        return null;
      }

      final authResponse = await _remoteDataSource.signInWithGoogle(idToken);

      await _localDataSource.saveAccessToken(authResponse.accessToken);
      await _localDataSource.saveRefreshToken(authResponse.refreshToken);
      await _localDataSource.saveUserData(authResponse.user);

      debugPrint(
        '[AuthRepo] sign-in completed user=${authResponse.user.email}',
      );
      return authResponse;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken != null) {
        await _remoteDataSource.signOut(refreshToken);
      }

      await _localDataSource.deleteAccessToken();
      await _localDataSource.deleteRefreshToken();
      await _localDataSource.deleteUserData();
      debugPrint('[AuthRepo] sign-out completed');
    } catch (e) {
      debugPrint('[AuthRepo] sign-out failed: $e');
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<String?> getAccessToken() {
    return _localDataSource.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() {
    return _localDataSource.getRefreshToken();
  }

  @override
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Refresh Token is missing.');
      }

      final newAccessToken = await _remoteDataSource.refreshAccessToken(
        refreshToken,
      );
      await _localDataSource.saveAccessToken(newAccessToken);

      debugPrint('[AuthRepo] access token refreshed');
      return newAccessToken;
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('[AuthRepo] token refresh failed: $e');
      throw Exception('Token refresh failed: $e');
    }
  }

  @override
  Future<UserModel?> getStoredUser() {
    return _localDataSource.getUserData();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await makeAuthenticatedRequest((accessToken) async {
        return http
            .get(
              Uri.parse(AppConstants.meEndpoint),
              headers: {
                'Authorization': 'Bearer $accessToken',
                'Content-Type': 'application/json',
              },
            )
            .timeout(AppConstants.connectTimeout);
      });

      if (response.statusCode != 200) {
        throw Exception('Server response error (${response.statusCode})');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData == null) {
          return null;
        }

        final user = UserModel.fromJson(userData);
        await _localDataSource.saveUserData(user);
        debugPrint('[AuthRepo] current user loaded');
        return user;
      }

      final message =
          responseData['message'] as String? ??
          responseData['data']?['message'] as String? ??
          'Failed to load user data.';
      throw Exception(message);
    } catch (e) {
      debugPrint('[AuthRepo] getCurrentUser failed: $e');
      throw Exception('Failed to load user data: $e');
    }
  }

  @override
  Future<http.Response> makeAuthenticatedRequest(
    Future<http.Response> Function(String accessToken) requestFn,
  ) async {
    try {
      final accessToken = await _localDataSource.getAccessToken();
      if (accessToken == null) {
        throw Exception('Access Token is missing. Login is required.');
      }

      var response = await requestFn(accessToken);
      debugPrint(
        '[AuthRepo] authenticated request status=${response.statusCode}',
      );

      if (response.statusCode == 401) {
        debugPrint('[AuthRepo] access token rejected; refreshing');
        try {
          final newAccessToken = await refreshAccessToken();
          if (newAccessToken == null) {
            throw Exception('Token refresh failed. Please login again.');
          }

          response = await requestFn(newAccessToken);
          debugPrint('[AuthRepo] retry status=${response.statusCode}');
        } catch (refreshError) {
          final isRefreshTokenExpired =
              refreshError is AuthException && refreshError.statusCode == 400;

          if (isRefreshTokenExpired) {
            await _localDataSource.deleteAccessToken();
            await _localDataSource.deleteRefreshToken();
            await _localDataSource.deleteUserData();
            throw AuthException(
              'REFRESH_TOKEN_EXPIRED: Refresh Token expired. Please login again.',
              400,
            );
          }

          throw Exception(
            'Token refresh failed: $refreshError. Please login again.',
          );
        }
      }

      return response;
    } catch (e) {
      debugPrint('[AuthRepo] authenticated request failed: $e');
      rethrow;
    }
  }
}
