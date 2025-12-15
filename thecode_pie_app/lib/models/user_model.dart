/// 사용자 모델
class UserModel {
  final int id;
  final String email;
  final String? username;
  final String? name; // 구글에서 오는 display_name (호환성 유지)
  final String? picture;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.name,
    this.picture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'picture': picture,
    };
  }
}
