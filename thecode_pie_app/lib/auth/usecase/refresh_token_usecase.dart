import '../data/repository/auth_repository.dart';

/// Access Token 갱신 UseCase
class RefreshTokenUseCase {
  final AuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  /// Refresh Token을 사용하여 Access Token 재발급
  Future<String?> call() async {
    return await _repository.refreshAccessToken();
  }
}
