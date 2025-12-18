import 'package:shared_preferences/shared_preferences.dart';
import 'package:thecode_pie_app/constants/app_constants.dart';

/// 진행 상황 저장소 (Static 클래스 - 기존 로직 유지)
class ProgressStorage {
  static String _clearedKey(int episodeId) =>
      '${AppConstants.lastClearedStageNoKey}_$episodeId';

  static Future<(int episodeId, int stageNo)> getLastProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final episodeId = prefs.getInt(AppConstants.lastEpisodeIdKey) ?? 1;
    final stageNo = prefs.getInt(AppConstants.lastStageNoKey) ?? 1;
    return (episodeId, stageNo);
  }

  static Future<void> saveLastProgress({
    required int episodeId,
    required int stageNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.lastEpisodeIdKey, episodeId);
    await prefs.setInt(AppConstants.lastStageNoKey, stageNo);
  }

  static Future<int> getLastClearedStageNo({required int episodeId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_clearedKey(episodeId)) ?? 0;
  }

  static Future<void> markStageCleared({
    required int episodeId,
    required int stageNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _clearedKey(episodeId);
    final current = prefs.getInt(key) ?? 0;
    if (stageNo > current) {
      await prefs.setInt(key, stageNo);
    }
  }
}
