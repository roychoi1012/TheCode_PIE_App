import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/progress_update_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/start_stage_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';

abstract class ContentsRepository {
  Future<StartStageModel> getStartStage();

  Future<ProgressUpdateModel> completeStage({
    required int episodeId,
    required int stageNo,
  });

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

  Future<bool> hasHintAccess({required int episodeId, required int stageNo});
}
