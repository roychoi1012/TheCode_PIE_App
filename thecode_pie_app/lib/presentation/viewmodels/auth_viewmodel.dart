import 'package:flutter/foundation.dart';

import '../../domain/entities/user_model.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

/// 인증 ViewModel (UI 상태 관리)
class AuthViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthViewModel({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _signInUseCase = signInUseCase,
       _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase;

  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _signInUseCase();

      // 사용자가 로그인 취소
      if (authResponse == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 서버 인증 성공
      _currentUser = authResponse.user;

      // 로그인 성공 후 Access Token 유효성 확인 (auth/me 호출)
      debugPrint('로그인 성공 후 Access Token 유효성 확인 시작');
      try {
        await loadCurrentUser();
        debugPrint('✅ 로그인 후 Access Token 유효성 확인 성공');
      } catch (e) {
        debugPrint('⚠️ 로그인 후 Access Token 유효성 확인 실패: $e');
        // 유효성 확인 실패해도 로그인은 성공한 상태이므로 계속 진행
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _signOutUseCase();
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 현재 사용자 정보 조회 (auth/me를 통해 Access Token 유효성 확인)
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('loadCurrentUser 시작 - Access Token 유효성 확인');
      final user = await _getCurrentUserUseCase();
      _currentUser = user;
      _errorMessage = null;
      debugPrint('✅ Access Token 유효성 확인 성공 - 사용자: ${user?.email}');
    } catch (e) {
      debugPrint('❌ Access Token 유효성 확인 실패: $e');
      _errorMessage = e.toString();
      // 토큰이 유효하지 않으면 현재 사용자 정보 초기화
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 앱 시작 시 Access Token 유효성 확인
  /// 저장된 토큰이 있으면 auth/me를 호출하여 유효성 확인
  Future<void> checkTokenValidity() async {
    debugPrint('=== 앱 시작 시 Access Token 유효성 확인 시작 ===');
    try {
      await loadCurrentUser();
      if (_currentUser != null) {
        debugPrint('✅ 저장된 Access Token이 유효합니다. 자동 로그인 성공');
      } else {
        debugPrint('⚠️ 저장된 Access Token이 없거나 유효하지 않습니다.');
      }
    } catch (e) {
      debugPrint('❌ Access Token 유효성 확인 중 오류: $e');
    }
    debugPrint('=== Access Token 유효성 확인 완료 ===');
  }

  /// 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
