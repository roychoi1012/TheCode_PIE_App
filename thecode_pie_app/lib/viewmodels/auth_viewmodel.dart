import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// 인증 ViewModel (상태 관리 및 비즈니스 로직)
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// 구글 로그인
  Future<bool> signInWithGoogle() async {
    debugPrint('[ViewModel] signInWithGoogle() 호출됨');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('[ViewModel] AuthService.signInWithGoogle() 호출 중...');
      final response = await _authService.signInWithGoogle();
      debugPrint('[ViewModel] AuthService.signInWithGoogle() 완료');

      if (response != null) {
        debugPrint('[ViewModel] ✅ 로그인 성공 - 사용자 정보 저장');
        debugPrint('[ViewModel] User ID: ${response.user.id}');
        debugPrint('[ViewModel] User Email: ${response.user.email}');
        _currentUser = response.user;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        debugPrint('[ViewModel] 사용자가 로그인을 취소했습니다.');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('[ViewModel] ❌ ========== ViewModel에서 에러 발생 ==========');
      debugPrint('[ViewModel] ❌ 오류 타입: ${e.runtimeType}');
      debugPrint('[ViewModel] ❌ 오류 메시지: $e');
      debugPrint('[ViewModel] ❌ 스택 트레이스:');
      debugPrint('[ViewModel] $stackTrace');
      debugPrint('[ViewModel] ❌ ===========================================');
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
      await _authService.signOut();
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

  /// 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
