import 'package:provider/provider.dart';

import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/refresh_token_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

/// 의존성 주입 설정
class DependencyInjection {
  /// Repository 및 UseCase 인스턴스 생성
  static AuthRepository _createAuthRepository() {
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final localDataSource = AuthLocalDataSourceImpl();
    return AuthRepositoryImpl(remoteDataSource, localDataSource);
  }

  /// UseCase 인스턴스 생성
  static SignInUseCase _createSignInUseCase(AuthRepository repository) {
    return SignInUseCase(repository);
  }

  static SignOutUseCase _createSignOutUseCase(AuthRepository repository) {
    return SignOutUseCase(repository);
  }

  static GetCurrentUserUseCase _createGetCurrentUserUseCase(
    AuthRepository repository,
  ) {
    return GetCurrentUserUseCase(repository);
  }

  /// ViewModel 인스턴스 생성
  static AuthViewModel _createAuthViewModel() {
    final repository = _createAuthRepository();
    return AuthViewModel(
      signInUseCase: _createSignInUseCase(repository),
      signOutUseCase: _createSignOutUseCase(repository),
      getCurrentUserUseCase: _createGetCurrentUserUseCase(repository),
    );
  }

  /// Provider 목록 반환
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => _createAuthViewModel(),
    ),
  ];
}
