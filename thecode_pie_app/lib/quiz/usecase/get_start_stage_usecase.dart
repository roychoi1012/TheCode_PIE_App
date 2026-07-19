import 'package:thecode_pie_app/quiz/data/repository/contents_repository.dart';
import 'package:thecode_pie_app/quiz/domain/model/start_stage_model.dart';

class GetStartStageUseCase {
  final ContentsRepository _repository;

  GetStartStageUseCase(this._repository);

  Future<StartStageModel> call() {
    return _repository.getStartStage();
  }
}
