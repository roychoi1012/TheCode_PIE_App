import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';

class GetHintUseCase {
  final ContentsRepository _repository;
  GetHintUseCase(this._repository);

  Future<HintModel> call({required int episodeId, required int stageNo}) {
    return _repository.getHint(episodeId: episodeId, stageNo: stageNo);
  }
}
