import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 백그라운드 음악 재생을 관리하는 서비스
class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();

  factory BackgroundMusicService() => _instance;

  BackgroundMusicService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;
  double _currentVolume = 0.5; // 현재 볼륨 값 추적
  bool _isDisposed = false; // dispose 상태 추적

  /// AudioPlayer 인스턴스 가져오기 (필요시 생성)
  AudioPlayer get _player {
    if (_audioPlayer == null || _isDisposed) {
      _audioPlayer = AudioPlayer();
      _isDisposed = false;
      _isInitialized = false; // 재생성 시 초기화 상태 리셋
    }
    return _audioPlayer!;
  }

  /// 저장된 볼륨 값 불러오기 (사용자 ID 기반)
  Future<double> _loadVolume(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String volumeKey;
      if (userId != null) {
        volumeKey = 'bgm_volume_$userId';
      } else {
        volumeKey = 'bgm_volume';
      }

      final savedVolume = prefs.getDouble(volumeKey);
      debugPrint('볼륨 불러오기 - 키: $volumeKey, 값: $savedVolume');

      return savedVolume ?? 0.5;
    } catch (e) {
      debugPrint('볼륨 불러오기 실패: $e');
      return 0.5;
    }
  }

  /// 음악 재생 시작 (사용자 ID를 받아서 해당 사용자의 볼륨 설정 적용)
  Future<void> play({String? userId}) async {
    if (_isPlaying) return;

    try {
      final player = _player; // 필요시 재생성

      if (!_isInitialized) {
        // 저장된 볼륨 값 불러오기
        _currentVolume = await _loadVolume(userId);

        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume(_currentVolume);
        _isInitialized = true;

        debugPrint('초기 볼륨 설정: $_currentVolume');
      }

      await player.play(AssetSource('audio/blue.mp3'));
      _isPlaying = true;
      debugPrint('백그라운드 음악 재생 시작');
    } catch (e) {
      debugPrint('백그라운드 음악 재생 실패: $e');
    }
  }

  /// 음악 일시정지
  Future<void> pause() async {
    if (!_isPlaying || _audioPlayer == null) return;

    try {
      await _audioPlayer!.pause();
      _isPlaying = false;
      debugPrint('백그라운드 음악 일시정지');
    } catch (e) {
      debugPrint('백그라운드 음악 일시정지 실패: $e');
    }
  }

  /// 음악 정지
  Future<void> stop() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
      _isPlaying = false;
      debugPrint('백그라운드 음악 정지');
    } catch (e) {
      debugPrint('백그라운드 음악 정지 실패: $e');
    }
  }

  /// 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setVolume(double volume) async {
    if (_audioPlayer == null) return;

    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer!.setVolume(clampedVolume);
      _currentVolume = clampedVolume;
      debugPrint('볼륨 설정: $clampedVolume');
    } catch (e) {
      debugPrint('볼륨 설정 실패: $e');
    }
  }

  /// 사용자 변경 시 볼륨 재로드
  Future<void> reloadVolume(String? userId) async {
    if (_audioPlayer == null) return;

    try {
      _currentVolume = await _loadVolume(userId);
      await _audioPlayer!.setVolume(_currentVolume);
      debugPrint('사용자 볼륨 재로드: $_currentVolume (userId: $userId)');
    } catch (e) {
      debugPrint('볼륨 재로드 실패: $e');
    }
  }

  /// 현재 볼륨 값 가져오기
  double get currentVolume => _currentVolume;

  /// 현재 재생 상태
  bool get isPlaying => _isPlaying;

  /// 리소스 정리
  Future<void> dispose() async {
    if (_isDisposed || _audioPlayer == null) return;

    await stop();
    await _audioPlayer!.dispose();
    _audioPlayer = null;
    _isDisposed = true;
    _isInitialized = false;
    _isPlaying = false;
    debugPrint('BackgroundMusicService disposed');
  }
}
