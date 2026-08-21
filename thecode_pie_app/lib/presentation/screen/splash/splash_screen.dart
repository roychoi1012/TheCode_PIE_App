import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:thecode_pie_app/presentation/screen/auth/auth_screen_root.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToAuth() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreenRoot()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2A41), // 기존 애니메이션 배경색과 동일하게
      body: Center(
        child: Lottie.asset(
          'assets/animation/lottie.json',
          width: 300,
          height: 300,
          controller: _controller,
          repeat: false,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(_goToAuth);
          },
        ),
      ),
    );
  }
}
