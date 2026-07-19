import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';

class HasHintAccessUseCase {
  final ContentsRepository _repository;
  HasHintAccessUseCase(this._repository);

  Future<bool> call({required int episodeId, required int stageNo}) {
    return _repository.hasHintAccess(episodeId: episodeId, stageNo: stageNo);
  }
}
