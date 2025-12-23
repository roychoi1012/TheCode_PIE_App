import '../domain/model/stage_info_model.dart';
import '../data/repository/contents_repository.dart';

class GetStageUseCase {
  final ContentsRepository _repository;
  GetStageUseCase(this._repository);

  Future<StageInfoModel> call({required int episodeId, required int stageNo}) {
    return _repository.getStage(episodeId: episodeId, stageNo: stageNo);
  }
}
