import 'user_model.dart';

/// 인증 응답 모델
class AuthResponseModel {
  final String token;
  final UserModel user;
  final bool created; // 새로 생성된 사용자인지 여부

  AuthResponseModel({
    required this.token,
    required this.user,
    required this.created,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      created: json['created'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user.toJson(), 'created': created};
  }
}
