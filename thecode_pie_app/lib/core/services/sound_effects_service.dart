import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();

  factory SoundEffectsService() => _instance;

  SoundEffectsService._internal();

  static const String _enabledKey = 'sound_effect_enabled';
  static const String _vibrationKey = 'sound_vibration_enabled';
  static const MethodChannel _vibrationChannel = MethodChannel(
    'com.clavis.thecodearc/vibration',
  );
  static const double _selectVolume = 0.45;
  static const double _resultVolume = 0.85;
  static final AudioContext _effectContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
  );
  final Set<AudioPlayer> _activePlayers = {};

  Future<void> playSelect() async {
    await _play('audio/sfx/select.ogg', volume: _selectVolume);
  }

  Future<void> playCorrect() async {
    await Future.wait([
      _play('audio/sfx/correct.ogg', volume: _resultVolume),
      _vibrate('correct'),
    ]);
  }

  Future<void> playWrong() async {
    await Future.wait([
      _play('audio/sfx/wrong.ogg', volume: _resultVolume),
      _vibrate('wrong'),
    ]);
  }

  VoidCallback? withSelect(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      playSelect();
      callback();
    };
  }

  Future<void> _play(String path, {required double volume}) async {
    AudioPlayer? player;
    StreamSubscription<void>? subscription;
    try {
      if (!await _isEffectSoundEnabled()) return;

      player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setAudioContext(_effectContext);
      _activePlayers.add(player);
      subscription = player.onPlayerComplete.listen((_) async {
        await subscription?.cancel();
        _activePlayers.remove(player);
        await player?.dispose();
      });
      await player.play(AssetSource(path), volume: volume, ctx: _effectContext);
    } catch (e) {
      if (player != null) {
        await subscription?.cancel();
        _activePlayers.remove(player);
        await player.dispose();
      }
      debugPrint('Failed to play sound effect: $e');
    }
  }

  Future<void> _vibrate(String pattern) async {
    try {
      if (!await _isVibrationEnabled()) return;
      await _vibrationChannel.invokeMethod<void>('vibrate', {
        'pattern': pattern,
      });
    } catch (e) {
      debugPrint('Failed to vibrate: $e');
    }
  }

  Future<bool> _isEffectSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_enabledKey)) {
      await prefs.setBool(_enabledKey, true);
    }
    return prefs.getBool(_enabledKey) ?? true;
  }

  Future<bool> _isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_vibrationKey)) {
      await prefs.setBool(_vibrationKey, true);
    }
    return prefs.getBool(_vibrationKey) ?? true;
  }
}
