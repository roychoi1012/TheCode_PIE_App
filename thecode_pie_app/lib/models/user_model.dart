/// 사용자 모델
class UserModel {
  final int id;
  final String email;
  final String? name;
  final String? picture;

  UserModel({required this.id, required this.email, this.name, this.picture});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'picture': picture};
  }
}
