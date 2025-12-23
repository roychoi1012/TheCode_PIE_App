class AnswerResultModel {
  final String message;
  final bool isCorrect;

  const AnswerResultModel({required this.message, required this.isCorrect});

  factory AnswerResultModel.fromJson(Map<String, dynamic> json) {
    return AnswerResultModel(
      message: json['message'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}
