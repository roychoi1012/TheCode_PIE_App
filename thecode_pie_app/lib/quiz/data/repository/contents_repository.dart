import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';

abstract class ContentsRepository {
  Future<StageInfoModel> getStage({
    required int episodeId,
    required int stageNo,
  });

  Future<AnswerResultModel> submitAnswer({
    required int episodeId,
    required int stageNo,
    required String answer,
  });

  Future<HintModel> getHint({required int episodeId, required int stageNo});
}
