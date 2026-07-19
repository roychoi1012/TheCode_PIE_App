class StartStageModel {
  final int episodeId;
  final String episodeCode;
  final int stageNo;
  final int? highestStageNo;

  const StartStageModel({
    required this.episodeId,
    required this.episodeCode,
    required this.stageNo,
    this.highestStageNo,
  });

  factory StartStageModel.fromJson(Map<String, dynamic> json) {
    return StartStageModel(
      episodeId: (json['episode_id'] as num).toInt(),
      episodeCode: json['episode_code'] as String? ?? '',
      stageNo: (json['stage_no'] as num).toInt(),
      highestStageNo: (json['highest_stage_no'] as num?)?.toInt(),
    );
  }
}
