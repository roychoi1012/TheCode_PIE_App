import 'package:flutter/material.dart';
import 'full_screen_loading.dart';

/// 다음 화면을 준비하는 동안 풀스크린 애니메이션을 보여주고,
/// 준비가 끝나면 자동으로 해당 화면으로 교체됨
class LoadingTransitionScreen extends StatefulWidget {
  const LoadingTransitionScreen({super.key, required this.loadNextScreen});

  /// 비동기 작업 후 다음에 보여줄 위젯을 반환
  final Future<Widget> Function() loadNextScreen;

  @override
  State<LoadingTransitionScreen> createState() =>
      _LoadingTransitionScreenState();
}

class _LoadingTransitionScreenState extends State<LoadingTransitionScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    final results = await Future.wait([
      widget.loadNextScreen(),
      Future.delayed(const Duration(milliseconds: 2500)), // 애니메이션 최소 노출 시간
    ]);

    if (!mounted) return;

    final nextScreen = results[0] as Widget;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: FullScreenLoading());
  }
}
