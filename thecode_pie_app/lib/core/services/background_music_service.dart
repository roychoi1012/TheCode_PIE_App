import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();

  factory BackgroundMusicService() => _instance;

  BackgroundMusicService._internal();

  static const String _enabledKey = 'sound_bgm_enabled';

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isInitialized = false;
  double _currentVolume = 0.5;
  bool _isDisposed = false;

  AudioPlayer get _player {
    if (_audioPlayer == null || _isDisposed) {
      _audioPlayer = AudioPlayer();
      _isDisposed = false;
      _isInitialized = false;
    }
    return _audioPlayer!;
  }

  Future<double> _loadVolume(String? userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final volumeKey = userId != null ? 'bgm_volume_$userId' : 'bgm_volume';
      return prefs.getDouble(volumeKey) ?? 0.5;
    } catch (e) {
      debugPrint('Failed to load BGM volume: $e');
      return 0.5;
    }
  }

  Future<void> play({String? userId}) async {
    if (_isPlaying) return;

    try {
      if (!await isBgmEnabled()) {
        debugPrint('Background music is disabled.');
        return;
      }

      final player = _player;

      if (!_isInitialized) {
        _currentVolume = await _loadVolume(userId);
        await player.setReleaseMode(ReleaseMode.loop);
        await player.setVolume(_currentVolume);
        _isInitialized = true;
      }

      await player.play(AssetSource('audio/blue.mp3'));
      _isPlaying = true;
      debugPrint('Background music started.');
    } catch (e) {
      debugPrint('Failed to play background music: $e');
    }
  }

  Future<void> pause() async {
    if (!_isPlaying || _audioPlayer == null) return;

    try {
      await _audioPlayer!.pause();
      _isPlaying = false;
      debugPrint('Background music paused.');
    } catch (e) {
      debugPrint('Failed to pause background music: $e');
    }
  }

  Future<void> stop() async {
    if (_audioPlayer == null) return;

    try {
      await _audioPlayer!.stop();
      _isPlaying = false;
      debugPrint('Background music stopped.');
    } catch (e) {
      debugPrint('Failed to stop background music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (_audioPlayer == null) return;

    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer!.setVolume(clampedVolume);
      _currentVolume = clampedVolume;
    } catch (e) {
      debugPrint('Failed to set BGM volume: $e');
    }
  }

  Future<void> reloadVolume(String? userId) async {
    if (_audioPlayer == null) return;

    try {
      _currentVolume = await _loadVolume(userId);
      await _audioPlayer!.setVolume(_currentVolume);
    } catch (e) {
      debugPrint('Failed to reload BGM volume: $e');
    }
  }

  Future<bool> isBgmEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_enabledKey)) {
      await prefs.setBool(_enabledKey, true);
    }
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<void> setBgmEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      await play();
    } else {
      await pause();
    }
  }

  double get currentVolume => _currentVolume;

  bool get isPlaying => _isPlaying;

  Future<void> dispose() async {
    if (_isDisposed || _audioPlayer == null) return;

    await stop();
    await _audioPlayer!.dispose();
    _audioPlayer = null;
    _isDisposed = true;
    _isInitialized = false;
    _isPlaying = false;
    debugPrint('BackgroundMusicService disposed.');
  }
}
