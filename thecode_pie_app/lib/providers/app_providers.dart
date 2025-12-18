import 'package:provider/provider.dart';
import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';

import '../core/api/auth_api.dart';
import '../core/storage/auth_storage.dart';
import '../quiz/data/data_source/contents_data_source.dart';
import '../auth/data/repository/auth_repository.dart';
import '../auth/data/repository/auth_repository_impl.dart';
import '../quiz/data/repository/contents_repository_impl.dart';
import '../auth/usecase/sign_in_usecase.dart';
import '../auth/usecase/sign_out_usecase.dart';
import '../auth/usecase/get_current_user_usecase.dart';
import '../core/usecases/get_stage_usecase.dart';
import '../core/usecases/submit_answer_usecase.dart';
import '../core/usecases/get_hint_usecase.dart';
import '../presentation/screen/auth/auth_view_model.dart';
import '../presentation/screen/quiz/quiz_view_model.dart';

/// 의존성 주입 설정
class DependencyInjection {
  /// Repository 및 UseCase 인스턴스 생성
  static final AuthRepository _authRepository = (() {
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final localDataSource = AuthLocalDataSourceImpl();
    return AuthRepositoryImpl(remoteDataSource, localDataSource);
  })();

  static final ContentsRepository _contentsRepository = (() {
    final remoteDataSource = ContentsRemoteDataSourceImpl();
    return ContentsRepositoryImpl(remoteDataSource, _authRepository);
  })();

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

  /// Provider 인스턴스 생성
  static AuthViewModel _createAuthViewModel() {
    return AuthViewModel(
      signInUseCase: _createSignInUseCase(_authRepository),
      signOutUseCase: _createSignOutUseCase(_authRepository),
      getCurrentUserUseCase: _createGetCurrentUserUseCase(_authRepository),
    );
  }

  static QuizViewModel _createQuizViewModel() {
    return QuizViewModel(
      getStageUseCase: GetStageUseCase(_contentsRepository),
      submitAnswerUseCase: SubmitAnswerUseCase(_contentsRepository),
      getHintUseCase: GetHintUseCase(_contentsRepository),
    );
  }

  /// QuizViewModel 인스턴스 생성 (외부에서 사용 가능)
  static QuizViewModel createQuizViewModel() {
    return _createQuizViewModel();
  }

  /// Provider 목록 반환
  static List<ChangeNotifierProvider> get providers => [
    ChangeNotifierProvider<AuthViewModel>(
      create: (_) => _createAuthViewModel(),
    ),
    ChangeNotifierProvider<QuizViewModel>(
      create: (_) => _createQuizViewModel(),
    ),
  ];
}
