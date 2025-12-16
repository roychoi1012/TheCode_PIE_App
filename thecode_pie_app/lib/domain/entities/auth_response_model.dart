import 'user_model.dart';

/// 인증 응답 모델 (Entity)
class AuthResponseModel {
  final bool success;
  final String message;
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Django 응답 형식: { "success": true, "data": { ... } }
    final data = json['data'] as Map<String, dynamic>;

    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      message: data['message'] as String? ?? '',
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }

  // 하위 호환성을 위한 getter (기존 코드에서 token으로 접근 가능하도록)
  String get token => accessToken;
}
