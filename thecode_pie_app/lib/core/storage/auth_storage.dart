import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecode_pie_app/auth/domain/model/user_model.dart';

import '../constants/app_constants.dart';

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
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: refreshToken,
    );
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
  }

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(AppConstants.userDataKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }

  @override
  Future<void> deleteAccessToken() {
    return _secureStorage.delete(key: AppConstants.tokenKey);
  }

  @override
  Future<void> deleteRefreshToken() {
    return _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userDataKey);
  }
}
