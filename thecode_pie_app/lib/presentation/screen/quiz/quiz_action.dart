/// 퀴즈 화면 액션
abstract class QuizAction {}

class LoadStageAction extends QuizAction {
  final int episodeId;
  final int stageNo;

  LoadStageAction({required this.episodeId, required this.stageNo});
}

class SubmitAnswerAction extends QuizAction {
  final int episodeId;
  final int stageNo;
  final String answer;

  SubmitAnswerAction({
    required this.episodeId,
    required this.stageNo,
    required this.answer,
  });
}

class LoadHintAction extends QuizAction {
  final int episodeId;
  final int stageNo;

  LoadHintAction({required this.episodeId, required this.stageNo});
}

class ClearErrorAction extends QuizAction {}

class PreflightStageAccessAction extends QuizAction {
  final int episodeId;
  final int stageNo;

  PreflightStageAccessAction({required this.episodeId, required this.stageNo});
}


