import 'package:flutter/foundation.dart';
import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';

import '../core/usecases/get_hint_usecase.dart';
import '../core/usecases/get_stage_usecase.dart';
import '../core/usecases/submit_answer_usecase.dart';

class QuizViewModel extends ChangeNotifier {
  final GetStageUseCase _getStageUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;
  final GetHintUseCase _getHintUseCase;

  QuizViewModel({
    required GetStageUseCase getStageUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
    required GetHintUseCase getHintUseCase,
  }) : _getStageUseCase = getStageUseCase,
       _submitAnswerUseCase = submitAnswerUseCase,
       _getHintUseCase = getHintUseCase;

  bool _isLoadingStage = false;
  bool _isSubmitting = false;
  bool _isLoadingHint = false;

  StageInfoModel? _stage;
  HintModel? _hint;
  AnswerResultModel? _lastAnswerResult;
  String? _errorMessage;

  bool get isLoadingStage => _isLoadingStage;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingHint => _isLoadingHint;

  StageInfoModel? get stage => _stage;
  HintModel? get hint => _hint;
  AnswerResultModel? get lastAnswerResult => _lastAnswerResult;
  String? get errorMessage => _errorMessage;

  Future<void> loadStage({required int episodeId, required int stageNo}) async {
    _isLoadingStage = true;
    _errorMessage = null;
    _stage = null;
    _hint = null;
    _lastAnswerResult = null;
    notifyListeners();

    try {
      _stage = await _getStageUseCase(episodeId: episodeId, stageNo: stageNo);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingStage = false;
      notifyListeners();
    }
  }

  Future<AnswerResultModel?> submitAnswer({
    required int episodeId,
    required int stageNo,
    required String answer,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _lastAnswerResult = null;
    notifyListeners();

    try {
      final result = await _submitAnswerUseCase(
        episodeId: episodeId,
        stageNo: stageNo,
        answer: answer,
      );
      _lastAnswerResult = result;
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<HintModel?> loadHint({
    required int episodeId,
    required int stageNo,
  }) async {
    _isLoadingHint = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final h = await _getHintUseCase(episodeId: episodeId, stageNo: stageNo);
      _hint = h;
      return h;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoadingHint = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// START 버튼에서 토큰/리프레시 흐름을 미리 태우기 위한 프리플라이트.
  /// auth/me를 호출하지 않고, 실제 quiz API(getStage)를 한번 호출해서
  /// 401이면 makeAuthenticatedRequest가 refresh 후 재시도하게 한다.
  Future<bool> preflightStageAccess({
    required int episodeId,
    required int stageNo,
  }) async {
    try {
      debugPrint(
        '[QuizVM] preflightStageAccess start episodeId=$episodeId stageNo=$stageNo',
      );
      await _getStageUseCase(episodeId: episodeId, stageNo: stageNo);
      debugPrint('[QuizVM] preflightStageAccess ok');
      return true;
    } catch (e) {
      debugPrint('[QuizVM] preflightStageAccess fail: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
