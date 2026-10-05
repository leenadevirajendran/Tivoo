import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralized audio service for realistic live stream gift sound effects
class GiftSoundService {
  GiftSoundService._() {
    _init();
  }

  static final GiftSoundService instance = GiftSoundService._();

  AudioPlayer? _player;
  bool _isMuted = false;
  int _playSessionId = 0;

  bool get isMuted => _isMuted;
  set isMuted(bool val) {
    _isMuted = val;
    if (_isMuted) stop();
  }

  void _init() {
    try {
      _player = AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('GiftSoundService init error: $e');
    }
  }

  /// Plays the authentic sound effect corresponding to the active gift category
  Future<void> playGiftSound(String category) async {
    if (_isMuted) return;

    final sessionId = ++_playSessionId;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      String soundFile;
      switch (category.toLowerCase()) {
        case 'horse':
          soundFile = 'sounds/sound_horse.wav';
          break;
        case 'car':
          soundFile = 'sounds/sound_car.wav';
          break;
        case 'lion':
          soundFile = 'sounds/sound_lion.wav';
          break;
        case 'rocket':
          soundFile = 'sounds/sound_rocket.wav';
          break;
        case 'yacht':
          soundFile = 'sounds/sound_yacht.wav';
          break;
        case 'whale':
          soundFile = 'sounds/sound_whale.wav';
          break;
        case 'wings':
        case 'angel_vehicle':
          soundFile = 'sounds/sound_wings.wav';
          break;
        case 'crown':
          soundFile = 'sounds/sound_crown.wav';
          break;
        case 'diamond':
        case 'meteor':
        case 'shower':
          soundFile = 'sounds/sound_diamond.wav';
          break;
        case 'rose':
        case 'flowers':
        case 'flower':
        case 'chariot':
          soundFile = 'sounds/sound_rose.wav';
          break;
        case 'castle':
        case 'world_tour':
        case 'tour':
          soundFile = 'sounds/sound_castle.wav';
          break;
        case 'love':
        case 'tiki':
          soundFile = 'sounds/sound_love.wav';
          break;
        case 'kitty':
        case 'teddy':
        case 'cat':
        case 'panda':
          soundFile = 'sounds/sound_kitty.wav';
          break;
        case 'cake':
          soundFile = 'sounds/sound_cake.wav';
          break;
        default:
          soundFile = 'sounds/sound_generic.wav';
      }

      if (_playSessionId != sessionId) return;

      // In browsers, directly set source and play without calling stop() immediately beforehand
      await _player?.play(AssetSource(soundFile), volume: 1.0);
    } catch (e) {
      // Ignored for harmless browser playback interruption
      if (!kIsWeb) {
        debugPrint('GiftSoundService non-critical play note: $e');
      }
    }
  }

  /// Stops current playing audio immediately (e.g. when skipped or overlay closed)
  Future<void> stop() async {
    _playSessionId++;
    try {
      await _player?.stop();
    } catch (_) {}
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
