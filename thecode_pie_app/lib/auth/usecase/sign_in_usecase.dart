import '../data/repository/auth_repository.dart';
import '../domain/model/auth_response_model.dart';

/// Google 로그인 UseCase
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase(this._repository);

  /// Google 로그인 실행
  ///
  /// 반환: AuthResponseModel (성공 시) 또는 null (사용자 취소 시)
  /// 예외: Exception (로그인 실패 시)
  Future<AuthResponseModel?> call() async {
    return await _repository.signInWithGoogle();
  }
}
