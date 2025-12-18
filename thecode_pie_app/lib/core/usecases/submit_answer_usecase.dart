import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';
import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';

class SubmitAnswerUseCase {
  final ContentsRepository _repository;
  SubmitAnswerUseCase(this._repository);

  Future<AnswerResultModel> call({
    required int episodeId,
    required int stageNo,
    required String answer,
  }) {
    return _repository.submitAnswer(
      episodeId: episodeId,
      stageNo: stageNo,
      answer: answer,
    );
  }
}
