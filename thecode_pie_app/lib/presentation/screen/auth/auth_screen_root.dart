import 'package:flutter/material.dart';
import 'auth_screen.dart';

/// 로그인 화면 루트 위젯
/// AuthViewModel은 MultiProvider에서 이미 제공됨
class AuthScreenRoot extends StatelessWidget {
  const AuthScreenRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
