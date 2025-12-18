import 'package:thecode_pie_app/quiz/domain/model/answer_result_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/hint_model.dart';
import 'package:thecode_pie_app/quiz/domain/model/stage_info_model.dart';

/// 퀴즈 화면 상태
class QuizState {
  final bool isLoadingStage;
  final bool isSubmitting;
  final bool isLoadingHint;
  final StageInfoModel? stage;
  final HintModel? hint;
  final AnswerResultModel? lastAnswerResult;
  final String? errorMessage;

  const QuizState({
    this.isLoadingStage = false,
    this.isSubmitting = false,
    this.isLoadingHint = false,
    this.stage,
    this.hint,
    this.lastAnswerResult,
    this.errorMessage,
  });

  QuizState copyWith({
    bool? isLoadingStage,
    bool? isSubmitting,
    bool? isLoadingHint,
    StageInfoModel? stage,
    HintModel? hint,
    AnswerResultModel? lastAnswerResult,
    String? errorMessage,
    bool clearError = false,
    bool clearStage = false,
    bool clearHint = false,
    bool clearAnswerResult = false,
  }) {
    return QuizState(
      isLoadingStage: isLoadingStage ?? this.isLoadingStage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingHint: isLoadingHint ?? this.isLoadingHint,
      stage: clearStage ? null : (stage ?? this.stage),
      hint: clearHint ? null : (hint ?? this.hint),
      lastAnswerResult: clearAnswerResult
          ? null
          : (lastAnswerResult ?? this.lastAnswerResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
