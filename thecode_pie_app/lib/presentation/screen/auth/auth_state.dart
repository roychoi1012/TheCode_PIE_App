import '../../../auth/domain/model/user_model.dart';

/// 로그인 화면 상태
class LoginState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
  });

  bool get isAuthenticated => currentUser != null;

  LoginState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
