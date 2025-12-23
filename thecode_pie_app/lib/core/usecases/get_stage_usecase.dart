import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';

class GetStageUseCase {
  final ContentsRepository _repository;
  GetStageUseCase(this._repository);

  Future<StageInfoModel> call({required int episodeId, required int stageNo}) {
    return _repository.getStage(episodeId: episodeId, stageNo: stageNo);
  }
}
