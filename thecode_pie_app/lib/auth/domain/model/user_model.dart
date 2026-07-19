/// 사용자 모델 (Entity)
class UserModel {
  final int? id;
  final String? providerUserId;
  final String email;
  final String? username;
  final String? name; // 구글에서 오는 display_name (호환성 유지)
  final String? picture;
  final String? provider; // 인증 제공자 (google 등)
  final String? createdAt; // ISO 형식의 생성일시

  UserModel({
    this.id,
    this.providerUserId,
    required this.email,
    this.username,
    this.name,
    this.picture,
    this.provider,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is num) {
      parsedId = rawId.toInt();
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId);
    }

    return UserModel(
      id: parsedId,
      providerUserId:
          json['provider_user_id'] as String? ?? json['p_id'] as String?,
      email: json['email'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      provider: json['provider'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_user_id': providerUserId,
      'email': email,
      'username': username,
      'name': name,
      'picture': picture,
      'provider': provider,
      'created_at': createdAt,
    };
  }
}
