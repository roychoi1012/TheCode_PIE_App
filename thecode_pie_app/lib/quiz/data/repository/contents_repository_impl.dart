import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thecode_pie_app/core/constants/app_constants.dart';
import 'package:thecode_pie_app/auth/data/repository/auth_repository.dart';

import '../../domain/model/answer_result_model.dart';
import '../../domain/model/hint_model.dart';
import '../../domain/model/progress_update_model.dart';
import '../../domain/model/start_stage_model.dart';
import '../../domain/model/stage_info_model.dart';
import 'contents_repository.dart';
import '../data_source/contents_data_source.dart';

class ContentsRepositoryImpl implements ContentsRepository {
  final ContentsRemoteDataSource _remote;
  final AuthRepository _authRepository;

  ContentsRepositoryImpl(this._remote, this._authRepository);

  Map<String, dynamic> _decodeBody(http.Response response) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _preview(String s, {int max = 400}) =>
      s.length <= max ? s : '${s.substring(0, max)}... (truncated)';

  Never _throwServerError(http.Response response) {
    try {
      final decoded = _decodeBody(response);
      final message =
          decoded['message'] as String? ??
          decoded['data']?['message'] as String? ??
          '서버 응답 오류 (${response.statusCode})';
      throw Exception(message);
    } catch (_) {
      throw Exception('서버 응답 오류 (${response.statusCode}): ${response.body}');
    }
  }

  @override
  Future<StartStageModel> getStartStage() async {
    debugPrint(
      '[ContentsRepo] getStartStage start url=${AppConstants.startStageEndpoint}',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.getStartStage(accessToken: accessToken);
    });

    debugPrint(
      '[ContentsRepo] getStartStage response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? 'Start stage is not available.');
    }

    return StartStageModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProgressUpdateModel> completeStage({
    required int episodeId,
    required int stageNo,
  }) async {
    debugPrint(
      '[ContentsRepo] completeStage start url=${AppConstants.completeStageEndpoint}',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.completeStage(
        accessToken: accessToken,
        episodeId: episodeId,
        stageNo: stageNo,
      );
    });

    debugPrint(
      '[ContentsRepo] completeStage response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? 'Stage progress update failed.');
    }

    return ProgressUpdateModel.fromJson(
      decoded['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<StageInfoModel> getStage({
    required int episodeId,
    required int stageNo,
  }) async {
    debugPrint(
      '[ContentsRepo] getStage start baseUrl=${AppConstants.baseUrl} url=${AppConstants.stageEndpoint(episodeId, stageNo)}',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.getStage(
        accessToken: accessToken,
        episodeId: episodeId,
        stageNo: stageNo,
      );
    });

    debugPrint(
      '[ContentsRepo] getStage response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? '스테이지 정보를 가져올 수 없습니다.');
    }

    return StageInfoModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  @override
  Future<AnswerResultModel> submitAnswer({
    required int episodeId,
    required int stageNo,
    required String answer,
  }) async {
    final normalized = answer.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (normalized.isEmpty) {
      throw Exception('정답을 입력해주세요.');
    }

    debugPrint(
      '[ContentsRepo] submitAnswer start url=${AppConstants.answerEndpoint(episodeId, stageNo)} normalized="$normalized"',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.submitAnswer(
        accessToken: accessToken,
        episodeId: episodeId,
        stageNo: stageNo,
        answer: normalized,
      );
    });

    debugPrint(
      '[ContentsRepo] submitAnswer response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? '정답 제출에 실패했습니다.');
    }

    return AnswerResultModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  @override
  Future<HintModel> getHint({
    required int episodeId,
    required int stageNo,
  }) async {
    debugPrint(
      '[ContentsRepo] getHint start url=${AppConstants.hintEndpoint(episodeId, stageNo)}',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.getHint(
        accessToken: accessToken,
        episodeId: episodeId,
        stageNo: stageNo,
      );
    });

    debugPrint(
      '[ContentsRepo] getHint response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(decoded['message'] ?? '힌트 정보를 가져올 수 없습니다.');
    }

    return HintModel.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  @override
  Future<bool> hasHintAccess({
    required int episodeId,
    required int stageNo,
  }) async {
    debugPrint(
      '[ContentsRepo] hasHintAccess start url=${AppConstants.hintAccessEndpoint(episodeId, stageNo)}',
    );
    final response = await _authRepository.makeAuthenticatedRequest((
      accessToken,
    ) async {
      return _remote.hasHintAccess(
        accessToken: accessToken,
        episodeId: episodeId,
        stageNo: stageNo,
      );
    });

    debugPrint(
      '[ContentsRepo] hasHintAccess response status=${response.statusCode} contentType=${response.headers['content-type']} body=${_preview(response.body)}',
    );
    if (response.statusCode != 200) {
      _throwServerError(response);
    }

    final decoded = _decodeBody(response);
    if (decoded['success'] != true || decoded['data'] == null) {
      throw Exception(
        decoded['message'] ?? 'Hint access status is not available.',
      );
    }

    final data = decoded['data'] as Map<String, dynamic>;
    return data['has_access'] == true;
  }
}
