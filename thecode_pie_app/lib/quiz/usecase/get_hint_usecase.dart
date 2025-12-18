import '../domain/model/hint_model.dart';
import '../data/repository/contents_repository.dart';

class GetHintUseCase {
  final ContentsRepository _repository;
  GetHintUseCase(this._repository);

  Future<HintModel> call({required int episodeId, required int stageNo}) {
    return _repository.getHint(episodeId: episodeId, stageNo: stageNo);
  }
}
