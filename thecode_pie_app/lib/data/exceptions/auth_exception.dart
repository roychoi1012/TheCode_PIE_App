/// 인증 관련 예외 클래스
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'AuthException: $message (Status: $statusCode)'
      : 'AuthException: $message';

  /// 401 Unauthorized 에러인지 확인
  bool get isUnauthorized => statusCode == 401;
}
