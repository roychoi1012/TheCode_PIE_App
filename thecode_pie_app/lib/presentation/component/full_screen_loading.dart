import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 문제 진입 / 스테이지 전환 시 공통으로 쓰는 풀스크린 로딩
class FullScreenLoading extends StatelessWidget {
  const FullScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDB8315), // 기존 배경색과 맞추기
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Lottie.asset(
          'assets/animation/lottie2.json',
          width: 350,
          height: 350,
          repeat: true,
        ),
      ),
    );
  }
}
