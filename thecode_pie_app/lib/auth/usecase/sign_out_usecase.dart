import '../data/repository/auth_repository.dart';

/// 로그아웃 UseCase
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  /// 로그아웃 실행
  Future<void> call() async {
    return await _repository.signOut();
  }
}
