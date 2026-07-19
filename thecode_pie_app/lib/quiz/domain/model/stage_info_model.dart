import 'package:thecode_pie_app/core/constants/app_constants.dart';

class StageInfoModel {
  final String message;
  final int? episodeId;
  final String episodeCode;
  final int stageNo;
  final String title;
  final String? imageUrl;
  final int? nextStageNo;

  const StageInfoModel({
    required this.message,
    required this.episodeId,
    required this.episodeCode,
    required this.stageNo,
    required this.title,
    required this.imageUrl,
    required this.nextStageNo,
  });

  factory StageInfoModel.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url'];
    String? parsedImageUrl;
    if (rawImageUrl is String && rawImageUrl.trim().isNotEmpty) {
      parsedImageUrl = AppConstants.resolveImageUrl(rawImageUrl);
    }

    return StageInfoModel(
      message: json['message'] as String? ?? '',
      episodeId: (json['episode_id'] as num?)?.toInt(),
      episodeCode: json['episode_code'] as String? ?? '',
      stageNo: (json['stage_no'] as num).toInt(),
      title: json['title'] as String? ?? '',
      imageUrl: parsedImageUrl,
      nextStageNo: (json['next_stage_no'] as num?)?.toInt(),
    );
  }
}
