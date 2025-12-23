import 'package:flutter/material.dart';
import 'quiz_screen.dart';

/// 퀴즈 화면 루트 위젯 (ViewModel과 Screen 연결)
/// QuizViewModel은 Navigator.push 시점에 ChangeNotifierProvider로 제공됨
class QuizScreenRoot extends StatelessWidget {
  final int episodeId;
  final int stageNo;

  const QuizScreenRoot({
    super.key,
    required this.episodeId,
    required this.stageNo,
  });

  @override
  Widget build(BuildContext context) {
    // QuizViewModel은 Navigator.push 시점에 ChangeNotifierProvider로 제공되므로
    // 여기서는 직접 QuizScreen을 반환
    return QuizScreen(episodeId: episodeId, stageNo: stageNo);
  }
}
