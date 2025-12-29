import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/core/constants/app_constants.dart';

abstract class ContentsRemoteDataSource {
  Future<http.Response> getStage({
    required String accessToken,
    required int episodeId,
    required int stageNo,
  });

  Future<http.Response> submitAnswer({
    required String accessToken,
    required int episodeId,
    required int stageNo,
    required String answer,
  });

  Future<http.Response> getHint({
    required String accessToken,
    required int episodeId,
    required int stageNo,
  });
}

class ContentsRemoteDataSourceImpl implements ContentsRemoteDataSource {
  @override
  Future<http.Response> getStage({
    required String accessToken,
    required int episodeId,
    required int stageNo,
  }) {
    final url = AppConstants.stageEndpoint(episodeId, stageNo);
    debugPrint(
      '[ContentsRemote] GET stage url=$url tokenLen=${accessToken.length}',
    );
    return http
        .get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        )
        .timeout(AppConstants.connectTimeout);
  }

  @override
  Future<http.Response> submitAnswer({
    required String accessToken,
    required int episodeId,
    required int stageNo,
    required String answer,
  }) {
    final url = AppConstants.answerEndpoint(episodeId, stageNo);
    debugPrint(
      '[ContentsRemote] POST answer url=$url tokenLen=${accessToken.length} body=${jsonEncode({'answer': answer})}',
    );
    return http
        .post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'answer': answer}),
        )
        .timeout(AppConstants.connectTimeout);
  }

  @override
  Future<http.Response> getHint({
    required String accessToken,
    required int episodeId,
    required int stageNo,
  }) {
    final url = AppConstants.hintEndpoint(episodeId, stageNo);
    debugPrint(
      '[ContentsRemote] GET hint url=$url tokenLen=${accessToken.length}',
    );
    return http
        .get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        )
        .timeout(AppConstants.connectTimeout);
  }
}
