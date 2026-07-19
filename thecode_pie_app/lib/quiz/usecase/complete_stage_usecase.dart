import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';
import 'package:thecode_pie_app/quiz/domain/model/progress_update_model.dart';

class CompleteStageUseCase {
  final ContentsRepository _repository;

  CompleteStageUseCase(this._repository);

  Future<ProgressUpdateModel> call({
    required int episodeId,
    required int stageNo,
  }) {
    return _repository.completeStage(episodeId: episodeId, stageNo: stageNo);
  }
}
