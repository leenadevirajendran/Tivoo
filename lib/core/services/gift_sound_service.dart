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
  void toggleMute() {
    isMuted = !_isMuted;
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
        case 'dolphin':
        case 'ocean_dolphin':
          soundFile = 'sounds/sound_whale.wav';
          break;
        case 'diamond_wings':
        case 'wings':
          soundFile = 'sounds/sound_diamond_wings.wav';
          break;
        case 'angel_vehicle':
          soundFile = 'sounds/sound_wings.wav';
          break;
        case 'crown':
          soundFile = 'sounds/sound_crown.wav';
          break;
        case 'throne':
          soundFile = 'sounds/sound_throne.wav';
          break;
        case 'diamond':
        case 'meteor':
        case 'shower':
        case 'shooting_star':
          soundFile = 'sounds/sound_diamond.wav';
          break;
        case 'roses':
          soundFile = 'sounds/sound_roses.wav';
          break;
        case 'rose':
        case 'flowers':
        case 'flower':
        case 'chariot':
          soundFile = 'sounds/sound_rose.wav';
          break;
        case 'castle':
        case 'love_castle':
          soundFile = 'sounds/sound_love_castle.wav';
          break;
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

  AudioPlayer? _sfxPlayer;

  /// Plays a secondary sound effect without cutting off the main channel
  Future<void> playChime() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_diamond.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays a galloping or neigh burst
  Future<void> playHorseNeigh() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_horse.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays a powerful wing flap whoosh
  Future<void> playWingFlap() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_wings.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays a glass / crystal shatter sound
  Future<void> playGlassShatter() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_diamond.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays romantic chimes
  Future<void> playRomanticChimes() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_rose.wav'), volume: 1.0);
    } catch (_) {}
  }


  /// Plays fast whoosh streak sound
  Future<void> playFastWhoosh() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_wings.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays magical sparkle chime
  Future<void> playMagicSparkle() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_diamond.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints matching the 6 stages of the Luxury Car animation (high-res MP3)
  static const String onlineCarFullAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/2/23/Ferrari_F355_under-hood_exhaust_sound.ogg/Ferrari_F355_under-hood_exhaust_sound.ogg.mp3';
  static const String onlineCarAccelerationUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/8/8a/Ferrari_250_GTO%2C_Engine_Sound.ogg/Ferrari_250_GTO%2C_Engine_Sound.ogg.mp3';

  /// Plays the complete 10-second master audio track for the 3D Car animation matching the storyboard
  Future<void> playCarMasterAudio({bool preferOnline = true}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineCarFullAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_car.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays the specific stage sound effect for the 3D Car animation:
  /// 1: Engine Start | 2: Engine Rev | 3: Speed Drive | 4: Drift Sound | 5: Celebration Music | 6: Exit Sound
  Future<void> playCarStageSound(int stage) async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      String asset;
      switch (stage) {
        case 1:
          asset = 'sounds/sound_car_start.wav';
          break;
        case 2:
          asset = 'sounds/sound_car_rev.wav';
          break;
        case 3:
          asset = 'sounds/sound_car_drive.wav';
          break;
        case 4:
          asset = 'sounds/sound_car_drift.wav';
          break;
        case 5:
          asset = 'sounds/sound_car_celebration.wav';
          break;
        case 6:
          asset = 'sounds/sound_car_exit.wav';
          break;
        default:
          asset = 'sounds/sound_car.wav';
      }
      await _sfxPlayer?.play(AssetSource(asset), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for heroic triumphant orchestral horse fanfare
  static const String onlineHorseAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/10/Rossini_-_William_Tell_Overture_%28finale%29.ogg/Rossini_-_William_Tell_Overture_%28finale%29.ogg.mp3';

  /// Plays the complete 10-second Golden Horse master audio track (magical chime, gallop, whoosh, orchestral rise, triumphant horns)
  Future<void> playHorseMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineHorseAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_horse.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for NASA / space rocket launch audio
  static const String onlineRocketAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/fa/Apollo_11_Launch.ogg/Apollo_11_Launch.ogg.mp3';

  /// Plays the complete 10-second Galaxy Rocket master audio track (ignition, launch roar, whoosh, space ambient, cosmic burst, fade out)
  Future<void> playRocketMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineRocketAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_rocket.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for lion roar and thunder audio
  static const String onlineLionAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1a/Lion_growl_and_roar.ogg/Lion_growl_and_roar.ogg.mp3';

  /// Plays the complete 10-second Golden Lion master audio track (magical chime, roar build-up, roar, thunder/impact, running steps, fade out)
  Future<void> playLionMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineLionAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_lion.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for heavenly ethereal choir / harp music matching Angel Vehicle
  static const String onlineAngelVehicleAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/c/c5/Faure_-_Requiem_-_07_In_Paradisum.ogg/Faure_-_Requiem_-_07_In_Paradisum.ogg.mp3';

  /// Plays the complete 10-second Heavenly Angel Chariot master audio track (harp, crystal chimes, celestial choir)
  Future<void> playAngelVehicleMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineAngelVehicleAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_wings.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for crystal glass chime resonance matching Diamond Wings
  static const String onlineDiamondWingsAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/3/30/Glass_harmonica_chime.ogg/Glass_harmonica_chime.ogg.mp3';

  /// Plays the complete 10-second Diamond Wings master audio track (Crystal Ping, Facet Lock, Silk-Air Unfold, Prism Sweep, Aether Resonance, Gemstone Tail)
  Future<void> playDiamondWingsMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineDiamondWingsAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_diamond_wings.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for magical fairytale romantic orchestral chime matching Love Castle
  static const String onlineLoveCastleAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/fe/Franz_Liszt_-_Liebestraum%2C_Ab_Major.ogg/Franz_Liszt_-_Liebestraum%2C_Ab_Major.ogg.mp3';

  /// Plays the complete 12-second Love Castle master audio track (Magic Rising, Island Emerges, Building Towers, Heart Ignites, Fireworks, Final Glow)
  Future<void> playLoveCastleMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineLoveCastleAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_love_castle.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays the romantic Heart Ignites sound effect (magical crystal ignition whoosh + audible lub-dub heartbeat)
  Future<void> playHeartIgnitesSound() async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      await _sfxPlayer?.play(AssetSource('sounds/sound_love_castle_heart_ignite.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for Luxury Yacht (coastal boat marina engine cruise)
  static const String onlineLuxuryYachtAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/7/77/Boat_by_a_wharf_1.ogg/Boat_by_a_wharf_1.ogg.mp3';

  /// Plays the complete 10-second Luxury Yacht master audio track (Water Splash, Engine Start, Smooth Sailing, Fireworks, Wind & Water, Soft Fade)
  Future<void> playLuxuryYachtMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineLuxuryYachtAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_yacht.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for Star Throne (celestial starlight royal chimes)
  static const String onlineStarThroneAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/fc/Tubular_bells_-_sound_sample.ogg/Tubular_bells_-_sound_sample.ogg.mp3';

  /// Plays the complete 10-second Star Throne master audio track
  /// (Cosmic Starfall, Energy Swirl, Sacred Chimes, Royal Rise, Angel Choir, Final Glow)
  Future<void> playStarThroneMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineStarThroneAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_throne.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays specific stage sound effect for Star Throne (1: Starfall, 2: Swirl, 3: Sacred, 4: Rise, 5: Choir, 6: Glow)
  Future<void> playStarThroneStageSound(int stage) async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      String asset;
      switch (stage) {
        case 1:
          asset = 'sounds/sound_throne_1_starfall.wav';
          break;
        case 2:
          asset = 'sounds/sound_throne_2_swirl.wav';
          break;
        case 3:
          asset = 'sounds/sound_throne_3_sacred.wav';
          break;
        case 4:
          asset = 'sounds/sound_throne_4_rise.wav';
          break;
        case 5:
          asset = 'sounds/sound_throne_5_choir.wav';
          break;
        case 6:
          asset = 'sounds/sound_throne_6_glow.wav';
          break;
        default:
          asset = 'sounds/sound_throne.wav';
      }
      await _sfxPlayer?.play(AssetSource(asset), volume: 1.0);
    } catch (_) {}
  }

  /// Online audio URL endpoints for Roses (romantic floral orchestral bloom)
  static const String onlineRosesAudioUrl =
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/fc/Tubular_bells_-_sound_sample.ogg/Tubular_bells_-_sound_sample.ogg.mp3';

  /// Plays the complete 12-second Roses master audio track
  /// (Blooming Chime, Ribbon Sweep, Petal Burst, Heart Swirl, Falling Petals, Fade Echo)
  Future<void> playRosesMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);

      if (preferOnline) {
        try {
          await _player?.play(UrlSource(onlineRosesAudioUrl), volume: 1.0);
          return;
        } catch (_) {}
      }
      await _player?.play(AssetSource('sounds/sound_roses.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays the complete 10-second Ocean Dolphin master audio track matching the 6-stage sound design timeline
  Future<void> playOceanDolphinMasterAudio({bool preferOnline = false}) async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
      await _player?.play(AssetSource('sounds/sound_whale.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays the complete 10-second Royal Chime master audio track across the entire Royal Crown animation
  Future<void> playCrownMasterAudio() async {
    if (_isMuted) return;
    try {
      _player ??= AudioPlayer();
      _player?.setReleaseMode(ReleaseMode.stop);
      await _player?.play(AssetSource('sounds/sound_crown.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Plays the specific stage sound effect for the Royal Crown animation:
  /// 1: Magical Chime (0-1s) | 2: Metallic Chimes (1-2.5s) | 3: Orchestral Swell (2.5-4s)
  /// 4: Impact (4-5.5s) | 5: Fireworks (5.5-7.5s) | 6: Royal Chime (7.5-10s)
  Future<void> playCrownStageSound(int stage) async {
    if (_isMuted) return;
    try {
      _sfxPlayer ??= AudioPlayer();
      String asset;
      switch (stage) {
        case 1:
          asset = 'sounds/sound_crown_1_awaken.wav';
          break;
        case 2:
          asset = 'sounds/sound_crown_2_emerge.wav';
          break;
        case 3:
          asset = 'sounds/sound_crown_3_rotation.wav';
          break;
        case 4:
          asset = 'sounds/sound_crown_4_surge.wav';
          break;
        case 5:
          asset = 'sounds/sound_crown_5_celebration.wav';
          break;
        case 6:
          asset = 'sounds/sound_crown_6_exit.wav';
          break;
        default:
          asset = 'sounds/sound_crown.wav';
      }
      await _sfxPlayer?.play(AssetSource(asset), volume: 1.0);
    } catch (_) {}
  }

  /// Stops current playing audio immediately (e.g. when skipped or overlay closed)
  Future<void> stop() async {
    _playSessionId++;
    try {
      await _player?.stop();
      await _sfxPlayer?.stop();
    } catch (_) {}
  }

  void dispose() {
    _player?.dispose();
    _sfxPlayer?.dispose();
    _player = null;
    _sfxPlayer = null;
  }
}
