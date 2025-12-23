class HintModel {
  final String message;
  final String content;

  const HintModel({required this.message, required this.content});

  factory HintModel.fromJson(Map<String, dynamic> json) {
    return HintModel(
      message: json['message'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }
}
