/// 로그인 화면 액션
abstract class AuthAction {}

class SignInWithGoogleAction extends AuthAction {}

class SignOutAction extends AuthAction {}

class LoadCurrentUserAction extends AuthAction {}

class CheckTokenValidityAction extends AuthAction {}

class ClearErrorAction extends AuthAction {}
