class ProgressUpdateModel {
  final int episodeId;
  final String episodeCode;
  final int stageNo;
  final int? nextStageNo;
  final int currentStageNo;
  final int highestStageNo;
  final bool isCleared;

  const ProgressUpdateModel({
    required this.episodeId,
    required this.episodeCode,
    required this.stageNo,
    required this.nextStageNo,
    required this.currentStageNo,
    required this.highestStageNo,
    required this.isCleared,
  });

  factory ProgressUpdateModel.fromJson(Map<String, dynamic> json) {
    return ProgressUpdateModel(
      episodeId: (json['episode_id'] as num).toInt(),
      episodeCode: json['episode_code'] as String? ?? '',
      stageNo: (json['stage_no'] as num).toInt(),
      nextStageNo: (json['next_stage_no'] as num?)?.toInt(),
      currentStageNo: (json['current_stage_no'] as num).toInt(),
      highestStageNo: (json['highest_stage_no'] as num).toInt(),
      isCleared: json['is_cleared'] == true,
    );
  }
}
