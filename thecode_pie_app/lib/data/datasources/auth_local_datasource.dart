import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/app_constants.dart';
import '../../domain/entities/user_model.dart';

/// 인증 로컬 데이터 소스 (로컬 저장소)
abstract class AuthLocalDataSource {
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

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    debugPrint('saveRefreshToken 호출 - 저장할 토큰 길이: ${refreshToken.length}');
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
    debugPrint('saveRefreshToken 완료 - 키: ${AppConstants.refreshTokenKey}');
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  @override
  Future<String?> getAccessToken() async {
    debugPrint('getAccessToken 호출 - 키: ${AppConstants.tokenKey}');
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token != null) {
      debugPrint('getAccessToken 성공 - 토큰 길이: ${token.length}');
      debugPrint(
        'getAccessToken 성공 - 토큰 (처음 20자): ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    } else {
      debugPrint('getAccessToken 실패 - 토큰이 null입니다');
    }
    return token;
  }

  @override
  Future<String?> getRefreshToken() async {
    debugPrint('getRefreshToken 호출 - 키: ${AppConstants.refreshTokenKey}');
    final token = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    if (token != null) {
      debugPrint('getRefreshToken 성공 - 토큰 길이: ${token.length}');
      debugPrint(
        'getRefreshToken 성공 - 토큰 (처음 20자): ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    } else {
      debugPrint('getRefreshToken 실패 - 토큰이 null입니다');
    }
    return token;
  }

  @override
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.userDataKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  @override
  Future<void> deleteAccessToken() async {
    debugPrint('deleteAccessToken 호출 - 키: ${AppConstants.tokenKey}');
    await _secureStorage.delete(key: AppConstants.tokenKey);
    debugPrint('deleteAccessToken 완료');
  }

  @override
  Future<void> deleteRefreshToken() async {
    debugPrint('deleteRefreshToken 호출 - 키: ${AppConstants.refreshTokenKey}');
    // 삭제 전에 현재 값 확인
    final currentToken = await _secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );
    debugPrint('deleteRefreshToken - 삭제 전 토큰 존재 여부: ${currentToken != null}');
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    // 삭제 후 확인
    final afterDelete = await _secureStorage.read(
      key: AppConstants.refreshTokenKey,
    );
    debugPrint('deleteRefreshToken 완료 - 삭제 후 토큰 존재 여부: ${afterDelete != null}');
  }

  @override
  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
  }
}
