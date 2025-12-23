import '../data/repository/auth_repository.dart';
import '../domain/model/user_model.dart';

/// 현재 사용자 정보 조회 UseCase
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  /// 현재 사용자 정보 조회 실행
  ///
  /// 401 에러 발생 시 자동으로 토큰 갱신 후 재시도
  Future<UserModel?> call() async {
    return await _repository.getCurrentUser();
  }
}
