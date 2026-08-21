import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';
import 'package:thecode_pie_app/core/usecases/get_hint_usecase.dart';
import 'package:thecode_pie_app/core/usecases/get_stage_usecase.dart';
import 'package:thecode_pie_app/core/usecases/submit_answer_usecase.dart';
import 'package:thecode_pie_app/quiz/data/data_source/progress_storage.dart';
import 'package:thecode_pie_app/quiz/domain/model/progress_update_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/start_stage_model.dart';
import 'package:thecode_pie_app/quiz/usecase/complete_stage_usecase.dart';
import 'package:thecode_pie_app/quiz/usecase/get_start_stage_usecase.dart';
import 'package:thecode_pie_app/quiz/usecase/has_hint_access_usecase.dart';

class QuizViewModel extends ChangeNotifier {
  final GetStartStageUseCase _getStartStageUseCase;
  final GetStageUseCase _getStageUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;
  final GetHintUseCase _getHintUseCase;
  final HasHintAccessUseCase _hasHintAccessUseCase;
  final CompleteStageUseCase _completeStageUseCase;

  QuizViewModel({
    required GetStartStageUseCase getStartStageUseCase,
    required GetStageUseCase getStageUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
    required GetHintUseCase getHintUseCase,
    required HasHintAccessUseCase hasHintAccessUseCase,
    required CompleteStageUseCase completeStageUseCase,
  }) : _getStartStageUseCase = getStartStageUseCase,
       _getStageUseCase = getStageUseCase,
       _submitAnswerUseCase = submitAnswerUseCase,
       _getHintUseCase = getHintUseCase,
       _hasHintAccessUseCase = hasHintAccessUseCase,
       _completeStageUseCase = completeStageUseCase;

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

  Future<bool> hasHintAccess({
    required int episodeId,
    required int stageNo,
  }) async {
    _isLoadingHint = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _hasHintAccessUseCase(
        episodeId: episodeId,
        stageNo: stageNo,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoadingHint = false;
      notifyListeners();
    }
  }

  Future<bool> waitForHintAccess({
    required int episodeId,
    required int stageNo,
    int attempts = 6,
    Duration delay = const Duration(seconds: 1),
  }) async {
    _isLoadingHint = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (var attempt = 0; attempt < attempts; attempt++) {
        final hasAccess = await _hasHintAccessUseCase(
          episodeId: episodeId,
          stageNo: stageNo,
        );
        if (hasAccess) {
          _errorMessage = null; // 성공 시 이전에 남아있을 수 있는 에러 메시지 제거
          return true;
        }
        if (attempt < attempts - 1) {
          await Future.delayed(delay);
        }
      }

      _errorMessage = '광고 보상 확인이 아직 도착하지 않았어요. 잠시 후 HINT를 다시 눌러주세요.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
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
  Future<StartStageModel> resolveStartProgress() async {
    _isLoadingStage = true;
    _errorMessage = null;
    notifyListeners();

    const totalStageCount = 50; // TODO: AppConstants로 중앙화 권장

    try {
      final start = await _getStartStageUseCase();

      final localClearedStageNo = await ProgressStorage.getLastClearedStageNo(
        episodeId: start.episodeId,
      );

      // "서버가 마지막 스테이지에서 다음으로 안 넘어가는" 특수 케이스에서만
      // 로컬 클리어 기록으로 보정한다. 서버가 그보다 낮은 값을 주면
      // (예: 관리자가 진행도를 되돌린 경우) 무조건 서버 값을 그대로 신뢰한다.
      final isServerStuckAtLastStage = start.stageNo >= totalStageCount;
      final wasFinalStageClearedLocally =
          localClearedStageNo >= totalStageCount;

      final resolvedStart =
          isServerStuckAtLastStage && wasFinalStageClearedLocally
          ? StartStageModel(
              episodeId: start.episodeId,
              episodeCode: start.episodeCode,
              stageNo: totalStageCount + 1,
              highestStageNo: totalStageCount + 1,
            )
          : start;

      await ProgressStorage.saveLastProgress(
        episodeId: resolvedStart.episodeId,
        stageNo: resolvedStart.stageNo,
      );
      // 서버 값(또는 위에서 보정된 값)을 로컬 캐시에도 그대로 덮어써서
      // 캐시가 서버와 어긋난 채로 남지 않게 한다.
      await ProgressStorage.setLastClearedStageNo(
        episodeId: resolvedStart.episodeId,
        stageNo: resolvedStart.stageNo > 1 ? resolvedStart.stageNo - 1 : 0,
      );

      debugPrint(
        '[QuizVM] resolved start episodeId=${resolvedStart.episodeId} '
        'stageNo=${resolvedStart.stageNo} (server=${start.stageNo}, '
        'localCleared=$localClearedStageNo)',
      );
      return resolvedStart;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoadingStage = false;
      notifyListeners();
    }
  }

  Future<ProgressUpdateModel?> completeStage({
    required int episodeId,
    required int stageNo,
  }) async {
    try {
      final progress = await _completeStageUseCase(
        episodeId: episodeId,
        stageNo: stageNo,
      );
      await ProgressStorage.saveLastProgress(
        episodeId: progress.episodeId,
        stageNo: progress.currentStageNo,
      );
      await ProgressStorage.markStageCleared(
        episodeId: progress.episodeId,
        stageNo: progress.stageNo,
      );
      return progress;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

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
