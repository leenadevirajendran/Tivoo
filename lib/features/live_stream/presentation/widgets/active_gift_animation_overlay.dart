import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/gift_sound_service.dart';
import '../../domain/models/gift_item.dart';

/// Tiki 3D Animated Isolated Gift Effects Overlay with Full-Screen Environmental Engine
/// Perfectly matches the 10 Master Tiki Gifts in reference poster:
/// 1. 👑 Royal Crown (The Highest Gift): Golden pedestal, vertical light pillars, golden sparkle rain.
/// 2. 🕊️ Angel Vehicle (Divine Blessings): Heavenly god-rays, floating feathers & white doves.
/// 3. 🐎 Golden Horse (Power & Success): Swirling golden stardust energy vortex ribbons.
/// 4. 🏎️ Luxury Car (Drive Your Dreams): Neon cyber highway, speed streaks, celebration fireworks!
/// 5. 🏰 Love Castle (A World of Love): Ascending glowing 3D neon hearts & heart fireworks bursts!
/// 6. 🚀 Galaxy Rocket (To the Stars): Deep cosmic galaxy, 120+ twinkling stars, planet, dual plasma jets!
/// 7. 💎 Diamond Wings (Fly Higher): Prismatic rainbow dispersion rays, 35+ diamond starburst glints!
/// 8. 🌹 Flower Chariot / Rose (A Journey of Love): Full-screen shower of 36+ tumbling 3D rose petals & fireflies!
/// 9. 🐋 Ocean Whale (Big Dreams): Deep ocean abyss, sunlight caustics & 32 ascending bioluminescent bubbles!
/// 10. ⭐ Meteor Shower (Wishes Come True): 35 golden shooting stars cascading diagonally across screen!
class ActiveGiftAnimationOverlay extends StatefulWidget {
  final Widget child;
  final bool isSuppressed;
  final bool showTopBanner;
  final void Function({required bool toLeft, required int points})? onScoreImpact;

  const ActiveGiftAnimationOverlay({
    super.key,
    required this.child,
    this.isSuppressed = false,
    this.showTopBanner = true,
    this.onScoreImpact,
  });

  static ActiveGiftAnimationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<ActiveGiftAnimationOverlayState>();
  }

  @override
  State<ActiveGiftAnimationOverlay> createState() =>
      ActiveGiftAnimationOverlayState();
}

class ActiveGiftAnimationOverlayState extends State<ActiveGiftAnimationOverlay>
    with TickerProviderStateMixin {
  // 15 Dedicated Controllers for the user-specified gifts
  late final AnimationController _carController;
  late final AnimationController _yachtController;
  late final AnimationController _rocketController;
  late final AnimationController _lionController;
  late final AnimationController _wingsController;
  late final AnimationController _roseController;
  late final AnimationController _crownController;
  late final AnimationController _diamondController;
  late final AnimationController _cakeController;
  late final AnimationController _teddyController;
  late final AnimationController _kittyController;
  late final AnimationController _tikiLoveController;
  late final AnimationController _loveController;
  late final AnimationController _flowersController;
  late final AnimationController _worldTourController;
  late final AnimationController _castleController;

  late final AnimationController _horseController;
  late final AnimationController _whaleController;
  late final AnimationController _angelVehicleController;
  late final AnimationController _throneController;
  late final AnimationController _rosesController;
  late final AnimationController _shakeController;
  late final AnimationController _flightController;

  GiftItem? _activeGift;
  String _currentSenderName = 'You';
  int _currentGiftCount = 1;
  String _currentRecipient = 'Neha ✨';
  bool _currentToLeft = true;
  bool _whaleImpactSoundTriggered = false;
  bool _horseSound1Triggered = false;
  bool _horseSound2Triggered = false;
  bool _horseSound3Triggered = false;
  bool _horseSound4Triggered = false;
  bool _horseSound5Triggered = false;
  bool _horseSound6Triggered = false;
  bool _horseScoreHookTriggered = false;
  bool _wingsSound1Triggered = false;
  bool _wingsSound2Triggered = false;
  bool _wingsSound3Triggered = false;
  bool _wingsSound4Triggered = false;
  bool _wingsSound5Triggered = false;
  bool _wingsSound6Triggered = false;
  bool _wingsScoreHookTriggered = false;
  bool _rosesSound1Triggered = false;
  bool _rosesSound2Triggered = false;
  bool _rosesSound3Triggered = false;
  bool _rosesSound4Triggered = false;
  bool _rosesSound5Triggered = false;
  bool _rosesSound6Triggered = false;
  bool _rosesScoreHookTriggered = false;
  bool _dolphinSound1Triggered = false;
  bool _dolphinSound2Triggered = false;
  bool _dolphinSound3Triggered = false;
  bool _dolphinSound4Triggered = false;
  bool _dolphinSound5Triggered = false;
  bool _dolphinSound6Triggered = false;
  bool _dolphinScoreHookTriggered = false;
  bool _carSound1Triggered = false;
  bool _carSound2Triggered = false;
  bool _carSound3Triggered = false;
  bool _carSound4Triggered = false;
  bool _carSound5Triggered = false;
  bool _carSound6Triggered = false;
  bool _carScoreHookTriggered = false;
  bool _crownSound1Triggered = false;
  bool _crownSound2Triggered = false;
  bool _crownSound3Triggered = false;
  bool _crownSound4Triggered = false;
  bool _crownSound5Triggered = false;
  bool _crownSound6Triggered = false;
  bool _crownScoreHookTriggered = false;
  bool _angelSound1Triggered = false;
  bool _angelSound2Triggered = false;
  bool _angelSound3Triggered = false;
  bool _angelSound4Triggered = false;
  bool _angelSound5Triggered = false;
  bool _angelSound6Triggered = false;
  bool _angelScoreHookTriggered = false;
  bool _rocketSound1Triggered = false;
  bool _rocketSound2Triggered = false;
  bool _rocketSound3Triggered = false;
  bool _rocketSound4Triggered = false;
  bool _rocketSound5Triggered = false;
  bool _rocketSound6Triggered = false;
  bool _rocketScoreHookTriggered = false;
  bool _lionSound1Triggered = false;
  bool _lionSound2Triggered = false;
  bool _lionSound3Triggered = false;
  bool _lionSound4Triggered = false;
  bool _lionSound5Triggered = false;
  bool _lionSound6Triggered = false;
  bool _lionScoreHookTriggered = false;
  bool _castleSound1Triggered = false;
  bool _castleSound2Triggered = false;
  bool _castleSound3Triggered = false;
  bool _castleSound4Triggered = false;
  bool _castleSound5Triggered = false;
  bool _castleSound6Triggered = false;
  bool _castleScoreHookTriggered = false;
  bool _yachtSound1Triggered = false;
  bool _yachtSound2Triggered = false;
  bool _yachtSound3Triggered = false;
  bool _yachtSound4Triggered = false;
  bool _yachtSound5Triggered = false;
  bool _yachtSound6Triggered = false;
  bool _yachtScoreHookTriggered = false;
  bool _throneSound1Triggered = false;
  bool _throneSound2Triggered = false;
  bool _throneSound3Triggered = false;
  bool _throneSound4Triggered = false;
  bool _throneSound5Triggered = false;
  bool _throneSound6Triggered = false;
  bool _throneScoreHookTriggered = false;

  @override
  void initState() {
    super.initState();

    void onComplete(AnimationController controller) {
      if (mounted) {
        setState(() => _activeGift = null);
        controller.reset();
        GiftSoundService.instance.stop();
      }
    }

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _carController.value * 10.0;
        // Step 1: 0 - 1 sec: Engine Start
        if (sec >= 0.1 && !_carSound1Triggered) {
          _carSound1Triggered = true;
          GiftSoundService.instance.playCarStageSound(1);
          HapticFeedback.lightImpact();
        }
        // Step 2: 1 - 2 sec: Engine Rev & Speed Up
        if (sec >= 1.0 && !_carSound2Triggered) {
          _carSound2Triggered = true;
          GiftSoundService.instance.playCarStageSound(2);
          HapticFeedback.mediumImpact();
        }
        // Step 3: 2 - 4 sec: Speed Drive & Drift
        if (sec >= 2.0 && !_carSound3Triggered) {
          _carSound3Triggered = true;
          GiftSoundService.instance.playCarStageSound(3);
        }
        // Step 4: 4 - 6 sec: Drift Sound & Celebration Effects
        if (sec >= 3.6 && !_carSound4Triggered) {
          _carSound4Triggered = true;
          GiftSoundService.instance.playCarStageSound(4);
          HapticFeedback.heavyImpact();
        }
        // Step 5: 6 - 8 sec: Celebration Music & User Name Display
        if (sec >= 5.8 && !_carSound5Triggered) {
          _carSound5Triggered = true;
          GiftSoundService.instance.playCarStageSound(5);
          HapticFeedback.heavyImpact();
        }
        // Score Hook at start of celebration
        if (sec >= 6.0 && !_carScoreHookTriggered) {
          _carScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 500) * _currentGiftCount,
          );
        }
        // Step 6: 8 - 10 sec: Car Exit with Particles
        if (sec >= 8.0 && !_carSound6Triggered) {
          _carSound6Triggered = true;
          GiftSoundService.instance.playCarStageSound(6);
          HapticFeedback.mediumImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _carSound1Triggered = false;
          _carSound2Triggered = false;
          _carSound3Triggered = false;
          _carSound4Triggered = false;
          _carSound5Triggered = false;
          _carSound6Triggered = false;
          _carScoreHookTriggered = false;
          onComplete(_carController);
        }
      });

    _yachtController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _yachtController.value * 10.0;
        // Step 1: 0 - 1.5 sec: Water Splash
        if (sec >= 0.05 && !_yachtSound1Triggered) {
          _yachtSound1Triggered = true;
          GiftSoundService.instance.playFastWhoosh();
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3 sec: Engine Start
        if (sec >= 1.5 && !_yachtSound2Triggered) {
          _yachtSound2Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 3: 3 - 5 sec: Smooth Sailing
        if (sec >= 3.0 && !_yachtSound3Triggered) {
          _yachtSound3Triggered = true;
          GiftSoundService.instance.playRomanticChimes();
        }
        // Step 4: 5 - 7 sec: Fireworks Burst
        if (sec >= 5.0 && !_yachtSound4Triggered) {
          _yachtSound4Triggered = true;
          GiftSoundService.instance.playGlassShatter();
          HapticFeedback.heavyImpact();
        }
        // Step 5: 7 - 9 sec: Wind & Water Ambience + 5,000 Stars Score Hook
        if (sec >= 7.0 && !_yachtSound5Triggered) {
          _yachtSound5Triggered = true;
          GiftSoundService.instance.playChime();
        }
        if (sec >= 7.0 && !_yachtScoreHookTriggered) {
          _yachtScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 5000) * _currentGiftCount,
          );
        }
        // Step 6: 9 - 10 sec: Soft Fade Out
        if (sec >= 9.0 && !_yachtSound6Triggered) {
          _yachtSound6Triggered = true;
          GiftSoundService.instance.playChime();
        }
      })..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _yachtSound1Triggered = false;
          _yachtSound2Triggered = false;
          _yachtSound3Triggered = false;
          _yachtSound4Triggered = false;
          _yachtSound5Triggered = false;
          _yachtSound6Triggered = false;
          _yachtScoreHookTriggered = false;
          onComplete(_yachtController);
        }
      });

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _rocketController.value * 10.0;
        // Step 1: 0 - 1.5 sec: Ignition Sound (Rocket powers up with glowing lights)
        if (sec >= 0.05 && !_rocketSound1Triggered) {
          _rocketSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3 sec: Rocket Launch (Rocket lifts off with dynamic smoke effects)
        if (sec >= 1.5 && !_rocketSound2Triggered) {
          _rocketSound2Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 3: 3 - 5 sec: Whoosh Effect (Rocket moves through clouds and atmosphere)
        if (sec >= 3.0 && !_rocketSound3Triggered) {
          _rocketSound3Triggered = true;
          HapticFeedback.selectionClick();
        }
        // Step 4: 5 - 7 sec: Space Ambient (Rocket flies across planets and stars)
        if (sec >= 5.0 && !_rocketSound4Triggered) {
          _rocketSound4Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 5: 7 - 9 sec: Cosmic Burst (Rocket reaches galaxy with light explosion) + Score Hook
        if (sec >= 7.0 && !_rocketSound5Triggered) {
          _rocketSound5Triggered = true;
          HapticFeedback.heavyImpact();
          if (!_rocketScoreHookTriggered) {
            _rocketScoreHookTriggered = true;
            widget.onScoreImpact?.call(
              toLeft: _currentToLeft,
              points: (_activeGift?.diamonds ?? 1000) * _currentGiftCount,
            );
          }
        }
        // Step 6: 9 - 10 sec: Fade Out (Final pose & star trail exit)
        if (sec >= 9.0 && !_rocketSound6Triggered) {
          _rocketSound6Triggered = true;
          HapticFeedback.lightImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _rocketSound1Triggered = false;
          _rocketSound2Triggered = false;
          _rocketSound3Triggered = false;
          _rocketSound4Triggered = false;
          _rocketSound5Triggered = false;
          _rocketSound6Triggered = false;
          _rocketScoreHookTriggered = false;
          onComplete(_rocketController);
        }
      });

    _lionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _lionController.value * 10.0;
        // Step 1: 0 - 1.5 sec: Magical Chime (Magical particles gather and form the lion)
        if (sec >= 0.05 && !_lionSound1Triggered) {
          _lionSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3 sec: Lion Roar Build-up (The lion gradually forms with golden light)
        if (sec >= 1.5 && !_lionSound2Triggered) {
          _lionSound2Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 3: 3 - 5 sec: Powerful Movement (The lion starts to run with majestic energy)
        if (sec >= 3.0 && !_lionSound3Triggered) {
          _lionSound3Triggered = true;
          HapticFeedback.heavyImpact();
        }
        // Step 4: 5 - 7 sec: Roar Effect & Thunder / Impact (The lion roars with intense golden sparks)
        if (sec >= 5.0 && !_lionSound4Triggered) {
          _lionSound4Triggered = true;
          HapticFeedback.heavyImpact();
          if (!_lionScoreHookTriggered) {
            _lionScoreHookTriggered = true;
            widget.onScoreImpact?.call(
              toLeft: _currentToLeft,
              points: (_activeGift?.diamonds ?? 5000) * _currentGiftCount,
            );
          }
        }
        // Step 5: 7 - 9 sec: Running Steps / Cinematic Showcase (The lion moves with power and grace)
        if (sec >= 7.0 && !_lionSound5Triggered) {
          _lionSound5Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 6: 9 - 10 sec: Fade Out (The lion settles with a lasting glow)
        if (sec >= 9.0 && !_lionSound6Triggered) {
          _lionSound6Triggered = true;
          HapticFeedback.lightImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _lionSound1Triggered = false;
          _lionSound2Triggered = false;
          _lionSound3Triggered = false;
          _lionSound4Triggered = false;
          _lionSound5Triggered = false;
          _lionSound6Triggered = false;
          _lionScoreHookTriggered = false;
          onComplete(_lionController);
        }
      });

    _wingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..addListener(() {
        final sec = _wingsController.value * 10.0;
        // Stage 1: Crystal Ping (0 - 1.0s)
        if (sec >= 0.05 && !_wingsSound1Triggered) {
          _wingsSound1Triggered = true;
          GiftSoundService.instance.playChime();
          HapticFeedback.lightImpact();
        }
        // Stage 2: Facet Lock (1.0 - 2.5s)
        if (sec >= 1.05 && !_wingsSound2Triggered) {
          _wingsSound2Triggered = true;
          GiftSoundService.instance.playGlassShatter();
          HapticFeedback.mediumImpact();
        }
        // Stage 3: Silk-Air Unfold (2.5 - 4.0s)
        if (sec >= 2.55 && !_wingsSound3Triggered) {
          _wingsSound3Triggered = true;
          GiftSoundService.instance.playWingFlap();
          HapticFeedback.mediumImpact();
        }
        // Stage 4: Prism Sweep (4.0 - 6.0s)
        if (sec >= 4.05 && !_wingsSound4Triggered) {
          _wingsSound4Triggered = true;
          GiftSoundService.instance.playMagicSparkle();
          HapticFeedback.selectionClick();
        }
        // Stage 5: Aether Resonance (6.0 - 8.0s) + 10,000 ⭐ Creator Score Impact
        if (sec >= 6.05 && !_wingsSound5Triggered) {
          _wingsSound5Triggered = true;
          GiftSoundService.instance.playChime();
          HapticFeedback.heavyImpact();
        }
        if (sec >= 6.00 && !_wingsScoreHookTriggered) {
          _wingsScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: 10000,
          );
        }
        // Stage 6: Gemstone Tail (8.0 - 10.0s)
        if (sec >= 8.05 && !_wingsSound6Triggered) {
          _wingsSound6Triggered = true;
          GiftSoundService.instance.playMagicSparkle();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _wingsSound1Triggered = false;
          _wingsSound2Triggered = false;
          _wingsSound3Triggered = false;
          _wingsSound4Triggered = false;
          _wingsSound5Triggered = false;
          _wingsSound6Triggered = false;
          _wingsScoreHookTriggered = false;
          onComplete(_wingsController);
        }
      });

    _roseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_roseController);
      });

    _crownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )
      ..addListener(() {
        final sec = _crownController.value * 10.0;
        // Step 1-6 Haptic Cues & Score Hook (Continuous 10s Royal Chime audio flows uninterrupted)
        if (sec >= 0.1 && !_crownSound1Triggered) {
          _crownSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        if (sec >= 1.0 && !_crownSound2Triggered) {
          _crownSound2Triggered = true;
          HapticFeedback.lightImpact();
        }
        if (sec >= 2.5 && !_crownSound3Triggered) {
          _crownSound3Triggered = true;
          HapticFeedback.mediumImpact();
        }
        if (sec >= 4.0 && !_crownSound4Triggered) {
          _crownSound4Triggered = true;
          HapticFeedback.mediumImpact();
        }
        if (sec >= 5.5 && !_crownSound5Triggered) {
          _crownSound5Triggered = true;
          HapticFeedback.heavyImpact();
        }
        // Score Hook at peak celebration moment
        if (sec >= 5.6 && !_crownScoreHookTriggered) {
          _crownScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 50000) * _currentGiftCount,
          );
        }
        if (sec >= 7.5 && !_crownSound6Triggered) {
          _crownSound6Triggered = true;
          HapticFeedback.lightImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _crownSound1Triggered = false;
          _crownSound2Triggered = false;
          _crownSound3Triggered = false;
          _crownSound4Triggered = false;
          _crownSound5Triggered = false;
          _crownSound6Triggered = false;
          _crownScoreHookTriggered = false;
          onComplete(_crownController);
        }
      });

    _diamondController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_diamondController);
      });

    _cakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_cakeController);
      });

    _teddyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_teddyController);
      });

    _kittyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_kittyController);
      });

    _tikiLoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_tikiLoveController);
      });

    _loveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_loveController);
      });

    _flowersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_flowersController);
      });

    _worldTourController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_worldTourController);
      });

    _castleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..addListener(() {
        final sec = _castleController.value * 12.0;
        // Stage 1: Magic Rising (0 - 1.5s)
        if (sec >= 0.05 && !_castleSound1Triggered) {
          _castleSound1Triggered = true;
          GiftSoundService.instance.playChime();
          HapticFeedback.lightImpact();
        }
        // Stage 2: Island Emerges (1.5 - 3.0s)
        if (sec >= 1.55 && !_castleSound2Triggered) {
          _castleSound2Triggered = true;
          GiftSoundService.instance.playWingFlap();
          HapticFeedback.mediumImpact();
        }
        // Stage 3: Building Towers (3.0 - 5.0s)
        if (sec >= 3.05 && !_castleSound3Triggered) {
          _castleSound3Triggered = true;
          GiftSoundService.instance.playMagicSparkle();
          HapticFeedback.selectionClick();
        }
        // Stage 4: Heart Ignites (5.0 - 7.0s)
        if (sec >= 5.05 && !_castleSound4Triggered) {
          _castleSound4Triggered = true;
          GiftSoundService.instance.playHeartIgnitesSound();
          HapticFeedback.mediumImpact();
        }
        // Stage 5: Fireworks (7.0 - 9.0s) + 100,000 ⭐ Creator Score Impact
        if (sec >= 7.05 && !_castleSound5Triggered) {
          _castleSound5Triggered = true;
          GiftSoundService.instance.playGlassShatter();
          HapticFeedback.heavyImpact();
        }
        if (sec >= 7.00 && !_castleScoreHookTriggered) {
          _castleScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: 100000,
          );
        }
        // Stage 6: Final Glow (9.0 - 12.0s)
        if (sec >= 9.05 && !_castleSound6Triggered) {
          _castleSound6Triggered = true;
          GiftSoundService.instance.playChime();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _castleSound1Triggered = false;
          _castleSound2Triggered = false;
          _castleSound3Triggered = false;
          _castleSound4Triggered = false;
          _castleSound5Triggered = false;
          _castleSound6Triggered = false;
          _castleScoreHookTriggered = false;
          onComplete(_castleController);
        }
      });

    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _horseController.value * 10.0;
        // Step 1: 0 - 1.5 sec: Magical Chime (Golden particles emerge)
        if (sec >= 0.05 && !_horseSound1Triggered) {
          _horseSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3 sec: Horse Gallop (Soft) (Horse forms)
        if (sec >= 1.5 && !_horseSound2Triggered) {
          _horseSound2Triggered = true;
          HapticFeedback.selectionClick();
        }
        // Step 3: 3 - 4.5 sec: Wind Whoosh (Detailed formation)
        if (sec >= 3.0 && !_horseSound3Triggered) {
          _horseSound3Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 4: 4.5 - 7 sec: Epic Orchestral Rise (Graceful movement)
        if (sec >= 4.5 && !_horseSound4Triggered) {
          _horseSound4Triggered = true;
          HapticFeedback.heavyImpact();
        }
        // Step 5: 7 - 9 sec: Triumphant Horns (Cinematic showcase) + Score Hook
        if (sec >= 7.0 && !_horseSound5Triggered) {
          _horseSound5Triggered = true;
          HapticFeedback.heavyImpact();
          if (!_horseScoreHookTriggered) {
            _horseScoreHookTriggered = true;
            widget.onScoreImpact?.call(
              toLeft: _currentToLeft,
              points: (_activeGift?.diamonds ?? 1000) * _currentGiftCount,
            );
          }
        }
        // Step 6: 9 - 10 sec: Gentle Fade Out (Final pose)
        if (sec >= 9.0 && !_horseSound6Triggered) {
          _horseSound6Triggered = true;
          HapticFeedback.lightImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _horseSound1Triggered = false;
          _horseSound2Triggered = false;
          _horseSound3Triggered = false;
          _horseSound4Triggered = false;
          _horseSound5Triggered = false;
          _horseSound6Triggered = false;
          _horseScoreHookTriggered = false;
          onComplete(_horseController);
        }
      });

    _whaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10.0s sequence matching storyboard
    )..addListener(() {
        final sec = _whaleController.value * 10.0;
        // Step 1: 0 - 1.5s: Water Splash (Deep ocean splash, water drops, soft whoosh)
        if (sec >= 0.05 && !_dolphinSound1Triggered) {
          _dolphinSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3.0s: Rising Tones (Gentle chimes, water bubbles, crystal shimmer)
        if (sec >= 1.5 && !_dolphinSound2Triggered) {
          _dolphinSound2Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 3: 3.0 - 5.0s: Whale Breath (Low calming whale sound with soft echo)
        if (sec >= 3.0 && !_dolphinSound3Triggered) {
          _dolphinSound3Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 4: 5.0 - 7.0s: Magical Harmonic (Ethereal music, light harp, soft wind)
        if (sec >= 5.0 && !_dolphinSound4Triggered) {
          _dolphinSound4Triggered = true;
          HapticFeedback.selectionClick();
        }
        // Step 4 Score Hook at 5.5s (+10,000 Stars Impact!)
        if (sec >= 5.5 && !_dolphinScoreHookTriggered) {
          _dolphinScoreHookTriggered = true;
          HapticFeedback.heavyImpact();
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: 10000,
          );
        }
        // Step 5: 7.0 - 9.0s: Ocean Flow (Flowing waves, cinematic swell, sparkling ambience)
        if (sec >= 7.0 && !_dolphinSound5Triggered) {
          _dolphinSound5Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 6: 9.0 - 10.0s: Distant Echo (Fade out with soft chimes and ocean breeze)
        if (sec >= 9.0 && !_dolphinSound6Triggered) {
          _dolphinSound6Triggered = true;
        }
      })..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _dolphinSound1Triggered = false;
          _dolphinSound2Triggered = false;
          _dolphinSound3Triggered = false;
          _dolphinSound4Triggered = false;
          _dolphinSound5Triggered = false;
          _dolphinSound6Triggered = false;
          _dolphinScoreHookTriggered = false;
          _whaleImpactSoundTriggered = false;
          onComplete(_whaleController);
        }
      });

    _angelVehicleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )
      ..addListener(() {
        final sec = _angelVehicleController.value * 10.0;
        // Step 1: 0 - 1 sec: Magical Awakening
        if (sec >= 0.1 && !_angelSound1Triggered) {
          _angelSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1 - 2.5 sec: Angelic Formation
        if (sec >= 1.0 && !_angelSound2Triggered) {
          _angelSound2Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 3: 2.5 - 4 sec: Full View & Gentle Float
        if (sec >= 2.5 && !_angelSound3Triggered) {
          _angelSound3Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 4: 4 - 5.5 sec: Heavenly Flight & Sparkle Trails
        if (sec >= 4.0 && !_angelSound4Triggered) {
          _angelSound4Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 5: 5.5 - 7 sec: Grand Celebration & Celestial Blessing
        if (sec >= 5.5 && !_angelSound5Triggered) {
          _angelSound5Triggered = true;
          HapticFeedback.heavyImpact();
        }
        // Score hook at start of celebration
        if (sec >= 5.6 && !_angelScoreHookTriggered) {
          _angelScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 50000) * _currentGiftCount,
          );
        }
        // Step 6: 7 - 8.5 sec: Gift Signature & Notification
        if (sec >= 7.0 && !_angelSound6Triggered) {
          _angelSound6Triggered = true;
          HapticFeedback.lightImpact();
        }
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _angelSound1Triggered = false;
          _angelSound2Triggered = false;
          _angelSound3Triggered = false;
          _angelSound4Triggered = false;
          _angelSound5Triggered = false;
          _angelSound6Triggered = false;
          _angelScoreHookTriggered = false;
          onComplete(_angelVehicleController);
        }
      });

    _throneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000), // 10s sequence matching storyboard
    )..addListener(() {
        final sec = _throneController.value * 10.0;
        // Step 1: 0 - 1.5 sec: Cosmic Starfall (soft celestial chime with falling star)
        if (sec >= 0.05 && !_throneSound1Triggered) {
          _throneSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3 sec: Energy Swirl (whimsical whoosh with rising tones)
        if (sec >= 1.5 && !_throneSound2Triggered) {
          _throneSound2Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 3: 3 - 5 sec: Sacred Chimes (gentle bell chimes and ethereal hum)
        if (sec >= 3.0 && !_throneSound3Triggered) {
          _throneSound3Triggered = true;
          HapticFeedback.selectionClick();
        }
        // Step 4: 5 - 7 sec: Royal Rise (deep, majestic orchestral rise)
        if (sec >= 5.0 && !_throneSound4Triggered) {
          _throneSound4Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 5: 7 - 9 sec: Royal Accession & Angel Choir (+5,000 Stars Score Hook)
        if (sec >= 7.0 && !_throneSound5Triggered) {
          _throneSound5Triggered = true;
          HapticFeedback.heavyImpact();
        }
        if (sec >= 7.0 && !_throneScoreHookTriggered) {
          _throneScoreHookTriggered = true;
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 5000) * _currentGiftCount,
          );
        }
        // Step 6: 9 - 10 sec: Final Glow (warm lingering chime with soft echo)
        if (sec >= 9.0 && !_throneSound6Triggered) {
          _throneSound6Triggered = true;
        }
      })..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _throneSound1Triggered = false;
          _throneSound2Triggered = false;
          _throneSound3Triggered = false;
          _throneSound4Triggered = false;
          _throneSound5Triggered = false;
          _throneSound6Triggered = false;
          _throneScoreHookTriggered = false;
          onComplete(_throneController);
        }
      });

    _rosesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000), // 12s sequence matching storyboard
    )..addListener(() {
        final sec = _rosesController.value * 12.0;
        // Step 1: 0 - 1.5s: Blooming Chime (Soft chimes + gentle floral bloom)
        if (sec >= 0.05 && !_rosesSound1Triggered) {
          _rosesSound1Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 2: 1.5 - 3.0s: Ribbon Sweep (Silk ribbon whoosh + light sparkle twinkle)
        if (sec >= 1.5 && !_rosesSound2Triggered) {
          _rosesSound2Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 3: 3.0 - 5.0s: Petal Burst (Light, airy petal flutter + crystal chimes)
        if (sec >= 3.0 && !_rosesSound3Triggered) {
          _rosesSound3Triggered = true;
          HapticFeedback.selectionClick();
        }
        // Step 4: 5.0 - 8.0s: Swirl & Romance (Whispering wind + soft harp melody + heart tone)
        if (sec >= 5.0 && !_rosesSound4Triggered) {
          _rosesSound4Triggered = true;
          HapticFeedback.mediumImpact();
        }
        // Step 4 Score Hook at 7.0s (+100,000 Stars Impact!)
        if (sec >= 7.0 && !_rosesScoreHookTriggered) {
          _rosesScoreHookTriggered = true;
          HapticFeedback.heavyImpact();
          widget.onScoreImpact?.call(
            toLeft: _currentToLeft,
            points: (_activeGift?.diamonds ?? 100000) * _currentGiftCount,
          );
        }
        // Step 5: 8.0 - 11.0s: Falling Petals (Gentle petal fall + soft piano notes)
        if (sec >= 8.0 && !_rosesSound5Triggered) {
          _rosesSound5Triggered = true;
          HapticFeedback.lightImpact();
        }
        // Step 6: 11.0 - 12.0s: Fade Echo (Distant chime + soft reverb fade out)
        if (sec >= 11.0 && !_rosesSound6Triggered) {
          _rosesSound6Triggered = true;
        }
      })..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _rosesSound1Triggered = false;
          _rosesSound2Triggered = false;
          _rosesSound3Triggered = false;
          _rosesSound4Triggered = false;
          _rosesSound5Triggered = false;
          _rosesSound6Triggered = false;
          _rosesScoreHookTriggered = false;
          onComplete(_rosesController);
        }
      });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_shakeController);
      });

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _flightController.dispose();
    _carController.dispose();
    _yachtController.dispose();
    _rocketController.dispose();
    _lionController.dispose();
    _wingsController.dispose();
    _roseController.dispose();
    _crownController.dispose();
    _diamondController.dispose();
    _cakeController.dispose();
    _teddyController.dispose();
    _kittyController.dispose();
    _tikiLoveController.dispose();
    _loveController.dispose();
    _flowersController.dispose();
    _worldTourController.dispose();
    _castleController.dispose();
    _horseController.dispose();
    _whaleController.dispose();
    _angelVehicleController.dispose();
    _throneController.dispose();
    _rosesController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _isActive(AnimationController c) => c.isAnimating || (c.value > 0.0 && !c.isCompleted);

  void _stopAllControllers() {
    _flightController.reset();
    GiftSoundService.instance.stop();
    _carController.reset();
    _yachtController.reset();
    _rocketController.reset();
    _rocketSound1Triggered = false;
    _rocketSound2Triggered = false;
    _rocketSound3Triggered = false;
    _rocketSound4Triggered = false;
    _rocketSound5Triggered = false;
    _rocketSound6Triggered = false;
    _rocketScoreHookTriggered = false;
    _lionController.reset();
    _lionSound1Triggered = false;
    _lionSound2Triggered = false;
    _lionSound3Triggered = false;
    _lionSound4Triggered = false;
    _lionSound5Triggered = false;
    _lionSound6Triggered = false;
    _lionScoreHookTriggered = false;
    _wingsController.reset();
    _wingsSound1Triggered = false;
    _wingsSound2Triggered = false;
    _wingsSound3Triggered = false;
    _wingsSound4Triggered = false;
    _wingsSound5Triggered = false;
    _wingsSound6Triggered = false;
    _wingsScoreHookTriggered = false;
    _roseController.reset();
    _crownController.reset();
    _diamondController.reset();
    _cakeController.reset();
    _teddyController.reset();
    _kittyController.reset();
    _tikiLoveController.reset();
    _loveController.reset();
    _flowersController.reset();
    _worldTourController.reset();
    _castleController.reset();
    _castleSound1Triggered = false;
    _castleSound2Triggered = false;
    _castleSound3Triggered = false;
    _castleSound4Triggered = false;
    _castleSound5Triggered = false;
    _castleSound6Triggered = false;
    _castleScoreHookTriggered = false;
    _horseController.reset();
    _horseSound1Triggered = false;
    _horseSound2Triggered = false;
    _horseSound3Triggered = false;
    _horseSound4Triggered = false;
    _horseSound5Triggered = false;
    _horseSound6Triggered = false;
    _horseScoreHookTriggered = false;
    _whaleController.reset();
    _whaleImpactSoundTriggered = false;
    _angelVehicleController.reset();
    _angelSound1Triggered = false;
    _angelSound2Triggered = false;
    _angelSound3Triggered = false;
    _angelSound4Triggered = false;
    _angelSound5Triggered = false;
    _angelSound6Triggered = false;
    _angelScoreHookTriggered = false;
    _throneController.reset();
    _throneSound1Triggered = false;
    _throneSound2Triggered = false;
    _throneSound3Triggered = false;
    _throneSound4Triggered = false;
    _throneSound5Triggered = false;
    _throneSound6Triggered = false;
    _throneScoreHookTriggered = false;
    _rosesController.reset();
    _rosesSound1Triggered = false;
    _rosesSound2Triggered = false;
    _rosesSound3Triggered = false;
    _rosesSound4Triggered = false;
    _rosesSound5Triggered = false;
    _rosesSound6Triggered = false;
    _rosesScoreHookTriggered = false;
    _whaleController.reset();
    _dolphinSound1Triggered = false;
    _dolphinSound2Triggered = false;
    _dolphinSound3Triggered = false;
    _dolphinSound4Triggered = false;
    _dolphinSound5Triggered = false;
    _dolphinSound6Triggered = false;
    _dolphinScoreHookTriggered = false;
    _shakeController.reset();
  }

  /// Immediately stops all active animations and clears any active gift or banner
  void clear() {
    _stopAllControllers();
    if (mounted) {
      setState(() {
        _activeGift = null;
        _currentSenderName = '';
        _currentGiftCount = 0;
      });
    }
  }

  /// Triggers the active moving 3D animation for the given gift
  void playGift(
    GiftItem gift, {
    String senderName = 'You',
    int count = 1,
    bool toLeft = true,
    String recipient = 'Neha ✨',
  }) {
    _stopAllControllers();

    setState(() {
      _activeGift = gift;
      _currentSenderName = senderName;
      _currentGiftCount = count;
      _currentRecipient = recipient;
      _currentToLeft = toLeft;
      _whaleImpactSoundTriggered = false;
      _horseSound1Triggered = false;
      _horseSound2Triggered = false;
      _horseSound3Triggered = false;
      _horseSound4Triggered = false;
      _horseSound5Triggered = false;
      _horseSound6Triggered = false;
      _horseScoreHookTriggered = false;
      _wingsSound1Triggered = false;
      _wingsSound2Triggered = false;
      _wingsSound3Triggered = false;
      _wingsSound4Triggered = false;
      _wingsSound5Triggered = false;
      _wingsSound6Triggered = false;
      _wingsScoreHookTriggered = false;
      _rosesSound1Triggered = false;
      _rosesSound2Triggered = false;
      _rosesSound3Triggered = false;
      _rosesSound4Triggered = false;
      _rosesSound5Triggered = false;
      _rosesSound6Triggered = false;
      _rosesScoreHookTriggered = false;
      _carSound1Triggered = false;
      _carSound2Triggered = false;
      _carSound3Triggered = false;
      _carSound4Triggered = false;
      _carSound5Triggered = false;
      _carSound6Triggered = false;
      _carScoreHookTriggered = false;
      _crownSound1Triggered = false;
      _crownSound2Triggered = false;
      _crownSound3Triggered = false;
      _crownSound4Triggered = false;
      _crownSound5Triggered = false;
      _crownSound6Triggered = false;
      _crownScoreHookTriggered = false;
      _angelSound1Triggered = false;
      _angelSound2Triggered = false;
      _angelSound3Triggered = false;
      _angelSound4Triggered = false;
      _angelSound5Triggered = false;
      _angelSound6Triggered = false;
      _angelScoreHookTriggered = false;
      _rocketSound1Triggered = false;
      _rocketSound2Triggered = false;
      _rocketSound3Triggered = false;
      _rocketSound4Triggered = false;
      _rocketSound5Triggered = false;
      _rocketSound6Triggered = false;
      _rocketScoreHookTriggered = false;
      _lionSound1Triggered = false;
      _lionSound2Triggered = false;
      _lionSound3Triggered = false;
      _lionSound4Triggered = false;
      _lionSound5Triggered = false;
      _lionSound6Triggered = false;
      _lionScoreHookTriggered = false;
      _wingsSound1Triggered = false;
      _wingsSound2Triggered = false;
      _wingsSound3Triggered = false;
      _wingsSound4Triggered = false;
      _wingsSound5Triggered = false;
      _wingsSound6Triggered = false;
      _wingsScoreHookTriggered = false;
      _castleSound1Triggered = false;
      _castleSound2Triggered = false;
      _castleSound3Triggered = false;
      _castleSound4Triggered = false;
      _castleSound5Triggered = false;
      _castleSound6Triggered = false;
      _castleScoreHookTriggered = false;
      _yachtSound1Triggered = false;
      _yachtSound2Triggered = false;
      _yachtSound3Triggered = false;
      _yachtSound4Triggered = false;
      _yachtSound5Triggered = false;
      _yachtSound6Triggered = false;
      _yachtScoreHookTriggered = false;
      _throneSound1Triggered = false;
      _throneSound2Triggered = false;
      _throneSound3Triggered = false;
      _throneSound4Triggered = false;
      _throneSound5Triggered = false;
      _throneSound6Triggered = false;
      _throneScoreHookTriggered = false;
    });

    _flightController.forward(from: 0.0);

    final soundCat = _getActiveGiftCategory();
    if (soundCat == 'car') {
      GiftSoundService.instance.playCarMasterAudio();
    } else if (soundCat == 'crown') {
      GiftSoundService.instance.playCrownMasterAudio();
    } else if (soundCat == 'angel_vehicle') {
      GiftSoundService.instance.playAngelVehicleMasterAudio();
    } else if (soundCat == 'wings') {
      GiftSoundService.instance.playDiamondWingsMasterAudio();
    } else if (soundCat == 'horse') {
      GiftSoundService.instance.playHorseMasterAudio();
    } else if (soundCat == 'rocket') {
      GiftSoundService.instance.playRocketMasterAudio();
    } else if (soundCat == 'lion') {
      GiftSoundService.instance.playLionMasterAudio();
    } else if (soundCat == 'castle') {
      GiftSoundService.instance.playLoveCastleMasterAudio();
    } else if (soundCat == 'yacht') {
      GiftSoundService.instance.playLuxuryYachtMasterAudio();
    } else if (soundCat == 'throne') {
      GiftSoundService.instance.playStarThroneMasterAudio();
    } else if (soundCat == 'roses') {
      GiftSoundService.instance.playRosesMasterAudio();
    } else if (soundCat == 'whale' || soundCat == 'dolphin' || soundCat == 'ocean_dolphin') {
      GiftSoundService.instance.playOceanDolphinMasterAudio();
    } else {
      GiftSoundService.instance.playGiftSound(soundCat);
    }

    final nameLower = gift.name.toLowerCase();
    final idLower = gift.id.toLowerCase();

    // Master Ani 1 to 10 Gifts
    if (idLower.contains('ani10') || idLower.contains('roses') || nameLower == 'roses' || idLower.contains('shooting') || nameLower.contains('shooting')) {
      _rosesController.forward(from: 0.0);
    } else if ((idLower.contains('ani1') && !idLower.contains('ani10')) || idLower.contains('whale') || nameLower.contains('whale') || idLower.contains('dolphin') || nameLower.contains('dolphin')) {
      _whaleController.forward(from: 0.0);
    } else if (idLower.contains('ani2') || idLower.contains('horse') || nameLower.contains('horse')) {
      _horseController.forward(from: 0.0);
    } else if (idLower.contains('ani3') || idLower.contains('chariot') || nameLower.contains('chariot') || idLower.contains('vehicle') || nameLower.contains('vehicle')) {
      _angelVehicleController.forward(from: 0.0);
    } else if (idLower.contains('ani4') || idLower.contains('throne') || nameLower.contains('throne')) {
      _throneController.forward(from: 0.0);
    } else if (idLower.contains('ani5') || idLower.contains('castle') || nameLower.contains('castle')) {
      _castleController.forward(from: 0.0);
    } else if (idLower.contains('lion') || nameLower.contains('lion')) {
      _lionController.forward(from: 0.0);
    } else if (idLower.contains('rocket') || nameLower.contains('rocket')) {
      _rocketController.forward(from: 0.0);
    } else if (idLower.contains('ani6') || idLower.contains('car') || nameLower.contains('car')) {
      _carController.forward(from: 0.0);
    } else if (idLower.contains('ani7') || idLower.contains('crown') || nameLower.contains('crown')) {
      _crownController.forward(from: 0.0);
    } else if (idLower.contains('ani9') || idLower.contains('wing') || nameLower.contains('wing')) {
      _wingsController.forward(from: 0.0);
    } else if (idLower.contains('yacht') || nameLower.contains('yacht')) {
      _yachtController.forward(from: 0.0);
    } else if (idLower.contains('rose') || nameLower.contains('rose')) {
      _roseController.forward(from: 0.0);
    } else if (idLower.contains('diamond') || nameLower.contains('diamond')) {
      _diamondController.forward(from: 0.0);
    } else if (idLower.contains('cake') || nameLower.contains('cake')) {
      _cakeController.forward(from: 0.0);
    } else if (idLower.contains('teddy') || nameLower.contains('teddy') || idLower.contains('panda') || nameLower.contains('panda')) {
      _teddyController.forward(from: 0.0);
    } else if (idLower.contains('kitty') || nameLower.contains('kitty') || idLower.contains('cat') || nameLower.contains('cat')) {
      _kittyController.forward(from: 0.0);
    } else if (idLower.contains('tiki') || nameLower.contains('tiki')) {
      _tikiLoveController.forward(from: 0.0);
    } else if (idLower.contains('love') || nameLower.contains('love') || idLower.contains('heart') || nameLower.contains('heart')) {
      _loveController.forward(from: 0.0);
    } else if (idLower.contains('flower') || nameLower.contains('flower') || idLower.contains('bouquet') || nameLower.contains('bouquet')) {
      _flowersController.forward(from: 0.0);
    } else if (idLower.contains('world') || nameLower.contains('world') || idLower.contains('tour') || nameLower.contains('tour')) {
      _worldTourController.forward(from: 0.0);
    } else {
      _shakeController.forward(from: 0.0);
    }
  }

  AnimationController? _getActiveController() {
    if (_isActive(_whaleController)) return _whaleController;
    if (_isActive(_horseController)) return _horseController;
    if (_isActive(_angelVehicleController)) return _angelVehicleController;
    if (_isActive(_throneController)) return _throneController;
    if (_isActive(_castleController)) return _castleController;
    if (_isActive(_carController)) return _carController;
    if (_isActive(_crownController)) return _crownController;
    if (_isActive(_wingsController)) return _wingsController;
    if (_isActive(_rosesController)) return _rosesController;
    if (_isActive(_yachtController)) return _yachtController;
    if (_isActive(_rocketController)) return _rocketController;
    if (_isActive(_lionController)) return _lionController;
    if (_isActive(_roseController)) return _roseController;
    if (_isActive(_diamondController)) return _diamondController;
    if (_isActive(_cakeController)) return _cakeController;
    if (_isActive(_teddyController)) return _teddyController;
    if (_isActive(_kittyController)) return _kittyController;
    if (_isActive(_tikiLoveController)) return _tikiLoveController;
    if (_isActive(_loveController)) return _loveController;
    if (_isActive(_flowersController)) return _flowersController;
    if (_isActive(_worldTourController)) return _worldTourController;
    if (_isActive(_shakeController)) return _shakeController;
    return null;
  }

  String _getActiveGiftCategory() {
    if (_activeGift == null) return '';
    final nameLower = _activeGift!.name.toLowerCase();
    final idLower = _activeGift!.id.toLowerCase();
    if (idLower.contains('ani10') || idLower.contains('roses') || nameLower == 'roses' || idLower.contains('shooting') || nameLower.contains('shooting')) return 'roses';
    if ((idLower.contains('ani1') && !idLower.contains('ani10')) || idLower.contains('whale') || nameLower.contains('whale')) return 'whale';
    if (idLower.contains('ani2') || idLower.contains('horse') || nameLower.contains('horse')) return 'horse';
    if (idLower.contains('ani3') || idLower.contains('chariot') || nameLower.contains('chariot')) return 'angel_vehicle';
    if (idLower.contains('ani4') || idLower.contains('throne') || nameLower.contains('throne')) return 'throne';
    if (idLower.contains('ani5') || idLower.contains('castle') || nameLower.contains('castle')) return 'castle';
    if (idLower.contains('lion') || nameLower.contains('lion')) return 'lion';
    if (idLower.contains('rocket') || nameLower.contains('rocket')) return 'rocket';
    if (idLower.contains('ani6') || idLower.contains('car') || nameLower.contains('car')) return 'car';
    if (idLower.contains('ani7') || idLower.contains('crown') || nameLower.contains('crown')) return 'crown';
    if (idLower.contains('ani9') || idLower.contains('wing') || nameLower.contains('wing')) return 'wings';
    if (idLower.contains('yacht') || nameLower.contains('yacht')) return 'yacht';
    if (nameLower.contains('angel') ||
        idLower.contains('dragon') ||
        nameLower.contains('dragon') ||
        idLower.contains('vehicle')) {
      return 'angel_vehicle';
    }
    if (idLower.contains('chariot') ||
        nameLower.contains('chariot')) {
      return 'flowers';
    }
    if (idLower.contains('rose') || nameLower.contains('rose')) return 'rose';
    if (idLower.contains('flower') ||
        nameLower.contains('flower') ||
        idLower.contains('bouquet')) {
      return 'flowers';
    }
    if (idLower.contains('throne') ||
        nameLower.contains('throne') ||
        idLower.contains('crown') ||
        nameLower.contains('crown')) {
      return 'crown';
    }
    if (idLower.contains('diamond') ||
        nameLower.contains('diamond') ||
        idLower.contains('meteor') ||
        idLower.contains('firework') ||
        nameLower.contains('firework') ||
        idLower.contains('star') ||
        nameLower.contains('star')) {
      return 'diamond';
    }
    if (idLower.contains('cake') || nameLower.contains('cake')) return 'cake';
    if (idLower.contains('teddy') || nameLower.contains('teddy') || idLower.contains('panda')) return 'teddy';
    if (idLower.contains('kitty') || nameLower.contains('kitty') || idLower.contains('cat')) return 'kitty';
    if (idLower.contains('tiki') || nameLower.contains('tiki')) return 'love';
    if (idLower.contains('love') || nameLower.contains('love') || idLower.contains('heart')) return 'love';
    if (idLower.contains('castle') || nameLower.contains('castle')) return 'castle';
    if (idLower.contains('horse') || nameLower.contains('horse')) return 'horse';
    if (idLower.contains('world') || nameLower.contains('world') || idLower.contains('tour')) return 'world_tour';
    return 'generic';
  }

  Offset _getScreenShakeOffset(double whaleVal) {
    if (whaleVal >= 0.65 && whaleVal < 0.78) {
      final p = (whaleVal - 0.65) / 0.13;
      final intensity = sin(p * pi) * 9.0;
      final shakeX = sin(p * 26 * pi) * intensity;
      final shakeY = cos(p * 22 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getHorseScreenShakeOffset(double horseVal) {
    final sec = horseVal * 10.0;
    // Cinematic Showcase triumphant impact at 7.0s - 7.6s in 10s duration
    if (sec >= 7.0 && sec <= 7.6) {
      final p = (sec - 7.0) / 0.60;
      final intensity = sin(p * pi) * 9.0;
      final shakeX = sin(p * 22 * pi) * intensity;
      final shakeY = cos(p * 18 * pi) * (intensity * 0.65);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getWingsScreenShakeOffset(double wingsVal) {
    final sec = wingsVal * 10.0;
    // Refraction Sweep caustics surge (4.0s - 4.5s)
    if (sec >= 4.0 && sec <= 4.5) {
      final p = (sec - 4.0) / 0.50;
      final intensity = sin(p * pi) * 4.5;
      final shakeX = sin(p * 20 * pi) * intensity;
      final shakeY = cos(p * 16 * pi) * (intensity * 0.6);
      return Offset(shakeX, shakeY);
    }
    // Full Radiance Aether bloom impact (6.0s - 6.6s)
    if (sec >= 6.0 && sec <= 6.6) {
      final p = (sec - 6.0) / 0.60;
      final intensity = sin(p * pi) * 6.5;
      final shakeX = sin(p * 24 * pi) * intensity;
      final shakeY = cos(p * 18 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getRocketScreenShakeOffset(double rocketVal) {
    final sec = rocketVal * 10.0;
    // Lift Off initial rumble at 1.5s - 2.4s
    if (sec >= 1.5 && sec <= 2.4) {
      final p = (sec - 1.5) / 0.90;
      final intensity = sin(p * pi) * 4.5;
      final shakeX = sin(p * 28 * pi) * intensity;
      final shakeY = cos(p * 20 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    // Cosmic Burst supernova punch at 7.0s - 7.6s
    if (sec >= 7.0 && sec <= 7.6) {
      final p = (sec - 7.0) / 0.60;
      final intensity = sin(p * pi) * 9.5;
      final shakeX = sin(p * 24 * pi) * intensity;
      final shakeY = cos(p * 18 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getLionScreenShakeOffset(double lionVal) {
    final sec = lionVal * 10.0;
    // Roar & Thunder Impact at 5.0s - 6.2s
    if (sec >= 5.0 && sec <= 6.2) {
      final p = (sec - 5.0) / 1.2;
      final intensity = sin(p * pi) * 9.5;
      final shakeX = sin(p * 26 * pi) * intensity;
      final shakeY = cos(p * 20 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getCastleScreenShakeOffset(double castleVal) {
    final sec = castleVal * 12.0;
    // Fireworks Show burst impact at 7.0s - 8.4s
    if (sec >= 7.0 && sec <= 8.4) {
      final p = (sec - 7.0) / 1.4;
      final intensity = sin(p * pi) * 6.5;
      final shakeX = sin(p * 22 * pi) * intensity;
      final shakeY = cos(p * 16 * pi) * (intensity * 0.7);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getYachtScreenShakeOffset(double yachtVal) {
    final sec = yachtVal * 10.0;
    // Fireworks Burst punch at 5.0s - 6.4s
    if (sec >= 5.0 && sec <= 6.4) {
      final p = (sec - 5.0) / 1.4;
      final intensity = sin(p * pi) * 5.5;
      final shakeX = sin(p * 20 * pi) * intensity;
      final shakeY = cos(p * 14 * pi) * (intensity * 0.6);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getThroneScreenShakeOffset(double throneVal) {
    final sec = throneVal * 10.0;
    // Royal Accession Supernova Shockwave at 7.0s - 7.9s
    if (sec >= 7.0 && sec <= 7.9) {
      final p = (sec - 7.0) / 0.9;
      final intensity = sin(p * pi) * 5.0;
      final shakeX = sin(p * 18 * pi) * intensity;
      final shakeY = cos(p * 14 * pi) * (intensity * 0.6);
      return Offset(shakeX, shakeY);
    }
    return Offset.zero;
  }

  Offset _getRosesScreenShakeOffset(double rosesVal) {
    final sec = rosesVal * 12.0;
    // Petal Burst at 3.0s - 3.8s & Swirl / Romance Impact at 7.0s - 7.9s
    if (sec >= 3.0 && sec <= 3.8) {
      final p = (sec - 3.0) / 0.8;
      final intensity = sin(p * pi) * 3.5;
      return Offset(sin(p * 16 * pi) * intensity, cos(p * 12 * pi) * (intensity * 0.5));
    }
    if (sec >= 7.0 && sec <= 7.9) {
      final p = (sec - 7.0) / 0.9;
      final intensity = sin(p * pi) * 4.8;
      return Offset(sin(p * 18 * pi) * intensity, cos(p * 14 * pi) * (intensity * 0.6));
    }
    return Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSuppressed) {
      return widget.child;
    }

    final activeController = _getActiveController();
    final giftCategory = _getActiveGiftCategory();

    return Stack(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _whaleController,
            _horseController,
            _wingsController,
            _rocketController,
            _lionController,
            _castleController,
            _yachtController,
            _throneController,
            _rosesController,
          ]),
          builder: (context, child) {
            final whaleShake = _whaleController.isAnimating ? _getScreenShakeOffset(_whaleController.value) : Offset.zero;
            final horseShake = _horseController.isAnimating ? _getHorseScreenShakeOffset(_horseController.value) : Offset.zero;
            final wingsShake = _wingsController.isAnimating ? _getWingsScreenShakeOffset(_wingsController.value) : Offset.zero;
            final rocketShake = _rocketController.isAnimating ? _getRocketScreenShakeOffset(_rocketController.value) : Offset.zero;
            final lionShake = _lionController.isAnimating ? _getLionScreenShakeOffset(_lionController.value) : Offset.zero;
            final castleShake = _castleController.isAnimating ? _getCastleScreenShakeOffset(_castleController.value) : Offset.zero;
            final yachtShake = _yachtController.isAnimating ? _getYachtScreenShakeOffset(_yachtController.value) : Offset.zero;
            final throneShake = _throneController.isAnimating ? _getThroneScreenShakeOffset(_throneController.value) : Offset.zero;
            Offset shake = Offset.zero;
            if (whaleShake != Offset.zero) {
              shake = whaleShake;
            } else if (horseShake != Offset.zero) {
              shake = horseShake;
            } else if (wingsShake != Offset.zero) {
              shake = wingsShake;
            } else if (rocketShake != Offset.zero) {
              shake = rocketShake;
            } else if (lionShake != Offset.zero) {
              shake = lionShake;
            } else if (castleShake != Offset.zero) {
              shake = castleShake;
            } else if (yachtShake != Offset.zero) {
              shake = yachtShake;
            } else if (throneShake != Offset.zero) {
              shake = throneShake;
            } else if (_rosesController.isAnimating) {
              final rosesShake = _getRosesScreenShakeOffset(_rosesController.value);
              if (rosesShake != Offset.zero) shake = rosesShake;
            }
            if (shake == Offset.zero) return child!;
            return Transform.translate(offset: shake, child: child);
          },
          child: widget.child,
        ),

        // Full-Screen Atmospheric Environmental Engine Layer
        if (activeController != null && giftCategory.isNotEmpty)
          _buildAtmosphericBackdrop(activeController, giftCategory),

        // 10 Master Cinematic Gifts (Ani1 to Ani10)
        if (_isActive(_whaleController)) _buildOceanWhaleAnimation(),
        if (_isActive(_horseController)) _buildGoldenHorseAnimation(),
        if (_isActive(_angelVehicleController)) _buildAngelChariotAnimation(),
        if (_isActive(_throneController)) _buildStarThroneAnimation(),
        if (_isActive(_castleController)) _buildLoveCastleAnimation(),
        if (_isActive(_carController)) _buildSparklingCarAnimation(),
        if (_isActive(_crownController)) _buildRoyalCrownAnimation(),
        if (_isActive(_wingsController)) _buildDiamondWingsAnimation(),
        if (_isActive(_rosesController)) _buildRosesAnimation(),

        // Other Standard & Special Storyboard Gifts
        if (_isActive(_yachtController)) _buildYachtAnimation(),
        if (_isActive(_rocketController)) _buildRocketAnimation(),
        if (_isActive(_lionController)) _buildLionAnimation(),
        if (_isActive(_roseController)) _buildRoseAnimation(),
        if (_isActive(_diamondController)) _buildDiamondAnimation(),
        if (_isActive(_cakeController)) _buildCakeAnimation(),
        if (_isActive(_teddyController)) _buildTeddyAnimation(),
        if (_isActive(_kittyController)) _buildKittyAnimation(),
        if (_isActive(_tikiLoveController)) _buildTikiLoveAnimation(),
        if (_isActive(_loveController)) _buildLoveHeartAnimation(),
        if (_isActive(_flowersController)) _buildFlowersAnimation(),
        if (_isActive(_worldTourController)) _buildWorldTourAnimation(),
        if (_isActive(_shakeController)) _buildStandardGiftAnimation(),

        // Step 4: Flying Animation from Sender to Creator
        if (_flightController.isAnimating && _activeGift != null)
          _buildSendingFlightAnimation(),

        // Step 5: Gift Received Banner matching Screenshot 2
        if (widget.showTopBanner &&
            _activeGift != null &&
            activeController != null &&
            !(_carController.isAnimating &&
                _carController.value >= 0.60 &&
                _carController.value < 0.80) &&
            !_crownController.isAnimating &&
            !_yachtController.isAnimating &&
            !_throneController.isAnimating &&
            !_rosesController.isAnimating &&
            !_whaleController.isAnimating)
          _buildGiftReceivedBanner(),
      ],
    );
  }

  Widget _buildSendingFlightAnimation() {
    final size = MediaQuery.sizeOf(context);
    final startX = 60.0;
    final startY = size.height - 110.0;
    final toLeft = !_currentRecipient.toLowerCase().contains('arun');
    final endX = toLeft ? size.width * 0.28 : size.width * 0.72;
    final endY = size.height * 0.32;

    return AnimatedBuilder(
      animation: _flightController,
      builder: (context, child) {
        final t = _flightController.value;
        final cpX = size.width * 0.50;
        final cpY = size.height * 0.55;
        final curX = (1 - t) * (1 - t) * startX + 2 * (1 - t) * t * cpX + t * t * endX;
        final curY = (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * cpY + t * t * endY;
        final scale = 0.75 + sin(t * pi) * 0.65;

        return Stack(
          children: [
            // Trail sparkles along the curve behind the flying gift
            for (int i = 1; i <= 4; i++)
              if (t > (i * 0.10))
                Builder(builder: (context) {
                  final trailT = (t - (i * 0.08)).clamp(0.0, 1.0);
                  final trX = (1 - trailT) * (1 - trailT) * startX +
                      2 * (1 - trailT) * trailT * cpX +
                      trailT * trailT * endX;
                  final trY = (1 - trailT) * (1 - trailT) * startY +
                      2 * (1 - trailT) * trailT * cpY +
                      trailT * trailT * endY;
                  return Positioned(
                    left: trX - 8,
                    top: trY - 8,
                    child: Opacity(
                      opacity: ((1.0 - t) * (1.0 - (i * 0.2))).clamp(0.0, 1.0),
                      child: const Text('✨', style: TextStyle(fontSize: 14)),
                    ),
                  );
                }),

            // Flying 3D Gift Item with glowing halo
            Positioned(
              left: curX - 28,
              top: curY - 28,
              child: Opacity(
                opacity: (1.0 - t * 0.2).clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D78).withValues(alpha: 0.8),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _activeGift!.imageAssetPath != null
                          ? Image.asset(
                              _activeGift!.imageAssetPath!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                            )
                          : Text(
                              _activeGift!.icon,
                              style: const TextStyle(fontSize: 34),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGiftReceivedBanner() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding + 62,
      left: 14,
      right: 14,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 360),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, val, child) {
          return Transform.scale(
            scale: val,
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xEE1E1338),
                Color(0xEE3D1B54),
                Color(0xEE2A0845),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFD600),
              width: 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF2D78),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFEA00), Color(0xFFFF2D78)],
                  ),
                ),
                child: const Center(
                  child: Text('🎁', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_currentSenderName sent ${_activeGift!.name} x$_currentGiftCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '⭐ ${_activeGift!.diamonds * _currentGiftCount} to $_currentRecipient',
                      style: const TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'GIFT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ===========================================================================
  // FULL-SCREEN CINEMATIC ATMOSPHERIC ENVIRONMENTAL ENGINE
  // Transforms the live screen into an active, immersive 3D spectacle!
  // ===========================================================================
  Widget _buildAtmosphericBackdrop(AnimationController controller, String category) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value;
        // Smooth entrance (0..0.12) and exit (0.88..1.0)
        final fade = (val < 0.12 ? (val / 0.12) : (val > 0.88 ? (1.0 - val) / 0.12 : 1.0)).clamp(0.0, 1.0);
        if (fade <= 0.0) return const SizedBox.shrink();

        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: fade,
              child: Stack(
                children: [
                  // 1. 🌹 FLOWER CHARIOT & ROSE: Full-Screen Falling & Swirling 3D Petal Rain & Fireflies!
                  if (category == 'rose' || category == 'flowers')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullPetalRainPainter(progress: val),
                    ),

                  // 2. 🚀 GALAXY ROCKET: Deep Space Cosmic Galaxy with Planets, Nebulae & 120+ Stars!
                  if (category == 'rocket')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullSpaceGalaxyPainter(progress: val),
                    ),

                  // 3. 👑 ROYAL CROWN: Giant Golden Pedestal, Vertical God-Rays & Golden Sparkle Rain!
                  if (category == 'crown')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullRoyalGoldenShowerPainter(progress: val),
                    ),

                  // 4. 🏰 LOVE CASTLE & TIKI LOVE: Ascending Glowing 3D Neon Hearts & Heart Fireworks!
                  if (category == 'castle' || category == 'love' || category == 'kitty' || category == 'teddy')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullLoveHeartsPainter(progress: val),
                    ),

                  // 5. 🏎️ LUXURY SUPER CAR: Neon Cyber Highway Speed Streaks & Celebration Fireworks!
                  if (category == 'car')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullHighwayFireworksPainter(progress: val),
                    ),

                  // 6. 🛥️ LUXURY YACHT: Deep Ocean Caustics & Ascending Bioluminescent Bubbles!
                  if (category == 'yacht')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullOceanBubblesPainter(progress: val),
                    ),

                  // 7. 💎 DIAMOND WINGS: Prismatic Rainbow Dispersion Rays & Diamond Starburst Glints!
                  if (category == 'wings')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullDiamondPrismPainter(progress: val),
                    ),

                  // 8. ⭐ METEOR SHOWER / DIAMOND: Golden Shooting Stars Raining Diagonally!
                  if (category == 'diamond')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullMeteorShowerPainter(progress: val),
                    ),

                  // 9. 🐎 GOLDEN HORSE: Golden Energy Vortex Ribbons & Stardust Blast!
                  if (category == 'horse')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullGoldenHorseVortexPainter(progress: val),
                    ),

                  // 10. 🕊️ ANGEL VEHICLE: Divine Heavenly God-Rays & Floating Feathers!
                  if (category == 'angel_vehicle')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullHeavenlyBlessingPainter(progress: val),
                    ),

                  // 11. 🎂 CELEBRATION CAKE: Confetti & Party Bokeh
                  if (category == 'cake')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullCelebrationConfettiPainter(progress: val),
                    ),

                  // 12. 👑✨ STAR THRONE: Cosmic Starfield, Glowing Nebulae & Star Dust Aurora
                  if (category == 'throne')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullStarThroneCosmicBackdropPainter(progress: val),
                    ),

                  // 13. 🌹 ROSES: Romantic Fairytale Castle on Lake & Floating Petals Aurora
                  if (category == 'roses')
                    CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _FullRosesRomanticBackdropPainter(progress: val),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 4. 🌹 COSMIC FIRE ROSE ("Phoenix Flame & Stardust Bloom")
  // Positioned safely in upper-center (screenHeight * 0.35) so comments are NEVER blocked!
  // Transparent alpha with glowing cosmic fire aura so background screen remains fully visible!
  // ===========================================================================
  Widget _buildRoseAnimation() {
    return AnimatedBuilder(
      animation: _roseController,
      builder: (context, child) {
        final val = _roseController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        const double roseWidth = 240;
        const double roseHeight = 240;
        final double centerX = (screenWidth - roseWidth) / 2;
        // Placed in upper-middle area (0.35) so comments at bottom are NEVER blocked!
        final double targetY = screenHeight * 0.35;

        double scale;
        double opacity = 1.0;
        double bloomAngle = 0.0;

        if (val < 0.28) {
          // ① Cosmic Ignition & Blooming (Bud bursts open with golden flame!)
          final p = Curves.easeOutBack.transform(val / 0.28);
          scale = 0.18 + (p * 0.98);
          bloomAngle = (1.0 - p) * -0.32;
          opacity = (val / 0.08).clamp(0.0, 1.0);
        } else if (val < 0.74) {
          // ② Living Flame Respiration (Floating & breathing cosmic energy!)
          final p = (val - 0.28) / 0.46;
          scale = 1.16 + (sin(p * 2 * pi) * 0.06);
          bloomAngle = sin(p * 4 * pi) * 0.03;
          opacity = 1.0;
        } else {
          // ③ Ascending Stardust Dispersal (Graceful rise and stardust fade!)
          final p = Curves.easeInOutCubic.transform((val - 0.74) / 0.26);
          scale = 1.16 - (p * 0.50);
          bloomAngle = p * 0.15;
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        // Soft floating levitation wave
        final double posY = targetY + sin(val * 4 * pi) * 4 - (val > 0.74 ? (val - 0.74) * 60 : 0.0);

        final roseAsset = (_activeGift?.imageAssetPath != null && _activeGift!.imageAssetPath!.isNotEmpty)
            ? _activeGift!.imageAssetPath!
            : AppAssets.giftCosmicRose;

        return Stack(
          children: [
            // Soft Translucent Radial Cosmic Glow behind Rose (Background video stays fully visible!)
            Positioned(
              left: centerX - 30,
              top: posY - 30,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (opacity * 0.75).clamp(0.0, 1.0),
                  child: Container(
                    width: roseWidth + 60,
                    height: roseHeight + 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x66FFB300), // Fiery golden core aura
                          Color(0x33E040FB), // Magenta cosmic mist
                          Colors.transparent, // Smooth falloff so live screen shines through!
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Cosmic Fire Rose with Isolated Transparent Alpha
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: bloomAngle,
                      child: SizedBox(
                        width: roseWidth,
                        height: roseHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Swirling Golden Fire Pedestal Beneath Rose
                            Positioned(
                              bottom: 14,
                              child: Container(
                                width: 180,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const RadialGradient(
                                    colors: [
                                      Color(0xFFFFEA00),
                                      Color(0xFFFF6D00),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x99FFB300),
                                      blurRadius: 22,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Cosmic Fire Rose Visual (Isolated Transparent PNG with zero black box!)
                            Image.asset(
                              roseAsset,
                              width: roseWidth,
                              height: roseHeight,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 1. 🏎️ LUXURY SUPER CAR ("Drive Your Dreams - Fireworks")
  // Sequence: ① Appear ➔ ② Drive In ➔ ③ Full View ➔ ④ Fireworks
  // ===========================================================================
  Widget _buildSuperCarAnimation() {
    return AnimatedBuilder(
      animation: _carController,
      builder: (context, child) {
        final val = _carController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double targetCenterX = (screenWidth - 230) / 2;
        final double targetCenterY = screenHeight * 0.58; // Near comments!

        final double startBackX = screenWidth * 0.95;
        final double exitLeftBackX = -280.0;

        double posX;
        double posY;
        double scale;
        double tiltAngle;
        double suspensionDip = 0.0;
        double opacity = 1.0;
        bool isDrifting = false;

        if (val < 0.35) {
          // ① Drive in from Right & Back towards Front Center (Zooming into foreground!)
          final p = Curves.easeOutQuad.transform(val / 0.35);
          posX = startBackX - (p * (startBackX - targetCenterX));
          posY = (targetCenterY - 24) + (p * 24);
          scale = 0.50 + (p * 0.75); // 0.50 in distance -> 1.25 in front!
          tiltAngle = 0.08 * (1.0 - p);
          suspensionDip = sin(p * 6 * pi) * 2.5;
        } else if (val < 0.65) {
          // ② Front Center Power Drift & Revving (Full foreground view!)
          final p = (val - 0.35) / 0.30;
          posX = targetCenterX - (p * 35);
          posY = targetCenterY - (sin(p * pi) * 6);
          scale = 1.25 + (sin(p * pi) * 0.06);
          tiltAngle = -0.15 * sin(p * pi);
          suspensionDip = sin(p * 8 * pi) * 2.0;
          isDrifting = true;
        } else {
          // ③ Accelerates off to Left & Back into distance (Zooming into depth!)
          final p = Curves.easeInQuad.transform((val - 0.65) / 0.35);
          posX = (targetCenterX - 35) - (p * ((targetCenterX - 35) - exitLeftBackX));
          posY = targetCenterY - (p * 20);
          scale = 1.25 - (p * 0.65); // 1.25 -> 0.60 into distance!
          tiltAngle = 0.04 * (1.0 - p);
          suspensionDip = sin(p * 10 * pi) * 1.8;
          opacity = val > 0.92 ? ((1.0 - val) / 0.08).clamp(0.0, 1.0) : 1.0;
        }

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: posX + 115,
              groundY: posY + 88,
              scale: scale,
              elevation: suspensionDip,
              width: 220,
            ),
            if (isDrifting)
              _buildSubtleTireDriftVfx(
                left: posX + 20,
                top: posY + 76,
                opacity: (sin((val - 0.35) / 0.30 * pi)).clamp(0.0, 1.0),
              ),
            if (val >= 0.06)
              _buildRealisticHeadlightGlow(
                left: posX + 160,
                top: posY + 16,
                opacity: ((val - 0.06) / 0.15).clamp(0.0, 1.0) * opacity * 0.85,
              ),
            Positioned(
              left: posX,
              top: posY + suspensionDip,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: tiltAngle,
                      child: SizedBox(
                        width: 230,
                        height: 125,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFD54F),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftSuperCar,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 6. 🚀 GALAXY ROCKET ("Power & Beyond - Live Animated Gift")
  // Storyboard 6 Stages (10.0 Seconds Total):
  //  1. (0 – 1.5s): Rocket Ignition (powers up on futuristic launchpad with glowing rings & rumble)
  //  2. (1.5 – 3.0s): Lift Off (vertical liftoff with dynamic fire plumes & billowing smoke)
  //  3. (3.0 – 5.0s): Sky Journey (rocket tilts diagonal, traverses clouds and atmosphere)
  //  4. (5.0 – 7.0s): Galaxy Travel (rocket cruises across planets and cosmic stars)
  //  5. (7.0 – 9.0s): Cosmic Burst (supernova shockwaves, 24 volumetric light rays, 300+ sparks)
  //  6. (9.0 – 10.0s): Final Pose (warp acceleration with glittering star trail, fade to live)
  // ===========================================================================
  Widget _buildRocketAnimation() {
    return AnimatedBuilder(
      animation: _rocketController,
      builder: (context, child) {
        final val = _rocketController.value;
        final sec = val * 10.0;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        // Base launchpad center coordinates
        final double padX = (screenWidth - 170.0) / 2.0;
        final double padY = screenHeight * 0.70;

        double posX = padX;
        double posY = padY - 70.0;
        double rocketAngle = 0.0;
        double scale = 1.0;
        double opacity = 1.0;

        if (sec < 1.5) {
          // STAGE 1: Rocket Ignition (0 - 1.5s)
          final p = (sec / 1.5).clamp(0.0, 1.0);
          opacity = (p * 2.5).clamp(0.0, 1.0);
          final rumble = sin(p * 45 * pi) * 1.5;
          posX = padX + rumble;
          posY = padY - 70.0;
          rocketAngle = 0.0; // Perfectly upright
          scale = 0.96 + (p * 0.04);
        } else if (sec < 3.0) {
          // STAGE 2: Lift Off (1.5 - 3.0s)
          final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          final liftCurve = Curves.easeInQuad.transform(p);
          final liftoffDist = screenHeight * 0.36;
          final tremble = sin(p * 24 * pi) * (2.2 * (1.0 - p));
          posX = padX + tremble;
          posY = (padY - 70.0) - (liftCurve * liftoffDist);
          rocketAngle = -0.10 * p; // slight initial pitch
          scale = 1.00 + (p * 0.08);
        } else if (sec < 5.0) {
          // STAGE 3: Sky Journey (3.0 - 5.0s)
          final p = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          final curveP = Curves.easeInOutCubic.transform(p);
          final startX = padX;
          final startY = (padY - 70.0) - (screenHeight * 0.36);
          final targetX = screenWidth * 0.54 - 85.0;
          final targetY = screenHeight * 0.26;
          posX = startX + (targetX - startX) * curveP;
          posY = startY + (targetY - startY) * curveP;
          rocketAngle = -0.10 + (-0.84 - (-0.10)) * curveP; // tilts to diagonal ~-48°
          scale = 1.08 + sin(p * pi) * 0.06;
        } else if (sec < 7.0) {
          // STAGE 4: Galaxy Travel (5.0 - 7.0s)
          final p = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          final startX = screenWidth * 0.54 - 85.0;
          final startY = screenHeight * 0.26;
          final targetX = screenWidth * 0.60 - 85.0;
          final targetY = screenHeight * 0.30;
          posX = (startX + (targetX - startX) * p) + sin(p * 2 * pi) * 4.0;
          posY = (startY + (targetY - startY) * p) + cos(p * 2 * pi) * 6.0;
          rocketAngle = -0.84 + sin(p * 2 * pi) * 0.03;
          scale = 1.14 + sin(p * pi) * 0.04;
        } else if (sec < 9.0) {
          // STAGE 5: Cosmic Burst (7.0 - 9.0s)
          final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          final burstPunch = sin(p * 18 * pi) * (2.0 * (1.0 - p));
          posX = (screenWidth * 0.60 - 85.0) + burstPunch;
          posY = (screenHeight * 0.30) - sin(p * pi) * 12.0;
          rocketAngle = -0.84;
          scale = 1.15 + (sin(p * pi) * 0.30); // brilliant burst expansion
        } else {
          // STAGE 6: Final Pose & Warp Exit (9.0 - 10.0s)
          final p = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          final warpCurve = Curves.easeInCubic.transform(p);
          final startX = screenWidth * 0.60 - 85.0;
          final startY = screenHeight * 0.30;
          final exitX = screenWidth + 260.0;
          final exitY = -260.0;
          posX = startX + (exitX - startX) * warpCurve;
          posY = startY + (exitY - startY) * warpCurve;
          rocketAngle = -0.84;
          scale = 1.15 - (p * 0.35);
          opacity = (1.0 - (p * 1.5)).clamp(0.0, 1.0);
        }

        // Rocket image selection with asset fallback
        final rocketAsset = AppAssets.galaxyRocketHero.isNotEmpty
            ? AppAssets.galaxyRocketHero
            : AppAssets.giftRocket;

        return Stack(
          children: [
            // 1. FULL BACKGROUND COSMIC & LAUNCHPAD CANVAS
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GalaxyRocketCanvasPainter(
                    progress: val,
                    sec: sec,
                    rocketCenter: Offset(posX + 85.0, posY + 85.0),
                    rocketAngle: rocketAngle,
                  ),
                ),
              ),
            ),

            // 2. STAGE 1 & 2 DYNAMIC LAUNCH SMOKE PLUME & BASE BILLOWING
            if (sec >= 1.2 && sec <= 4.0)
              Positioned(
                left: padX - 40,
                top: padY - 20,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: ((sec <= 3.0 ? (sec - 1.2) / 0.8 : (4.0 - sec)) * 0.85).clamp(0.0, 0.85),
                    child: _buildRocketSmokePlume(
                      tailX: padX + 85,
                      tailY: padY + 30,
                      progress: val,
                    ),
                  ),
                ),
              ),

            // 3. ROCKET THRUSTER PLUMES (ATTACHED TO NOZZLE)
            if (sec >= 1.0 && opacity > 0.05)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.translate(
                      offset: const Offset(85, 85),
                      child: Transform.rotate(
                        angle: rocketAngle,
                        child: Transform.translate(
                          offset: const Offset(-85, -85),
                          child: SizedBox(
                            width: 170,
                            height: 260,
                            child: Stack(
                              children: [
                                // Engine Fire Stream from rocket base
                                Positioned(
                                  left: 54,
                                  top: 125,
                                  child: _buildDualRocketThrusterFlames(progress: val),
                                ),
                                // Mach shock diamond glow
                                Positioned(
                                  left: 45,
                                  top: 128,
                                  child: Opacity(
                                    opacity: (sin(val * 32 * pi).abs() * 0.35 + 0.65).clamp(0.0, 1.0),
                                    child: Container(
                                      width: 80,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Color(0xAA00E5FF),
                                            Colors.white,
                                            Color(0xAA00E5FF),
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.25, 0.50, 0.75, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. MAIN 3D GALAXY ROCKET ACTOR
            if (opacity > 0.01)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: rocketAngle,
                        child: SizedBox(
                          width: 170,
                          height: 170,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radial Engine Glow behind rocket
                              if (sec >= 0.8)
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        (sec >= 7.0
                                                ? const Color(0xFFFF007F)
                                                : const Color(0xFF00E5FF))
                                            .withValues(alpha: 0.38),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.75],
                                    ),
                                  ),
                                ),
                              // 3D Specular Sheen & Rocket Sprite
                              _buildRealisticSpecularSheen(
                                progress: val,
                                lightColor: sec >= 7.0
                                    ? const Color(0xFFFF80DF)
                                    : const Color(0xFF80D8FF),
                                child: Image.asset(
                                  rocketAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    AppAssets.giftRocket,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 5. SIGNATURE TOP GIFT NOTIFICATION CARD (Storyboard Steps 4 - 6)
            if (sec >= 1.5 && sec <= 9.8)
              _buildRocketTopBanner(sec),

            // 6. AUDIO CONTROLS & TIMELINE HUD BAR AT BOTTOM (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC080C1E),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x6600E5FF), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF00E5FF), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getRocketStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRocketTopBanner(double sec) {
    final bannerOpacity = (sec < 2.0
            ? (sec - 1.5) / 0.5
            : (sec > 9.2 ? (9.8 - sec) / 0.6 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD0D1127),
                      Color(0xDD1A103C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6600E5FF),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender Avatar or Rocket Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF0A0E2A),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Color(0xFF00E5FF),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Ravi'} sent',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Galaxy Rocket',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$_currentGiftCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '1,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF007F), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'POWER & BEYOND',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getRocketStageTitle(double sec) {
    if (sec < 1.5) {
      return '✦ 1. Rocket Ignition (0 - 1.5s)';
    } else if (sec < 3.0) {
      return '✦ 2. Lift Off (1.5 - 3s)';
    } else if (sec < 5.0) {
      return '✦ 3. Sky Journey (3 - 5s)';
    } else if (sec < 7.0) {
      return '✦ 4. Galaxy Travel (5 - 7s)';
    } else if (sec < 9.0) {
      return '✦ 5. Cosmic Burst (7 - 9s)';
    } else {
      return '✦ 6. Final Pose (9 - 10s)';
    }
  }

  // ===========================================================================
  // 🦁 GOLDEN LION ("Power & Courage - Live Animated Gift")
  // Storyboard 6 Stages (10.0 Seconds Total):
  //  1. (0 – 1.5s): Golden Particles Emerge (magical particles gather and form the lion)
  //  2. (1.5 – 3.0s): Lion Takes Shape (lion gradually forms with golden light & fiery mane)
  //  3. (3.0 – 5.0s): Powerful Movement (lion starts to run with majestic energy across terrain)
  //  4. (5.0 – 7.0s): Roar Effect (lion roars with intense golden sparks & shockwaves)
  //  5. (7.0 – 9.0s): Cinematic Showcase (lion moves with power, royal grace & god-rays)
  //  6. (9.0 – 10.0s): Final Pose (lion settles with lasting glow, fades into stream)
  // ===========================================================================
  Widget _buildLionAnimation() {
    return AnimatedBuilder(
      animation: _lionController,
      builder: (context, child) {
        final val = _lionController.value;
        final sec = val * 10.0;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double baseCenterX = (screenWidth - 260.0) / 2.0;
        final double baseCenterY = screenHeight * 0.44;

        double posX = baseCenterX;
        double posY = baseCenterY;
        double scale = 1.0;
        double opacity = 1.0;
        bool isRoaring = false;

        if (sec < 1.5) {
          // STAGE 1: Golden Particles Emerge (0 - 1.5s)
          final p = (sec / 1.5).clamp(0.0, 1.0);
          opacity = (p * 0.65).clamp(0.0, 0.65);
          scale = 0.88 + (p * 0.12);
          posX = baseCenterX;
          posY = baseCenterY + (sin(p * pi) * 6.0);
        } else if (sec < 3.0) {
          // STAGE 2: Lion Takes Shape (1.5 - 3.0s)
          final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          opacity = 0.65 + (p * 0.35);
          scale = 1.00 + (sin(p * pi) * 0.06);
          posX = baseCenterX;
          posY = baseCenterY;
        } else if (sec < 5.0) {
          // STAGE 3: Powerful Movement (3.0 - 5.0s)
          final p = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          final runCurve = Curves.easeInOutCubic.transform(p);
          final startX = baseCenterX - 45.0;
          final targetX = baseCenterX + 35.0;
          posX = startX + (targetX - startX) * runCurve;
          // Galloping paw stride vertical rhythm
          final pawBounce = sin(p * 8.0 * pi).abs() * 12.0;
          posY = baseCenterY - pawBounce;
          scale = 1.05 + sin(p * pi) * 0.08;
        } else if (sec < 7.0) {
          // STAGE 4: Roar Effect (5.0 - 7.0s)
          final p = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          isRoaring = true;
          final roarPunch = sin(p * pi) * 0.22;
          scale = 1.15 + roarPunch;
          posX = baseCenterX + (sin(p * 20.0 * pi) * (1.8 * (1.0 - p)));
          posY = baseCenterY - 14.0;
        } else if (sec < 9.0) {
          // STAGE 5: Cinematic Showcase (7.0 - 9.0s)
          final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          scale = 1.08 + sin(p * pi) * 0.05;
          posX = baseCenterX + sin(p * 2.0 * pi) * 12.0;
          posY = baseCenterY + cos(p * 2.0 * pi) * 6.0;
        } else {
          // STAGE 6: Final Pose (9.0 - 10.0s)
          final p = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          scale = 1.08 - (p * 0.10);
          opacity = (1.0 - (p * 1.35)).clamp(0.0, 1.0);
          posX = baseCenterX;
          posY = baseCenterY;
        }

        // Active lion image sprite (switches to roaring stand during roar phase)
        final lionAsset = isRoaring
            ? AppAssets.goldenLionRoar
            : AppAssets.goldenLionHero;

        return Stack(
          children: [
            // 1. FULL BACKGROUND GOLDEN EMBER & SHOCKWAVE CANVAS
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GoldenLionCanvasPainter(
                    progress: val,
                    sec: sec,
                    lionCenter: Offset(posX + 130.0, posY + 130.0),
                  ),
                ),
              ),
            ),

            // 2. CRACKED MAGMA STONE GROUND / PEDESTAL
            if (sec >= 1.2 && opacity > 0.05)
              Positioned(
                left: (screenWidth - 320.0) / 2.0,
                top: posY + 195.0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (opacity * 0.85).clamp(0.0, 0.85),
                    child: Container(
                      width: 320,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFF6D00).withValues(alpha: 0.55),
                            const Color(0xFFFFD700).withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. MAIN 3D GOLDEN LION ACTOR
            if (opacity > 0.01)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Core Fiery Lion Aura
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (isRoaring
                                            ? const Color(0xFFFF3D00)
                                            : const Color(0xFFFFD700))
                                        .withValues(alpha: 0.45),
                                    const Color(0xFFFF9100).withValues(alpha: 0.18),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                            // 3D Specular Sheen & Lion Sprite
                            _buildRealisticSpecularSheen(
                              progress: val,
                              lightColor: const Color(0xFFFFE082),
                              child: Image.asset(
                                lionAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  AppAssets.giftGoldenLion,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. SIGNATURE TOP GIFT NOTIFICATION CARD (Storyboard Steps 4 - 6)
            if (sec >= 1.5 && sec <= 9.8)
              _buildLionTopBanner(sec),

            // 5. AUDIO CONTROLS & TIMELINE HUD BAR AT BOTTOM (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC160F06),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x66FFD700), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getLionStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLionTopBanner(double sec) {
    final bannerOpacity = (sec < 2.0
            ? (sec - 1.5) / 0.5
            : (sec > 9.2 ? (9.8 - sec) / 0.6 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD1E1408),
                      Color(0xDD3A2408),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FFD700),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender Avatar / Golden Lion Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF1E1005),
                          child: const Center(
                            child: Text(
                              '🦁',
                              style: TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Anju'} sent',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Golden Lion',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$_currentGiftCount',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '5,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF6D00)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'POWER & COURAGE',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLionStageTitle(double sec) {
    if (sec < 1.5) {
      return '✦ 1. Golden Particles Emerge (0 - 1.5s)';
    } else if (sec < 3.0) {
      return '✦ 2. Lion Takes Shape (1.5 - 3s)';
    } else if (sec < 5.0) {
      return '✦ 3. Powerful Movement (3 - 5s)';
    } else if (sec < 7.0) {
      return '✦ 4. Roar Effect (5 - 7s)';
    } else if (sec < 9.0) {
      return '✦ 5. Cinematic Showcase (7 - 9s)';
    } else {
      return '✦ 6. Final Pose (9 - 10s)';
    }
  }

  // ===========================================================================
  // 1. 👑 ROYAL CROWN ("The Highest Gift - Royal Effect")
  // Sequence: ① Appear ➔ ② Rise ➔ ③ Crown on Head ➔ ④ Royal Effect
  // ===========================================================================
  Widget _buildCrownAnimation() {
    return AnimatedBuilder(
      animation: _crownController,
      builder: (context, child) {
        final val = _crownController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 210) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY + (sin(p * 2 * pi) * 3);
          scale = 1.00 + (sin(p * pi) * 0.20);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double rotY = sin(val * 2 * pi) * 0.22;
        final double rotX = -0.05 + sin(val * 2 * pi) * 0.02;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 105,
              groundY: posY + 165,
              scale: scale,
              elevation: (targetY - posY).abs(),
              width: 190,
            ),
            _buildRealisticStudioAura(
              centerX: centerX + 105,
              centerY: posY + 90,
              scale: scale,
              color: const Color(0xFFFFD54F),
              radius: 200,
              opacity: 0.35 * opacity,
            ),
            if (val >= 0.15 && val <= 0.85) ...[
              _buildSparkleGlint(
                x: centerX + 55,
                y: posY + 70,
                progress: (val * 4.0) % 1.0,
                color: const Color(0xFFFFD54F),
              ),
              _buildSparkleGlint(
                x: centerX + 145,
                y: posY + 65,
                progress: ((val * 4.0) + 0.5) % 1.0,
                color: const Color(0xFF00E5FF),
              ),
            ],
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0014)
                        ..rotateY(rotY)
                        ..rotateX(rotX),
                      child: SizedBox(
                        width: 210,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFD54F),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftCrown,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 5. 🏰 LOVE CASTLE ("A World of Love - Heart Fireworks")
  // Sequence: ① Appear ➔ ② Build ➔ ③ Full Castle ➔ ④ Heart Fireworks
  // ===========================================================================
  Widget _buildCastleAnimation() {
    return AnimatedBuilder(
      animation: _castleController,
      builder: (context, child) {
        final val = _castleController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 230) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.30) {
          final p = Curves.easeOutCubic.transform(val / 0.30);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.30) / 0.45;
          posY = targetY;
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.25);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        return Stack(
          children: [
            Positioned(
              left: centerX - 25,
              top: posY + 160,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (0.50 * opacity).clamp(0.0, 0.50),
                  child: Container(
                    width: 280,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.65),
                          const Color(0xFFF48FB1).withOpacity(0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.50, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (val >= 0.20)
              _buildRealisticStudioAura(
                centerX: centerX + 115,
                centerY: posY + 115,
                scale: scale,
                color: const Color(0xFFFF4081),
                radius: 200,
                opacity: (0.35 * opacity).clamp(0.0, 0.35),
              ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: _buildRealisticSpecularSheen(
                        progress: val,
                        lightColor: const Color(0xFFFF80AB),
                        child: Image.asset(
                          _activeGift?.imageAssetPath ?? AppAssets.giftCastle,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 7. 🪽 DIAMOND WINGS ("Fly Higher - Shine Effect")
  // Sequence: ① Appear ➔ ② Spread ➔ ③ Full Wings ➔ ④ Shine Effect
  // ===========================================================================
  Widget _buildAngelWingsAnimation() {
    return AnimatedBuilder(
      animation: _wingsController,
      builder: (context, child) {
        final val = _wingsController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 240) / 2;
        final double centerY = screenHeight * 0.56;

        double scale;
        double flapFactor;
        double opacity = 1.0;

        if (val < 0.25) {
          final p = Curves.easeOutCubic.transform(val / 0.25);
          scale = 0.70 + (p * 0.30);
          flapFactor = 0.20 + (p * 0.80);
          opacity = (p / 0.12).clamp(0.0, 1.0);
        } else if (val < 0.75) {
          final p = (val - 0.25) / 0.50;
          scale = 1.00 + (sin(p * pi) * 0.18);
          flapFactor = 0.88 + (sin(p * 4 * pi).abs() * 0.12);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          scale = 1.00 - (p * 0.35);
          flapFactor = 1.00 - (p * 0.80);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double airflowSway = sin(val * 2 * pi) * 0.025;
        final double naturalElevation = sin(val * 2 * pi) * 6;
        final double posY = centerY + naturalElevation;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 120,
              groundY: posY + 160,
              scale: scale,
              elevation: naturalElevation,
              width: 220,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateZ(airflowSway)
                        ..scale(flapFactor, 1.0, 1.0),
                      child: SizedBox(
                        width: 240,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFE0F7FA),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftAngelWings,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 🐎 GOLDEN HORSE (Ani2.png) - Legendary | 7 Seconds | Coverage: 65%
  // Particles: Golden sparkles + glowing dust | SFX: Gallop (loop) + neigh + chime
  // SLICE RIG: Front body + hindquarters pivoted at waist + mane/tail wind wave
  // 0-1.2s: Entrance with golden glow pulse, gold dust swirl, scaling 0.6 -> 0.9 + ghost trails
  // 1.2-3.8s: Gallop across S-curve at 3.5 Hz, front/rear alternating rotation, hoof sparks, parallax lines
  // 3.8-5.2s: Rear-up -35° easeOutBack in slow-mo, golden flash, radial shockwave, 300 particles, rays, zoom punch, score hook
  // 5.2-7.0s: Dash & exit with 8-ghost motion blur, horizontal stretch, golden streak fade
  // ===========================================================================
  Widget _buildGoldenHorseAnimation() {
    return AnimatedBuilder(
      animation: _horseController,
      builder: (context, child) {
        final val = _horseController.value;
        final sec = val * 10.0; // 0.0s -> 10.0s matching storyboard timeline
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final padding = MediaQuery.paddingOf(context);

        // UI geometry
        final usableHeight = screenHeight - padding.top - padding.bottom;
        final videoHeight = (usableHeight * 0.36).clamp(220.0, 400.0);
        final arenaTop = padding.top + 92.0;
        final centerY = arenaTop + (videoHeight * 0.48);

        // 68% Screen coverage for horse actor with exact 422:591 aspect ratio
        final horseWidth = (screenWidth * 0.68).clamp(250.0, 390.0);
        final horseHeight = horseWidth * (591.0 / 422.0);
        final centerX = (screenWidth - horseWidth) / 2.0;

        double posX = centerX;
        double posY = centerY;
        double globalScale = 1.0;
        double stretchX = 1.0;
        double stretchY = 1.0;
        double baseTilt = 0.0;
        double frontAngle = 0.0;
        double rearAngle = 0.0;
        double horseOpacity = 1.0;
        bool isEntrance = false;
        bool isForming = false;
        bool isDetailed = false;
        bool isMovement = false;
        bool isShowcase = false;
        bool isExit = false;
        double gallopPhase = 0.0;
        final List<Offset> ghostPositions = [];

        if (sec < 1.5) {
          // ① 0 - 1.5s: Golden Particles Emerge
          isEntrance = true;
          final p = (sec / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeOutCubic.transform(p);
          horseOpacity = (p * 0.40).clamp(0.0, 0.40); // Ethereal particle outline
          globalScale = 0.88 + (ease * 0.08);
          posX = centerX;
          posY = centerY + (1.0 - ease) * 18.0;
        } else if (sec < 3.0) {
          // ② 1.5 - 3.0s: Horse Forms
          isForming = true;
          final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeInOutCubic.transform(p);
          horseOpacity = 0.40 + (ease * 0.55); // Ramps to 0.95
          globalScale = 0.96 + (ease * 0.06);
          gallopPhase = 2 * pi * 3.0 * (sec - 1.5);
          posX = centerX;
          posY = centerY + (sin(gallopPhase) * 6.0);
          baseTilt = -0.03 + (sin(gallopPhase) * 0.02);
          frontAngle = sin(gallopPhase) * 0.05;
          rearAngle = -sin(gallopPhase + 0.4) * 0.04;
        } else if (sec < 4.5) {
          // ③ 3.0 - 4.5s: Detailed Formation (Armor and details appear)
          isDetailed = true;
          final p = ((sec - 3.0) / 1.5).clamp(0.0, 1.0);
          horseOpacity = 1.0;
          globalScale = 1.02 + (sin(p * pi) * 0.06);
          gallopPhase = 2 * pi * 3.2 * (sec - 3.0);
          posX = centerX;
          posY = centerY + (sin(gallopPhase) * 8.0);
          frontAngle = sin(gallopPhase) * 0.06;
          rearAngle = -sin(gallopPhase + 0.5) * 0.05;
          baseTilt = -0.04 + (sin(gallopPhase) * 0.03);
        } else if (sec < 7.0) {
          // ④ 4.5 - 7.0s: Graceful Movement (The horse runs with flowing mane and trails)
          isMovement = true;
          final p = ((sec - 4.5) / 2.5).clamp(0.0, 1.0);
          horseOpacity = 1.0;
          gallopPhase = 2 * pi * 3.5 * (sec - 4.5);
          // Majestic gentle S-curve traversal
          final sCurve = sin(p * 2 * pi) * 22.0;
          posX = centerX + sCurve;
          final verticalBob = sin(gallopPhase) * 15.0;
          posY = centerY + verticalBob;
          baseTilt = -0.06 + (sin(gallopPhase - 0.4) * 0.06);
          frontAngle = sin(gallopPhase) * 0.09;
          rearAngle = -sin(gallopPhase + 0.5) * 0.08;
          globalScale = 1.06 + (p * 0.06);

          // Golden trailing ghost echoes
          for (int g = 1; g <= 4; g++) {
            final lagP = (p - (g * 0.035)).clamp(0.0, 1.0);
            final gx = centerX + sin(lagP * 2 * pi) * 22.0;
            final gy = centerY + sin(gallopPhase - g * 0.55) * 15.0;
            ghostPositions.add(Offset(gx, gy));
          }
        } else if (sec < 9.0) {
          // ⑤ 7.0 - 9.0s: Cinematic Showcase (Full glory with golden aura and light bursts)
          isShowcase = true;
          final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          horseOpacity = 1.0;
          // Triumphant rearing stance / heroic pose
          final rearEase = Curves.easeOutBack.transform((p * 1.5).clamp(0.0, 1.0));
          frontAngle = -0.58 * rearEase; // -33° rearing angle
          rearAngle = 0.08 * sin(p * pi);
          baseTilt = -0.05 * rearEase;
          posX = centerX;
          posY = centerY - (12.0 * rearEase);
          // Camera zoom punch
          final zoomPunch = sin(p * pi) * 0.16;
          globalScale = 1.12 + zoomPunch;
        } else {
          // ⑥ 9.0 - 10.0s: Final Pose & Gentle Fade Out
          isExit = true;
          final p = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          posX = centerX;
          posY = centerY + (sin(p * 2 * pi) * 2.5);
          globalScale = 1.12 - (p * 0.10);
          horseOpacity = (1.0 - p).clamp(0.0, 1.0);
          frontAngle = 0.0;
          rearAngle = 0.0;
          baseTilt = 0.0;
        }

        final horseCenter = Offset(posX + (horseWidth * 0.50), posY + (horseHeight * 0.45));
        final visualBaseY = posY + (horseHeight * 0.88);
        final daisWidth = (horseWidth * 1.18).clamp(280.0, screenWidth * 0.94);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. PARTICLES & CINEMATIC ENVIRONMENT ENGINE (Concentric magic rings, rays, stardust, bursts)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _GoldenHorseDustPainter(
                    progress: val,
                    sec: sec,
                    horseCenter: horseCenter,
                    horseWidth: horseWidth,
                    horseHeight: horseHeight,
                    daisCenter: Offset(horseCenter.dx, visualBaseY),
                    daisWidth: daisWidth,
                    isEntrance: isEntrance,
                    isForming: isForming,
                    isDetailed: isDetailed,
                    isMovement: isMovement,
                    isShowcase: isShowcase,
                    isExit: isExit,
                    gallopPhase: gallopPhase,
                  ),
                ),
              ),
            ),

            // 2. CONCENTRIC GOLDEN GROUND DAIS SHADOW (direct grounding beneath hooves)
            if (horseOpacity > 0.0)
              Positioned(
                left: horseCenter.dx - (daisWidth / 2),
                top: visualBaseY - 14,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (horseOpacity * (isExit ? 0.40 : 0.85)).clamp(0.0, 1.0),
                    child: Container(
                      width: daisWidth,
                      height: 38 * globalScale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(daisWidth / 2, (38 * globalScale) / 2),
                        ),
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFFFEA00),
                            Color(0xDDCC8800),
                            Color(0x00774400),
                          ],
                          stops: [0.0, 0.55, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.50 * horseOpacity),
                            blurRadius: 28,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 3. REALISTIC STUDIO AURA BACKLIGHT
            if (horseOpacity > 0.0)
              _buildRealisticStudioAura(
                centerX: horseCenter.dx,
                centerY: horseCenter.dy,
                scale: globalScale,
                color: const Color(0xFFFFD700),
                radius: 260,
                opacity: isShowcase ? 0.70 : (0.42 * horseOpacity),
              ),

            // 4. GHOST TRAILS / MOTION BLUR SILHOUETTES
            for (int g = 0; g < ghostPositions.length; g++)
              Positioned(
                left: ghostPositions[g].dx,
                top: ghostPositions[g].dy,
                child: IgnorePointer(
                  child: Transform.scale(
                    scale: globalScale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(baseTilt)
                        ..scale(stretchX, stretchY),
                      child: _buildGhostSliceRig(
                        horseWidth: horseWidth,
                        horseHeight: horseHeight,
                        frontAngle: frontAngle,
                        rearAngle: rearAngle,
                        gallopPhase: gallopPhase,
                        opacity: ((1.0 - (g / (ghostPositions.length + 1))) * 0.32 * horseOpacity).clamp(0.0, 1.0),
                      ),
                    ),
                  ),
                ),
              ),

            // 5. MAIN GOLDEN HORSE ACTOR: SKELETAL SLICE RIG WITH WAIST PIVOT
            Positioned(
              left: posX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: horseOpacity,
                  child: Transform.scale(
                    scale: globalScale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(baseTilt)
                        ..scale(stretchX, stretchY),
                      child: _buildRealisticSpecularSheen(
                        progress: val,
                        lightColor: const Color(0xFFFFD700),
                        child: _buildHorseSliceRig(
                          horseWidth: horseWidth,
                          horseHeight: horseHeight,
                          frontAngle: frontAngle,
                          rearAngle: rearAngle,
                          gallopPhase: gallopPhase,
                          isRearingUp: isShowcase,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 6. TOP SIGNATURE NOTIFICATION BANNER (Storyboard panels 4, 5, 6: Arjun sent Golden Horse x1)
            if (sec >= 4.5)
              Positioned(
                top: padding.top + 62,
                left: 20,
                right: 20,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, scaleVal, child) {
                      return Transform.scale(
                        scale: scaleVal,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xF02A1A05),
                            Color(0xF04A3008),
                            Color(0xF01E1303),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99FFD700),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Color(0x66FFA000),
                            blurRadius: 32,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🐎 Golden Horse Emblem Icon
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                              ),
                            ),
                            child: const Center(
                              child: Text('🐎', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Sender Avatar with gold border
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                              image: const DecorationImage(
                                image: AssetImage('assets/avatar_arun.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Text Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Arjun'} sent',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Golden Horse',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'x$_currentGiftCount',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0x77FFD700), width: 1),
                                    ),
                                    child: const Text(
                                      '1,000 ⭐',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 7. AUDIO CONTROLS & TIMELINE HUD BAR AT BOTTOM (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0D0818),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x55FFD700), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getHorseStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Skeletal Slice Rig: splits horse at shoulder into front body & hindquarters with waist pivot
  Widget _buildHorseSliceRig({
    required double horseWidth,
    required double horseHeight,
    required double frontAngle,
    required double rearAngle,
    required double gallopPhase,
    required bool isRearingUp,
  }) {
    // Pivot at the waist/shoulder connection (center of golden saddle blanket)
    final pivotX = horseWidth * 0.50;
    final pivotY = horseHeight * 0.44;

    return SizedBox(
      width: horseWidth,
      height: horseHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. HINDQUARTERS SLICE (Waist, hind legs, flank, tail)
          // Clipped to left portion: 0.0 to 0.56 with pivot at waist
          ClipRect(
            clipper: _SliceClipper(Rect.fromLTWH(0, 0, horseWidth * 0.56, horseHeight)),
            child: Transform(
              alignment: Alignment.topLeft,
              transform: Matrix4.identity()
                ..translate(pivotX, pivotY)
                ..rotateZ(rearAngle)
                ..translate(-pivotX, -pivotY),
              child: Image.asset(
                AppAssets.ani2,
                width: horseWidth,
                height: horseHeight,
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 2. FRONT BODY SLICE (Chest, front legs, neck, head, mane)
          // Clipped to right portion: 0.44 to 1.0 with pivot at waist/shoulder
          ClipRect(
            clipper: _SliceClipper(Rect.fromLTWH(horseWidth * 0.44, 0, horseWidth * 0.56, horseHeight)),
            child: Transform(
              alignment: Alignment.topLeft,
              transform: Matrix4.identity()
                ..translate(pivotX, pivotY)
                ..rotateZ(frontAngle)
                ..translate(-pivotX, -pivotY),
              child: Image.asset(
                AppAssets.ani2,
                width: horseWidth,
                height: horseHeight,
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 3. MANE & TAIL DYNAMIC WIND WAVE LAYER
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HorseManeTailWavePainter(
                  horseWidth: horseWidth,
                  horseHeight: horseHeight,
                  gallopPhase: gallopPhase,
                  frontAngle: frontAngle,
                  rearAngle: rearAngle,
                  isRearingUp: isRearingUp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ghost silhouette slice rig for motion blur trails
  Widget _buildGhostSliceRig({
    required double horseWidth,
    required double horseHeight,
    required double frontAngle,
    required double rearAngle,
    required double gallopPhase,
    required double opacity,
  }) {
    final pivotX = horseWidth * 0.50;
    final pivotY = horseHeight * 0.44;

    return Opacity(
      opacity: opacity,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0xFFFFD700),
          BlendMode.modulate,
        ),
        child: SizedBox(
          width: horseWidth,
          height: horseHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRect(
                clipper: _SliceClipper(Rect.fromLTWH(0, 0, horseWidth * 0.56, horseHeight)),
                child: Transform(
                  alignment: Alignment.topLeft,
                  transform: Matrix4.identity()
                    ..translate(pivotX, pivotY)
                    ..rotateZ(rearAngle)
                    ..translate(-pivotX, -pivotY),
                  child: Image.asset(
                    AppAssets.ani2,
                    width: horseWidth,
                    height: horseHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              ClipRect(
                clipper: _SliceClipper(Rect.fromLTWH(horseWidth * 0.44, 0, horseWidth * 0.56, horseHeight)),
                child: Transform(
                  alignment: Alignment.topLeft,
                  transform: Matrix4.identity()
                    ..translate(pivotX, pivotY)
                    ..rotateZ(frontAngle)
                    ..translate(-pivotX, -pivotY),
                  child: Image.asset(
                    AppAssets.ani2,
                    width: horseWidth,
                    height: horseHeight,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Score Bar Hook: Clean, no-text overlay to prevent overflow glitches
  Widget _buildGoldenHorseScoreImpactBanner({
    required double scoreBarY,
    required double rearProgress,
  }) {
    return const SizedBox.shrink();
  }

  String _getHorseStageTitle(double sec) {
    if (sec < 1.5) return '✦ 1. Golden Particles Emerge';
    if (sec < 3.0) return '✦ 2. Horse Forms';
    if (sec < 4.5) return '✦ 3. Detailed Formation';
    if (sec < 7.0) return '✦ 4. Graceful Movement';
    if (sec < 9.0) return '✦ 5. Cinematic Showcase';
    return '✦ 6. Final Pose';
  }

  // ===========================================================================
  // 9. 🐬 OCEAN DOLPHIN (10,000 STARS - "Ride the Waves of Endless Possibilities")
  // Storyboard 6 Stages (10.0 Seconds Total Sequence):
  //  1. (0.0 – 1.5s): 1. Ocean Ripple Burst (Water particles swirl and rise, forming a luminous vortex)
  //  2. (1.5 – 3.0s): 2. Whale Formation (The whale's shape materializes with sparkling crystal trails)
  //  3. (3.0 – 5.0s): 3. Whale Awakens (The whale opens its eye, light flows across its body)
  //  4. (5.0 – 7.0s): 4. Rider Appears (A graceful figure descends and sits on the whale, blessing journey)
  //  5. (7.0 – 9.0s): 5. Majestic Glide (The whale swims through sky with flowing water and sparkles)
  //  6. (9.0 – 10.0s): 6. Fade Out (The whale moves into distance, leaving trail of light and ocean waves)
  // ===========================================================================
  Widget _buildOceanWhaleAnimation() {
    return AnimatedBuilder(
      animation: _whaleController,
      builder: (context, child) {
        final val = _whaleController.value;
        final sec = val * 10.0;
        final size = MediaQuery.sizeOf(context);
        final screenWidth = size.width;
        final screenHeight = size.height;

        // Stage Envelopes
        final isStage1 = sec < 1.5;              // 1. Ocean Ripple Burst
        final isStage2 = sec >= 1.5 && sec < 3.0; // 2. Whale Formation
        final isStage3 = sec >= 3.0 && sec < 5.0; // 3. Whale Awakens
        final isStage4 = sec >= 5.0 && sec < 7.0; // 4. Rider Appears
        final isStage5 = sec >= 7.0 && sec < 9.0; // 5. Majestic Glide
        final isStage6 = sec >= 9.0;             // 6. Fade Out

        // Overall Opacity envelope
        final masterOpacity = (sec < 0.25
                ? (sec / 0.25)
                : (sec > 9.4 ? (10.0 - sec) / 0.6 : 1.0))
            .clamp(0.0, 1.0);

        // Whale Actor Dimensions (Grand 3D scale)
        final whaleW = (screenWidth * 0.88).clamp(320.0, 560.0);
        final whaleH = whaleW * 0.56;

        // Kinematics across the 6 stages
        double whaleX;
        double whaleY;
        double whaleScale = 1.0;
        double whaleOpacity = 0.0;
        double whaleTilt = 0.0;
        double rippleScale = 0.0;
        double rippleAlpha = 0.0;
        double riderOpacity = 0.0;
        double riderOffsetY = -40.0;

        final centerWhaleX = (screenWidth - whaleW) * 0.50;
        final targetWhaleY = screenHeight * 0.38;

        if (isStage1) {
          // STEP 1: Ocean Ripple Burst (0.0 - 1.5s)
          final p1 = (sec / 1.5).clamp(0.0, 1.0);
          rippleAlpha = (sin(p1 * pi * 0.95) * 1.2).clamp(0.0, 1.0);
          rippleScale = 0.35 + Curves.easeOutBack.transform(p1) * 0.75;
          whaleX = centerWhaleX;
          whaleY = targetWhaleY + 60.0;
          whaleScale = 0.40;
          whaleOpacity = 0.0;
        } else if (isStage2) {
          // STEP 2: Whale Formation (1.5 - 3.0s)
          final p2 = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          final ease2 = Curves.easeOutCubic.transform(p2);
          rippleAlpha = (1.0 - (p2 * 0.8)).clamp(0.0, 1.0);
          rippleScale = 1.1 + (p2 * 0.3);
          whaleX = centerWhaleX;
          whaleY = targetWhaleY + 60.0 - (ease2 * 45.0);
          whaleScale = 0.50 + (ease2 * 0.45);
          whaleOpacity = (p2 * 1.5).clamp(0.0, 1.0);
          whaleTilt = -0.10 + (ease2 * 0.06);
        } else if (isStage3) {
          // STEP 3: Whale Awakens (3.0 - 5.0s)
          final p3 = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          whaleX = centerWhaleX;
          whaleY = (targetWhaleY + 15.0) - (p3 * 15.0) + sin(p3 * 2 * pi) * 6.0;
          whaleScale = 0.95 + sin(p3 * pi) * 0.06;
          whaleOpacity = 1.0;
          whaleTilt = -0.04 + sin(p3 * 2 * pi) * 0.05;
        } else if (isStage4) {
          // STEP 4: Rider Appears (5.0 - 7.0s) - Graceful figure descends
          final p4 = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          final riderEase = Curves.easeOutCubic.transform(p4);
          whaleX = centerWhaleX + sin(p4 * pi) * 15.0;
          whaleY = targetWhaleY + sin(p4 * 2 * pi) * 8.0;
          whaleScale = 1.02;
          whaleOpacity = 1.0;
          whaleTilt = sin(p4 * 2 * pi) * 0.04;

          riderOpacity = (p4 * 1.4).clamp(0.0, 1.0);
          riderOffsetY = -55.0 + (riderEase * 55.0); // Descends from above
        } else if (isStage5) {
          // STEP 5: Majestic Glide (7.0 - 9.0s) - Whale glides through sky
          final p5 = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          // Gliding parabolic flight across screen
          whaleX = centerWhaleX - 25.0 + (p5 * 60.0);
          whaleY = targetWhaleY - sin(p5 * pi) * 45.0;
          whaleScale = 1.04 + sin(p5 * pi) * 0.06;
          whaleOpacity = 1.0;
          whaleTilt = -0.08 + (p5 * 0.16);

          riderOpacity = 1.0;
          riderOffsetY = 0.0;
        } else {
          // STEP 6: Fade Out (9.0 - 10.0s) - Whale moves into distance
          final p6 = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          whaleX = centerWhaleX + 35.0 + (p6 * 120.0);
          whaleY = targetWhaleY - 20.0 - (p6 * 40.0);
          whaleScale = (1.05 - (p6 * 0.35)).clamp(0.5, 1.1);
          whaleOpacity = (1.0 - p6).clamp(0.0, 1.0);
          whaleTilt = 0.08;

          riderOpacity = (1.0 - p6).clamp(0.0, 1.0);
          riderOffsetY = 0.0;
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: masterOpacity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Ambient Deep Oceanic Twilight & Moonlit Azure Aura
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, (targetWhaleY / screenHeight) * 2 - 1),
                          radius: 0.95,
                          colors: [
                            const Color(0xFF00B0FF).withValues(alpha: 0.35), // Electric Cyan Aura
                            const Color(0xFF0D47A1).withValues(alpha: 0.22), // Deep Marine Blue
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Custom Painter: Swirling Vortex, Starlight Constellations, Water Ripples & Bubbles
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: _OceanDolphinStoryPainter(
                      progress: val,
                      sec: sec,
                      whaleCenter: Offset(whaleX + whaleW * 0.50, whaleY + whaleH * 0.50),
                      whaleWidth: whaleW,
                      whaleHeight: whaleH,
                      toLeft: _currentToLeft,
                    ),
                  ),

                  // 3. Stage 1 & 2: Luminous Ocean Ripple Burst & Water Vortex
                  if (rippleAlpha > 0.0)
                    Positioned(
                      left: (screenWidth - whaleW * 1.15) * 0.50,
                      top: targetWhaleY + whaleH * 0.20,
                      width: whaleW * 1.15,
                      height: whaleW * 1.15,
                      child: Opacity(
                        opacity: rippleAlpha,
                        child: Transform.scale(
                          scale: rippleScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Concentric water energy glow
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.65 * rippleAlpha),
                                      blurRadius: 46,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF2979FF).withValues(alpha: 0.45 * rippleAlpha),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                AppAssets.oceanDolphinRipple,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 4. Main 3D Bioluminescent Crystal Whale Actor
                  if (whaleOpacity > 0.0)
                    Positioned(
                      left: whaleX,
                      top: whaleY,
                      width: whaleW,
                      height: whaleH,
                      child: Opacity(
                        opacity: whaleOpacity,
                        child: Transform.scale(
                          scale: whaleScale,
                          child: Transform.rotate(
                            angle: whaleTilt,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                // Bioluminescent Cyan Glow Aura
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.45 * whaleOpacity),
                                        blurRadius: 55,
                                        spreadRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF2979FF).withValues(alpha: 0.35 * whaleOpacity),
                                        blurRadius: 36,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),

                                // Crystal Celestial Whale
                                Image.asset(
                                  AppAssets.oceanDolphinActor,
                                  width: whaleW,
                                  height: whaleH,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    AppAssets.ani1,
                                    width: whaleW,
                                    height: whaleH,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Dynamic Specular Starlight Sheen
                                _buildRealisticSpecularSheen(
                                  progress: val,
                                  lightColor: const Color(0xFF80D8FF),
                                  child: Container(
                                    width: whaleW,
                                    height: whaleH,
                                    color: Colors.transparent,
                                  ),
                                ),

                                // 5. Ethereal Maiden Rider (Sitting on whale back)
                                if (riderOpacity > 0.0)
                                  Positioned(
                                    top: -whaleH * 0.42 + riderOffsetY,
                                    left: whaleW * 0.32,
                                    width: whaleW * 0.46,
                                    height: whaleW * 0.46,
                                    child: Opacity(
                                      opacity: riderOpacity,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Golden lantern glow
                                          Positioned(
                                            top: whaleW * 0.14,
                                            left: whaleW * 0.16,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFFFFD700).withValues(alpha: 0.85 * riderOpacity),
                                                    blurRadius: 20,
                                                    spreadRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            AppAssets.oceanDolphinRider,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 6. Dedicated Ocean Dolphin Top Banner (Matching Storyboard & 10,000 Stars Value)
                  if (widget.showTopBanner)
                    _buildOceanDolphinTopBanner(sec),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getOceanDolphinStageTitle(double sec) {
    if (sec < 1.5) return '1. Ocean Ripple Burst • Luminous Vortex';
    if (sec < 3.0) return '2. Whale Formation • Crystal Trails';
    if (sec < 5.0) return '3. Whale Awakens • Light Flows Across Body';
    if (sec < 7.0) return '4. Rider Appears • Angelic Blessing';
    if (sec < 9.0) return '5. Majestic Glide • Flying Sky & Ocean';
    return '6. Fade Out • Trail of Stardust & Light';
  }

  Widget _buildOceanDolphinTopBanner(double sec) {
    final sender = _currentSenderName.isNotEmpty ? _currentSenderName : 'Ananya';
    final count = _currentGiftCount > 1 ? ' x${_currentGiftCount}' : ' x1';
    final isImpactActive = sec >= 5.5 && sec <= 7.2;

    final bannerOpacity = (sec < 0.6
            ? (sec / 0.6)
            : (sec > 9.3 ? (10.0 - sec) / 0.7 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xEE0A192F), // Midnight Deep Marine
                      Color(0xEE0284C7), // Celestial Ocean Blue
                      Color(0xEE0EA5E9), // Glowing Cyan Wave
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isImpactActive
                        ? const Color(0xFFFFD700)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.85),
                    width: isImpactActive ? 2.2 : 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x8800E5FF),
                      blurRadius: isImpactActive ? 26 : 16,
                      spreadRadius: isImpactActive ? 3 : 1,
                    ),
                    BoxShadow(
                      color: const Color(0x660284C7),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Celestial Whale Crest Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFFFD700)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF0A192F),
                          child: const Center(
                            child: Text('🐬', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$sender sent Ocean Dolphin$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                ),
                              ),
                              child: const Text(
                                '10,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFF0A192F),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getOceanDolphinStageTitle(sec),
                              style: TextStyle(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.95),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isImpactActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '+10,000 Stars Impact!',
                                  style: TextStyle(
                                    color: Color(0xFF0A192F),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. 🕊️ ANGEL VEHICLE ("Divine Blessings - Blessing Effect")
  // Sequence: ① Appear ➔ ② Fly In ➔ ③ Full View ➔ ④ Blessing Effect
  // ===========================================================================
  Widget _buildAngelVehicleAnimation() {
    return AnimatedBuilder(
      animation: _angelVehicleController,
      builder: (context, child) {
        final val = _angelVehicleController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 240) / 2;
        final double centerY = screenHeight * 0.56;

        final double scale = 0.94 + (sin(val * pi) * 0.14);
        final double sway = sin(val * 2 * pi) * 0.03;
        final double opacity = val > 0.85 ? ((1.0 - val) / 0.15).clamp(0.0, 1.0) : (val / 0.12).clamp(0.0, 1.0);

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 120,
              groundY: centerY + 175,
              scale: scale,
              width: 220,
            ),
            Positioned(
              left: centerX,
              top: centerY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: sway,
                      child: SizedBox(
                        width: 240,
                        height: 210,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFF9C4),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftAngelVehicle,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 👑 ROYAL CROWN (Ani7.png) - Legendary | 5 Seconds | Coverage: 55%
  // Particles: Golden stars + glitter | SFX: Royal fanfare + sparkle chimes
  // Motion: Descends from above -> rotates in 3D -> lands with golden flash & circular wave -> fades
  // ===========================================================================
  // ===========================================================================
  // 👑 ROYAL CROWN (Ani7.png) - 3D Animated Gift (Client Storyboard 6-Stage Engine)
  // ① 0 - 1s: Royal Energy Awakens (Pedestal, energy ring, silhouette, rising embers)
  // ② 1 - 2.5s: Crown Emerges (Particles assemble, red velvet & jewels settle on dais)
  // ③ 2.5 - 4s: Royal Crown Rotation (35° 3D perspective rotation, camera pushes in)
  // ④ 4 - 5.5s: Royal Power Surge (Central gem pulses, expanding shockwaves & god-rays)
  // ⑤ 5.5 - 7.5s: Grand Royal Celebration (Arched royal halo, dual fireworks, glitter shower)
  // ⑥ 7.5 - 10s: Gift Signature & Exit (Top signature card, final sparkle, stardust dissolve)
  // ===========================================================================
  Widget _buildRoyalCrownAnimation() {
    return AnimatedBuilder(
      animation: _crownController,
      builder: (context, child) {
        final val = _crownController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final topPadding = MediaQuery.paddingOf(context).top;
        final sec = val * 10.0;

        final double crownWidth = 260.0;
        final double crownHeight = 230.0;
        final double centerX = (screenWidth - crownWidth) / 2;
        final double centerY = screenHeight * 0.44;
        double posX = centerX;
        double posY = centerY;
        double scale = 1.0;
        double rotY = 0.0;
        double rotX = -0.05;
        double opacity = 1.0;
        bool isEnergyAwaken = false;
        bool isPowerSurge = false;
        bool isCelebration = false;
        bool isExit = false;
        double flareScale = 0.0;

        if (sec < 1.0) {
          // ① 0 - 1 sec: Royal Energy Awakens
          isEnergyAwaken = true;
          opacity = 0.0; // Wireframe energy silhouette drawn by painter
          scale = 0.90;
          posY = centerY;
        } else if (sec < 2.5) {
          // ② 1 - 2.5 sec: Crown Emerges & Settles on Pedestal
          final p = ((sec - 1.0) / 1.5).clamp(0.0, 1.0);
          final assembleEase = Curves.easeOutCubic.transform(p);
          opacity = assembleEase.clamp(0.0, 1.0);
          posY = (centerY - 35.0) + (assembleEase * 35.0);
          scale = 0.95 + (assembleEase * 0.15);
        } else if (sec < 4.0) {
          // ③ 2.5 - 4 sec: Royal Crown Rotation (35° 3D reveal + camera push in)
          final p = ((sec - 2.5) / 1.5).clamp(0.0, 1.0);
          opacity = 1.0;
          scale = 1.10 + (p * 0.22); // Push-in from 1.10x to 1.32x
          rotY = sin(p * pi) * 0.56; // ~32 degree rotation showing craftsmanship
          rotX = -0.06 + sin(p * pi) * 0.03;
          posY = centerY + sin(p * 2 * pi) * 2.0;
        } else if (sec < 5.5) {
          // ④ 4 - 5.5 sec: Royal Power Surge (Central gem pulses, shockwaves)
          final p = ((sec - 4.0) / 1.5).clamp(0.0, 1.0);
          isPowerSurge = true;
          scale = 1.32 + sin(p * pi) * 0.14;
          flareScale = 1.0 + sin(p * pi) * 1.8;
          posY = centerY;
        } else if (sec < 7.5) {
          // ⑤ 5.5 - 7.5 sec: Grand Royal Celebration (Halo, fireworks, glitter shower)
          final p = ((sec - 5.5) / 2.0).clamp(0.0, 1.0);
          isCelebration = true;
          scale = 1.30;
          posY = centerY + sin(p * 2 * pi) * 3.5;
          rotY = sin(p * pi * 0.5) * 0.06;
        } else {
          // ⑥ 7.5 - 10 sec: Gift Signature & Exit
          final p = ((sec - 7.5) / 2.5).clamp(0.0, 1.0);
          isExit = true;
          posY = centerY + (p * 8.0);
          if (p < 0.35) {
            scale = 1.25;
            opacity = 1.0;
          } else {
            final exitP = (p - 0.35) / 0.65;
            scale = 1.25 - (exitP * 0.40);
            opacity = (1.0 - exitP).clamp(0.0, 1.0);
          }
        }

        // Dynamically compute the grounded pedestal floor position & width based on crown scale & position:
        final double visualBaseY = (posY + crownHeight / 2) + (86.0 * scale);
        final double daisWidth = ((crownWidth * scale) * 1.22).clamp(290.0, screenWidth * 0.96);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Stage 1-6 Royal Canvas (Dais, Energy Rings, Vertical Beam, Silhouette, Halo, Fireworks, Glitter)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _RoyalCrownGlitterPainter(
                    progress: val,
                    sec: sec,
                    crownCenter: Offset(centerX + crownWidth / 2, posY + crownHeight / 2 - 20),
                    daisCenter: Offset(centerX + crownWidth / 2, visualBaseY),
                    daisWidth: daisWidth,
                    isEnergyAwaken: isEnergyAwaken,
                    isPowerSurge: isPowerSurge,
                    isCelebration: isCelebration,
                    isExit: isExit,
                  ),
                ),
              ),
            ),

            // Even Golden Base Shadow & Grounding Glow (Anchored directly under crown rim with zero gaps)
            if (opacity > 0.0)
              Positioned(
                left: centerX + (crownWidth / 2) - (daisWidth / 2),
                top: visualBaseY - 14,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (opacity * (isExit ? 0.35 : 0.85)).clamp(0.0, 1.0),
                    child: Container(
                      width: daisWidth,
                      height: 38 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(daisWidth / 2, (38 * scale) / 2),
                        ),
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFFFFEA00),
                            Color(0xDDCC8800),
                            Color(0x00774400),
                          ],
                          stops: [0.0, 0.60, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.50 * opacity),
                            blurRadius: 26,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Royal Aura Studio Backlight
            if (opacity > 0.0)
              _buildRealisticStudioAura(
                centerX: centerX + crownWidth / 2,
                centerY: posY + crownHeight / 2,
                scale: scale,
                color: const Color(0xFFFFD700),
                radius: 220,
                opacity: isPowerSurge ? 0.75 : (0.40 * opacity),
              ),

            // Imperial Royal Crown 3D Actor (Ani7.png)
            if (opacity > 0.0)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0014)
                          ..rotateY(rotY)
                          ..rotateX(rotX),
                        child: SizedBox(
                          width: crownWidth,
                          height: crownHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildRealisticSpecularSheen(
                                progress: val,
                                lightColor: const Color(0xFFFFEA00),
                                child: Image.asset(
                                  _activeGift?.imageAssetPath ?? AppAssets.ani7,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // Central Gemstone Power Surge Flare (Diamond Cross Core)
                              if (isPowerSurge && flareScale > 0.1)
                                Positioned(
                                  top: 10,
                                  left: crownWidth / 2 - 25,
                                  child: Transform.scale(
                                    scale: flareScale,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFFFFEA00),
                                            Color(0x00FFD700),
                                          ],
                                          stops: [0.0, 0.45, 1.0],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xEEFFFFFF),
                                            blurRadius: 28,
                                            spreadRadius: 6,
                                          ),
                                          BoxShadow(
                                            color: Color(0xAAFFD700),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Stage 6 Top Signature Banner: [👑] [Avatar] Leena sent Royal Crown x1 (Panel 6)
            if (sec >= 7.2)
              Positioned(
                top: topPadding + 62,
                left: 20,
                right: 20,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, scaleVal, child) {
                      return Transform.scale(
                        scale: scaleVal,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xF02A0845),
                            Color(0xF04A154B),
                            Color(0xF01E0836),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x99FFD700),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Color(0x66BA43F6),
                            blurRadius: 32,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 👑 Royal Crown Icon Emblem
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                              ),
                            ),
                            child: const Center(
                              child: Text('👑', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Sender Avatar with gold border
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                              image: const DecorationImage(
                                image: AssetImage('assets/avatar_arun.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Text Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Leena'} sent',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Royal Crown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'x$_currentGiftCount',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Audio Controls & Timeline HUD Bar at Bottom (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0D0818),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x55FFD700), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getCrownStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getCrownStageTitle(double sec) {
    if (sec < 1.0) return '✦ 1. Royal Energy';
    if (sec < 2.5) return '✦ 2. Crown Emerges';
    if (sec < 4.0) return '✦ 3. Royal 3D Rotation';
    if (sec < 5.5) return '✦ 4. Power Surge';
    if (sec < 7.5) return '✦ 5. Royal Celebration';
    return '✦ 6. Gift Exit';
  }

  // ===========================================================================
  // 🕊️ ANGEL VEHICLE / CHARIOT (Ani3.png) - 3D Animated Gift (Animation Sequence)
  // Storyboard 10.0-second 8-Stage Cinematic Sequence:
  // ① 0–1s: Magical Awakening (Energy rings, god-ray, constellation outline)
  // ② 1–2.5s: Formation of Angel Vehicle (Light particles coalesce, wings open)
  // ③ 2.5–4s: Full View & Gentle Float (Majestic angel + Pegasus float, drifting feathers)
  // ④ 4–5.5s: Flight & Sparkle Trails (Dynamic gliding with sweeping ribbon light trails)
  // ⑤ 5.5–7s: Grand Celebration (Celestial sacred halo, fireworks, radiant rays)
  // ⑥ 7–8.5s: Gift Signature & Notification (Top notification card + divine pulse)
  // ⑦ 8.5–9.5s: Fade Out (Ascending toward top-right into ethereal clouds)
  // ⑧ 9.5–10s: Return to Live Stream (Smooth lingering feathers dissolve into feed)
  // ===========================================================================
  Widget _buildAngelChariotAnimation() {
    return AnimatedBuilder(
      animation: _angelVehicleController,
      builder: (context, child) {
        final val = _angelVehicleController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;
        final topPadding = MediaQuery.paddingOf(context).top;
        final sec = val * 10.0;

        final double chariotWidth = 320.0;
        final double chariotHeight = 226.0;
        final double centerX = (screenWidth - chariotWidth) / 2;
        final double centerY = screenHeight * 0.42;

        double posX = centerX;
        double posY = centerY;
        double scale = 1.0;
        double tiltAngle = 0.0;
        double rotY = 0.0;
        double rotX = -0.04;
        double opacity = 1.0;

        bool isAwakening = false;
        bool isFormation = false;
        bool isFlight = false;
        bool isCelebration = false;
        bool isSignature = false;
        bool isFadeOut = false;

        if (sec < 1.0) {
          // ① 0 - 1 sec: Magical Awakening
          isAwakening = true;
          opacity = 0.0; // Constellation outline drawn by painter
          scale = 0.95;
          posY = centerY;
        } else if (sec < 2.5) {
          // ② 1 - 2.5 sec: Formation of Angel Vehicle
          isFormation = true;
          final p = ((sec - 1.0) / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeOutCubic.transform(p);
          opacity = ease.clamp(0.0, 1.0);
          scale = 0.95 + (ease * 0.15);
          posY = (centerY - 25.0) + (ease * 25.0);
          tiltAngle = -0.04 + (ease * 0.04);
        } else if (sec < 4.0) {
          // ③ 2.5 - 4 sec: Full View & Gentle Float
          final p = ((sec - 2.5) / 1.5).clamp(0.0, 1.0);
          opacity = 1.0;
          scale = 1.10 + (p * 0.06);
          posY = centerY + sin(p * 2 * pi) * 6.0; // Gentle float
          tiltAngle = sin(p * 2 * pi) * 0.03;
          rotY = sin(p * pi) * 0.10;
        } else if (sec < 5.5) {
          // ④ 4 - 5.5 sec: Flight & Sparkle Trails
          isFlight = true;
          final p = ((sec - 4.0) / 1.5).clamp(0.0, 1.0);
          opacity = 1.0;
          scale = 1.16 + sin(p * pi) * 0.06;
          posX = centerX - 30.0 + (p * 60.0);
          posY = centerY + sin(p * 2 * pi) * 12.0;
          tiltAngle = -0.06 + (sin(p * 2 * pi) * 0.04);
          rotY = 0.05 + sin(p * pi) * 0.08;
        } else if (sec < 7.0) {
          // ⑤ 5.5 - 7 sec: Grand Celebration & Celestial Blessing
          isCelebration = true;
          final p = ((sec - 5.5) / 1.5).clamp(0.0, 1.0);
          scale = 1.22 + sin(p * pi) * 0.05;
          posX = centerX + (1.0 - p) * 30.0;
          posY = centerY + sin(p * 2 * pi) * 4.0;
          tiltAngle = sin(p * pi) * 0.02;
          opacity = 1.0;
        } else if (sec < 8.5) {
          // ⑥ 7 - 8.5 sec: Gift Signature & Notification
          isSignature = true;
          final p = ((sec - 7.0) / 1.5).clamp(0.0, 1.0);
          scale = 1.18 + sin(p * 2 * pi) * 0.03;
          posX = centerX;
          posY = centerY + 8.0;
          opacity = 1.0;
        } else {
          // ⑦ & ⑧ 8.5 - 10 sec: Fade Out & Return to Live Stream
          isFadeOut = true;
          final p = ((sec - 8.5) / 1.5).clamp(0.0, 1.0);
          final flyEase = Curves.easeInOutCubic.transform(p);
          posX = centerX + (flyEase * (screenWidth * 0.55));
          posY = (centerY + 8.0) - (flyEase * 180.0);
          scale = 1.18 - (flyEase * 0.65);
          tiltAngle = -0.16;
          opacity = (1.0 - flyEase).clamp(0.0, 1.0);
        }

        final chariotCenter = Offset(posX + chariotWidth / 2, posY + chariotHeight / 2);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Stages 1-8 Celestial Canvas (Atmospheric Clouds, Floor Rings, God-Ray, Trails, Sacred Halo, Fireworks, Feathers)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _AngelChariotCanvasPainter(
                    progress: val,
                    sec: sec,
                    chariotCenter: chariotCenter,
                    isAwakening: isAwakening,
                    isFormation: isFormation,
                    isFlight: isFlight,
                    isCelebration: isCelebration,
                    isSignature: isSignature,
                    isFadeOut: isFadeOut,
                  ),
                ),
              ),
            ),

            // Heavenly Aura Studio Backlight
            if (opacity > 0.0)
              _buildRealisticStudioAura(
                centerX: chariotCenter.dx,
                centerY: chariotCenter.dy,
                scale: scale,
                color: isCelebration ? const Color(0xFFFFD700) : const Color(0xFFFFF9C4),
                radius: 240,
                opacity: isCelebration ? 0.70 : (0.42 * opacity),
              ),

            // Angel Chariot Actor (Ani3.png)
            if (opacity > 0.0)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.0012)
                          ..rotateY(rotY)
                          ..rotateX(rotX)
                          ..rotateZ(tiltAngle),
                        child: SizedBox(
                          width: chariotWidth,
                          height: chariotHeight,
                          child: _buildRealisticSpecularSheen(
                            progress: val,
                            lightColor: const Color(0xFFFFF9C4),
                            child: Image.asset(
                              _activeGift?.imageAssetPath ?? AppAssets.ani3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Top Gift Signature & Notification Card (Stage 6: 7.0 - 8.5s)
            if (sec >= 7.0 && sec < 8.6)
              Positioned(
                top: topPadding + 65,
                left: 16,
                right: 16,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xEE2A0E46), Color(0xDD5E1B8A), Color(0xEE20073B)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x88FFD700),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFD700),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF4A148C), size: 16),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: const AssetImage('assets/person.png'),
                            backgroundColor: Colors.white24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${_currentSenderName.isNotEmpty ? _currentSenderName : "You"} sent Angel Vehicle ×$_currentGiftCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Audio Controls & Timeline HUD Bar (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC0D0818),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x55FFD700), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getAngelStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getAngelStageTitle(double sec) {
    if (sec < 1.0) return '✦ 1. Magical Awakening';
    if (sec < 2.5) return '✦ 2. Angelic Formation';
    if (sec < 4.0) return '✦ 3. Full View & Float';
    if (sec < 5.5) return '✦ 4. Heavenly Flight';
    if (sec < 7.0) return '✦ 5. Celestial Blessing';
    if (sec < 8.5) return '✦ 6. Gift Signature';
    return '✦ 7. Fade & Return';
  }

  // ===========================================================================
  // 🏰💖 LOVE CASTLE - Mythic Storyboard Gift | 12.0 Seconds | Value: 100,000 Stars
  // Reference Storyboard 6-Stage Timeline:
  // 1. Magic Rising / Magic Circle (0.0s - 1.5s): Soft chimes + magical swirl
  // 2. Island Emerges / Floating Island Rise (1.5s - 3.0s): Gentle whoosh + nature ambience
  // 3. Building Towers / Castle Construction (3.0s - 5.0s): Crystal chimes + soft orchestral rise
  // 4. Heart Ignites / Heart Crystal Activation (5.0s - 7.0s): Warm chime + heartbeat pulse
  // 5. Fireworks / Fireworks Show (7.0s - 9.0s): Sparkle burst + light tinkles + 100,000 ⭐ score burst
  // 6. Final Glow / Final Reveal (9.0s - 12.0s): Gentle echo + heavenly chime
  // ===========================================================================
  Widget _buildLoveCastleAnimation() {
    return AnimatedBuilder(
      animation: _castleController,
      builder: (context, child) {
        final val = _castleController.value;
        final sec = val * 12.0; // 0.0s -> 12.0s
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final castleWidth = (screenWidth * 0.94).clamp(320.0, 520.0);
        final castleHeight = castleWidth * 0.92;
        final centerX = (screenWidth - castleWidth) / 2.0;
        final centerY = screenHeight * 0.44;

        double posY = centerY;
        double scale = 1.0;
        double opacity = 1.0;
        double circleOpacity = 0.0;
        double circleScale = 1.0;

        if (sec < 1.5) {
          // -------------------------------------------------------------------
          // STAGE 1: Magic Circle / Summon the Castle (0.0 - 1.5s)
          // Radiant pink circle forms on water with sparkling particles & light trails
          // -------------------------------------------------------------------
          final p = (sec / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeOutBack.transform(p);
          circleOpacity = (p * 1.2).clamp(0.0, 1.0);
          circleScale = 0.60 + (ease * 0.45);
          posY = centerY + 140.0;
          scale = 0.60;
          opacity = (p * 0.15).clamp(0.0, 0.15); // silhouette beneath circle
        } else if (sec < 3.0) {
          // -------------------------------------------------------------------
          // STAGE 2: Floating Island Rise / Foundation Forms (1.5 - 3.0s)
          // Island ascends with glowing edges, petals, mist & clouds
          // -------------------------------------------------------------------
          final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeOutCubic.transform(p);
          circleOpacity = ((1.0 - p) * 0.95).clamp(0.0, 0.95);
          circleScale = 1.05 + (p * 0.15);
          posY = centerY + 140.0 - (ease * 140.0);
          scale = 0.60 + (ease * 0.38);
          opacity = 0.15 + (ease * 0.75);
        } else if (sec < 5.0) {
          // -------------------------------------------------------------------
          // STAGE 3: Castle Construction / Castle Emerges (3.0 - 5.0s)
          // Towers and walls build up with magical particles and light streaks
          // -------------------------------------------------------------------
          final p = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          circleOpacity = 0.0;
          posY = centerY;
          scale = 0.98 + (sin(p * pi) * 0.06);
          opacity = 1.0;
        } else if (sec < 7.0) {
          // -------------------------------------------------------------------
          // STAGE 4: Heart Crystal Activation / Heart Lights Up (5.0 - 7.0s)
          // Central heart crystal ignites with glowing pink energy waves & heartbeat
          // -------------------------------------------------------------------
          final p = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          final pulse = (sin((sec - 5.0) * 4.0 * pi).abs()) * 0.045;
          posY = centerY;
          scale = 1.02 + pulse;
          opacity = 1.0;
        } else if (sec < 9.0) {
          // -------------------------------------------------------------------
          // STAGE 5: Fireworks Show / Fireworks & Magic (7.0 - 9.0s)
          // Heart-shaped fireworks burst with glittering particles, petals & 100k Stars
          // -------------------------------------------------------------------
          final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          posY = centerY + (sin(p * 2.0 * pi) * 3.0);
          scale = 1.05 + (sin(p * 2.0 * pi) * 0.02);
          opacity = 1.0;
        } else {
          // -------------------------------------------------------------------
          // STAGE 6: Final Reveal / Final Glow (9.0 - 12.0s)
          // Castle glows in full splendor floating above water with reflections
          // -------------------------------------------------------------------
          final p = ((sec - 9.0) / 3.0).clamp(0.0, 1.0);
          final floatBob = sin((sec - 9.0) * pi * 0.8) * 4.5;
          posY = centerY + floatBob;
          scale = 1.04;
          opacity = (sec > 10.8 ? (12.0 - sec) / 1.2 : 1.0).clamp(0.0, 1.0);
        }

        final castleCenter = Offset(centerX + (castleWidth * 0.50), posY + (castleHeight * 0.46));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Full-screen 6-Stage Mystical Love Castle Canvas (Runic circle, petals, shockwaves, fireworks, reflections)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _LoveCastleHeartsPainter(
                    progress: val,
                    sec: sec,
                    castleCenter: castleCenter,
                    castleWidth: castleWidth,
                    castleHeight: castleHeight,
                  ),
                ),
              ),
            ),

            // 2. Stage 1 & 2 Magic Summon Circle (AppAssets.loveCastleCircle)
            if (circleOpacity > 0.01)
              Positioned(
                left: centerX + (castleWidth * 0.05),
                top: centerY + (castleHeight * 0.42),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: circleOpacity,
                    child: Transform.scale(
                      scale: circleScale,
                      child: Transform.rotate(
                        angle: sec * 0.35,
                        child: Container(
                          width: castleWidth * 0.90,
                          height: (castleWidth * 0.90) * 0.55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4081).withValues(alpha: 0.65),
                                blurRadius: 42,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.loveCastleCircle,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Giant Pulsing Neon Heart Aura Behind Central Spire (Stages 3 - 6)
            if (sec >= 3.0 && opacity > 0.01)
              Positioned(
                left: castleCenter.dx - 170.0,
                top: castleCenter.dy - 190.0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (sec < 4.0
                            ? (sec - 3.0) / 1.0
                            : (sec > 10.8 ? (12.0 - sec) / 1.2 : 0.85))
                        .clamp(0.0, 0.85),
                    child: Container(
                      width: 340,
                      height: 320,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x99FF4081), blurRadius: 65, spreadRadius: 20),
                          BoxShadow(color: Color(0x66FF80AB), blurRadius: 45, spreadRadius: 8),
                          BoxShadow(color: Color(0x44FFD54F), blurRadius: 30, spreadRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Main Love Castle Actor (1:1 Cutout / Specular Sheen)
            if (opacity > 0.01)
              Positioned(
                left: centerX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: castleWidth,
                        height: castleHeight,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFF80AB),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.loveCastleActor,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              AppAssets.giftLoveCastle,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                AppAssets.ani5,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Stage 4 Heart Crystal Ignition Radiant Diamond Bloom (Pure crystal starburst lighting, no emojis)
            if (sec >= 4.8 && sec <= 8.5)
              Positioned(
                left: castleCenter.dx - 36.0,
                top: castleCenter.dy - (castleHeight * 0.43),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (sec < 5.2
                            ? (sec - 4.8) / 0.4
                            : (sec > 8.0 ? (8.5 - sec) / 0.5 : 0.85))
                        .clamp(0.0, 0.85),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            const Color(0xFFFF80AB).withValues(alpha: 0.60),
                            const Color(0xFFFF1493).withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4081).withValues(alpha: 0.55),
                            blurRadius: 28,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Stage 5 Floating 100,000 ⭐ Score Celebration Badge
            if (sec >= 7.0 && sec <= 9.3)
              Positioned(
                left: 0,
                right: 0,
                top: posY - 50.0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (sec < 7.3
                            ? (sec - 7.0) / 0.3
                            : (sec > 8.9 ? (9.3 - sec) / 0.4 : 1.0))
                        .clamp(0.0, 1.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF1493), Color(0xFFFF80AB), Color(0xFFFFD54F)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x99FF1493),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 18),
                            SizedBox(width: 5),
                            Text(
                              '100,000 STARS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 7. Signature Top Gift Notification Card (Storyboard: Live Gift Flow — User to Creator)
            if (sec >= 1.2 && sec <= 11.5)
              _buildLoveCastleTopBanner(sec),

            // 8. Bottom Sound Timeline & Audio HUD Bar
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC20051E),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFFF4081), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FF4081),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFFF4081), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getLoveCastleStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0x66FF1744)
                                  : const Color(0x44FF4081),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              GiftSoundService.instance.isMuted ? 'UNMUTE' : 'MUTE',
                              style: TextStyle(
                                color: GiftSoundService.instance.isMuted
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFFFF80AB),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoveCastleTopBanner(double sec) {
    final bannerOpacity = (sec < 1.8
            ? (sec - 1.2) / 0.6
            : (sec > 10.8 ? (11.5 - sec) / 0.7 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD3A0A30),
                      Color(0xDD560E45),
                      Color(0xDD240720),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF4081).withValues(alpha: 0.75),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FF4081),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender Avatar / Love Castle Icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF20051E),
                          child: const Center(
                            child: Icon(
                              Icons.castle_rounded,
                              color: Color(0xFFFF80AB),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Anju'} sent',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Love Castle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$_currentGiftCount',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFF4081),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '100,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFFFF80AB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'LOVE ✦ DREAMS ✦ FOREVER',
                          style: TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLoveCastleStageTitle(double sec) {
    if (sec < 1.5) return '✦ 1. Magic Circle (0 - 1.5s)';
    if (sec < 3.0) return '✦ 2. Floating Island Rise (1.5 - 3s)';
    if (sec < 5.0) return '✦ 3. Castle Construction (3 - 5s)';
    if (sec < 7.0) return '✦ 4. Heart Crystal Activation (5 - 7s)';
    if (sec < 9.0) return '✦ 5. Fireworks Show (7 - 9s)';
    return '✦ 6. Final Reveal (9 - 12s)';
  }

  // ===========================================================================
  // 👑✨ STAR THRONE ("POWER & ROYALTY - Live Animated Gift")
  // Storyboard 6 Stages (10.0 Seconds Total):
  //  1. (0.0 – 1.5s): 1. Star Descent (A radiant star falls from the sky, creating a magical trail)
  //  2. (1.5 – 3.0s): 2. Energy Spiral (The star spins and releases cosmic energy waves)
  //  3. (3.0 – 5.0s): 3. Throne Formation (The throne assembles with light and golden particles)
  //  4. (5.0 – 7.0s): 4. Rise to Power (The throne elevates with celestial rings and glow)
  //  5. (7.0 – 9.0s): 5. Royal Accession (Wings and crown appear with brilliant light effects)
  //  6. (9.0 – 10.0s): 6. Final Glow (The throne settles with a lasting star glow)
  // ===========================================================================
  Widget _buildStarThroneAnimation() {
    return AnimatedBuilder(
      animation: _throneController,
      builder: (context, child) {
        final val = _throneController.value;
        final sec = val * 10.0;
        final size = MediaQuery.sizeOf(context);
        final screenWidth = size.width;
        final screenHeight = size.height;

        // Dynamic Throne Dimensions (Majestic coverage ~78% screen width)
        final throneWidth = (screenWidth * 0.78).clamp(300.0, 520.0);
        final throneHeight = throneWidth * 1.05;

        final centerThroneX = (screenWidth - throneWidth) * 0.50;
        final centerThroneY = screenHeight * 0.44;

        // Stage Time Envelopes
        final isStage1 = sec < 1.5;              // 1. Star Descent
        final isStage2 = sec >= 1.5 && sec < 3.0; // 2. Energy Spiral
        final isStage3 = sec >= 3.0 && sec < 5.0; // 3. Throne Formation
        final isStage4 = sec >= 5.0 && sec < 7.0; // 4. Rise to Power
        final isStage5 = sec >= 7.0 && sec < 9.0; // 5. Royal Accession
        final isStage6 = sec >= 9.0;              // 6. Final Glow

        // Overall Opacity envelope
        final masterOpacity = (sec < 0.2
                ? (sec / 0.2)
                : (sec > 9.4 ? (1.0 - (sec - 9.4) / 0.6) : 1.0))
            .clamp(0.0, 1.0);

        // Stage 1 Descent Focal Point (Shooting Star Position)
        final double starX;
        final double starY;
        if (isStage1) {
          final p1 = (sec / 1.5).clamp(0.0, 1.0);
          final easeP1 = Curves.easeOutCubic.transform(p1);
          starX = screenWidth * 0.65 - (easeP1 * (screenWidth * 0.15));
          starY = screenHeight * 0.06 + (easeP1 * (centerThroneY + throneHeight * 0.20 - screenHeight * 0.06));
        } else {
          starX = screenWidth * 0.50;
          starY = centerThroneY + throneHeight * 0.22;
        }

        // Throne Formation & Elevation Kinematics
        double currentThroneY = centerThroneY;
        double currentThroneScale = 1.0;
        double throneOpacity = 0.0;
        double runeScale = 0.0;
        double runeOpacity = 0.0;
        double wingsSpread = 0.0;
        double crownFlareAlpha = 0.0;

        if (isStage1 || isStage2) {
          throneOpacity = 0.0;
        } else if (isStage3) {
          // Throne Formation: Rune platform lights up on ground, particles rise
          final p3 = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          runeScale = 0.60 + Curves.easeOutBack.transform(p3) * 0.40;
          runeOpacity = (p3 * 1.5).clamp(0.0, 1.0);
          currentThroneY = centerThroneY + (1.0 - p3) * 50.0;
          currentThroneScale = 0.88 + (p3 * 0.08);
          throneOpacity = (p3 * 0.85).clamp(0.0, 1.0);
        } else if (isStage4) {
          // Rise to Power: Throne elevates with celestial rings & glow
          final p4 = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          final easeP4 = Curves.easeInOutCubic.transform(p4);
          runeScale = 1.0;
          runeOpacity = (1.0 - (p4 * 0.4)).clamp(0.0, 1.0);
          currentThroneY = (centerThroneY + 40.0) - (easeP4 * 40.0);
          currentThroneScale = 0.96 + (easeP4 * 0.08);
          throneOpacity = 1.0;
          wingsSpread = 0.35 + (p4 * 0.40);
        } else if (isStage5) {
          // Royal Accession: Wings and star crown blaze with brilliant light
          final p5 = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          runeScale = 0.95;
          runeOpacity = 0.65;
          currentThroneY = centerThroneY + sin(p5 * 2 * pi) * 3.0;
          currentThroneScale = 1.04 + sin(p5 * pi) * 0.04;
          throneOpacity = 1.0;
          wingsSpread = 1.0;
          crownFlareAlpha = (sin(p5 * pi * 1.5)).clamp(0.0, 1.0);
        } else {
          // Final Glow: Serene royal hover & soft lasting glow
          final p6 = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          runeScale = 0.90;
          runeOpacity = (0.60 * (1.0 - p6)).clamp(0.0, 1.0);
          currentThroneY = centerThroneY + sin(p6 * pi) * 2.0;
          currentThroneScale = 1.04;
          throneOpacity = (1.0 - (p6 * 0.15)).clamp(0.0, 1.0);
          wingsSpread = 1.0;
          crownFlareAlpha = 0.40 * (1.0 - p6);
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: masterOpacity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Full-Screen Celestial Starlight & Cosmic Aura
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, (centerThroneY / screenHeight) * 2 - 1),
                          radius: 0.90,
                          colors: [
                            const Color(0xFF1E3A8A).withValues(alpha: 0.35), // Deep Royal Celestial Blue
                            const Color(0xFFD97706).withValues(alpha: 0.18), // Imperial Amber Gold
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.60, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Custom Painter: Star Descent Trail, Energy Spiral Waves, Light Pillars, Celestial Orbit Rings
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: _StarThroneCosmicPainter(
                      progress: val,
                      sec: sec,
                      starPos: Offset(starX, starY),
                      throneCenter: Offset(screenWidth * 0.50, centerThroneY + throneHeight * 0.50),
                      throneWidth: throneWidth,
                      throneHeight: throneHeight,
                      isAccession: isStage5,
                    ),
                  ),

                  // 3. Stage 3 & 4: Glowing Magic Circle Rune Platform on Ground
                  if (runeOpacity > 0.0)
                    Positioned(
                      left: (screenWidth - throneWidth * 1.15) * 0.50,
                      top: centerThroneY + throneHeight * 0.52,
                      width: throneWidth * 1.15,
                      height: throneHeight * 0.55,
                      child: Opacity(
                        opacity: runeOpacity,
                        child: Transform.scale(
                          scale: runeScale,
                          child: Image.asset(
                            AppAssets.starThroneRune,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // 4. Grand Star Throne Actor (Royal Blue Velvet + Sculpted Gold Wings + Crown)
                  if (throneOpacity > 0.0)
                    Positioned(
                      left: centerThroneX,
                      top: currentThroneY,
                      width: throneWidth,
                      height: throneHeight,
                      child: Opacity(
                        opacity: throneOpacity,
                        child: Transform.scale(
                          scale: currentThroneScale,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Royal Golden Aura Glow Behind Throne
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.40 * throneOpacity),
                                      blurRadius: 54,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.35 * throneOpacity),
                                      blurRadius: 42,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),

                              // High Definition Star Throne 3D Render
                              Image.asset(
                                AppAssets.starThroneActor,
                                width: throneWidth,
                                height: throneHeight,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  AppAssets.ani4,
                                  width: throneWidth,
                                  height: throneHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),

                              // Specular Celestial Light Sheen across Throne
                              _buildRealisticSpecularSheen(
                                progress: val,
                                lightColor: const Color(0xFFFFE082),
                                child: Container(
                                  width: throneWidth,
                                  height: throneHeight,
                                  color: Colors.transparent,
                                ),
                              ),

                              // Stage 5 & 6: Blazing 8-Pointed Star Crown Supernova Lens Flare at Top Pinnacle
                              if (crownFlareAlpha > 0.0)
                                Positioned(
                                  top: throneHeight * 0.06,
                                  child: Opacity(
                                    opacity: crownFlareAlpha,
                                    child: Transform.scale(
                                      scale: 1.0 + crownFlareAlpha * 0.35,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFFF9C4),
                                              blurRadius: 28,
                                              spreadRadius: 10,
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                                              blurRadius: 48,
                                              spreadRadius: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 5. Dedicated Star Throne Top Banner (Matching Storyboard Panels 4, 5, 6)
                  if (widget.showTopBanner)
                    _buildStarThroneTopBanner(sec),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getStarThroneStageTitle(double sec) {
    if (sec < 1.5) return '1. Star Descent • Radiant Stardust Trail';
    if (sec < 3.0) return '2. Energy Spiral • Cosmic Energy Waves';
    if (sec < 5.0) return '3. Throne Formation • Golden Rune & Pillars';
    if (sec < 7.0) return '4. Rise to Power • Celestial Rings & Glow';
    if (sec < 9.0) return '5. Royal Accession • Majestic Wings & Star Crown';
    return '6. Final Glow • Lasting Star Radiance';
  }

  Widget _buildStarThroneTopBanner(double sec) {
    final sender = _currentSenderName.isNotEmpty ? _currentSenderName : 'Ravi';
    final count = _currentGiftCount > 1 ? ' x${_currentGiftCount}' : ' x1';
    final isImpactActive = sec >= 7.0 && sec <= 8.8;

    final bannerOpacity = (sec < 0.6
            ? (sec / 0.6)
            : (sec > 9.3 ? (10.0 - sec) / 0.7 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xEE0B192C), // Deep Midnight Royal Blue
                      Color(0xEE1E1B4B), // Galactic Indigo
                      Color(0xEE312E81), // Imperial Star Velvet
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isImpactActive
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFFFD700).withValues(alpha: 0.70),
                    width: isImpactActive ? 2.2 : 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x88FFD700),
                      blurRadius: isImpactActive ? 24 : 16,
                      spreadRadius: isImpactActive ? 3 : 1,
                    ),
                    BoxShadow(
                      color: const Color(0x661E3A8A),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Royal Golden Star Crest Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFD700),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$sender sent Star Throne$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '5,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFF1E1B4B),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStarThroneStageTitle(sec),
                              style: TextStyle(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.95),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isImpactActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '+5000 Stars Impact!',
                                  style: TextStyle(
                                    color: Color(0xFF1E1B4B),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ===========================================================================
  // 🏎️ LUXURY CAR (Ani6.png) - 3D Animation Sequence matching Approved Storyboard
  // 6 Stages across 10 Seconds | Audio: Engine Start -> Rev -> Drive -> Drift -> Celebration -> Exit
  // 1: 0 - 1 sec: Car Enters from Left across dark reflective highway
  // 2: 1 - 2 sec: Engine Rev & Speed Up with tire smoke and speed streaks
  // 3: 2 - 4 sec: 3D Drift & Spin Movement with asphalt friction sparks
  // 4: 4 - 6 sec: Full Screen Celebration Effects (Neon Portal Ring & Fireworks)
  // 5: 6 - 8 sec: Floating Golden Crown & Center User Name Display with Gift Count
  // 6: 8 - 10 sec: Car Exit with Shockwave, Particle Trails & Smooth Fade
  // ===========================================================================
  Widget _buildSparklingCarAnimation() {
    return AnimatedBuilder(
      animation: _carController,
      builder: (context, child) {
        final val = _carController.value;
        final sec = val * 10.0; // 0.0 to 10.0 seconds
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double carWidth = 300.0;
        final double carHeight = 185.0;
        final double centerX = (screenWidth - carWidth) / 2;
        final double centerY = screenHeight * 0.48;

        double posX;
        double posY;
        double scale;
        double tiltAngle;
        double opacity = 1.0;
        bool isDrifting = false;
        bool isCelebration = false;
        bool isExit = false;
        bool showCenterBadge = false;

        if (sec < 1.0) {
          // ① 0 - 1 sec: Car Enters from Left/Right
          final p = Curves.easeOutCubic.transform(sec / 1.0);
          final startX = -carWidth - 40.0;
          final targetX = screenWidth * 0.10;
          posX = startX + p * (targetX - startX);
          posY = centerY + 24.0 - p * 12.0;
          scale = 0.88 + p * 0.22;
          tiltAngle = -0.05 * (1.0 - p * 0.5);
          opacity = (p * 3.0).clamp(0.0, 1.0);
        } else if (sec < 2.0) {
          // ② 1 - 2 sec: Engine Rev & Speed Up
          final p = Curves.easeInOutQuad.transform((sec - 1.0) / 1.0);
          final startX = screenWidth * 0.10;
          final targetX = screenWidth * 0.28;
          posX = startX + p * (targetX - startX);
          posY = centerY + 12.0 - p * 12.0;
          scale = 1.10 + p * 0.10;
          // Suspension squats forward on rev
          tiltAngle = -0.09 * sin(p * pi);
        } else if (sec < 4.0) {
          // ③ 2 - 4 sec: Drift & Spin (3D Movement)
          final p = (sec - 2.0) / 2.0;
          isDrifting = true;
          // Wide 3D lateral sweep across screen
          final driftX = sin(p * pi) * (screenWidth * 0.26);
          final driftY = -sin(p * 2 * pi) * 16.0;
          posX = centerX + driftX;
          posY = centerY + driftY;
          scale = 1.20 + sin(p * pi) * 0.12;
          // Dramatic 3D drift swing angle
          tiltAngle = sin(p * pi * 1.5) * 0.38;
        } else if (sec < 6.0) {
          // ④ 4 - 6 sec: Full Screen Celebration Effects
          final p = (sec - 4.0) / 2.0;
          isCelebration = true;
          posX = centerX;
          posY = centerY + sin(p * 2 * pi) * 3.5;
          scale = 1.28 + sin(p * pi) * 0.04;
          tiltAngle = sin(p * 2 * pi) * 0.02;
        } else if (sec < 8.0) {
          // ⑤ 6 - 8 sec: User Name Display with Gift Count
          final p = (sec - 6.0) / 2.0;
          isCelebration = true;
          showCenterBadge = true;
          posX = centerX;
          posY = centerY + sin(p * 2 * pi) * 2.5;
          scale = 1.28;
          tiltAngle = 0.0;
        } else {
          // ⑥ 8 - 10 sec: Car Exit with Particles
          final p = ((sec - 8.0) / 2.0).clamp(0.0, 1.0);
          isExit = true;
          final accel = Curves.easeInCubic.transform(p);
          final endX = screenWidth + carWidth + 50.0;
          posX = centerX + accel * (endX - centerX);
          posY = centerY - p * 28.0;
          scale = 1.28 - p * 0.38;
          tiltAngle = 0.08 + p * 0.08;
          opacity = (1.0 - accel * 1.25).clamp(0.0, 1.0);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Road, Highway, Headlight Cones, Tire Smoke, Neon Rings & Fireworks
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _SparklingCarHighwayPainter(
                    progress: val,
                    sec: sec,
                    carCenter: Offset(posX + carWidth / 2, posY + carHeight / 2),
                    isDrifting: isDrifting,
                    isCelebration: isCelebration,
                    isExit: isExit,
                  ),
                ),
              ),
            ),

            // Luxury Car Actor (Ani6.png) with realistic specular sheen & reflections
            Positioned(
              left: posX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: tiltAngle,
                      child: SizedBox(
                        width: carWidth,
                        height: carHeight,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFD700),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.ani6,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Stage 5 Center User Name Display with Gift Count (Screen 5 of storyboard)
            if (showCenterBadge)
              Positioned(
                top: screenHeight * 0.20,
                left: 16,
                right: 16,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 450),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, scaleVal, child) {
                      return Transform.scale(
                        scale: scaleVal,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Floating Golden Crown with radiant bloom
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xAAFFD700),
                                blurRadius: 22,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.ani7,
                              width: 42,
                              height: 42,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Text('👑', style: TextStyle(fontSize: 34)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Center Deluxe Glowing Badge matching Screen 5 in Reference Image
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xF2120C22),
                                Color(0xF2281545),
                                Color(0xF216092C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 2.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x99FFD700),
                                blurRadius: 26,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Color(0x66FF2D78),
                                blurRadius: 40,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Avatar circle with 24K gold border
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 2.0,
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/avatar_arun.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Sender Name & "sent Luxury Car"
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentSenderName.isNotEmpty
                                            ? _currentSenderName
                                            : 'Arjun',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'sent Luxury Car',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('⭐', style: TextStyle(fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(_activeGift?.diamonds ?? 500) * _currentGiftCount} Stars to $_currentRecipient',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Luxury Car 3D thumbnail icon
                              Image.asset(
                                AppAssets.ani6,
                                width: 38,
                                height: 26,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),

                              // "x1" or "xN" count pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'x$_currentGiftCount',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 💎 DIAMOND WINGS ("Grace in Motion - Live Animated Gift")
  // Storyboard 6 Stages (10.0 Seconds Total):
  //  1. (0.0 – 1.0s): Prism Awakening (single crystal catches narrow beam of light)
  //  2. (1.0 – 2.5s): Feather Assembly (small faceted feathers align with precise movement)
  //  3. (2.5 – 4.0s): Wings Unfold (left & right wings open symmetrically with controlled easing)
  //  4. (4.0 – 6.0s): Refraction Sweep (light streak travels across facets with natural caustics)
  //  5. (6.0 – 8.0s): Full Radiance (wings hold in majestic pose with soft halo & sparse motes)
  //  6. (8.0 – 10.0s): Graceful Dissolve (light contracts to center gemstone & fades into motes)
  // ===========================================================================
  Widget _buildDiamondWingsAnimation() {
    return AnimatedBuilder(
      animation: _wingsController,
      builder: (context, child) {
        final val = _wingsController.value;
        final sec = val * 10.0; // 0.0s -> 10.0s
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final normalWidth = (screenWidth * 0.90).clamp(320.0, 520.0);
        final normalHeight = normalWidth;

        double wingsWidth = normalWidth;
        double wingsHeight = normalHeight;
        double globalScale = 1.0;
        double leftAngle = 0.0;
        double rightAngle = 0.0;
        double leftScaleX = 1.0;
        double rightScaleX = 1.0;
        double leftScaleY = 1.0;
        double rightScaleY = 1.0;
        double leftYPerspective = 0.0;
        double rightYPerspective = 0.0;
        double wingsOpacity = 1.0;
        double shineSweepOffset = -1.5;
        bool isPrismAwakening = false;
        double prismScale = 1.0;
        double prismOpacity = 0.0;

        if (sec < 1.0) {
          // -------------------------------------------------------------------
          // STAGE 1: Prism Awakening (0 - 1.0s)
          // A single crystal catches a narrow beam of celestial blue light.
          // -------------------------------------------------------------------
          isPrismAwakening = true;
          final p = (sec / 1.0).clamp(0.0, 1.0);
          prismOpacity = (p * 1.5).clamp(0.0, 1.0);
          prismScale = 0.75 + (p * 0.35);
          wingsOpacity = 0.0;
        } else if (sec < 2.5) {
          // -------------------------------------------------------------------
          // STAGE 2: Feather Assembly (1.0 - 2.5s)
          // Small faceted feathers align with precise movement around center.
          // -------------------------------------------------------------------
          final p = ((sec - 1.0) / 1.5).clamp(0.0, 1.0);
          final alignP = Curves.easeOutCubic.transform(p);
          wingsOpacity = (alignP * 0.95).clamp(0.0, 0.95);
          globalScale = 0.85 + (alignP * 0.15);
          // Feathers folded tight while assembling
          leftAngle = -0.75 * (1.0 - alignP * 0.25);
          rightAngle = 0.75 * (1.0 - alignP * 0.25);
          leftScaleX = 0.30 + (alignP * 0.30);
          rightScaleX = 0.30 + (alignP * 0.30);
          leftYPerspective = 0.35 * (1.0 - alignP * 0.2);
          rightYPerspective = 0.35 * (1.0 - alignP * 0.2);
        } else if (sec < 4.0) {
          // -------------------------------------------------------------------
          // STAGE 3: Wings Unfold (2.5 - 4.0s)
          // Left and right wings open symmetrically with controlled easing.
          // -------------------------------------------------------------------
          final p = ((sec - 2.5) / 1.5).clamp(0.0, 1.0);
          final unfoldCurve = Curves.easeOutBack.transform(p);
          wingsOpacity = 1.0;
          globalScale = 0.96 + (unfoldCurve * 0.12);
          leftAngle = -0.56 * (1.0 - unfoldCurve);
          rightAngle = 0.56 * (1.0 - unfoldCurve);
          leftScaleX = 0.55 + (unfoldCurve * 0.45);
          rightScaleX = 0.55 + (unfoldCurve * 0.45);
          leftYPerspective = 0.28 * (1.0 - unfoldCurve);
          rightYPerspective = 0.28 * (1.0 - unfoldCurve);
        } else if (sec < 6.0) {
          // -------------------------------------------------------------------
          // STAGE 4: Refraction Sweep (4.0 - 6.0s)
          // A light streak travels across the facets with natural caustics & depth.
          // -------------------------------------------------------------------
          final p = ((sec - 4.0) / 2.0).clamp(0.0, 1.0);
          wingsOpacity = 1.0;
          globalScale = 1.08 + sin(p * pi) * 0.05;
          leftAngle = 0.0;
          rightAngle = 0.0;
          leftScaleX = 1.0;
          rightScaleX = 1.0;
          // Shimmering caustics streak sweeping across the facets
          shineSweepOffset = -1.2 + (p * 2.8);
        } else if (sec < 8.0) {
          // -------------------------------------------------------------------
          // STAGE 5: Full Radiance (6.0 - 8.0s)
          // Wings hold in a majestic pose with soft halo and sparse crystal motes.
          // -------------------------------------------------------------------
          final p = ((sec - 6.0) / 2.0).clamp(0.0, 1.0);
          wingsOpacity = 1.0;
          // Majestic breathing idle pose
          globalScale = 1.10 + (sin(p * 2.0 * pi) * 0.025);
          leftAngle = sin(p * 2.0 * pi) * 0.03;
          rightAngle = -sin(p * 2.0 * pi) * 0.03;
          leftScaleX = 1.0;
          rightScaleX = 1.0;
        } else {
          // -------------------------------------------------------------------
          // STAGE 6: Graceful Dissolve (8.0 - 10.0s)
          // Light contracts to center gemstone and dissolves into floating motes.
          // -------------------------------------------------------------------
          final p = ((sec - 8.0) / 2.0).clamp(0.0, 1.0);
          globalScale = 1.10 - (p * 0.35);
          wingsOpacity = (1.0 - (p * 1.3)).clamp(0.0, 1.0);
          leftAngle = -0.40 * p;
          rightAngle = 0.40 * p;
          leftScaleX = 1.0 - (p * 0.50);
          rightScaleX = 1.0 - (p * 0.50);
        }

        final centerY = screenHeight * 0.45;
        final posX = (screenWidth - wingsWidth) / 2.0;
        final posY = centerY - (wingsHeight * 0.48);
        final wingsCenter = Offset(posX + (wingsWidth * 0.50), posY + (wingsHeight * 0.50));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. CELESTIAL PRISMATIC CANVAS & LIGHT EFFECTS (All 6 Stages)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _DiamondWingsPrismPainter(
                    progress: val,
                    sec: sec,
                    wingsCenter: wingsCenter,
                    wingsWidth: wingsWidth,
                    wingsHeight: wingsHeight,
                  ),
                ),
              ),
            ),

            // 2. STAGE 1 SINGLE PRISM CRYSTAL (0 - 1.0s)
            if (isPrismAwakening && prismOpacity > 0.01)
              Positioned(
                left: wingsCenter.dx - 110.0,
                top: wingsCenter.dy - 110.0,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: prismOpacity,
                    child: Transform.scale(
                      scale: prismScale,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.65),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.diamondWingsPrism,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.asset(
                            AppAssets.giftDiamondWings,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. MAIN SKELETAL 3D WINGS ACTOR (Stages 2 - 6)
            if (wingsOpacity > 0.01)
              Positioned(
                left: posX,
                top: posY,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: wingsOpacity,
                    child: Transform.scale(
                      scale: globalScale,
                      child: _buildDiamondWingsSliceRig(
                        wingsWidth: wingsWidth,
                        wingsHeight: wingsHeight,
                        leftAngle: leftAngle,
                        rightAngle: rightAngle,
                        leftScaleX: leftScaleX,
                        rightScaleX: rightScaleX,
                        leftScaleY: leftScaleY,
                        rightScaleY: rightScaleY,
                        leftYPerspective: leftYPerspective,
                        rightYPerspective: rightYPerspective,
                        shineSweepOffset: shineSweepOffset,
                      ),
                    ),
                  ),
                ),
              ),

            // 4. SIGNATURE TOP GIFT NOTIFICATION CARD (Storyboard Steps 4 - 6)
            if (sec >= 1.5 && sec <= 9.8)
              _buildDiamondWingsTopBanner(sec),

            // 5. AUDIO CONTROLS & TIMELINE HUD BAR AT BOTTOM (matching Reference Image)
            Positioned(
              bottom: 92,
              left: 12,
              right: 12,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xCC060F24),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0x6600E5FF), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFF00E5FF), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _getDiamondWingsStageTitle(sec),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              GiftSoundService.instance.toggleMute();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GiftSoundService.instance.isMuted
                                  ? const Color(0xFFFF2D78)
                                  : Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: GiftSoundService.instance.isMuted
                                    ? Colors.transparent
                                    : Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  GiftSoundService.instance.isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  GiftSoundService.instance.isMuted ? 'Muted' : 'Mute Option',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiamondWingsTopBanner(double sec) {
    final bannerOpacity = (sec < 2.0
            ? (sec - 1.5) / 0.5
            : (sec > 9.2 ? (9.8 - sec) / 0.6 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD0A1128),
                      Color(0xDD121F45),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x6600E5FF),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sender Avatar / Diamond Wings Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF060D20),
                          child: const Center(
                            child: Text(
                              '💎',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Anju'} sent',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Diamond Wings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E5FF), Color(0xFF2979FF)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$_currentGiftCount',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '10,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'GRACE IN MOTION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDiamondWingsStageTitle(double sec) {
    if (sec < 1.0) {
      return '✦ 1. Prism Awakening (0 - 1s)';
    } else if (sec < 2.5) {
      return '✦ 2. Feather Assembly (1 - 2.5s)';
    } else if (sec < 4.0) {
      return '✦ 3. Wings Unfold (2.5 - 4s)';
    } else if (sec < 6.0) {
      return '✦ 4. Refraction Sweep (4 - 6s)';
    } else if (sec < 8.0) {
      return '✦ 5. Full Radiance (6 - 8s)';
    } else {
      return '✦ 6. Graceful Dissolve (8 - 10s)';
    }
  }

  /// Skeletal Slice Rig for Diamond Wings: Left & Right wings hinged at center with 3D depth
  Widget _buildDiamondWingsSliceRig({
    required double wingsWidth,
    required double wingsHeight,
    required double leftAngle,
    required double rightAngle,
    required double leftScaleX,
    required double rightScaleX,
    required double leftScaleY,
    required double rightScaleY,
    required double leftYPerspective,
    required double rightYPerspective,
    required double shineSweepOffset,
  }) {
    final wingsAsset = AppAssets.diamondWingsHero;

    Widget buildRigContent() {
      return SizedBox(
        width: wingsWidth,
        height: wingsHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Core luminous aura behind wings
            Container(
              width: wingsWidth * 0.70,
              height: wingsHeight * 0.70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00E5FF).withValues(alpha: 0.40),
                    const Color(0xFF2979FF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            // Symmetrical 3D wings actor with specular shine
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..scale((leftScaleX + rightScaleX) * 0.5, (leftScaleY + rightScaleY) * 0.5)
                ..rotateZ((leftAngle + rightAngle) * 0.5),
              child: Image.asset(
                wingsAsset,
                width: wingsWidth,
                height: wingsHeight,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset(
                  AppAssets.giftDiamondWings,
                  width: wingsWidth,
                  height: wingsHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Iridescent shine sweep across wings during Refraction Sweep (Stage 4)
    if (shineSweepOffset > -1.0 && shineSweepOffset < 2.0) {
      return ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1.5 + shineSweepOffset, -0.3),
            end: Alignment(0.5 + shineSweepOffset, 0.3),
            colors: [
              Colors.white.withValues(alpha: 0.0),
              const Color(0xFF80D8FF).withValues(alpha: 0.70),
              Colors.white,
              const Color(0xFFEA80FC).withValues(alpha: 0.70),
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: buildRigContent(),
      );
    }

    return buildRigContent();
  }

  // ===========================================================================
  // 🌹 ROSES ("LOVE • PASSION • ETERNITY - Scattered Sky Full of Roses")
  // Storyboard 6 Stages (12.0 Seconds Total - No Bunches, Scattered Across Screen):
  //  1. (0.0 – 1.5s): 1. First Petal (A single glowing rose petal appears, floating gently)
  //  2. (1.5 – 3.0s): 2. Petals Multiply (The petal splits into many, releasing trail of shimmering light)
  //  3. (3.0 – 5.0s): 3. Roses Bloom in Motion (Roses of different sizes bloom and scatter across screen)
  //  4. (5.0 – 8.0s): 4. Swirling Elegance (Petals and roses dance in circular waves, filling scene)
  //  5. (8.0 – 11.0s): 5. Full Screen Bloom (Screen fills with floating roses, dreamy romantic atmosphere)
  //  6. (11.0 – 12.0s): 6. Fade & Glow (The petals slowly drift and fade, leaving soft lingering glow)
  // ===========================================================================
  Widget _buildRosesAnimation() {
    return AnimatedBuilder(
      animation: _rosesController,
      builder: (context, child) {
        final val = _rosesController.value;
        final sec = val * 12.0;
        final size = MediaQuery.sizeOf(context);
        final screenWidth = size.width;
        final screenHeight = size.height;

        // Overall Opacity envelope
        final masterOpacity = (sec < 0.2
                ? (sec / 0.2)
                : (sec > 11.4 ? (12.0 - sec) / 0.6 : 1.0))
            .clamp(0.0, 1.0);

        // Center origin for the initial single glowing petal
        final singlePetalOrigin = Offset(screenWidth * 0.50, screenHeight * 0.44);

        return Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: masterOpacity,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // 1. Ambient Romantic Twilight Glow Aura
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, (singlePetalOrigin.dy / screenHeight) * 2 - 1),
                          radius: 0.95,
                          colors: [
                            const Color(0xFFE11D48).withValues(alpha: 0.28), // Velvet Rose
                            const Color(0xFFBE185D).withValues(alpha: 0.16), // Pink Aura
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.60, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Custom Painter: Particle trails, star sparkles, circular waves & petal shower
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: _RosesStoryPainter(
                      progress: val,
                      sec: sec,
                      bouquetCenter: singlePetalOrigin,
                      bouquetWidth: screenWidth * 0.8,
                      bouquetHeight: screenHeight * 0.5,
                    ),
                  ),

                  // 3. STEP 1 & 2: Single Glowing Rose Petal & Multiplying Petals (0.0 - 3.2s)
                  if (sec < 3.2)
                    ..._buildInitialGlowingPetals(sec, screenWidth, screenHeight, singlePetalOrigin),

                  // 4. STEP 3, 4, 5, 6: Scattered Blooming Roses of Different Sizes (NO BUNCH/NO BOUQUET)
                  if (sec >= 2.8)
                    ..._buildScatteredRosesOfDifferentSizes(sec, screenWidth, screenHeight, singlePetalOrigin),

                  // 5. Dedicated Roses Top Banner (Matching Storyboard & 100,000 Stars Value)
                  if (widget.showTopBanner)
                    _buildRosesTopBanner(sec),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildInitialGlowingPetals(double sec, double screenWidth, double screenHeight, Offset center) {
    final widgets = <Widget>[];

    if (sec < 1.5) {
      // STEP 1: Single Glowing Rose Petal (0.0 - 1.5s)
      final p1 = (sec / 1.5).clamp(0.0, 1.0);
      final petalScale = 0.85 + (sin(sec * 3.5) * 0.08) + Curves.easeOutBack.transform(p1.clamp(0.0, 0.8)) * 0.25;
      final petalRot = sin(sec * 2.2) * 0.12;
      final petalOpacity = (p1 * 1.8).clamp(0.0, 1.0);
      const petalSize = 135.0;

      widgets.add(
        Positioned(
          left: center.dx - petalSize / 2,
          top: center.dy - petalSize / 2 + sin(sec * 2.8) * 12.0,
          width: petalSize,
          height: petalSize,
          child: Opacity(
            opacity: petalOpacity,
            child: Transform.rotate(
              angle: petalRot,
              child: Transform.scale(
                scale: petalScale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glowing soft halo
                    Container(
                      width: petalSize * 0.85,
                      height: petalSize * 0.85,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4081).withValues(alpha: 0.65),
                            blurRadius: 38,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      AppAssets.roseSinglePetal,
                      width: petalSize,
                      height: petalSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('🌸', style: TextStyle(fontSize: 60)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // STEP 2: Petals Multiply (1.5 - 3.0s)
      final p2 = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
      final alpha2 = (1.0 - (p2 * 0.7)).clamp(0.0, 1.0);

      for (int i = 0; i < 7; i++) {
        final splitPhase = (i / 7.0);
        final spreadR = Curves.easeOutCubic.transform(p2) * (140.0 + (i * 24.0));
        final angle = (splitPhase * 2 * pi) + (p2 * 1.4);
        final px = center.dx + cos(angle) * spreadR;
        final py = center.dy + sin(angle) * spreadR * 0.65 + (p2 * 35.0);
        final pScale = (0.75 - (splitPhase * 0.3)) * (1.0 - p2 * 0.25);

        widgets.add(
          Positioned(
            left: px - 45,
            top: py - 45,
            width: 90,
            height: 90,
            child: Opacity(
              opacity: alpha2,
              child: Transform.rotate(
                angle: angle + (sec * 2.0),
                child: Transform.scale(
                  scale: pScale,
                  child: Image.asset(
                    AppAssets.roseSinglePetal,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text('🌸', style: TextStyle(fontSize: 34)),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // 22 Deterministically positioned scattered roses of different sizes and depths
  static final List<_ScatteredRoseConfig> _scatteredRoseConfigs = [
    // (normX, normY, size, isPink, bloomDelay, swaySpeed, swayAmp, curveT, layer)
    _ScatteredRoseConfig(0.18, 0.42, 78.0, false, 0.05, 1.8, 14.0, 0.12, 1),
    _ScatteredRoseConfig(0.32, 0.32, 92.0, true,  0.18, 2.2, 18.0, 0.26, 2),
    _ScatteredRoseConfig(0.48, 0.38, 108.0, false, 0.10, 1.5, 16.0, 0.42, 2),
    _ScatteredRoseConfig(0.66, 0.28, 86.0, true,  0.25, 2.0, 20.0, 0.60, 1),
    _ScatteredRoseConfig(0.82, 0.36, 96.0, false, 0.32, 1.7, 15.0, 0.78, 2),
    _ScatteredRoseConfig(0.88, 0.52, 74.0, true,  0.40, 2.4, 18.0, 0.90, 1),
    _ScatteredRoseConfig(0.72, 0.62, 84.0, false, 0.28, 1.9, 14.0, 0.72, 1),
    _ScatteredRoseConfig(0.54, 0.68, 102.0, true, 0.15, 2.1, 22.0, 0.52, 2),
    _ScatteredRoseConfig(0.36, 0.62, 88.0, false, 0.22, 1.6, 16.0, 0.34, 1),
    _ScatteredRoseConfig(0.12, 0.58, 68.0, true,  0.35, 2.3, 14.0, 0.08, 0),
    // Foreground and accent blooming roses
    _ScatteredRoseConfig(0.08, 0.75, 114.0, false, 0.42, 1.4, 20.0, 0.15, 2),
    _ScatteredRoseConfig(0.92, 0.20, 72.0, true,  0.50, 2.5, 16.0, 0.95, 1),
    _ScatteredRoseConfig(0.24, 0.22, 60.0, false, 0.58, 1.8, 12.0, 0.22, 0),
    _ScatteredRoseConfig(0.58, 0.18, 64.0, true,  0.48, 2.1, 14.0, 0.55, 0),
    _ScatteredRoseConfig(0.78, 0.16, 58.0, false, 0.62, 1.9, 12.0, 0.75, 0),
    _ScatteredRoseConfig(0.42, 0.50, 118.0, true, 0.08, 1.6, 24.0, 0.45, 2),
    _ScatteredRoseConfig(0.62, 0.48, 98.0, false, 0.20, 2.0, 18.0, 0.62, 2),
    _ScatteredRoseConfig(0.28, 0.78, 80.0, true,  0.45, 1.7, 16.0, 0.28, 1),
    _ScatteredRoseConfig(0.84, 0.72, 88.0, false, 0.38, 2.2, 18.0, 0.82, 1),
    _ScatteredRoseConfig(0.15, 0.30, 56.0, true,  0.65, 2.6, 12.0, 0.18, 0),
    _ScatteredRoseConfig(0.50, 0.82, 94.0, false, 0.52, 1.5, 20.0, 0.48, 1),
    _ScatteredRoseConfig(0.70, 0.80, 76.0, true,  0.60, 2.3, 14.0, 0.68, 0),
  ];

  List<Widget> _buildScatteredRosesOfDifferentSizes(
      double sec, double screenWidth, double screenHeight, Offset center) {
    final widgets = <Widget>[];

    for (int i = 0; i < _scatteredRoseConfigs.length; i++) {
      final config = _scatteredRoseConfigs[i];
      final roseAsset = config.isPink ? AppAssets.roseHeadPink : AppAssets.roseHeadRed;

      double x, y, scale, opacity, rot;

      if (sec < 5.0) {
        // STEP 3: Roses Bloom in Motion
        final bloomStart = 3.0 + config.bloomDelay * 0.8;
        if (sec < bloomStart) continue; // Not bloomed yet

        final p3 = ((sec - bloomStart) / (5.0 - bloomStart)).clamp(0.0, 1.0);
        final bloomEase = Curves.easeOutBack.transform(p3);

        final targetX = config.normX * screenWidth;
        final targetY = config.normY * screenHeight;

        // Spread outwards from center
        x = center.dx + (targetX - center.dx) * bloomEase;
        y = center.dy + (targetY - center.dy) * bloomEase;
        scale = bloomEase * (config.layer == 2 ? 1.05 : 0.95);
        opacity = (p3 * 1.5).clamp(0.0, 1.0);
        rot = (p3 * pi * 0.8) + (i * 0.4);
      } else if (sec < 8.0) {
        // STEP 4: Swirling Elegance (Circular Waves Dance)
        final p4 = ((sec - 5.0) / 3.0).clamp(0.0, 1.0);

        // Circular wave constellation trajectory matching reference hero
        final waveT = (config.curveT + (p4 * 0.25)) % 1.0;
        final waveX = screenWidth * (0.12 + 0.76 * waveT);
        final waveY = screenHeight * (0.54 - 0.28 * sin(waveT * pi) + 0.08 * sin(waveT * 2 * pi));

        // Circular dance sway
        final circleOffset = Offset(
          cos((sec * 2.5) + config.phase) * (config.swayAmp * 1.2),
          sin((sec * 2.5) + config.phase) * (config.swayAmp * 0.9),
        );

        // Blend from bloom position to wave position
        final targetX = config.normX * screenWidth;
        final targetY = config.normY * screenHeight;
        final waveBlend = Curves.easeInOutCubic.transform((p4 * 1.5).clamp(0.0, 1.0));

        x = (targetX * (1.0 - waveBlend)) + ((waveX + circleOffset.dx) * waveBlend);
        y = (targetY * (1.0 - waveBlend)) + ((waveY + circleOffset.dy) * waveBlend);

        scale = (1.0 + sin((sec * 2.0) + config.phase) * 0.06);
        opacity = 1.0;
        rot = (sec * 0.8) + config.phase;
      } else if (sec < 11.0) {
        // STEP 5: Full Screen Bloom (Dreamy romantic floating atmosphere)
        final p5 = ((sec - 8.0) / 3.0).clamp(0.0, 1.0);

        final targetX = config.normX * screenWidth + sin(sec * config.swaySpeed + config.phase) * config.swayAmp;
        final targetY = config.normY * screenHeight + cos(sec * (config.swaySpeed * 0.8) + config.phase) * (config.swayAmp * 0.6) + (p5 * 20.0);

        x = targetX;
        y = targetY;
        scale = 1.0 + sin(sec * 1.8 + config.phase) * 0.04;
        opacity = 1.0;
        rot = (sec * 0.5) + config.phase;
      } else {
        // STEP 6: Fade & Glow (Slow drift & fade out)
        final p6 = ((sec - 11.0) / 1.0).clamp(0.0, 1.0);

        x = config.normX * screenWidth + sin(sec * config.swaySpeed + config.phase) * config.swayAmp;
        y = config.normY * screenHeight + 20.0 + (p6 * 25.0);
        scale = 1.0 - (p6 * 0.08);
        opacity = (1.0 - p6).clamp(0.0, 1.0);
        rot = (sec * 0.3) + config.phase;
      }

      final roseWidth = config.size * scale;
      final roseHeight = roseWidth;

      widgets.add(
        Positioned(
          left: x - roseWidth / 2,
          top: y - roseHeight / 2,
          width: roseWidth,
          height: roseHeight,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: rot,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Romantic rose halo aura
                  Container(
                    width: roseWidth * 0.85,
                    height: roseHeight * 0.85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (config.isPink ? const Color(0xFFFF4081) : const Color(0xFFE11D48))
                              .withValues(alpha: 0.40 * opacity),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                        if (config.layer == 2)
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.30 * opacity),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),

                  // High definition blooming rose blossom head
                  Image.asset(
                    roseAsset,
                    width: roseWidth,
                    height: roseHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Text(
                      config.isPink ? '🌸' : '🌹',
                      style: TextStyle(fontSize: roseWidth * 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _getRosesStageTitle(double sec) {
    if (sec < 1.5) return '1. First Petal • Single Glowing Petal';
    if (sec < 3.0) return '2. Petals Multiply • Trail of Shimmering Light';
    if (sec < 5.0) return '3. Roses Bloom in Motion • Scattered Blossoms';
    if (sec < 8.0) return '4. Swirling Elegance • Circular Waves Dance';
    if (sec < 11.0) return '5. Full Screen Bloom • Dreamy Romantic Atmosphere';
    return '6. Fade & Glow • Soft Lingering Radiance';
  }

  Widget _buildRosesTopBanner(double sec) {
    final sender = _currentSenderName.isNotEmpty ? _currentSenderName : 'Ravi';
    final count = _currentGiftCount > 1 ? ' x${_currentGiftCount}' : ' x1';
    final isImpactActive = sec >= 7.0 && sec <= 8.8;

    final bannerOpacity = (sec < 0.6
            ? (sec / 0.6)
            : (sec > 11.3 ? (12.0 - sec) / 0.7 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xEE4C0519), // Deep Velvet Burgundy Rose
                      Color(0xEE831843), // Royal Pink Wine
                      Color(0xEE9D174D), // Magenta Crimson
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isImpactActive
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFFF80AB).withValues(alpha: 0.80),
                    width: isImpactActive ? 2.2 : 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x88FF1493),
                      blurRadius: isImpactActive ? 24 : 16,
                      spreadRadius: isImpactActive ? 3 : 1,
                    ),
                    BoxShadow(
                      color: const Color(0x664C0519),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Blooming Rose Crest Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF4081), Color(0xFFFFD700)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF260417),
                          child: const Center(
                            child: Text('🌹', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$sender sent Roses$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '100,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFF4C0519),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getRosesStageTitle(sec),
                              style: TextStyle(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.95),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isImpactActive) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '+100,000 Stars Impact!',
                                  style: TextStyle(
                                    color: Color(0xFF4C0519),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ===========================================================================
  // 10. ⭐ METEOR SHOWER / DIAMOND ("Wishes Come True - Star Rain")
  // Sequence: ① Appear ➔ ② Star Rain ➔ ③ Full Effect ➔ ④ Shine
  // ===========================================================================
  Widget _buildDiamondAnimation() {
    return AnimatedBuilder(
      animation: _diamondController,
      builder: (context, child) {
        final val = _diamondController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 200) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY + (sin(p * 2 * pi) * 4);
          scale = 1.00 + (sin(p * pi) * 0.22);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double rotY = sin(val * 2 * pi) * 0.35;
        final double rotZ = sin(val * 4 * pi) * 0.04;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 100,
              groundY: posY + 160,
              scale: scale,
              elevation: (targetY - posY).abs(),
              width: 170,
            ),
            _buildRealisticStudioAura(
              centerX: centerX + 100,
              centerY: posY + 90,
              scale: scale,
              color: const Color(0xFF00E5FF),
              radius: 220,
              opacity: 0.35 * opacity,
            ),
            if (val >= 0.18 && val <= 0.85) ...[
              _buildSparkleGlint(
                x: centerX + 70,
                y: posY + 60,
                progress: (val * 5.0) % 1.0,
                color: Colors.white,
              ),
              _buildSparkleGlint(
                x: centerX + 120,
                y: posY + 95,
                progress: ((val * 5.0) + 0.4) % 1.0,
                color: const Color(0xFF80D8FF),
              ),
            ],
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0014)
                        ..rotateY(rotY)
                        ..rotateZ(rotZ),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFE0F7FA),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftDiamond,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 5. 🛥️ LUXURY YACHT ("POWER & ELEGANCE - Live Animated Gift")
  // Storyboard 6 Stages (10.0 Seconds Total):
  //  1. (0.0 – 1.5s): 1. Yacht Emerges (The yacht appears from the water with sparkling waves)
  //  2. (1.5 – 3.0s): 2. Sail Forward (The yacht moves forward with smooth water trail)
  //  3. (3.0 – 5.0s): 3. Grand View (Camera pans around the yacht showcasing its luxury and elegance)
  //  4. (5.0 – 7.0s): 4. Fireworks & Sparkles (Sky lights up with fireworks and golden sparkles)
  //  5. (7.0 – 9.0s): 5. Circular Glow (Golden light rings surround the yacht as it sails)
  //  6. (9.0 – 10.0s): 6. Final Pose (The yacht settles with a lasting glow)
  // ===========================================================================
  Widget _buildYachtAnimation() {
    return AnimatedBuilder(
      animation: _yachtController,
      builder: (context, child) {
        final val = _yachtController.value;
        final sec = val * 10.0;
        final size = MediaQuery.sizeOf(context);
        final screenWidth = size.width;
        final screenHeight = size.height;

        final yachtWidth = (screenWidth * 0.88).clamp(320.0, 520.0);
        final yachtHeight = yachtWidth * 0.58;

        final double centerX = (screenWidth - yachtWidth) * 0.5;
        final double centerY = screenHeight * 0.50;

        double posX;
        double posY;
        double scale;
        double rotY = 0.0;
        double rotZ = 0.0;
        double opacity = 1.0;
        double ringAlpha = 0.0;
        double fireworksAlpha = 0.0;

        if (sec < 1.5) {
          // 1. (0 - 1.5s): Yacht Emerges
          final p = (sec / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeOutCubic.transform(p);
          posX = centerX;
          posY = (centerY + 60.0) - (ease * 60.0);
          scale = 0.72 + (ease * 0.28);
          opacity = (p * 2.0).clamp(0.0, 1.0);
          rotZ = -0.04 * (1.0 - ease);
        } else if (sec < 3.0) {
          // 2. (1.5 - 3.0s): Sail Forward
          final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
          final ease = Curves.easeInOutCubic.transform(p);
          posX = (centerX - 40.0) + (ease * 40.0);
          posY = centerY + sin(p * 2 * pi) * 6.0;
          scale = 1.0 + (p * 0.08);
          rotZ = sin(p * 3 * pi) * 0.025;
        } else if (sec < 5.0) {
          // 3. (3.0 - 5.0s): Grand View
          final p = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
          posX = centerX + sin(p * pi) * 18.0;
          posY = centerY + sin(p * 2 * pi) * 7.0;
          scale = 1.08 + sin(p * pi) * 0.08;
          rotY = sin(p * pi) * 0.22; // 3D Camera Orbit
          rotZ = sin(p * 2 * pi) * 0.02;
        } else if (sec < 7.0) {
          // 4. (5.0 - 7.0s): Fireworks & Sparkles
          final p = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
          posX = centerX + sin(p * pi) * 12.0;
          posY = centerY + sin(p * 2 * pi) * 5.0;
          scale = 1.12 + sin(p * pi) * 0.05;
          fireworksAlpha = sin(p * pi).clamp(0.0, 1.0);
        } else if (sec < 9.0) {
          // 5. (7.0 - 9.0s): Circular Glow
          final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
          posX = centerX;
          posY = centerY + sin(p * pi) * 4.0;
          scale = 1.14 - (p * 0.04);
          ringAlpha = sin(p * pi).clamp(0.0, 1.0);
        } else {
          // 6. (9.0 - 10.0s): Final Pose
          final p = ((sec - 9.0) / 1.0).clamp(0.0, 1.0);
          posX = centerX;
          posY = centerY;
          scale = 1.10;
          ringAlpha = (1.0 - p) * 0.5;
          opacity = (1.0 - p * 0.95).clamp(0.0, 1.0);
        }

        final waterHeave = sin(sec * 3.5) * 4.0;
        final waterRoll = sin(sec * 2.2) * 0.025;

        final yachtAsset = (_activeGift?.imageAssetPath != null &&
                (_activeGift!.imageAssetPath!.contains('yacht') ||
                    _activeGift!.imageAssetPath!.contains('luxury')))
            ? _activeGift!.imageAssetPath!
            : AppAssets.luxuryYachtActor;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Full-screen Ocean Surface, Water Wake, Waves, Fireworks & Circular Glow Painter
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _LuxuryYachtOceanPainter(
                    sec: sec,
                    yachtCenter: Offset(posX + yachtWidth * 0.5, posY + yachtHeight * 0.65),
                    yachtWidth: yachtWidth,
                    fireworksAlpha: fireworksAlpha,
                    ringAlpha: ringAlpha,
                  ),
                ),
              ),
            ),

            // 2. Cinematic Sunset / Twilight Backdrop during Grand View & Fireworks
            if (sec >= 2.8 && sec <= 7.5)
              Positioned(
                top: screenHeight * 0.18,
                left: (screenWidth - (yachtWidth * 1.35)) * 0.5,
                width: yachtWidth * 1.35,
                height: (yachtWidth * 1.35) * 0.56,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (sec < 3.5
                            ? (sec - 2.8) / 0.7
                            : (sec > 6.8 ? (7.5 - sec) / 0.7 : 1.0))
                        .clamp(0.0, 0.45),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        AppAssets.luxuryYachtHero,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

            // 3. The 3D Luxury Yacht Actor
            Positioned(
              left: posX,
              top: posY + waterHeave,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(rotY)
                      ..rotateZ(rotZ + waterRoll)
                      ..scale(scale),
                    child: SizedBox(
                      width: yachtWidth,
                      height: yachtHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Under-hull turquoise LED glow
                          Positioned(
                            bottom: yachtHeight * 0.08,
                            child: Container(
                              width: yachtWidth * 0.78,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Specular Sheen on 3D Yacht
                          _buildRealisticSpecularSheen(
                            progress: (sec / 10.0),
                            lightColor: const Color(0xFFE0F7FA),
                            child: Image.asset(
                              yachtAsset,
                              width: yachtWidth,
                              height: yachtHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 4. Score Celebration Badge at 7.0s - 9.0s
            if (sec >= 7.0 && sec <= 9.2)
              Positioned(
                top: posY - 54,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (sec < 7.4 ? (sec - 7.0) / 0.4 : (sec > 8.8 ? (9.2 - sec) / 0.4 : 1.0)).clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x99FFD700),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '+${(_activeGift?.diamonds ?? 5000) * _currentGiftCount} Stars Impact!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 5. Luxury Yacht Top Banner
            if (widget.showTopBanner)
              _buildLuxuryYachtTopBanner(sec),
          ],
        );
      },
    );
  }

  String _getLuxuryYachtStageTitle(double sec) {
    if (sec < 1.5) return '1. Yacht Emerges • Sparkling Waves';
    if (sec < 3.0) return '2. Sail Forward • Smooth Water Trail';
    if (sec < 5.0) return '3. Grand View • Luxury & Elegance';
    if (sec < 7.0) return '4. Fireworks & Sparkles';
    if (sec < 9.0) return '5. Circular Glow • Golden Rings';
    return '6. Final Pose • Lasting Glow';
  }

  Widget _buildLuxuryYachtTopBanner(double sec) {
    final bannerOpacity = (sec < 1.0
            ? (sec / 1.0)
            : (sec > 9.3 ? (10.0 - sec) / 0.7 : 1.0))
        .clamp(0.0, 1.0);

    return Positioned(
      top: 56,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Opacity(
          opacity: bannerOpacity,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD0D1B2A),
                      Color(0xDD1B263B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.75),
                    width: 1.4,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FFD700),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Yacht Crest Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFF00E5FF)],
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          color: const Color(0xFF0B132B),
                          child: const Center(
                            child: Icon(
                              Icons.directions_boat_rounded,
                              color: Color(0xFFFFD700),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_currentSenderName.isNotEmpty ? _currentSenderName : 'Ravi'} sent Luxury Yacht',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'x$_currentGiftCount',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFD700),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                '5,000 ⭐',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getLuxuryYachtStageTitle(sec),
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 9. 🎂 BIRTHDAY CAKE
  // ===========================================================================
  Widget _buildCakeAnimation() {
    return AnimatedBuilder(
      animation: _cakeController,
      builder: (context, child) {
        final val = _cakeController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 200) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY + (sin(p * 2 * pi) * 3);
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double tiltAngle = sin(val * 2 * pi) * 0.025;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 100,
              groundY: posY + 160,
              scale: scale,
              width: 190,
            ),
            if (val >= 0.10 && val <= 0.88)
              ...List.generate(3, (i) {
                final flameX = centerX + 62 + (i * 38.0);
                final flameFlicker = (sin((val * 26 * pi) + (i * 1.8)).abs() * 0.35 + 0.65);
                return Positioned(
                  left: flameX,
                  top: posY + 26,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (flameFlicker * opacity).clamp(0.0, 1.0),
                      child: Container(
                        width: 12,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFFF9C4), Color(0xFFFF9100), Colors.transparent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withOpacity(0.70),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: tiltAngle,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFF9C4),
                          child: Image.asset(
                            AppAssets.giftCake,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 10. 🧸 TEDDY
  // ===========================================================================
  Widget _buildTeddyAnimation() {
    return AnimatedBuilder(
      animation: _teddyController,
      builder: (context, child) {
        final val = _teddyController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 190) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY;
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double tiltAngle = sin(val * 4 * pi) * 0.035;
        final double breathScaleY = 1.0 + (sin(val * 4 * pi) * 0.018);

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 95,
              groundY: posY + 155,
              scale: scale,
              width: 170,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..rotateZ(tiltAngle)
                        ..scale(1.0, breathScaleY, 1.0),
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFE0B2),
                          child: Image.asset(
                            AppAssets.giftPanda,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 2. 🐱 KITTY — CUTE CAT
  // ===========================================================================
  Widget _buildKittyAnimation() {
    return AnimatedBuilder(
      animation: _kittyController,
      builder: (context, child) {
        final val = _kittyController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 190) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY;
          scale = 1.00 + (sin(p * pi) * 0.16);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double headTilt = sin(val * 4 * pi) * 0.04;
        final double breathScale = 1.0 + (sin(val * 3 * pi) * 0.015);

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 95,
              groundY: posY + 155,
              scale: scale,
              width: 170,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(headTilt)
                        ..scale(breathScale, breathScale, 1.0),
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFCDD2),
                          child: Image.asset(
                            AppAssets.giftKitty,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 3. 💖 TIKI LOVE
  // ===========================================================================
  Widget _buildTikiLoveAnimation() {
    return AnimatedBuilder(
      animation: _tikiLoveController,
      builder: (context, child) {
        final val = _tikiLoveController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 200) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          posY = targetY + (sin(p * 2 * pi) * 4);
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = 1.00 - (p * 0.15);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double heartbeat = 1.0 + (sin(val * 8 * pi).abs() * 0.04);
        final double floatRot = sin(val * 3 * pi) * 0.03;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 100,
              groundY: posY + 160,
              scale: scale,
              elevation: (targetY - posY).abs(),
              width: 180,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(floatRot)
                        ..scale(heartbeat, heartbeat, 1.0),
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFF4081),
                          child: Image.asset(
                            AppAssets.giftTikiLove,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 15. ❤️ LOVE / HEART
  // ===========================================================================
  Widget _buildLoveHeartAnimation() {
    return AnimatedBuilder(
      animation: _loveController,
      builder: (context, child) {
        final val = _loveController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 200) / 2;
        final double centerY = screenHeight * 0.56;

        double scale;
        double opacity = 1.0;

        if (val < 0.28) {
          final p = Curves.easeOutBack.transform(val / 0.28);
          scale = 0.50 + (p * 0.50);
        } else if (val < 0.75) {
          final p = (val - 0.28) / 0.47;
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.75) / 0.25);
          scale = 1.00 + (p * 0.25);
          opacity = (1.0 - p).clamp(0.0, 1.0);
        }

        final double pulse = 1.0 + (sin(val * 8 * pi).abs() * 0.06);
        final double floatElevation = sin(val * 2 * pi) * 6;
        final double posY = centerY + floatElevation;

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 100,
              groundY: posY + 160,
              scale: scale,
              elevation: floatElevation,
              width: 180,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.scale(
                      scale: pulse,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFF80AB),
                          child: Image.asset(
                            AppAssets.giftLove,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 1. 🌹 FLOWERS / BOUQUET
  // ===========================================================================
  Widget _buildFlowersAnimation() {
    return AnimatedBuilder(
      animation: _flowersController,
      builder: (context, child) {
        final val = _flowersController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 210) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = screenHeight * 0.72;

        double posY;
        double scale;
        double petalUnfurl;
        double opacity = 1.0;
        double rotZ;

        // Stage 1: Emerges as tightly closed flower bouquet bud (0.00 -> 0.15)
        if (val < 0.15) {
          final p = Curves.easeOutCubic.transform(val / 0.15);
          posY = startY - (p * (startY - targetY));
          scale = 0.25 + (p * 0.35);
          petalUnfurl = 0.35 + (p * 0.15);
          opacity = (p / 0.8).clamp(0.0, 1.0);
          rotZ = -0.06 + (p * 0.04);
        }
        // Stage 2: Flowers unfold and bloom wide open (0.15 -> 0.40)
        else if (val < 0.40) {
          final p = Curves.easeOutBack.transform((val - 0.15) / 0.25);
          posY = targetY;
          scale = 0.60 + (p * 0.55);
          petalUnfurl = 0.50 + (p * 0.50);
          rotZ = -0.02 + (sin(p * pi) * 0.05);
        }
        // Stage 3: Full open bloom with living breathing & swaying (0.40 -> 0.75)
        else if (val < 0.75) {
          final p = (val - 0.40) / 0.35;
          final breathing = sin(p * 3 * pi) * 0.05;
          posY = targetY + (sin(p * 2 * pi) * 3);
          scale = 1.08 + breathing;
          petalUnfurl = 1.0 + (sin(p * 2 * pi) * 0.04);
          rotZ = sin(p * 2 * pi) * 0.035;
        }
        // Stage 4: Petals fold back in and flowers close (0.75 -> 1.00)
        else {
          final p = Curves.easeInOutCubic.transform((val - 0.75) / 0.25);
          posY = targetY + (p * (exitY - targetY));
          scale = (1.08 * (1.0 - (p * 0.45))).clamp(0.0, 2.0);
          petalUnfurl = 1.0 - (p * 0.60);
          opacity = (1.0 - p).clamp(0.0, 1.0);
          rotZ = p * 0.08;
        }

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 105,
              groundY: posY + 165,
              scale: scale,
              width: 180,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(rotZ)
                        ..scale(petalUnfurl, scale, 1.0),
                      child: SizedBox(
                        width: 210,
                        height: 210,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFF80AB),
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftFlowers,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 13. 🌍 WORLD TOUR
  // ===========================================================================
  Widget _buildWorldTourAnimation() {
    return AnimatedBuilder(
      animation: _worldTourController,
      builder: (context, child) {
        final val = _worldTourController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 210) / 2;
        final double startY = screenHeight * 0.70;
        final double targetY = screenHeight * 0.56;
        final double exitY = -180.0;

        double posY;
        double scale;
        double rotY;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posY = startY - (p * (startY - targetY));
          scale = 0.88 + (p * 0.12);
          rotY = val * 2.5 * pi;
        } else if (val < 0.72) {
          final p = (val - 0.28) / 0.44;
          posY = targetY + (sin(p * 2 * pi) * 3);
          scale = 1.00 + (sin(p * pi) * 0.20);
          rotY = (0.28 * 2.5 * pi) + (p * 2.0 * pi);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.72) / 0.28);
          posY = targetY - (p * (targetY - exitY));
          scale = 1.00 + (p * 0.05);
          rotY = (0.28 * 2.5 * pi) + (2.0 * pi) + (p * 0.8 * pi);
        }

        return Stack(
          children: [
            _buildRealisticStudioAura(
              centerX: centerX + 105,
              centerY: posY + 105,
              scale: scale,
              color: const Color(0xFF00E5FF),
              radius: 220,
              opacity: 0.25,
            ),
            Positioned(
              left: centerX,
              top: posY,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: scale,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..rotateY(rotY),
                    child: SizedBox(
                      width: 210,
                      height: 210,
                      child: _buildRealisticSpecularSheen(
                        progress: val,
                        lightColor: const Color(0xFFB3E5FC),
                        child: Image.asset(
                          AppAssets.giftWorldTour,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (val >= 0.15 && val <= 0.85)
              _buildAirplaneOrbit(
                centerX: centerX + 105,
                centerY: posY + 105,
                progress: val,
                scale: scale,
                opacity: 0.95,
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // STANDARD / GENERIC GIFT FALLBACK
  // ===========================================================================
  Widget _buildStandardGiftAnimation() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final val = _shakeController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 190) / 2;
        final double centerY = screenHeight * 0.56;

        final double scale = 0.92 + (sin(val * pi) * 0.16);
        final double rot = sin(val * 4 * pi) * 0.04;
        final double opacity = val > 0.85 ? ((1.0 - val) / 0.15).clamp(0.0, 1.0) : (val / 0.15).clamp(0.0, 1.0);

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 95,
              groundY: centerY + 165,
              scale: scale,
              width: 170,
            ),
            Positioned(
              left: centerX,
              top: centerY,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rot,
                      child: SizedBox(
                        width: 190,
                        height: 190,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: Colors.white,
                          child: Image.asset(
                            _activeGift?.imageAssetPath ?? AppAssets.giftRose,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // PROCEDURAL VFX & REALISTIC SHADING HELPERS
  // ===========================================================================

  Widget _buildDualRocketThrusterFlames({required double progress}) {
    final flicker = (sin(progress * 38 * pi).abs() * 0.25 + 0.75);

    Widget singleThruster() {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 32,
            height: 95 * flicker,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF4081),
                  Color(0xFFE040FB),
                  Color(0x887C4DFF),
                  Colors.transparent,
                ],
                stops: [0.0, 0.30, 0.65, 1.0],
              ),
            ),
          ),
          Container(
            width: 20,
            height: 70 * flicker,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFF00E5FF),
                  Color(0xFF00B0FF),
                  Colors.transparent,
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),
          Container(
            width: 10,
            height: 40 * flicker,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF00E5FF),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        singleThruster(),
        const SizedBox(width: 8),
        singleThruster(),
      ],
    );
  }

  Widget _buildRocketSmokePlume({
    required double tailX,
    required double tailY,
    required double progress,
  }) {
    return SizedBox(
      width: 250,
      height: 200,
      child: Stack(
        children: [
        ...List.generate(7, (i) {
          final cloudAge = ((progress * 2.2) + (i * 0.14)) % 1.0;
          final puffX = tailX - (cloudAge * 95) + (sin(cloudAge * 4 * pi) * 12);
          final puffY = tailY + (cloudAge * 115);
          final puffSize = 28.0 + (cloudAge * 48.0);
          final puffOpacity = (1.0 - cloudAge).clamp(0.0, 0.75);

          return Positioned(
            left: puffX - (puffSize / 2),
            top: puffY - (puffSize / 2),
            child: IgnorePointer(
              child: Opacity(
                opacity: puffOpacity,
                child: Container(
                  width: puffSize,
                  height: puffSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF90CAF9).withOpacity(0.65),
                        const Color(0xFF5C6BC0).withOpacity(0.35),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.50, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        ...List.generate(6, (i) {
          final emberP = ((progress * 3.0) + (i * 0.18)) % 1.0;
          final emberX = tailX - (emberP * 80) + (sin(emberP * 6 * pi) * 16);
          final emberY = tailY + (emberP * 95);
          final emberColor = i % 2 == 0 ? const Color(0xFFFF80AB) : const Color(0xFF00E5FF);

          return Positioned(
            left: emberX,
            top: emberY,
            child: IgnorePointer(
              child: Opacity(
                opacity: (sin(emberP * pi)).clamp(0.0, 1.0),
                child: Container(
                  width: 4.5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: emberColor,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
      ),
    );
  }

  Widget _buildRealisticHeadlightGlow({
    required double left,
    required double top,
    required double opacity,
  }) {
    if (opacity <= 0.0) return const SizedBox.shrink();
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 0.85),
          child: Container(
            width: 220,
            height: 80,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.85, 0.0),
                radius: 0.95,
                colors: [
                  Colors.white.withOpacity(0.90),
                  const Color(0xFFFFF9C4).withOpacity(0.55),
                  const Color(0xFFFFD54F).withOpacity(0.20),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.25, 0.60, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSparkleGlint({
    required double x,
    required double y,
    required double progress,
    required Color color,
  }) {
    final glintScale = sin(progress * pi).clamp(0.0, 1.0);
    if (glintScale <= 0.01) return const SizedBox.shrink();

    return Positioned(
      left: x - 12,
      top: y - 12,
      child: IgnorePointer(
        child: Opacity(
          opacity: glintScale,
          child: Transform.rotate(
            angle: progress * pi * 0.5,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20 * glintScale,
                    height: 2.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                  Container(
                    width: 2.2,
                    height: 20 * glintScale,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealisticSpecularSheen({
    required Widget child,
    required double progress,
    Color lightColor = Colors.white,
  }) {
    final offset = (progress * 2.8) - 1.4;
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(-1.6 + offset, -1.0),
          end: Alignment(0.4 + offset, 1.0),
          colors: [
            Colors.white.withOpacity(0.0),
            lightColor.withOpacity(0.35),
            Colors.white.withOpacity(0.85),
            lightColor.withOpacity(0.35),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.38, 0.50, 0.62, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }

  Widget _buildRealisticGroundShadow({
    required double centerX,
    required double groundY,
    required double scale,
    double elevation = 0.0,
    double width = 180,
  }) {
    final shadowScale = (scale * (1.0 - (elevation * 0.0025))).clamp(0.4, 1.5);
    final shadowOpacity = (0.50 - (elevation * 0.0035)).clamp(0.10, 0.50);

    return Positioned(
      left: centerX - (width * shadowScale / 2),
      top: groundY + (elevation * 0.15),
      child: IgnorePointer(
        child: Opacity(
          opacity: shadowOpacity,
          child: Container(
            width: width * shadowScale,
            height: 22 * shadowScale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: RadialGradient(
                colors: [
                  Colors.black.withOpacity(0.80),
                  Colors.black.withOpacity(0.40),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealisticStudioAura({
    required double centerX,
    required double centerY,
    required double scale,
    required Color color,
    double radius = 240,
    double opacity = 0.45,
  }) {
    return Positioned(
      left: centerX - (radius * scale / 2),
      top: centerY - (radius * scale / 2),
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Container(
            width: radius * scale,
            height: radius * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.45),
                  color.withOpacity(0.18),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.50, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealisticWaterRipples({
    required double left,
    required double top,
    required double width,
    required double progress,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 0.85),
          child: Container(
            width: width,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withOpacity(0.55),
                  const Color(0xFF0044AA).withOpacity(0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtleTireDriftVfx({
    required double left,
    required double top,
    required double opacity,
  }) {
    if (opacity <= 0.0) return const SizedBox.shrink();
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 0.70),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.55),
                      const Color(0xFFCFD8DC).withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFD54F),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF9100),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirplaneOrbit({
    required double centerX,
    required double centerY,
    required double progress,
    required double scale,
    required double opacity,
  }) {
    if (opacity <= 0.0) return const SizedBox.shrink();
    final angle = progress * 2.5 * pi;
    final radiusX = 118.0 * scale;
    final radiusY = 48.0 * scale;
    final planeX = centerX + (cos(angle) * radiusX);
    final planeY = centerY + (sin(angle) * radiusY);
    final headingAngle = angle + (pi / 2);

    return Positioned(
      left: planeX - 12,
      top: planeY - 12,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity.clamp(0.0, 0.95),
          child: Transform.rotate(
            angle: headingAngle,
            child: const Icon(
              Icons.airplanemode_active,
              size: 20,
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Color(0xFF00E5FF),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FULL-SCREEN CINEMATIC ENVIRONMENTAL CUSTOM PAINTERS (Matching Poster Image 2!)
// =============================================================================

/// 1. 🌹 Flower Chariot & Rose: Full-Screen 36+ Tumbling 3D Petal Rain & Fireflies
class _FullPetalRainPainter extends CustomPainter {
  final double progress;

  _FullPetalRainPainter({required this.progress});

  static final List<_PetalData> _petals = List.generate(36, (i) {
    final rand = Random(i * 123 + 45);
    return _PetalData(
      startX: rand.nextDouble(),
      speed: 0.8 + (rand.nextDouble() * 0.8),
      size: 14.0 + (rand.nextDouble() * 14.0),
      swayFreq: 2.0 + (rand.nextDouble() * 3.0),
      swayAmp: 20.0 + (rand.nextDouble() * 30.0),
      rotSpeed: 2.0 + (rand.nextDouble() * 4.0),
      phase: rand.nextDouble() * 2 * pi,
      color: _petalColors[i % _petalColors.length],
    );
  });

  static const List<Color> _petalColors = [
    Color(0xFFFF1744), // Crimson
    Color(0xFFFF4081), // Rose pink
    Color(0xFFE91E63), // Magenta
    Color(0xFFFF80AB), // Soft pink
    Color(0xFFC2185B), // Deep velvet rose
    Color(0xFFFFD54F), // Golden stardust flake
  ];

  static final List<_FireflyData> _fireflies = List.generate(24, (i) {
    final rand = Random(i * 456 + 78);
    return _FireflyData(
      x: rand.nextDouble(),
      yStart: rand.nextDouble(),
      speed: 0.4 + (rand.nextDouble() * 0.6),
      size: 2.5 + (rand.nextDouble() * 3.0),
      blinkSpeed: 3.0 + (rand.nextDouble() * 5.0),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Romantic warm glow at center
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.45),
        radius: 0.95,
        colors: [
          const Color(0x66FF4081),
          const Color(0x28FFA000),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // 2. Rising Golden Stardust Fireflies
    for (final f in _fireflies) {
      final curY = (f.yStart * size.height - (progress * f.speed * size.height)) % size.height;
      final curX = (f.x * size.width) + (sin(progress * 4 * pi + f.x * 10) * 15);
      final alpha = (sin((progress * f.blinkSpeed * 2 * pi) + f.x * 10).abs() * 0.6 + 0.4).clamp(0.0, 1.0);

      final flyPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(curX, curY), f.size / 2, flyPaint);
    }

    // 3. Falling & 3D Tumbling Rose Petals across the whole screen
    for (final p in _petals) {
      final curY = ((p.speed * progress * size.height * 1.4) + (p.phase * 100)) % (size.height + 60) - 30;
      final curX = (p.startX * size.width) + (sin((progress * p.swayFreq * 2 * pi) + p.phase) * p.swayAmp);
      final rot = (progress * p.rotSpeed * 2 * pi) + p.phase;
      final tiltScaleX = cos(rot * 1.5).abs().clamp(0.2, 1.0);

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(rot);
      canvas.scale(tiltScaleX, 1.0);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.color,
            p.color.withOpacity(0.85),
            const Color(0x88000000),
          ],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.4));

      final path = Path()
        ..moveTo(0, -p.size * 0.7)
        ..cubicTo(p.size * 0.6, -p.size * 0.5, p.size * 0.5, p.size * 0.5, 0, p.size * 0.7)
        ..cubicTo(-p.size * 0.5, p.size * 0.5, -p.size * 0.6, -p.size * 0.5, 0, -p.size * 0.7);

      canvas.drawPath(path, petalPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FullPetalRainPainter oldDelegate) => true;
}

class _PetalData {
  final double startX;
  final double speed;
  final double size;
  final double swayFreq;
  final double swayAmp;
  final double rotSpeed;
  final double phase;
  final Color color;

  const _PetalData({
    required this.startX,
    required this.speed,
    required this.size,
    required this.swayFreq,
    required this.swayAmp,
    required this.rotSpeed,
    required this.phase,
    required this.color,
  });
}

class _FireflyData {
  final double x;
  final double yStart;
  final double speed;
  final double size;
  final double blinkSpeed;

  const _FireflyData({
    required this.x,
    required this.yStart,
    required this.speed,
    required this.size,
    required this.blinkSpeed,
  });
}

/// 2. 🚀 Galaxy Rocket: Full-Screen Cosmic Galaxy, Planet, Nebulae & 120+ Stars
class _FullSpaceGalaxyPainter extends CustomPainter {
  final double progress;

  _FullSpaceGalaxyPainter({required this.progress});

  static final List<_StarData> _stars = List.generate(120, (i) {
    final rand = Random(i * 997 + 13);
    return _StarData(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: 0.8 + (rand.nextDouble() * 2.8),
      baseAlpha: 0.35 + (rand.nextDouble() * 0.65),
      speed: 1.5 + (rand.nextDouble() * 4.5),
      phase: rand.nextDouble() * 2 * pi,
      hasCrossFlare: i < 18,
      isColorTinted: rand.nextDouble() < 0.25,
      tintColor: rand.nextBool() ? const Color(0xFF80D8FF) : const Color(0xFFFF80AB),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Cosmic Nebulae (Transparent glow over live stream)
    final nebulaPaint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x354A148C),
          const Color(0x10311B92),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.75, size.height * 0.25),
        radius: size.width * 0.65,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebulaPaint1);

    final nebulaPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x2800B0FF),
          const Color(0x080D47A1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.25, size.height * 0.45),
        radius: size.width * 0.55,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), nebulaPaint2);

    // 3. Distant Glowing Planet Orb with Atmospheric Rim in upper right (matching Image 2)
    final planetCenter = Offset(size.width * 0.88, size.height * 0.16);
    const planetRadius = 32.0;
    canvas.drawCircle(
      planetCenter,
      planetRadius + 6,
      Paint()
        ..color = const Color(0x4400E5FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      planetCenter,
      planetRadius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.4),
          colors: [
            Color(0xFF80D8FF),
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
            Color(0xFF000A1F),
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
        ).createShader(Rect.fromCircle(center: planetCenter, radius: planetRadius)),
    );

    // Planet Atmospheric Crescent Rim
    final rimPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          Colors.transparent,
          const Color(0xAA00E5FF),
        ],
        stops: const [0.70, 1.0],
      ).createShader(Rect.fromCircle(center: planetCenter, radius: planetRadius));
    canvas.drawCircle(planetCenter, planetRadius, rimPaint);

    // 4. Galaxy Deep Cosmic Starfield (Twinkling Diamonds & Shooting Plasma)
    for (final s in _stars) {
      final alpha = (sin((progress * s.speed * 2 * pi) + s.phase).abs() * (1.0 - s.baseAlpha) + s.baseAlpha).clamp(0.0, 1.0);
      final curX = s.x * size.width;
      final curY = s.y * size.height;

      final starPaint = Paint()
        ..color = s.isColorTinted ? s.tintColor.withOpacity(alpha) : Colors.white.withOpacity(alpha);

      if (s.size > 2.2) {
        starPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      }

      canvas.drawCircle(Offset(curX, curY), s.size / 2, starPaint);

      // 4-point cross diffraction spikes on brightest stars
      if (s.hasCrossFlare && alpha > 0.65) {
        final flarePaint = Paint()
          ..color = Colors.white.withOpacity(alpha * 0.75)
          ..strokeWidth = 0.8;
        final flareLen = s.size * 2.6;
        canvas.drawLine(Offset(curX - flareLen, curY), Offset(curX + flareLen, curY), flarePaint);
        canvas.drawLine(Offset(curX, curY - flareLen), Offset(curX, curY + flareLen), flarePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FullSpaceGalaxyPainter oldDelegate) => true;
}

class _StarData {
  final double x;
  final double y;
  final double size;
  final double baseAlpha;
  final double speed;
  final double phase;
  final bool hasCrossFlare;
  final bool isColorTinted;
  final Color tintColor;

  const _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.baseAlpha,
    required this.speed,
    required this.phase,
    required this.hasCrossFlare,
    required this.isColorTinted,
    required this.tintColor,
  });
}

/// 3. 👑 Royal Crown: Golden Pedestal, Subtle Sparkle Rain over live video
class _FullRoyalGoldenShowerPainter extends CustomPainter {
  final double progress;

  _FullRoyalGoldenShowerPainter({required this.progress});

  static final List<_GoldSparkleData> _sparks = List.generate(45, (i) {
    final rand = Random(i * 321 + 65);
    return _GoldSparkleData(
      x: rand.nextDouble(),
      speed: 0.7 + (rand.nextDouble() * 0.9),
      size: 2.0 + (rand.nextDouble() * 3.5),
      phase: rand.nextDouble() * 2 * pi,
      isStar: i % 2 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Vertical Golden God-Rays beaming upward from base
    for (int i = 0; i < 5; i++) {
      final rayX = size.width * (0.2 + (i * 0.15));
      final rayWidth = 35.0 + (i * 8.0);
      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0x55FFD700),
            const Color(0x22FFA000),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromLTWH(rayX - rayWidth / 2, 0, rayWidth, size.height));

      canvas.drawRect(Rect.fromLTWH(rayX - rayWidth / 2, 0, rayWidth, size.height), rayPaint);
    }

    // 3. Golden Sparkling Star Rain cascading down
    for (final s in _sparks) {
      final curY = ((progress * s.speed * size.height * 1.3) + (s.phase * 90)) % size.height;
      final curX = (s.x * size.width) + (sin(progress * 4 * pi + s.phase) * 12);
      final alpha = (sin(progress * 5 * 2 * pi + s.phase).abs() * 0.5 + 0.5).clamp(0.0, 1.0);

      final sparkPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      if (s.isStar) {
        final p = Path()
          ..moveTo(curX, curY - s.size * 2)
          ..lineTo(curX + s.size * 0.4, curY - s.size * 0.4)
          ..lineTo(curX + s.size * 2, curY)
          ..lineTo(curX + s.size * 0.4, curY + s.size * 0.4)
          ..lineTo(curX, curY + s.size * 2)
          ..lineTo(curX - s.size * 0.4, curY + s.size * 0.4)
          ..lineTo(curX - s.size * 2, curY)
          ..lineTo(curX - s.size * 0.4, curY - s.size * 0.4)
          ..close();
        canvas.drawPath(p, sparkPaint);
      } else {
        canvas.drawCircle(Offset(curX, curY), s.size / 2, sparkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FullRoyalGoldenShowerPainter oldDelegate) => true;
}

class _GoldSparkleData {
  final double x;
  final double speed;
  final double size;
  final double phase;
  final bool isStar;

  const _GoldSparkleData({
    required this.x,
    required this.speed,
    required this.size,
    required this.phase,
    required this.isStar,
  });
}

/// 4. 🏰 Love Castle & Tiki Love: Ascending 3D Neon Hearts & Heart Fireworks
class _FullLoveHeartsPainter extends CustomPainter {
  final double progress;

  _FullLoveHeartsPainter({required this.progress});

  static final List<_HeartParticle> _hearts = List.generate(30, (i) {
    final rand = Random(i * 789 + 12);
    return _HeartParticle(
      startX: rand.nextDouble(),
      speed: 0.6 + (rand.nextDouble() * 0.9),
      size: 16.0 + (rand.nextDouble() * 22.0),
      swayAmp: 18.0 + (rand.nextDouble() * 25.0),
      phase: rand.nextDouble() * 2 * pi,
      color: i % 3 == 0 ? const Color(0xFFFF4081) : (i % 3 == 1 ? const Color(0xFFFF80AB) : const Color(0xFFE040FB)),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Romantic Pink Magical Aurora
    final auraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.40),
        radius: 0.95,
        colors: [
          const Color(0x66E91E63),
          const Color(0x339C27B0),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auraPaint);

    // 2. Ascending 3D Neon Hearts floating from bottom to top
    for (final h in _hearts) {
      final curY = size.height - ((progress * h.speed * size.height * 1.3 + (h.phase * 80)) % (size.height + 60)) + 30;
      final curX = (h.startX * size.width) + (sin((progress * 3 * 2 * pi) + h.phase) * h.swayAmp);
      final pulse = 1.0 + (sin(progress * 6 * pi + h.phase).abs() * 0.15);

      canvas.save();
      canvas.translate(curX, curY);
      canvas.scale(pulse, pulse);

      final heartPath = _createHeartPath(h.size);
      final heartPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white,
            h.color,
            h.color.withOpacity(0.7),
          ],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: h.size, height: h.size))
        ..style = PaintingStyle.fill;

      canvas.drawPath(
        heartPath,
        Paint()
          ..color = h.color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(heartPath, heartPaint);
      canvas.restore();
    }

    // 3. Heart Fireworks Bursts in Upper Sky (Phase 3 & 4)
    if (progress > 0.35) {
      final fwProgress = ((progress - 0.35) / 0.60).clamp(0.0, 1.0);
      _drawHeartFirework(canvas, Offset(size.width * 0.25, size.height * 0.18), fwProgress, const Color(0xFFFF4081));
      _drawHeartFirework(canvas, Offset(size.width * 0.75, size.height * 0.22), (fwProgress + 0.33) % 1.0, const Color(0xFFFF80AB));
      _drawHeartFirework(canvas, Offset(size.width * 0.50, size.height * 0.12), (fwProgress + 0.66) % 1.0, const Color(0xFFFFD54F));
    }
  }

  Path _createHeartPath(double size) {
    final path = Path();
    path.moveTo(0, size * 0.35);
    path.cubicTo(-size * 0.5, -size * 0.2, -size * 0.5, -size * 0.5, 0, -size * 0.2);
    path.cubicTo(size * 0.5, -size * 0.5, size * 0.5, -size * 0.2, 0, size * 0.35);
    return path;
  }

  void _drawHeartFirework(Canvas canvas, Offset center, double p, Color color) {
    if (p <= 0.05 || p >= 0.95) return;
    final radius = p * 65.0;
    final alpha = (1.0 - p).clamp(0.0, 1.0);

    for (int i = 0; i < 12; i++) {
      final angle = i * (2 * pi / 12);
      final x = center.dx + (cos(angle) * radius);
      final y = center.dy + (sin(angle) * radius * 0.75) - (sin(angle).abs() * radius * 0.25);

      final sparkPaint = Paint()
        ..color = color.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), 2.5 * (1.0 - p * 0.5), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullLoveHeartsPainter oldDelegate) => true;
}

class _HeartParticle {
  final double startX;
  final double speed;
  final double size;
  final double swayAmp;
  final double phase;
  final Color color;

  const _HeartParticle({
    required this.startX,
    required this.speed,
    required this.size,
    required this.swayAmp,
    required this.phase,
    required this.color,
  });
}

/// 5. 🏎️ Luxury Super Car: Neon Cyber Highway & Celebration Fireworks
class _FullHighwayFireworksPainter extends CustomPainter {
  final double progress;

  _FullHighwayFireworksPainter({required this.progress});

  static final List<_StreakData> _streaks = List.generate(14, (i) {
    final rand = Random(i * 333 + 7);
    return _StreakData(
      yNorm: 0.12 + (rand.nextDouble() * 0.24),
      length: 90.0 + (rand.nextDouble() * 160.0),
      speed: 2.2 + (rand.nextDouble() * 3.5),
      color: i % 3 == 0
          ? const Color(0xFFFF9100)
          : (i % 3 == 1 ? const Color(0xFF00E5FF) : Colors.white),
      thickness: 1.2 + (rand.nextDouble() * 2.0),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cyber Highway Dark Asphalt & Amber Horizon Haze
    final roadPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00000000),
          Color(0x44FF6D00),
          Color(0x77000000),
          Color(0x00000000),
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, size.height * 0.12, size.width, size.height * 0.24));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.12, size.width, size.height * 0.24), roadPaint);

    // 2. High-speed horizontal neon speed lines
    for (final s in _streaks) {
      final curX = (size.width - ((progress * s.speed * size.width) % (size.width + s.length * 2))) + s.length;
      final curY = s.yNorm * size.height;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            s.color.withOpacity(0.85),
            s.color,
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(curX - s.length, curY, s.length, s.thickness))
        ..strokeWidth = s.thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(curX - s.length, curY), Offset(curX, curY), paint);
    }

    // 3. Celebration Fireworks in the Sky (Image 2: "④ Fireworks")
    if (progress > 0.45) {
      final p = ((progress - 0.45) / 0.50).clamp(0.0, 1.0);
      _drawFirework(canvas, Offset(size.width * 0.20, size.height * 0.12), p, const Color(0xFFFFD54F));
      _drawFirework(canvas, Offset(size.width * 0.80, size.height * 0.15), (p + 0.35) % 1.0, const Color(0xFF00E5FF));
      _drawFirework(canvas, Offset(size.width * 0.50, size.height * 0.08), (p + 0.70) % 1.0, const Color(0xFFFF4081));
    }
  }

  void _drawFirework(Canvas canvas, Offset center, double p, Color color) {
    if (p <= 0.05 || p >= 0.95) return;
    final radius = p * 60.0;
    final alpha = (1.0 - p).clamp(0.0, 1.0);

    for (int i = 0; i < 10; i++) {
      final angle = i * (2 * pi / 10);
      final x = center.dx + (cos(angle) * radius);
      final y = center.dy + (sin(angle) * radius);

      final sparkPaint = Paint()
        ..color = color.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), 2.2 * (1.0 - p * 0.5), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullHighwayFireworksPainter oldDelegate) => true;
}

class _StreakData {
  final double yNorm;
  final double length;
  final double speed;
  final Color color;
  final double thickness;

  const _StreakData({
    required this.yNorm,
    required this.length,
    required this.speed,
    required this.color,
    required this.thickness,
  });
}

/// 6. 🐋 Ocean Whale & Yacht: Deep Ocean Abyss, Caustics & Ascending Bubbles
class _FullOceanBubblesPainter extends CustomPainter {
  final double progress;

  _FullOceanBubblesPainter({required this.progress});

  static final List<_BubbleData> _bubbles = List.generate(32, (i) {
    final rand = Random(i * 654 + 32);
    return _BubbleData(
      x: rand.nextDouble(),
      speed: 0.6 + (rand.nextDouble() * 0.8),
      size: 5.0 + (rand.nextDouble() * 12.0),
      wobbleSpeed: 2.0 + (rand.nextDouble() * 4.0),
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep Ocean Marine Abyss
    final oceanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x3300E5FF),
          const Color(0x66004D60),
          const Color(0xAA001830),
          const Color(0xCC000E1C),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);

    // 2. Sunlight Water Caustics Shimmer in upper section
    for (int i = 0; i < 4; i++) {
      final caustY = size.height * (0.08 + (i * 0.06));
      final caustPaint = Paint()
        ..color = const Color(0x3300E5FF).withOpacity((sin(progress * 4 * pi + i).abs() * 0.2 + 0.15))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final p = Path();
      p.moveTo(0, caustY);
      for (double x = 0; x <= size.width; x += 30) {
        p.lineTo(x, caustY + sin((x / 50) + (progress * 5 * pi) + i) * 6);
      }
      canvas.drawPath(p, caustPaint);
    }

    // 3. Ascending Bioluminescent Bubbles
    for (final b in _bubbles) {
      final curY = size.height - ((progress * b.speed * size.height * 1.3 + (b.phase * 80)) % (size.height + 40)) + 20;
      final curX = (b.x * size.width) + (sin((progress * b.wobbleSpeed * 2 * pi) + b.phase) * 12);
      final alpha = (sin(progress * 4 * pi + b.phase).abs() * 0.35 + 0.65).clamp(0.0, 1.0);

      final bubblePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white.withOpacity(alpha),
            const Color(0x8800E5FF).withOpacity(alpha * 0.7),
            const Color(0x22004D60).withOpacity(alpha * 0.2),
          ],
        ).createShader(Rect.fromCircle(center: Offset(curX, curY), radius: b.size / 2))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(curX, curY), b.size / 2, bubblePaint);

      // Bubble rim highlight
      canvas.drawCircle(
        Offset(curX, curY),
        b.size / 2,
        Paint()
          ..color = Colors.white.withOpacity(alpha * 0.8)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FullOceanBubblesPainter oldDelegate) => true;
}

class _BubbleData {
  final double x;
  final double speed;
  final double size;
  final double wobbleSpeed;
  final double phase;

  const _BubbleData({
    required this.x,
    required this.speed,
    required this.size,
    required this.wobbleSpeed,
    required this.phase,
  });
}

/// 7. 🪽 Diamond Wings: Prismatic Rainbow Dispersion Rays & Starburst Glints
class _FullDiamondPrismPainter extends CustomPainter {
  final double progress;

  _FullDiamondPrismPainter({required this.progress});

  static final List<_DiamondGlintData> _glints = List.generate(35, (i) {
    final rand = Random(i * 852 + 19);
    return _DiamondGlintData(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      size: 3.0 + (rand.nextDouble() * 5.0),
      speed: 3.0 + (rand.nextDouble() * 5.0),
      phase: rand.nextDouble() * 2 * pi,
      color: i % 4 == 0
          ? const Color(0xFF80D8FF)
          : (i % 4 == 1 ? const Color(0xFFFF80AB) : (i % 4 == 2 ? const Color(0xFFFFD54F) : Colors.white)),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Diamond Starburst Glints (Transparent)
    for (final g in _glints) {
      final alpha = (sin((progress * g.speed * 2 * pi) + g.phase).abs()).clamp(0.0, 1.0);
      if (alpha < 0.15) continue;

      final curX = (g.x * size.width) + (sin(progress * 2 * pi + g.phase) * 8);
      final curY = (g.y * size.height) + (cos(progress * 2 * pi + g.phase) * 8);

      final sparkPaint = Paint()
        ..color = g.color.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      final p = Path()
        ..moveTo(curX, curY - g.size * 2.5)
        ..lineTo(curX + g.size * 0.4, curY - g.size * 0.4)
        ..lineTo(curX + g.size * 2.5, curY)
        ..lineTo(curX + g.size * 0.4, curY + g.size * 0.4)
        ..lineTo(curX, curY + g.size * 2.5)
        ..lineTo(curX - g.size * 0.4, curY + g.size * 0.4)
        ..lineTo(curX - g.size * 2.5, curY)
        ..lineTo(curX - g.size * 0.4, curY - g.size * 0.4)
        ..close();
      canvas.drawPath(p, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullDiamondPrismPainter oldDelegate) => true;
}

class _DiamondGlintData {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _DiamondGlintData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

/// 8. ⭐ Meteor Shower: Cascading Shooting Stars Raining Diagonally (Transparent)
class _FullMeteorShowerPainter extends CustomPainter {
  final double progress;

  _FullMeteorShowerPainter({required this.progress});

  static final List<_MeteorData> _meteors = List.generate(35, (i) {
    final rand = Random(i * 741 + 83);
    return _MeteorData(
      startX: rand.nextDouble() * 1.4,
      startY: rand.nextDouble() * 0.7,
      speed: 1.2 + (rand.nextDouble() * 1.6),
      length: 60.0 + (rand.nextDouble() * 100.0),
      thickness: 1.5 + (rand.nextDouble() * 2.0),
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Shooting stars streaking diagonally across screen over live video
    for (final m in _meteors) {
      final p = ((progress * m.speed) + (m.phase / (2 * pi))) % 1.0;
      final curX = (m.startX * size.width) - (p * size.width * 1.2);
      final curY = (m.startY * size.height) + (p * size.height * 1.1);

      final tailX = curX + (m.length * 0.75);
      final tailY = curY - (m.length * 0.65);

      final meteorPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.transparent,
            const Color(0xFFFFD54F).withOpacity(0.4),
            const Color(0xFFFFD54F),
            Colors.white,
          ],
          stops: const [0.0, 0.4, 0.85, 1.0],
        ).createShader(Rect.fromPoints(Offset(tailX, tailY), Offset(curX, curY)))
        ..strokeWidth = m.thickness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(tailX, tailY), Offset(curX, curY), meteorPaint);

      // Star head spark
      canvas.drawCircle(
        Offset(curX, curY),
        m.thickness * 1.2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FullMeteorShowerPainter oldDelegate) => true;
}

class _MeteorData {
  final double startX;
  final double startY;
  final double speed;
  final double length;
  final double thickness;
  final double phase;

  const _MeteorData({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.length,
    required this.thickness,
    required this.phase,
  });
}

/// 9. 🐎 Golden Horse: Swirling Energy Vortex Ribbons (Transparent)
class _FullGoldenHorseVortexPainter extends CustomPainter {
  final double progress;

  _FullGoldenHorseVortexPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Swirling golden stardust energy rings wrapping the center
    for (int i = 0; i < 4; i++) {
      final ringAngle = (progress * 3 * pi) + (i * pi / 2);
      final ringWidth = size.width * (0.55 + (i * 0.12));
      final ringHeight = size.height * (0.22 + (i * 0.05));

      final ringPaint = Paint()
        ..shader = SweepGradient(
          transform: GradientRotation(ringAngle),
          colors: const [
            Colors.transparent,
            Color(0x88FFD700),
            Color(0xFFFF9100),
            Colors.white,
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
        ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.58),
          width: ringWidth,
          height: ringHeight,
        ))
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.58),
          width: ringWidth,
          height: ringHeight,
        ),
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FullGoldenHorseVortexPainter oldDelegate) => true;
}

/// 10. 🕊️ Angel Vehicle: Divine Floating Feathers & Stardust (100% Transparent)
class _FullHeavenlyBlessingPainter extends CustomPainter {
  final double progress;

  _FullHeavenlyBlessingPainter({required this.progress});

  static final List<_FeatherParticle> _feathers = List.generate(24, (i) {
    final rand = Random(i * 123 + 45);
    return _FeatherParticle(
      startX: rand.nextDouble(),
      speed: 0.5 + rand.nextDouble() * 0.6,
      size: 14.0 + rand.nextDouble() * 12.0,
      swayAmp: 20.0 + rand.nextDouble() * 25.0,
      phase: rand.nextDouble() * 2 * pi,
      isGold: i % 3 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Elegant floating divine feathers over live stream (100% transparent background)
    for (final f in _feathers) {
      final curY = ((progress * f.speed * size.height * 1.2) + (f.phase * 80)) % (size.height + 40) - 20;
      final curX = (f.startX * size.width) + (sin(progress * 4 * pi + f.phase) * f.swayAmp);
      final rot = sin(progress * 3 * pi + f.phase) * 0.4;
      final alpha = (sin(progress * 3 * pi + f.phase).abs() * 0.4 + 0.6).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(rot);

      final p = Paint()
        ..color = (f.isGold ? const Color(0xFFFFD54F) : Colors.white).withValues(alpha: alpha * 0.75)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(0, -f.size / 2)
        ..cubicTo(f.size * 0.35, -f.size * 0.2, f.size * 0.35, f.size * 0.2, 0, f.size / 2)
        ..cubicTo(-f.size * 0.35, f.size * 0.2, -f.size * 0.35, -f.size * 0.2, 0, -f.size / 2);

      canvas.drawPath(path, p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FullHeavenlyBlessingPainter oldDelegate) => true;
}

class _FeatherParticle {
  final double startX;
  final double speed;
  final double size;
  final double swayAmp;
  final double phase;
  final bool isGold;

  const _FeatherParticle({
    required this.startX,
    required this.speed,
    required this.size,
    required this.swayAmp,
    required this.phase,
    required this.isGold,
  });
}

/// 11. 🎂 Celebration Cake: Confetti Shower & Party Bokeh (Transparent)
class _FullCelebrationConfettiPainter extends CustomPainter {
  final double progress;

  _FullCelebrationConfettiPainter({required this.progress});

  static final List<_ConfettiData> _confetti = List.generate(40, (i) {
    final rand = Random(i * 555 + 18);
    return _ConfettiData(
      startX: rand.nextDouble(),
      speed: 0.7 + (rand.nextDouble() * 0.8),
      size: 7.0 + (rand.nextDouble() * 9.0),
      rotSpeed: 3.0 + (rand.nextDouble() * 5.0),
      phase: rand.nextDouble() * 2 * pi,
      color: _confettiColors[i % _confettiColors.length],
    );
  });

  static const List<Color> _confettiColors = [
    Color(0xFFFFD700),
    Color(0xFFFF4081),
    Color(0xFF00E5FF),
    Color(0xFF76FF03),
    Color(0xFFE040FB),
    Color(0xFFFF9100),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in _confetti) {
      final curY = ((progress * c.speed * size.height * 1.3) + (c.phase * 90)) % (size.height + 40) - 20;
      final curX = (c.startX * size.width) + (sin(progress * 4 * pi + c.phase) * 16);
      final rot = (progress * c.rotSpeed * 2 * pi) + c.phase;

      canvas.save();
      canvas.translate(curX, curY);
      canvas.rotate(rot);

      final p = Paint()..color = c.color;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.6), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FullCelebrationConfettiPainter oldDelegate) => true;
}

class _ConfettiData {
  final double startX;
  final double speed;
  final double size;
  final double rotSpeed;
  final double phase;
  final Color color;

  const _ConfettiData({
    required this.startX,
    required this.speed,
    required this.size,
    required this.rotSpeed,
    required this.phase,
    required this.color,
  });
}

// =============================================================================
// 🐋 OCEAN WHALE / DOLPHIN DEDICATED CINEMATIC PAINTERS (TIKTOK LIVE PK BATTLE)
// =============================================================================

/// 1. Volumetric Rising & Receding Ocean Water with Continuous Sinusoidal Waves,
/// Foaming Crest, Underwater Caustic Reflections, and Concentric Sender Ripples.
class _OceanWhaleRisingWaterPainter extends CustomPainter {
  final double waterY;
  final double progress;
  final bool toLeft;
  final double rippleProgress;
  final double opacity;

  const _OceanWhaleRisingWaterPainter({
    required this.waterY,
    required this.progress,
    required this.toLeft,
    required this.rippleProgress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.0 || waterY >= size.height + 30) return;

    final waterHeight = size.height - waterY;
    if (waterHeight <= 0) return;

    // 1. Volumetric Ocean Gradient
    final waterRect = Rect.fromLTWH(0, waterY - 15, size.width, size.height - waterY + 15);
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xCC00E5FF).withValues(alpha: (0.75 * opacity).clamp(0.0, 1.0)),
          const Color(0xDD0077B6).withValues(alpha: (0.85 * opacity).clamp(0.0, 1.0)),
          const Color(0xEE023E8A).withValues(alpha: (0.92 * opacity).clamp(0.0, 1.0)),
          const Color(0xFA03045E).withValues(alpha: (0.96 * opacity).clamp(0.0, 1.0)),
        ],
        stops: const [0.0, 0.28, 0.65, 1.0],
      ).createShader(waterRect)
      ..style = PaintingStyle.fill;

    // Sinusoidal wave surface
    final wavePath = Path();
    wavePath.moveTo(0, waterY);
    for (double x = 0; x <= size.width; x += 8) {
      final yOffset = sin((x / 28.0) + (progress * 16.0)) * 6.5 +
          cos((x / 55.0) - (progress * 10.0)) * 3.5;
      wavePath.lineTo(x, waterY + yOffset);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, waterPaint);

    // 2. Foaming Crest Line
    final crestPath = Path();
    for (double x = 0; x <= size.width; x += 8) {
      final yOffset = sin((x / 28.0) + (progress * 16.0)) * 6.5 +
          cos((x / 55.0) - (progress * 10.0)) * 3.5;
      if (x == 0) {
        crestPath.moveTo(x, waterY + yOffset);
      } else {
        crestPath.lineTo(x, waterY + yOffset);
      }
    }

    // Glowing foam aura
    final glowPaint = Paint()
      ..color = const Color(0x8000E5FF).withValues(alpha: (0.50 * opacity).clamp(0.0, 1.0))
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(crestPath, glowPaint);

    // Crisp white foam highlight
    final foamPaint = Paint()
      ..color = const Color(0xFFE0F7FA).withValues(alpha: (0.90 * opacity).clamp(0.0, 1.0))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(crestPath, foamPaint);

    // 3. Underwater Sun Caustic Reflections
    for (int i = 0; i < 3; i++) {
      final caustY = waterY + 22.0 + (i * 24.0);
      if (caustY < size.height) {
        final caustPaint = Paint()
          ..color = const Color(0x4000E5FF).withValues(
              alpha: ((0.22 + 0.14 * sin(progress * 6 * pi + i)).clamp(0.0, 1.0) * opacity).clamp(0.0, 1.0))
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        final cp = Path();
        for (double x = 0; x <= size.width; x += 20) {
          final dy = sin((x / 30.0) + (progress * 8.0) + i) * 4.0;
          if (x == 0) {
            cp.moveTo(x, caustY + dy);
          } else {
            cp.lineTo(x, caustY + dy);
          }
        }
        canvas.drawPath(cp, caustPaint);
      }
    }

    // 4. Concentric Water Ripples Expanding from Sender Side
    if (rippleProgress > 0.0 && rippleProgress < 1.0) {
      final senderCenter = Offset(
        toLeft ? size.width * 0.22 : size.width * 0.78,
        size.height * 0.86,
      );

      for (int i = 0; i < 4; i++) {
        final ringP = ((rippleProgress * 1.8) + (i * 0.25)) % 1.0;
        final radiusX = ringP * 180.0;
        final radiusY = ringP * 55.0; // Perspective elliptical ripple
        final ringAlpha = ((1.0 - ringP) * 0.75 * opacity).clamp(0.0, 1.0);

        if (radiusX > 6 && ringAlpha > 0.02) {
          final ripplePaint = Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: ringAlpha)
            ..strokeWidth = (2.8 * (1.0 - ringP * 0.5)).clamp(1.0, 3.0)
            ..style = PaintingStyle.stroke;
          canvas.drawOval(
            Rect.fromCenter(center: senderCenter, width: radiusX * 2, height: radiusY * 2),
            ripplePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OceanWhaleRisingWaterPainter old) => true;
}

/// 2. 55+ Bioluminescent Rising Bubbles Filling the Screen
class _OceanWhaleBubblesPainter extends CustomPainter {
  final double progress;
  final double waterY;
  final double opacity;

  const _OceanWhaleBubblesPainter({
    required this.progress,
    required this.waterY,
    required this.opacity,
  });

  static final List<_OceanBubbleSpec> _specs = List.generate(55, (i) {
    final rand = Random(i * 911 + 47);
    return _OceanBubbleSpec(
      xRatio: rand.nextDouble(),
      speed: 0.7 + rand.nextDouble() * 1.1,
      radius: 3.5 + rand.nextDouble() * 9.5,
      wobbleSpeed: 2.5 + rand.nextDouble() * 4.0,
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.0) return;

    for (final b in _specs) {
      final totalTravel = size.height * 1.5;
      final yTravel = ((progress * b.speed * totalTravel) + (b.phase * 90.0)) % (size.height + 60.0);
      final curY = (size.height + 30.0) - yTravel;

      final curX = (b.xRatio * size.width) + (sin((progress * b.wobbleSpeed * 2 * pi) + b.phase) * 14.0);

      final alpha = (sin(progress * 4 * pi + b.phase).abs() * 0.35 + 0.65).clamp(0.0, 1.0) * opacity;
      if (alpha <= 0.01) continue;

      final center = Offset(curX, curY);

      // 3D Sphere Radial Gradient with Highlight
      final bubblePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white.withValues(alpha: (0.95 * alpha).clamp(0.0, 1.0)),
            const Color(0xAA00E5FF).withValues(alpha: (0.70 * alpha).clamp(0.0, 1.0)),
            const Color(0x330077B6).withValues(alpha: (0.25 * alpha).clamp(0.0, 1.0)),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: b.radius))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, b.radius, bubblePaint);

      // Outer crisp rim
      final rimPaint = Paint()
        ..color = const Color(0xFFE0F7FA).withValues(alpha: (0.85 * alpha).clamp(0.0, 1.0))
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, b.radius, rimPaint);

      // Specular highlight spot
      final spotPaint = Paint()
        ..color = Colors.white.withValues(alpha: (0.90 * alpha).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(curX - b.radius * 0.32, curY - b.radius * 0.32),
        (b.radius * 0.22).clamp(1.0, 3.0),
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OceanWhaleBubblesPainter old) => true;
}

class _OceanBubbleSpec {
  final double xRatio;
  final double speed;
  final double radius;
  final double wobbleSpeed;
  final double phase;

  const _OceanBubbleSpec({
    required this.xRatio,
    required this.speed,
    required this.radius,
    required this.wobbleSpeed,
    required this.phase,
  });
}

/// 3. Bioluminescent Trailing Wake and Stardust Behind Whale
class _OceanWhaleTrailPainter extends CustomPainter {
  final Offset whalePosition;
  final double progress;
  final bool toLeft;

  const _OceanWhaleTrailPainter({
    required this.whalePosition,
    required this.progress,
    required this.toLeft,
  });

  static final List<_OceanTrailParticle> _particles = List.generate(28, (i) {
    final rand = Random(i * 331 + 79);
    return _OceanTrailParticle(
      dxOffset: (rand.nextDouble() - 0.5) * 60.0,
      dyOffset: (rand.nextDouble() - 0.5) * 50.0,
      radius: 2.0 + rand.nextDouble() * 5.0,
      speed: 0.6 + rand.nextDouble() * 0.8,
      isGold: rand.nextBool(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.18 || progress > 0.78) return;

    final tailOffset = Offset(
      toLeft ? whalePosition.dx + 230.0 : whalePosition.dx + 25.0,
      whalePosition.dy + 110.0,
    );

    for (int i = 0; i < _particles.length; i++) {
      final p = _particles[i];
      final alpha = ((1.0 - (i / _particles.length)) * 0.85).clamp(0.0, 1.0);
      final lagX = toLeft
          ? tailOffset.dx + (i * 5.5) + p.dxOffset
          : tailOffset.dx - (i * 5.5) + p.dxOffset;
      final lagY = tailOffset.dy + (i * 3.5) + p.dyOffset + sin(progress * 15 + i) * 6.0;

      final color = p.isGold ? const Color(0xFFFFD54F) : const Color(0xFF00E5FF);
      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(lagX, lagY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanWhaleTrailPainter old) => true;
}

class _OceanTrailParticle {
  final double dxOffset;
  final double dyOffset;
  final double radius;
  final double speed;
  final bool isGold;

  const _OceanTrailParticle({
    required this.dxOffset,
    required this.dyOffset,
    required this.radius,
    required this.speed,
    required this.isGold,
  });
}

/// 4. Huge Splash Explosion with 70+ Droplets, Gravity Arc, and Shockwaves
class _OceanImpactSplashPainter extends CustomPainter {
  final double progress;
  final Offset impactCenter;

  const _OceanImpactSplashPainter({
    required this.progress,
    required this.impactCenter,
  });

  static final List<_OceanSplashDroplet> _droplets = List.generate(70, (i) {
    final rand = Random(i * 777 + 103);
    final angle = -pi + (rand.nextDouble() * pi); // upward burst [-pi, 0]
    final speed = 190.0 + (rand.nextDouble() * 270.0);
    return _OceanSplashDroplet(
      angle: angle,
      speed: speed,
      radius: 2.5 + rand.nextDouble() * 5.5,
      gravity: 360.0 + rand.nextDouble() * 220.0,
      isFoam: rand.nextDouble() > 0.55,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final p = progress;
    final alpha = (1.0 - p).clamp(0.0, 1.0);

    // 1. Concentric Expanding Shockwave Rings
    for (int r = 0; r < 3; r++) {
      final ringP = ((p * 1.5) + (r * 0.20)).clamp(0.0, 1.0);
      final ringRadius = ringP * 240.0;
      final ringAlpha = ((1.0 - ringP) * 0.85).clamp(0.0, 1.0);

      final ringPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: ringAlpha)
        ..strokeWidth = (3.5 * (1.0 - ringP)).clamp(1.0, 4.0)
        ..style = PaintingStyle.stroke;
      canvas.drawOval(
        Rect.fromCenter(center: impactCenter, width: ringRadius * 2, height: ringRadius * 0.75),
        ringPaint,
      );
    }

    // 2. 70+ Water Droplets with Realistic Gravity Ballistics
    for (final d in _droplets) {
      final dx = cos(d.angle) * d.speed * p;
      final dy = sin(d.angle) * d.speed * p + 0.5 * d.gravity * p * p;
      final pos = Offset(impactCenter.dx + dx, impactCenter.dy + dy);

      final dropPaint = Paint()
        ..color = (d.isFoam ? const Color(0xFFFFFFFF) : const Color(0xFF80D8FF))
            .withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, (d.radius * (1.0 - p * 0.3)).clamp(0.5, 8.0), dropPaint);

      // Droplet highlight
      if (!d.isFoam && d.radius > 4.0) {
        canvas.drawCircle(
          pos - Offset(d.radius * 0.25, d.radius * 0.25),
          d.radius * 0.35,
          Paint()..color = Colors.white.withValues(alpha: alpha * 0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OceanImpactSplashPainter old) => true;
}

class _OceanSplashDroplet {
  final double angle;
  final double speed;
  final double radius;
  final double gravity;
  final bool isFoam;

  const _OceanSplashDroplet({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.gravity,
    required this.isFoam,
  });
}

/// 5. VS Logo Glowing Electric Plasma Aura Burst & Radiating Shockwaves
class _VsLogoImpactGlowPainter extends CustomPainter {
  final double progress;
  final Offset vsCenter;

  const _VsLogoImpactGlowPainter({
    required this.progress,
    required this.vsCenter,
  });

  static final List<double> _sparkAngles = List.generate(
    24,
    (i) => (i * 2 * pi / 24) + ((i % 2 == 0) ? 0.08 : -0.08),
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final p = progress;
    final alpha = (sin(p * pi)).clamp(0.0, 1.0);

    // 1. Core Blinding Radiant Flash
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFF00E5FF).withValues(alpha: (0.85 * alpha).clamp(0.0, 1.0)),
          const Color(0xFFFFD700).withValues(alpha: (0.50 * alpha).clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: vsCenter, radius: 110.0 * (0.8 + p * 0.4)))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vsCenter, 110.0 * (0.8 + p * 0.4), corePaint);

    // 2. Concentric Electric Shockwaves
    for (int i = 0; i < 2; i++) {
      final ringP = ((p * 1.4) + (i * 0.30)).clamp(0.0, 1.0);
      final radius = ringP * 140.0;
      final ringAlpha = ((1.0 - ringP) * alpha).clamp(0.0, 1.0);
      final ringPaint = Paint()
        ..color = (i == 0 ? const Color(0xFFFFD700) : const Color(0xFF00E5FF))
            .withValues(alpha: ringAlpha)
        ..strokeWidth = (3.0 * (1.0 - ringP)).clamp(1.0, 3.5)
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(vsCenter, radius, ringPaint);
    }

    // 3. 24 Electric Starburst Spark Rays
    for (int i = 0; i < _sparkAngles.length; i++) {
      final angle = _sparkAngles[i];
      final rayLen = (40.0 + (i % 3) * 25.0) * (0.5 + p * 0.7);
      final startR = 25.0 * (0.8 + p * 0.3);
      final endR = startR + rayLen;

      final p1 = Offset(vsCenter.dx + cos(angle) * startR, vsCenter.dy + sin(angle) * startR);
      final p2 = Offset(vsCenter.dx + cos(angle) * endR, vsCenter.dy + sin(angle) * endR);

      final rayPaint = Paint()
        ..color = (i % 2 == 0 ? const Color(0xFFFFFFFF) : const Color(0xFFFFD700))
            .withValues(alpha: (alpha * 0.9).clamp(0.0, 1.0))
        ..strokeWidth = (2.2 * (1.0 - p * 0.5)).clamp(1.0, 2.5)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VsLogoImpactGlowPainter old) => true;
}

// =============================================================================
// 🐎 1. GOLDEN HORSE CINEMATIC PAINTER
// =============================================================================
// 🐎 1. GOLDEN HORSE CINEMATIC RIG & ENVIRONMENTAL PAINTERS
// =============================================================================

class _SliceClipper extends CustomClipper<Rect> {
  final Rect clipRect;
  const _SliceClipper(this.clipRect);

  @override
  Rect getClip(Size size) => clipRect;

  @override
  bool shouldReclip(covariant _SliceClipper oldClipper) => clipRect != oldClipper.clipRect;
}

class _HorseBurstParticle {
  final double angle;
  final double speed;
  final double radius;
  final bool isStar;

  const _HorseBurstParticle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.isStar,
  });
}

class _SpeedLine {
  final double yRatio;
  final double length;
  final double speed;
  final double thickness;

  const _SpeedLine({
    required this.yRatio,
    required this.length,
    required this.speed,
    required this.thickness,
  });
}

class _HorseManeTailWavePainter extends CustomPainter {
  final double horseWidth;
  final double horseHeight;
  final double gallopPhase;
  final double frontAngle;
  final double rearAngle;
  final bool isRearingUp;

  const _HorseManeTailWavePainter({
    required this.horseWidth,
    required this.horseHeight,
    required this.gallopPhase,
    required this.frontAngle,
    required this.rearAngle,
    required this.isRearingUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Flowing golden ribbons on the tail (left side: x ~ 0.04 to 0.30 * W, y ~ 0.44 to 0.82 * H)
    final tailPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: isRearingUp ? 0.70 : 0.48)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int t = 0; t < 5; t++) {
      final path = Path();
      final startX = horseWidth * (0.24 - t * 0.035);
      final startY = horseHeight * (0.46 + t * 0.06);
      path.moveTo(startX, startY);

      final controlX1 = startX - 35.0 + sin(gallopPhase * 1.6 + t) * 14.0;
      final controlY1 = startY + 15.0 + cos(gallopPhase * 2.0 + t) * 8.0;
      final controlX2 = startX - 68.0 + sin(gallopPhase * 2.2 + t * 1.5) * 18.0;
      final controlY2 = startY + 36.0 + sin(gallopPhase * 1.8 + t) * 10.0;
      final endX = startX - 98.0 + sin(gallopPhase * 2.6 + t) * 22.0;
      final endY = startY + 56.0 + cos(gallopPhase * 2.5 + t) * 12.0;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
      canvas.drawPath(path, tailPaint);
    }

    // 2. Flowing golden mane crest ribbons (top right: x ~ 0.48 to 0.72 * W, y ~ 0.12 to 0.36 * H)
    final manePaint = Paint()
      ..color = const Color(0xFFFFF176).withValues(alpha: isRearingUp ? 0.80 : 0.52)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    for (int m = 0; m < 4; m++) {
      final path = Path();
      final startX = horseWidth * (0.64 - m * 0.04);
      final startY = horseHeight * (0.16 + m * 0.05);
      path.moveTo(startX, startY);

      final flutter = sin(gallopPhase * 2.8 + m * 1.2) * 14.0;
      final waveY = cos(gallopPhase * 3.0 + m) * 6.0;

      path.cubicTo(
        startX - 22.0 + flutter * 0.5,
        startY + waveY,
        startX - 46.0 + flutter,
        startY + 12.0 + waveY * 1.5,
        startX - 68.0 + flutter * 1.2,
        startY + 20.0 + waveY * 2.0,
      );
      canvas.drawPath(path, manePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HorseManeTailWavePainter old) => true;
}

class _GoldenHorseDustPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset horseCenter;
  final double horseWidth;
  final double horseHeight;
  final Offset daisCenter;
  final double daisWidth;
  final bool isEntrance;
  final bool isForming;
  final bool isDetailed;
  final bool isMovement;
  final bool isShowcase;
  final bool isExit;
  final double gallopPhase;

  const _GoldenHorseDustPainter({
    required this.progress,
    required this.sec,
    required this.horseCenter,
    required this.horseWidth,
    required this.horseHeight,
    required this.daisCenter,
    required this.daisWidth,
    required this.isEntrance,
    required this.isForming,
    required this.isDetailed,
    required this.isMovement,
    required this.isShowcase,
    required this.isExit,
    required this.gallopPhase,
  });

  // 300 pre-generated burst particles for the cinematic showcase explosion
  static final List<_HorseBurstParticle> _burstParticles = List.generate(300, (i) {
    final rand = Random(i * 997 + 101);
    final angle = rand.nextDouble() * 2 * pi;
    final speed = 120.0 + (rand.nextDouble() * 460.0);
    final radius = 1.6 + (rand.nextDouble() * 4.6);
    final isStar = i % 2 == 0;
    return _HorseBurstParticle(angle: angle, speed: speed, radius: radius, isStar: isStar);
  });

  // 20 parallax speed lines for graceful galloping movement
  static final List<_SpeedLine> _speedLines = List.generate(20, (i) {
    final rand = Random(i * 349 + 71);
    return _SpeedLine(
      yRatio: 0.32 + rand.nextDouble() * 0.58,
      length: 70.0 + rand.nextDouble() * 170.0,
      speed: 1.2 + rand.nextDouble() * 1.6,
      thickness: 1.0 + rand.nextDouble() * 2.5,
    );
  });

  // 60 ambient swirling golden stardust motes
  static final List<_DustParticle> _dust = List.generate(60, (i) {
    final rand = Random(i * 313 + 51);
    final angle = rand.nextDouble() * 2 * pi;
    final speed = 50.0 + (rand.nextDouble() * 160.0);
    return _DustParticle(
      angle: angle,
      speed: speed,
      radius: 1.8 + rand.nextDouble() * 4.5,
      isSpark: rand.nextBool(),
    );
  });

  // 12 Constellation nodes outlining horse shape for Stage 1
  static final List<Offset> _constellationPoints = [
    const Offset(0.70, 0.16), // Head / muzzle
    const Offset(0.64, 0.12), // Ears / crest
    const Offset(0.58, 0.22), // Neck
    const Offset(0.52, 0.35), // Chest / shoulder
    const Offset(0.48, 0.50), // Front knee
    const Offset(0.46, 0.72), // Front hoof
    const Offset(0.38, 0.36), // Saddle / back
    const Offset(0.24, 0.38), // Flank
    const Offset(0.18, 0.44), // Hip / rump
    const Offset(0.16, 0.62), // Hock / hind leg
    const Offset(0.14, 0.76), // Hind hoof
    const Offset(0.08, 0.52), // Tail tip
  ];

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    // =========================================================================
    // 1. CONCENTRIC GOLDEN MAGIC ENERGY DAIS ON FLOOR (Matching Storyboard 1-6)
    // =========================================================================
    final double daisAlpha = (isExit ? (10.0 - sec) / 1.0 : (sec < 1.0 ? sec / 1.0 : 1.0)).clamp(0.0, 1.0);
    if (daisAlpha > 0.0) {
      final double rxOuter = daisWidth * 0.46;
      final double ryOuter = daisWidth * 0.13;

      // (a) Concentric Glowing Floor Pool
      final poolRect = Rect.fromCenter(center: daisCenter, width: daisWidth, height: ryOuter * 2.6);
      final poolPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFEA00).withValues(alpha: 0.45 * daisAlpha),
            const Color(0xFFFFA000).withValues(alpha: 0.22 * daisAlpha),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(poolRect);
      canvas.drawOval(poolRect, poolPaint);

      // (b) Outer Glowing Concentric Ring
      final outerRingPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.70 * daisAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawOval(Rect.fromCenter(center: daisCenter, width: rxOuter * 2, height: ryOuter * 2), outerRingPaint);

      // (c) Mid Rune Ring with Rotating Tick Marks
      final double rxMid = daisWidth * 0.36;
      final double ryMid = daisWidth * 0.10;
      final midRingPaint = Paint()
        ..color = const Color(0xFFFFF176).withValues(alpha: 0.85 * daisAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawOval(Rect.fromCenter(center: daisCenter, width: rxMid * 2, height: ryMid * 2), midRingPaint);

      // 24 Rotating Rune Tick Notches
      final tickPaint = Paint()
        ..color = const Color(0xFFFFEA00).withValues(alpha: 0.75 * daisAlpha)
        ..strokeWidth = 1.4;
      final double rotAngle = sec * 0.40;
      for (int i = 0; i < 24; i++) {
        final double theta = rotAngle + (i * 2 * pi / 24);
        final double x1 = daisCenter.dx + cos(theta) * rxMid * 0.94;
        final double y1 = daisCenter.dy + sin(theta) * ryMid * 0.94;
        final double x2 = daisCenter.dx + cos(theta) * rxMid * 1.06;
        final double y2 = daisCenter.dy + sin(theta) * ryMid * 1.06;
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
      }

      // (d) Inner Radiant Ring
      final double rxInner = daisWidth * 0.24;
      final double ryInner = daisWidth * 0.07;
      final innerRingPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.90 * daisAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawOval(Rect.fromCenter(center: daisCenter, width: rxInner * 2, height: ryInner * 2), innerRingPaint);

      // (e) Expanding Ground Energy Wave (pulsing in Detailed Formation & Showcase)
      if (isDetailed || isShowcase) {
        final double wavePhase = (sec * 2.0) % 1.0;
        final double waveRx = rxOuter * (0.8 + wavePhase * 0.45);
        final double waveRy = ryOuter * (0.8 + wavePhase * 0.45);
        final double waveAlpha = ((1.0 - wavePhase) * 0.75 * daisAlpha).clamp(0.0, 1.0);
        final shockPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawOval(Rect.fromCenter(center: daisCenter, width: waveRx * 2, height: waveRy * 2), shockPaint);
      }
    }

    // =========================================================================
    // 2. ASCENDING GOD-RAY / GOLDEN AURA COLUMN (0-1.5s and 7-9s)
    // =========================================================================
    if (isEntrance || isShowcase) {
      final double pillarAlpha = (isEntrance ? (sec / 1.5) * 0.42 : ((9.0 - sec) / 2.0) * 0.50).clamp(0.0, 0.50);
      final pillarRect = Rect.fromLTWH(daisCenter.dx - (daisWidth * 0.32), 0, daisWidth * 0.64, daisCenter.dy);
      final pillarPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: pillarAlpha * 0.9),
            const Color(0xFFFFA000).withValues(alpha: pillarAlpha * 0.4),
            Colors.transparent,
          ],
        ).createShader(pillarRect);
      canvas.drawRect(pillarRect, pillarPaint);
    }

    // =========================================================================
    // 3. STAGE 1 (0 – 1.5s): CONSTELLATION SILHOUETTE & SWIRLING PARTICLES
    // =========================================================================
    if (isEntrance) {
      final double p = (sec / 1.5).clamp(0.0, 1.0);
      final linePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: (p * 0.75).clamp(0.0, 0.75))
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      final starPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      final horseOrigin = Offset(horseCenter.dx - horseWidth * 0.5, horseCenter.dy - horseHeight * 0.5);

      // Draw constellation filament connections
      for (int i = 0; i < _constellationPoints.length - 1; i++) {
        final p1 = Offset(
          horseOrigin.dx + _constellationPoints[i].dx * horseWidth,
          horseOrigin.dy + _constellationPoints[i].dy * horseHeight,
        );
        final p2 = Offset(
          horseOrigin.dx + _constellationPoints[i + 1].dx * horseWidth,
          horseOrigin.dy + _constellationPoints[i + 1].dy * horseHeight,
        );
        canvas.drawLine(p1, p2, linePaint);

        // Constellation star nodes
        starPaint.color = (i % 2 == 0) ? Colors.white : const Color(0xFFFFEA00);
        _drawStar(canvas, p1, 3.2, starPaint);
      }

      // Swirling particles gathering inward
      final spiralPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      for (int s = 0; s < 40; s++) {
        final rand = Random(s * 71 + 3);
        final angle = (s * 0.35) + (sec * 4.0);
        final radius = (1.0 - p) * (180.0 + rand.nextDouble() * 120.0);
        final spx = horseCenter.dx + cos(angle) * radius;
        final spy = horseCenter.dy + sin(angle) * (radius * 0.65) - (p * 20.0);
        spiralPaint.color = const Color(0xFFFFD700).withValues(alpha: (p * 0.85).clamp(0.0, 0.85));
        canvas.drawCircle(Offset(spx, spy), 2.2, spiralPaint);
      }
    }

    // =========================================================================
    // 4. STAGE 3 (3.0 – 4.5s): ARMOR GLEAM SPECULAR FLASH SWEEP
    // =========================================================================
    if (isDetailed) {
      final double p = ((sec - 3.0) / 1.5).clamp(0.0, 1.0);
      final double sweepX = horseCenter.dx - (horseWidth * 0.6) + (p * horseWidth * 1.2);
      final beamRect = Rect.fromLTWH(sweepX - 18, horseCenter.dy - (horseHeight * 0.45), 36, horseHeight * 0.9);
      final beamPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: (sin(p * pi) * 0.85).clamp(0.0, 0.85)),
            const Color(0xFFFFD700).withValues(alpha: (sin(p * pi) * 0.75).clamp(0.0, 0.75)),
            Colors.transparent,
          ],
        ).createShader(beamRect);
      canvas.drawRect(beamRect, beamPaint);
    }

    // =========================================================================
    // 5. STAGE 4 (4.5 – 7.0s): PARALLAX SPEED LINES & GALLOP HOOF SPARKS
    // =========================================================================
    if (isMovement) {
      final linePaint = Paint()
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      for (int i = 0; i < _speedLines.length; i++) {
        final line = _speedLines[i];
        final phaseOffset = (i * 0.14);
        final xProg = ((progress * line.speed * 4.0) + phaseOffset) % 1.0;
        final startX = size.width - (xProg * (size.width + line.length * 2));
        final endX = startX + line.length;
        final y = size.height * line.yRatio;

        final lineAlpha = ((1.0 - (xProg - 0.5).abs() * 2.0) * 0.55).clamp(0.0, 1.0);
        linePaint
          ..strokeWidth = line.thickness
          ..color = const Color(0xFFFFD700).withValues(alpha: lineAlpha);

        canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
      }

      // Hoof strike spark bursts
      if (sin(gallopPhase) < -0.75) {
        final hoofY = daisCenter.dy;
        final hoofX = horseCenter.dx - (horseWidth * 0.10);
        final hoofPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        for (int s = 0; s < 8; s++) {
          final angle = -pi * 0.15 - (s * 0.22);
          final dist = 12.0 + (s * 4.2);
          final sparkPos = Offset(hoofX + cos(angle) * dist, hoofY + sin(angle) * dist);
          hoofPaint.color = (s % 2 == 0)
              ? const Color(0xFFFFD700).withValues(alpha: 0.90)
              : Colors.white.withValues(alpha: 0.95);
          _drawStar(canvas, sparkPos, 2.8, hoofPaint);
        }
      }
    }

    // =========================================================================
    // 6. STAGE 5 (7.0 – 9.0s): CINEMATIC SHOWCASE BURST (Light Rays + Shockwave + 300 Sparks)
    // =========================================================================
    if (isShowcase) {
      final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);

      // (a) Fullscreen Golden Flash at Impact (7.0s - 7.35s)
      if (p < 0.35) {
        final flashAlpha = (sin(p / 0.35 * pi) * 0.45).clamp(0.0, 1.0);
        final flashPaint = Paint()..color = const Color(0xFFFFE082).withValues(alpha: flashAlpha);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
      }

      // (b) 20 Volumetric Golden Light Rays radiating 360°
      final rayCount = 20;
      final rayAngleStep = (2 * pi) / rayCount;
      final rayLength = size.width * 0.88;
      final rayAlpha = ((1.0 - p) * 0.46).clamp(0.0, 1.0);
      final rayPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      for (int r = 0; r < rayCount; r++) {
        final baseAngle = (r * rayAngleStep) + (p * 0.32);
        final path = Path();
        path.moveTo(horseCenter.dx, horseCenter.dy);
        path.lineTo(
          horseCenter.dx + cos(baseAngle - 0.07) * rayLength,
          horseCenter.dy + sin(baseAngle - 0.07) * rayLength,
        );
        path.lineTo(
          horseCenter.dx + cos(baseAngle + 0.07) * rayLength,
          horseCenter.dy + sin(baseAngle + 0.07) * rayLength,
        );
        path.close();

        rayPaint.shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: rayAlpha),
            const Color(0xFFFFA000).withValues(alpha: rayAlpha * 0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: horseCenter, radius: rayLength));

        canvas.drawPath(path, rayPaint);
      }

      // (c) Expanding Radial Shockwave
      final waveRadius = p * 350.0;
      final waveAlpha = ((1.0 - p) * 0.90).clamp(0.0, 1.0);
      final wavePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: waveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - p) * 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(horseCenter, waveRadius, wavePaint);

      final innerWavePaint = Paint()
        ..color = Colors.white.withValues(alpha: waveAlpha * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - p) * 3.5;
      canvas.drawCircle(horseCenter, waveRadius * 0.96, innerWavePaint);

      // (d) 300 Glowing Burst Particles (150 Stars + 150 Dust motes)
      final starPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      final dustPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      for (int i = 0; i < _burstParticles.length; i++) {
        final bp = _burstParticles[i];
        final dist = bp.speed * p;
        final px = horseCenter.dx + cos(bp.angle) * dist;
        final py = horseCenter.dy + sin(bp.angle) * dist + (p * 45.0);
        final alpha = ((1.0 - p) * 0.92).clamp(0.0, 1.0);

        if (bp.isStar) {
          starPaint.color = (i % 3 == 0)
              ? Colors.white.withValues(alpha: alpha)
              : const Color(0xFFFFD700).withValues(alpha: alpha);
          _drawStar(canvas, Offset(px, py), bp.radius * (1.0 + p * 0.3), starPaint);
        } else {
          dustPaint.color = const Color(0xFFFFA726).withValues(alpha: alpha * 0.75);
          canvas.drawCircle(Offset(px, py), bp.radius, dustPaint);
        }
      }
    }

    // =========================================================================
    // 7. AMBIENT DUST & GLOWING EMBERS AROUND THE STALLION
    // =========================================================================
    for (int i = 0; i < _dust.length; i++) {
      final d = _dust[i];
      final trailLag = (i * 0.015);
      final p = (progress - trailLag).clamp(0.0, 1.0);
      final alpha = ((1.0 - (i / _dust.length)) * (isShowcase ? 1.0 : 0.65)).clamp(0.0, 1.0);

      final spread = isShowcase ? 2.5 : 1.0;
      final dx = cos(d.angle) * d.speed * (p % 0.28) * spread;
      final dy = sin(d.angle) * d.speed * (p % 0.28) * spread + (isShowcase ? -30.0 * (p % 0.28) : 0.0);

      final pos = Offset(horseCenter.dx + dx - 35.0, horseCenter.dy + dy + 35.0);
      final color = d.isSpark ? const Color(0xFFFFD700) : const Color(0xFFFFECB3);

      final paint = Paint()
        ..color = color.withValues(alpha: (alpha * 0.85).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(pos, d.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenHorseDustPainter old) => true;
}

class _DustParticle {
  final double angle;
  final double speed;
  final double radius;
  final bool isSpark;

  const _DustParticle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.isSpark,
  });
}

// =============================================================================
// =============================================================================
// 👑 2. ROYAL CROWN 6-STAGE STORYBOARD PAINTER
// ① Royal Energy Awakens: Pedestal, concentric energy rings, vertical light beam, silhouette wireframe
// ② Crown Emerges: Dais underglow, particle assembly glints, rising embers
// ③ Crown Rotation: Floor reflections, specular sheen glints
// ④ Royal Power Surge: Piercing radial god-rays, expanding shockwave rings, gemstone pulse
// ⑤ Grand Royal Celebration: Royal arched halo, dual blooming fireworks, slow-mo glitter shower
// ⑥ Gift Signature & Exit: Stardust fade and gentle embers
// =============================================================================
class _RoyalCrownGlitterPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset crownCenter;
  final Offset daisCenter;
  final double daisWidth;
  final bool isEnergyAwaken;
  final bool isPowerSurge;
  final bool isCelebration;
  final bool isExit;

  const _RoyalCrownGlitterPainter({
    required this.progress,
    required this.sec,
    required this.crownCenter,
    required this.daisCenter,
    required this.daisWidth,
    required this.isEnergyAwaken,
    required this.isPowerSurge,
    required this.isCelebration,
    required this.isExit,
  });

  // Pre-seeded rising embers (zero GC)
  static final List<_CrownParticle> _risingEmbers = List.generate(45, (i) {
    final rand = Random(i * 317 + 59);
    return _CrownParticle(
      xOffset: (rand.nextDouble() - 0.5) * 220.0,
      speed: 0.6 + rand.nextDouble() * 0.9,
      radius: 1.5 + rand.nextDouble() * 2.8,
      phase: rand.nextDouble() * 2 * pi,
      color: (i % 3 == 0) ? const Color(0xFFFFFFFF) : const Color(0xFFFFD700),
    );
  });

  // Pre-seeded slow-motion cascading glitter shower
  static final List<_CrownParticle> _glitterShower = List.generate(60, (i) {
    final rand = Random(i * 541 + 103);
    return _CrownParticle(
      xOffset: rand.nextDouble(), // xRatio across screen
      speed: 0.4 + rand.nextDouble() * 0.7,
      radius: 1.8 + rand.nextDouble() * 3.4,
      phase: rand.nextDouble() * 2 * pi,
      color: (i % 4 == 0)
          ? const Color(0xFFFFFFFF)
          : (i % 2 == 0)
              ? const Color(0xFFFFEA00)
              : const Color(0xFFFFB300),
    );
  });

  // Pre-seeded firework rays
  static final List<double> _fwAngles = List.generate(32, (i) => i * (2 * pi / 32));

  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------------------
    // 1. TIERED GOLDEN PEDESTAL / DAIS (FLOOR PERSPECTIVE) - SOLID & SEAMLESS
    // -------------------------------------------------------------------------
    final daisFloorY = daisCenter.dy;
    final daisX = daisCenter.dx;
    final baseW = daisWidth.clamp(300.0, size.width * 0.95);
    final baseH = baseW * 0.28;

    // 1. Solid Ambient Ground Gold Bloom (Soft, even, radiant illumination)
    final bloomRect = Rect.fromCenter(
      center: Offset(daisX, daisFloorY + 10),
      width: baseW * 1.35,
      height: baseH * 1.45,
    );
    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xEEFFD700),
          const Color(0x99FFA000),
          const Color(0x44FF8F00),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(bloomRect);
    canvas.drawOval(bloomRect, bloomPaint);

    // 2. Tier 1 (Solid Gold Foundation Pedestal Base - Spans full width)
    final tier1Rect = Rect.fromCenter(
      center: Offset(daisX, daisFloorY + 10),
      width: baseW,
      height: baseH * 0.95,
    );
    final tier1Paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFEA00), Color(0xFFD49B18), Color(0xFF4A3200)],
      ).createShader(tier1Rect);
    canvas.drawOval(tier1Rect, tier1Paint);

    // 3. Tier 2 (Middle Polished Golden Platform - Seamless wide coverage)
    final tier2Rect = Rect.fromCenter(
      center: Offset(daisX, daisFloorY + 4),
      width: baseW * 0.96,
      height: baseH * 0.85,
    );
    final tier2Paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD54F), Color(0xFF8D6E14)],
      ).createShader(tier2Rect);
    canvas.drawOval(tier2Rect, tier2Paint);

    // 4. Tier 3 (Top Illuminated Golden Dais Surface - Spans under entire crown rim)
    final tier3Rect = Rect.fromCenter(
      center: Offset(daisX, daisFloorY),
      width: baseW * 0.92,
      height: baseH * 0.72,
    );
    final tier3Paint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFFE082), Color(0xFFFFB300)],
        stops: [0.0, 0.50, 1.0],
      ).createShader(tier3Rect);
    canvas.drawOval(tier3Rect, tier3Paint);

    // Continuous polished gold rim highlight
    final rimPaint = Paint()
      ..color = const Color(0xFFFFFDE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawOval(tier3Rect, rimPaint);

    // 5. Physical Occlusion Contact Shadow directly on top of pedestal (Solid anchor, eliminates gaps)
    final contactRect = Rect.fromCenter(
      center: Offset(daisX, daisFloorY + 2),
      width: baseW * 0.90,
      height: baseH * 0.42,
    );
    final contactPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xEE2A1200),
          const Color(0x993D1A00),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(contactRect);
    canvas.drawOval(contactRect, contactPaint);

    // -------------------------------------------------------------------------
    // 2. CONCENTRIC EXPANDING FLOOR ENERGY RINGS
    // -------------------------------------------------------------------------
    if (isEnergyAwaken || isPowerSurge || isCelebration) {
      final ringCount = isPowerSurge ? 4 : 3;
      for (int r = 0; r < ringCount; r++) {
        final phase = (progress * 3.5 + (r * 0.28)) % 1.0;
        final ringWidth = (baseW * 0.8) + (phase * (baseW * 0.8));
        final ringHeight = ringWidth * 0.28;
        final ringAlpha = ((1.0 - phase) * (isPowerSurge ? 0.95 : 0.70)).clamp(0.0, 1.0);

        final ringPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - phase) * (isPowerSurge ? 4.5 : 2.5);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(daisX, daisFloorY + 10), width: ringWidth, height: ringHeight),
          ringPaint,
        );
      }
    }

    // -------------------------------------------------------------------------
    // 3. VERTICAL COLUMN OF DIVINE ROYAL LIGHT (Stage 1: 0 - 1s & Stage 4: 4 - 5.5s)
    // -------------------------------------------------------------------------
    if (sec < 1.0 || isPowerSurge) {
      final beamAlpha = (sec < 1.0 ? (sec / 1.0) : 0.65).clamp(0.0, 1.0);
      final beamRect = Rect.fromLTRB(daisX - 80, 0, daisX + 80, daisFloorY);
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x00FFD700),
            const Color(0x66FFEA00).withValues(alpha: beamAlpha * 0.40),
            const Color(0xEEFFFFFF).withValues(alpha: beamAlpha * 0.75),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(beamRect);
      canvas.drawRect(beamRect, beamPaint);

      // Core narrow white god-ray
      final coreRect = Rect.fromLTRB(daisX - 25, 0, daisX + 25, daisFloorY);
      final corePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x00FFFFFF),
            Colors.white.withValues(alpha: beamAlpha * 0.85),
          ],
        ).createShader(coreRect);
      canvas.drawRect(coreRect, corePaint);
    }

    // -------------------------------------------------------------------------
    // 4. LUMINOUS CROWN SILHOUETTE WIREFRAME (Stage 1: 0 - 1s)
    // -------------------------------------------------------------------------
    if (sec < 1.0) {
      final silAlpha = (sec / 1.0).clamp(0.0, 1.0);
      final cx = crownCenter.dx;
      final cy = crownCenter.dy;

      final wirePaint = Paint()
        ..color = const Color(0xFFFFEA00).withValues(alpha: silAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2.0);

      final glowPaint = Paint()
        ..color = const Color(0xAAFFD700).withValues(alpha: silAlpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

      // Crown Base Rim Arc
      final baseRect = Rect.fromCenter(center: Offset(cx, cy + 50), width: 170, height: 35);
      canvas.drawArc(baseRect, 0, pi, false, glowPaint);
      canvas.drawArc(baseRect, 0, pi, false, wirePaint);

      // 5 Ornate Arches of Crown
      final path = Path();
      // Outer Left Arch
      path.moveTo(cx - 80, cy + 50);
      path.cubicTo(cx - 95, cy + 10, cx - 75, cy - 30, cx, cy - 45);
      // Outer Right Arch
      path.moveTo(cx + 80, cy + 50);
      path.cubicTo(cx + 95, cy + 10, cx + 75, cy - 30, cx, cy - 45);
      // Inner Left Arch
      path.moveTo(cx - 45, cy + 55);
      path.cubicTo(cx - 55, cy + 15, cx - 35, cy - 25, cx, cy - 45);
      // Inner Right Arch
      path.moveTo(cx + 45, cy + 55);
      path.cubicTo(cx + 55, cy + 15, cx + 35, cy - 25, cx, cy - 45);
      // Center Arch
      path.moveTo(cx, cy + 58);
      path.lineTo(cx, cy - 45);

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, wirePaint);

      // Top Cross Pattée
      final crossPath = Path();
      final crossY = cy - 60;
      crossPath.moveTo(cx - 10, crossY - 14);
      crossPath.lineTo(cx + 10, crossY - 14);
      crossPath.lineTo(cx + 4, crossY);
      crossPath.lineTo(cx + 14, crossY + 4);
      crossPath.lineTo(cx + 14, crossY + 12);
      crossPath.lineTo(cx + 4, crossY + 10);
      crossPath.lineTo(cx + 4, crossY + 22);
      crossPath.lineTo(cx - 4, crossY + 22);
      crossPath.lineTo(cx - 4, crossY + 10);
      crossPath.lineTo(cx - 14, crossY + 12);
      crossPath.lineTo(cx - 14, crossY + 4);
      crossPath.lineTo(cx - 4, crossY);
      crossPath.close();

      canvas.drawPath(crossPath, glowPaint);
      canvas.drawPath(crossPath, wirePaint);

      // Sparkling gemstone nodes
      final nodePaint = Paint()..color = Colors.white.withValues(alpha: silAlpha);
      for (final pt in [
        Offset(cx, crossY + 4),
        Offset(cx - 80, cy + 50),
        Offset(cx + 80, cy + 50),
        Offset(cx - 45, cy + 55),
        Offset(cx + 45, cy + 55),
        Offset(cx, cy + 58),
        Offset(cx - 75, cy - 28),
        Offset(cx + 75, cy - 28),
      ]) {
        canvas.drawCircle(pt, 3.5, nodePaint);
      }
    }

    // -------------------------------------------------------------------------
    // 5. RISING GOLDEN EMBERS (Stages 1 & 2: 0 - 2.5s)
    // -------------------------------------------------------------------------
    if (sec < 2.8) {
      final emberAlpha = (sec < 2.5 ? 1.0 : (2.8 - sec) / 0.3).clamp(0.0, 1.0);
      final emberPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      for (final e in _risingEmbers) {
        final yDist = ((progress * e.speed * 420.0 + e.phase * 60.0) % 320.0);
        final py = daisFloorY - yDist;
        final px = daisX + e.xOffset + sin(progress * 8.0 + e.phase) * 10.0;
        final a = (sin(progress * 6.0 + e.phase).abs() * 0.7 + 0.3) * emberAlpha;

        emberPaint.color = e.color.withValues(alpha: a.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(px, py), e.radius, emberPaint);
      }
    }

    // -------------------------------------------------------------------------
    // 6. ROYAL POWER SURGE RAYS & EXPANDING SHOCKWAVES (Stage 4: 4 - 5.5s)
    // -------------------------------------------------------------------------
    if (isPowerSurge) {
      final p = ((sec - 4.0) / 1.5).clamp(0.0, 1.0);
      final cx = crownCenter.dx;
      final cy = crownCenter.dy;

      // 12 Piercing Radial God-Rays
      final rayPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      for (int i = 0; i < 12; i++) {
        final angle = (i * 2 * pi / 12) + (sec * 0.35);
        final rayLen = 80.0 + sin(p * pi) * 180.0;
        final endX = cx + cos(angle) * rayLen;
        final endY = cy + sin(angle) * rayLen;
        final rayAlpha = (sin(p * pi) * 0.85).clamp(0.0, 1.0);

        rayPaint.color = (i % 2 == 0)
            ? Colors.white.withValues(alpha: rayAlpha)
            : const Color(0xFFFFD700).withValues(alpha: rayAlpha);
        canvas.drawLine(Offset(cx, cy), Offset(endX, endY), rayPaint);
      }

      // Massive expanding circular shockwave
      final shockwaveR = p * (size.width * 0.65);
      final shockwaveAlpha = ((1.0 - p) * 0.90).clamp(0.0, 1.0);
      final shockwavePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: shockwaveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - p) * 7.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(cx, cy), shockwaveR, shockwavePaint);
    }

    // -------------------------------------------------------------------------
    // 7. GRAND ARCHED ROYAL HALO (Stage 5: 5.5 - 7.5s)
    // -------------------------------------------------------------------------
    if (isCelebration) {
      final p = ((sec - 5.5) / 2.0).clamp(0.0, 1.0);
      final haloAlpha = sin(p * pi).clamp(0.0, 1.0);
      final cx = crownCenter.dx;
      final cy = crownCenter.dy - 10.0;
      const haloRadius = 145.0;

      // Outer glowing halo arch
      final haloGlowPaint = Paint()
        ..color = const Color(0xAAFFD700).withValues(alpha: haloAlpha * 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: haloRadius),
        pi * 0.80,
        pi * 1.40,
        false,
        haloGlowPaint,
      );

      // Sharp golden arch rim
      final haloRimPaint = Paint()
        ..color = const Color(0xFFFFF176).withValues(alpha: haloAlpha * 0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: haloRadius),
        pi * 0.80,
        pi * 1.40,
        false,
        haloRimPaint,
      );

      // Star studs along the halo arch
      final starPaint = Paint()..color = Colors.white.withValues(alpha: haloAlpha);
      for (int i = 0; i < 9; i++) {
        final angle = pi * 0.80 + (i * (pi * 1.40 / 8));
        final sx = cx + cos(angle) * haloRadius;
        final sy = cy + sin(angle) * haloRadius;
        canvas.drawCircle(Offset(sx, sy), 3.2, starPaint);
      }
    }

    // -------------------------------------------------------------------------
    // 8. SPECTACULAR DUAL FIREWORKS (Stage 5: 5.5 - 7.5s)
    // -------------------------------------------------------------------------
    if (isCelebration) {
      final p = ((sec - 5.5) / 2.0).clamp(0.0, 1.0);
      final fwAlpha = ((1.0 - (p * 1.3 - 0.3)).clamp(0.0, 1.0) * sin(p * pi)).clamp(0.0, 1.0);

      final leftCenter = Offset(size.width * 0.18, size.height * 0.28);
      final rightCenter = Offset(size.width * 0.82, size.height * 0.26);

      final fwSparkPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      for (final center in [leftCenter, rightCenter]) {
        final burstRadius = p * 130.0;
        for (int i = 0; i < _fwAngles.length; i++) {
          final angle = _fwAngles[i];
          final r = burstRadius * (0.8 + 0.4 * sin(angle * 4.0).abs());
          final px = center.dx + cos(angle) * r;
          final py = center.dy + sin(angle) * r + (p * p * 30.0); // Gravity fall

          fwSparkPaint.color = (i % 3 == 0)
              ? Colors.white.withValues(alpha: fwAlpha)
              : (i % 2 == 0)
                  ? const Color(0xFFFFEA00).withValues(alpha: fwAlpha)
                  : const Color(0xFFFF9100).withValues(alpha: fwAlpha);

          canvas.drawCircle(Offset(px, py), 2.5 * (1.0 - p * 0.5), fwSparkPaint);
        }
      }
    }

    // -------------------------------------------------------------------------
    // 9. SLOW-MOTION CASCADING GOLDEN GLITTER SHOWER (Stages 5 & 6: 5.5 - 10s)
    // -------------------------------------------------------------------------
    if (sec >= 5.5) {
      final rainAlpha = (sec < 9.0 ? 1.0 : (10.0 - sec) / 1.0).clamp(0.0, 1.0);
      final glitterPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      for (final s in _glitterShower) {
        final y = ((progress * s.speed * size.height * 1.3) + (s.phase * 90.0)) % (size.height + 40.0) - 20.0;
        final x = (s.xOffset * size.width) + sin(progress * 5 * pi + s.phase) * 14.0;
        final a = (sin(progress * 7 * pi + s.phase).abs() * 0.55 + 0.45) * rainAlpha;

        glitterPaint.color = s.color.withValues(alpha: a.clamp(0.0, 1.0));
        canvas.drawCircle(Offset(x, y), s.radius, glitterPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoyalCrownGlitterPainter old) => true;
}

class _CrownParticle {
  final double xOffset;
  final double speed;
  final double radius;
  final double phase;
  final Color color;

  const _CrownParticle({
    required this.xOffset,
    required this.speed,
    required this.radius,
    required this.phase,
    required this.color,
  });
}

// =============================================================================
// 🕊️ 3. ANGEL CHARIOT CANVAS PAINTER (Storyboard Stages 1 - 8)
// Clouds, Awakening Rings, Beam, Constellation, Trails, Halo, Fireworks, Feathers
// =============================================================================
class _AngelChariotCanvasPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset chariotCenter;
  final bool isAwakening;
  final bool isFormation;
  final bool isFlight;
  final bool isCelebration;
  final bool isSignature;
  final bool isFadeOut;

  const _AngelChariotCanvasPainter({
    required this.progress,
    required this.sec,
    required this.chariotCenter,
    required this.isAwakening,
    required this.isFormation,
    required this.isFlight,
    required this.isCelebration,
    required this.isSignature,
    required this.isFadeOut,
  });

  // Pre-seeded rising stardust particles
  static final List<_CrownParticle> _stardust = List.generate(45, (i) {
    final rand = Random(i * 383 + 71);
    return _CrownParticle(
      xOffset: (rand.nextDouble() - 0.5) * 260.0,
      speed: 0.5 + rand.nextDouble() * 0.9,
      radius: 1.5 + rand.nextDouble() * 2.8,
      phase: rand.nextDouble() * 2 * pi,
      color: (i % 3 == 0) ? const Color(0xFFFFFFFF) : (i % 2 == 0 ? const Color(0xFFFFEA00) : const Color(0xFFFFD54F)),
    );
  });

  // Pre-seeded drifting feathers
  static final List<_FeatherSpec> _feathers = List.generate(40, (i) {
    final rand = Random(i * 521 + 19);
    return _FeatherSpec(
      dxOffset: (rand.nextDouble() - 0.5) * 320.0,
      dyOffset: (rand.nextDouble() - 0.5) * 450.0,
      length: 12.0 + rand.nextDouble() * 18.0,
      width: 4.5 + rand.nextDouble() * 6.0,
      rotSpeed: 1.2 + rand.nextDouble() * 2.5,
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  // Pre-seeded firework angles
  static final List<double> _fwAngles = List.generate(32, (i) => i * (2 * pi / 32));

  @override
  void paint(Canvas canvas, Size size) {
    final cx = chariotCenter.dx;
    final cy = chariotCenter.dy;

    // 1. Ethereal Heavenly Sunset Clouds (volumetric atmospheric gradient)
    final cloudAlpha = (sec < 8.5 ? (sec / 1.0).clamp(0.0, 1.0) : (1.0 - (sec - 8.5) / 1.5).clamp(0.0, 1.0));
    if (cloudAlpha > 0.0) {
      final cloudPaint = Paint()
        ..color = const Color(0xFFD1C4E9).withValues(alpha: (0.28 * cloudAlpha).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 38);
      canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.35), 140, cloudPaint);
      canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.30), 160, cloudPaint);

      final goldCloudPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: (0.22 * cloudAlpha).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.65), 170, goldCloudPaint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.70), 140, goldCloudPaint);
    }

    // 2. Stage 1 (0 - 1s & 1 - 2.5s): Concentric Golden Floor Rings & Divine Light Column
    if (isAwakening || isFormation) {
      final floorY = cy + 110.0;
      final ringCount = 3;
      for (int r = 0; r < ringCount; r++) {
        final phase = (progress * 4.0 + (r * 0.33)) % 1.0;
        final ringW = 120.0 + (phase * 220.0);
        final ringH = ringW * 0.28;
        final alpha = ((1.0 - phase) * (isAwakening ? 0.85 : 0.55)).clamp(0.0, 1.0);
        final ringPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = (1.0 - phase) * 3.5;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, floorY), width: ringW, height: ringH), ringPaint);
      }

      // Vertical Divine God-Ray Beam (Stage 1)
      if (isAwakening) {
        final beamAlpha = (sec / 1.0).clamp(0.0, 1.0);
        final beamRect = Rect.fromLTRB(cx - 70, 0, cx + 70, floorY);
        final beamPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0x00FFD700),
              const Color(0x66FFEA00).withValues(alpha: beamAlpha * 0.45),
              const Color(0xEEFFFFFF).withValues(alpha: beamAlpha * 0.80),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(beamRect);
        canvas.drawRect(beamRect, beamPaint);
      }
    }

    // 3. Stage 1 (0 - 1s): Constellation Wireframe Outline of Angel Chariot
    if (sec < 1.0) {
      final silAlpha = (sec / 1.0).clamp(0.0, 1.0);
      final wirePaint = Paint()
        ..color = const Color(0xFFFFEA00).withValues(alpha: silAlpha * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: silAlpha)
        ..style = PaintingStyle.fill;

      // Stylized constellation chariot points
      final points = [
        Offset(cx - 70, cy + 25), // rear wheel
        Offset(cx - 20, cy + 25), // front wheel
        Offset(cx - 85, cy - 10), // chariot hull back
        Offset(cx - 15, cy - 5),  // chariot hull front
        Offset(cx - 50, cy - 45), // angel maiden head
        Offset(cx - 80, cy - 65), // angel wing tip
        Offset(cx + 45, cy - 20), // horse harness
        Offset(cx + 75, cy - 45), // horse head
        Offset(cx + 55, cy - 75), // horse wing tip
        Offset(cx + 90, cy + 15), // horse front hoof
      ];

      final path = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[3].dx, points[3].dy)
        ..lineTo(points[2].dx, points[2].dy)
        ..close()
        ..moveTo(points[2].dx, points[2].dy)
        ..lineTo(points[5].dx, points[5].dy)
        ..lineTo(points[4].dx, points[4].dy)
        ..lineTo(points[3].dx, points[3].dy)
        ..moveTo(points[3].dx, points[3].dy)
        ..lineTo(points[6].dx, points[6].dy)
        ..lineTo(points[7].dx, points[7].dy)
        ..lineTo(points[8].dx, points[8].dy)
        ..lineTo(points[6].dx, points[6].dy)
        ..lineTo(points[9].dx, points[9].dy);

      canvas.drawPath(path, wirePaint);

      // Star nodes
      for (final p in points) {
        canvas.drawCircle(p, 3.5, starPaint);
      }
    }

    // 4. Stage 4 & 7 (Flight & Fade Out): Undulating Golden Ribbon Stardust Trail
    if (isFlight || isFadeOut) {
      final trailAlpha = (isFlight ? 1.0 : (1.0 - (sec - 8.5) / 1.5)).clamp(0.0, 1.0);
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.85 * trailAlpha),
            const Color(0xFFFFB300).withValues(alpha: 0.50 * trailAlpha),
            const Color(0x00FF8F00),
          ],
        ).createShader(Rect.fromLTRB(cx - 280, cy - 50, cx, cy + 80))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      final trailPath = Path()
        ..moveTo(cx - 40, cy + 20)
        ..cubicTo(cx - 100, cy + 40, cx - 180, cy - 20, cx - 260, cy + 30);
      canvas.drawPath(trailPath, trailPaint);

      // Core bright light filament
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.90 * trailAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawPath(trailPath, corePaint);
    }

    // 5. Stage 5 (5.5 - 7.0s): Grand Celebration Celestial Sacred Halo & Fireworks
    if (isCelebration) {
      final p = ((sec - 5.5) / 1.5).clamp(0.0, 1.0);
      final haloAlpha = sin(p * pi).clamp(0.0, 1.0);

      // Sacred Golden Halo Ring behind Angel
      final haloRadius = 78.0 + (sin(p * pi) * 10.0);
      final haloCenter = Offset(cx - 30, cy - 25);
      final haloPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: haloAlpha * 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
      canvas.drawCircle(haloCenter, haloRadius, haloPaint);

      // Outer radial sunburst rays
      final rayCount = 16;
      for (int i = 0; i < rayCount; i++) {
        final angle = (i * 2 * pi / rayCount) + (progress * pi);
        final r1 = haloRadius + 6.0;
        final r2 = haloRadius + 22.0 + (i % 2 == 0 ? 12.0 : 0.0);
        final p1 = Offset(haloCenter.dx + cos(angle) * r1, haloCenter.dy + sin(angle) * r1);
        final p2 = Offset(haloCenter.dx + cos(angle) * r2, haloCenter.dy + sin(angle) * r2);
        final rayPaint = Paint()
          ..color = const Color(0xFFFFF9C4).withValues(alpha: haloAlpha * 0.70)
          ..strokeWidth = (i % 2 == 0 ? 2.2 : 1.4);
        canvas.drawLine(p1, p2, rayPaint);
      }

      // Blooming Fireworks
      final fwCenters = [
        Offset(cx - 120, cy - 110),
        Offset(cx + 120, cy - 90),
        Offset(cx - 80, cy + 90),
        Offset(cx + 130, cy + 70),
      ];
      for (int f = 0; f < fwCenters.length; f++) {
        final fwPhase = ((p * 2.2) + (f * 0.25)) % 1.0;
        final fwRadius = fwPhase * 55.0;
        final fwAlpha = ((1.0 - fwPhase) * haloAlpha).clamp(0.0, 1.0);
        if (fwAlpha > 0.05) {
          final sparkPaint = Paint()
            ..color = (f % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFFFFF59D)).withValues(alpha: fwAlpha)
            ..strokeWidth = 1.8;
          for (final angle in _fwAngles) {
            final spX = fwCenters[f].dx + cos(angle) * fwRadius;
            final spY = fwCenters[f].dy + sin(angle) * fwRadius;
            canvas.drawCircle(Offset(spX, spY), 1.5, sparkPaint);
          }
        }
      }
    }

    // 6. Rising Golden Stardust Particles
    final stardustAlpha = (sec < 8.5 ? (sec / 1.0).clamp(0.0, 1.0) : (1.0 - (sec - 8.5) / 1.5).clamp(0.0, 1.0));
    if (stardustAlpha > 0.05) {
      for (int i = 0; i < _stardust.length; i++) {
        final p = _stardust[i];
        final yRel = (sec * 55.0 * p.speed + p.phase * 40.0) % 360.0;
        final partY = size.height * 0.75 - yRel;
        final partX = cx + p.xOffset + sin(sec * 3.0 + p.phase) * 15.0;

        final partPaint = Paint()
          ..color = p.color.withValues(alpha: (stardustAlpha * 0.85).clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);
        canvas.drawCircle(Offset(partX, partY), p.radius, partPaint);
      }
    }

    // 7. Drifting Glowing White Feathers with Gold Spines
    final featherAlpha = (sec < 0.3 ? (sec / 0.3) : (sec > 9.0 ? (10.0 - sec) / 1.0 : 1.0)).clamp(0.0, 1.0);
    if (featherAlpha > 0.05) {
      for (int i = 0; i < _feathers.length; i++) {
        final f = _feathers[i];
        final fallY = (progress * 380.0 + f.phase * 80.0) % size.height;
        final swayX = sin(progress * f.rotSpeed * 2 * pi + f.phase) * 35.0;
        final pos = Offset((cx + f.dxOffset + swayX) % size.width, fallY);

        canvas.save();
        canvas.translate(pos.dx, pos.dy);
        canvas.rotate(sin(progress * 3 * pi + f.phase) * 0.45);

        final featherPaint = Paint()
          ..color = Colors.white.withValues(alpha: (featherAlpha * 0.88).clamp(0.0, 1.0))
          ..style = PaintingStyle.fill;
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: f.width, height: f.length), featherPaint);

        // Gold spine highlight
        final spinePaint = Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: (featherAlpha * 0.75).clamp(0.0, 1.0))
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(0, -f.length / 2), Offset(0, f.length / 2), spinePaint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AngelChariotCanvasPainter old) => true;
}

class _FeatherSpec {
  final double dxOffset;
  final double dyOffset;
  final double length;
  final double width;
  final double rotSpeed;
  final double phase;

  const _FeatherSpec({
    required this.dxOffset,
    required this.dyOffset,
    required this.length,
    required this.width,
    required this.rotSpeed,
    required this.phase,
  });
}

// =============================================================================
// 🏰 4. LOVE CASTLE HEARTS & SPARKLES PAINTER
// =============================================================================
class _LoveCastleHeartsPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset castleCenter;
  final double castleWidth;
  final double castleHeight;

  const _LoveCastleHeartsPainter({
    required this.progress,
    required this.sec,
    required this.castleCenter,
    this.castleWidth = 380,
    this.castleHeight = 360,
  });

  static final List<_HeartSpec> _hearts = List.generate(45, (i) {
    final rand = Random(i * 613 + 37);
    return _HeartSpec(
      xOffset: (rand.nextDouble() - 0.5) * 320.0,
      speed: 0.6 + rand.nextDouble() * 1.2,
      size: 8.0 + rand.nextDouble() * 18.0,
      phase: rand.nextDouble() * 2 * pi,
      isGold: rand.nextDouble() > 0.70,
    );
  });

  static final List<_CastleSparkleSpec> _sparkles = List.generate(60, (i) {
    final rand = Random(i * 719 + 89);
    return _CastleSparkleSpec(
      dx: (rand.nextDouble() - 0.5) * 340.0,
      dy: (rand.nextDouble() - 0.5) * 320.0,
      size: 2.0 + rand.nextDouble() * 5.5,
      phase: rand.nextDouble() * 2 * pi,
      isGold: rand.nextBool(),
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final basePlaneY = castleCenter.dy + (castleHeight * 0.38);

    // =========================================================================
    // 1. STAGE 1: MAGIC CIRCLE RUNES & VERTICAL LIGHT BEAMS (0.0s - 2.5s)
    // =========================================================================
    if (sec < 2.5) {
      final p = (sec / 1.5).clamp(0.0, 1.0);
      final circleAlpha = (sec < 1.5 ? (p * 0.95) : ((2.5 - sec) / 1.0) * 0.95).clamp(0.0, 0.95);

      if (circleAlpha > 0.01) {
        // Vertical pink radiance pillar
        final beamPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFFFF4081).withValues(alpha: circleAlpha * 0.75),
              const Color(0xFFFF80AB).withValues(alpha: circleAlpha * 0.40),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(castleCenter.dx - 80, castleCenter.dy - 260, 160, 420));
        canvas.drawRect(Rect.fromLTWH(castleCenter.dx - 80, castleCenter.dy - 260, 160, 420), beamPaint);

        // Ground Runic Ellipses
        final ringCenter = Offset(castleCenter.dx, basePlaneY);
        final ringRadiusX = 140.0 * p;
        final ringRadiusY = ringRadiusX * 0.32;

        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFF4081).withValues(alpha: circleAlpha);
        canvas.drawOval(Rect.fromCenter(center: ringCenter, width: ringRadiusX * 2, height: ringRadiusY * 2), ringPaint);

        // Outer rotating dashed glyph ring
        final outerPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0xFFFF80AB).withValues(alpha: circleAlpha * 0.7);
        canvas.drawOval(Rect.fromCenter(center: ringCenter, width: ringRadiusX * 2.3, height: ringRadiusY * 2.3), outerPaint);

        // Inner glowing core
        final corePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFFFFD54F).withValues(alpha: circleAlpha * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
        canvas.drawOval(Rect.fromCenter(center: ringCenter, width: ringRadiusX * 0.8, height: ringRadiusY * 0.8), corePaint);
      }
    }

    // =========================================================================
    // 2. STAGE 2 & 3: ASCENDING CHERRY BLOSSOM PETALS & SPARKLE TRAILS (1.5s - 5.5s)
    // =========================================================================
    if (sec >= 1.2 && sec <= 6.0) {
      final petalAlpha = (sec < 2.0
              ? (sec - 1.2) / 0.8
              : (sec > 5.0 ? (6.0 - sec) / 1.0 : 1.0))
          .clamp(0.0, 1.0);

      for (final h in _hearts) {
        final floatP = ((sec * 0.6 * h.speed) + (h.phase / (2 * pi))) % 1.0;
        final py = basePlaneY + 40.0 - (floatP * 340.0);
        final px = castleCenter.dx + h.xOffset + (sin(sec * 3.0 + h.phase) * 22.0);
        final a = (sin(floatP * pi) * petalAlpha).clamp(0.0, 1.0);

        final petalPaint = Paint()
          ..color = (h.isGold ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB)).withValues(alpha: a * 0.85)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(px, py);
        canvas.rotate(sin(sec * 2.0 + h.phase) * 0.6);
        final r = h.size * 0.5;
        final pth = Path();
        pth.moveTo(0, r * 0.3);
        pth.cubicTo(-r, -r * 0.6, -r * 1.1, r * 0.4, 0, r * 1.2);
        pth.cubicTo(r * 1.1, r * 0.4, r, -r * 0.6, 0, r * 0.3);
        canvas.drawPath(pth, petalPaint);
        canvas.restore();
      }
    }

    // =========================================================================
    // 3. STAGE 4: HEART CRYSTAL PULSING SHOCKWAVES (5.0s - 7.2s)
    // =========================================================================
    if (sec >= 4.8 && sec <= 7.2) {
      final heartApex = Offset(castleCenter.dx, castleCenter.dy - (castleHeight * 0.36));
      final pulseSec = sec - 4.8;

      // 3 expanding heart shockwaves
      for (int i = 0; i < 3; i++) {
        final wavePhase = ((pulseSec * 1.2) - (i * 0.35)) % 1.0;
        if (wavePhase > 0.0) {
          final waveRadius = 30.0 + (wavePhase * 160.0);
          final waveAlpha = ((1.0 - wavePhase) * 0.75).clamp(0.0, 0.75);

          final wavePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 * (1.0 - wavePhase * 0.5)
            ..color = const Color(0xFFFF4081).withValues(alpha: waveAlpha);

          // Draw heart outline wave
          canvas.save();
          canvas.translate(heartApex.dx, heartApex.dy);
          final hr = waveRadius * 0.5;
          final hPath = Path();
          hPath.moveTo(0, hr * 0.3);
          hPath.cubicTo(-hr, -hr * 0.6, -hr * 1.1, hr * 0.4, 0, hr * 1.2);
          hPath.cubicTo(hr * 1.1, hr * 0.4, hr, -hr * 0.6, 0, hr * 0.3);
          canvas.drawPath(hPath, wavePaint);
          canvas.restore();
        }
      }
    }

    // =========================================================================
    // 4. STAGE 5: HEART-SHAPED FIREWORKS SHOW (7.0s - 9.5s)
    // =========================================================================
    if (sec >= 6.9 && sec <= 9.6) {
      final fireworkOrigins = [
        Offset(castleCenter.dx - 140, castleCenter.dy - 170), // Burst 1 (7.1s)
        Offset(castleCenter.dx + 140, castleCenter.dy - 180), // Burst 2 (7.4s)
        Offset(castleCenter.dx, castleCenter.dy - 230),       // Burst 3 (7.7s)
        Offset(castleCenter.dx - 110, castleCenter.dy - 90),  // Burst 4 (8.1s)
        Offset(castleCenter.dx + 120, castleCenter.dy - 100), // Burst 5 (8.4s)
      ];
      final burstTimes = [7.05, 7.35, 7.65, 8.05, 8.35];

      for (int i = 0; i < fireworkOrigins.length; i++) {
        final origin = fireworkOrigins[i];
        final bTime = burstTimes[i];
        if (sec >= bTime && sec <= bTime + 1.4) {
          final bp = ((sec - bTime) / 1.4).clamp(0.0, 1.0);
          final expandEase = Curves.easeOutCubic.transform(bp);
          final fireworkAlpha = ((1.0 - bp) * 0.95).clamp(0.0, 0.95);
          final isGoldFw = (i % 2 == 1);

          // 24 parametric heart particles
          for (int pIdx = 0; pIdx < 24; pIdx++) {
            final t = (pIdx / 24.0) * 2 * pi;
            // Parametric heart formula
            final hx = 16.0 * pow(sin(t), 3);
            final hy = -(13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t));

            final distScale = 3.6 * expandEase;
            final px = origin.dx + (hx * distScale);
            final py = origin.dy + (hy * distScale) + (bp * bp * 24.0); // Gravity fall

            final color = isGoldFw
                ? (pIdx % 2 == 0 ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB))
                : (pIdx % 2 == 0 ? const Color(0xFFFF4081) : const Color(0xFFFFFFFF));

            final fwPaint = Paint()
              ..color = color.withValues(alpha: fireworkAlpha)
              ..style = PaintingStyle.fill;

            canvas.drawCircle(Offset(px, py), 2.8 * (1.0 - bp * 0.4), fwPaint);
          }

          // Core flash at explosion moment
          if (bp < 0.25) {
            final flashAlpha = (1.0 - (bp / 0.25)).clamp(0.0, 1.0);
            final flashPaint = Paint()
              ..color = Colors.white.withValues(alpha: flashAlpha * 0.8)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
            canvas.drawCircle(origin, 18.0 * (1.0 + bp * 2), flashPaint);
          }
        }
      }
    }

    // =========================================================================
    // 5. STAGE 6: FINAL GLOW & SHIMMERING WATER REFLECTIONS (9.0s - 12.0s)
    // =========================================================================
    if (sec >= 8.8) {
      final glowAlpha = (sec < 9.5
              ? (sec - 8.8) / 0.7
              : (sec > 11.0 ? (12.0 - sec) / 1.0 : 1.0))
          .clamp(0.0, 1.0);

      // Shimmering horizontal reflection wave bands beneath island
      final waterTopY = basePlaneY + 15.0;
      for (int w = 0; w < 7; w++) {
        final wy = waterTopY + (w * 14.0);
        final waveWidth = (castleWidth * 0.75) * (1.0 - (w * 0.10));
        final waveOffset = sin((sec * 2.5) + (w * 0.8)) * 12.0;
        final waveColor = (w % 2 == 0 ? const Color(0xFFFF4081) : const Color(0xFFFFD54F))
            .withValues(alpha: glowAlpha * (0.35 - (w * 0.04)).clamp(0.0, 0.4));

        final wavePaint = Paint()
          ..color = waveColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawLine(
          Offset(castleCenter.dx - (waveWidth / 2) + waveOffset, wy),
          Offset(castleCenter.dx + (waveWidth / 2) + waveOffset, wy),
          wavePaint,
        );
      }
    }

    // Ambient floating stardust across all active stages
    final starAlpha = (sec < 1.0 ? sec : (sec > 11.0 ? 12.0 - sec : 1.0)).clamp(0.0, 1.0);
    for (final sp in _sparkles) {
      final a = (sin(sec * 4.0 + sp.phase).abs() * starAlpha * 0.75).clamp(0.0, 1.0);
      final spPaint = Paint()
        ..color = (sp.isGold ? const Color(0xFFFFD54F) : const Color(0xFFFF80AB)).withValues(alpha: a)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(castleCenter.dx + sp.dx, castleCenter.dy + sp.dy), sp.size * 0.5, spPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LoveCastleHeartsPainter old) => true;
}

class _CastleSparkleSpec {
  final double dx;
  final double dy;
  final double size;
  final double phase;
  final bool isGold;

  const _CastleSparkleSpec({
    required this.dx,
    required this.dy,
    required this.size,
    required this.phase,
    required this.isGold,
  });
}

class _HeartSpec {
  final double xOffset;
  final double speed;
  final double size;
  final double phase;
  final bool isGold;

  const _HeartSpec({
    required this.xOffset,
    required this.speed,
    required this.size,
    required this.phase,
    required this.isGold,
  });
}

// =============================================================================
// 👑✨ 5. STAR THRONE COSMIC 6-STAGE CINEMATIC PAINTER
// =============================================================================
class _StarThroneCosmicPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset starPos;
  final Offset throneCenter;
  final double throneWidth;
  final double throneHeight;
  final bool isAccession;

  const _StarThroneCosmicPainter({
    required this.progress,
    required this.sec,
    required this.starPos,
    required this.throneCenter,
    required this.throneWidth,
    required this.throneHeight,
    required this.isAccession,
  });

  // Deterministic seed random cosmic particles
  static final List<_ThroneStarMote> _starMotes = List.generate(70, (i) {
    final rand = Random(i * 733 + 41);
    return _ThroneStarMote(
      normX: rand.nextDouble(),
      normY: rand.nextDouble(),
      speed: 0.4 + rand.nextDouble() * 0.8,
      size: 2.0 + rand.nextDouble() * 3.5,
      phase: rand.nextDouble() * 2 * pi,
      isGold: i % 2 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    // -------------------------------------------------------------------------
    // STAGE 1: Star Descent (0.0 – 1.5s): Radiant shooting star & stardust trail
    // -------------------------------------------------------------------------
    if (sec < 1.5) {
      final p1 = (sec / 1.5).clamp(0.0, 1.0);
      final trailLen = 35;
      final startPos = Offset(size.width * 0.65, size.height * 0.06);

      // Draw Stardust Comet Tail
      for (int i = trailLen; i >= 1; i--) {
        final trailT = (p1 - (i * 0.018)).clamp(0.0, 1.0);
        final trailEase = Curves.easeOutCubic.transform(trailT);
        final tx = size.width * 0.65 - (trailEase * (size.width * 0.15));
        final ty = size.height * 0.06 + (trailEase * (throneCenter.dy - size.height * 0.06));

        final alpha = ((1.0 - (i / trailLen)) * sin(p1 * pi * 0.9)).clamp(0.0, 1.0);
        final r = (1.5 + (trailLen - i) * 0.22);
        final pColor = i % 3 == 0
            ? Colors.white
            : (i % 3 == 1 ? const Color(0xFFFFD700) : const Color(0xFFF59E0B));

        final paint = Paint()
          ..color = pColor.withValues(alpha: alpha * 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(Offset(tx + sin(i * 1.8) * 4.0, ty + cos(i * 1.5) * 3.0), r, paint);
      }

      // Draw Radiant 8-Pointed Celestial Star Head
      _drawRadiantStar(canvas, starPos, radius: 24.0 + sin(sec * 12) * 3.0, alpha: 1.0);
    }

    // -------------------------------------------------------------------------
    // STAGE 2: Energy Spiral (1.5 – 3.0s): Spinning star orb & cosmic energy waves
    // -------------------------------------------------------------------------
    if (sec >= 1.4 && sec < 3.2) {
      final p2 = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
      final spinAngle = sec * 8 * pi;

      // Concentric Expanding Cosmic Energy Spiral Waves
      for (int i = 0; i < 4; i++) {
        final waveOffset = (p2 + (i * 0.25)) % 1.0;
        final waveRadiusX = 30.0 + (waveOffset * (size.width * 0.42));
        final waveRadiusY = 12.0 + (waveOffset * (size.height * 0.14));
        final waveAlpha = (sin(waveOffset * pi) * 0.85).clamp(0.0, 1.0);

        final wavePaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: waveAlpha * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 * (1.0 - waveOffset)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

        canvas.save();
        canvas.translate(starPos.dx, starPos.dy);
        canvas.rotate(waveOffset * 0.4);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: waveRadiusX * 2, height: waveRadiusY * 2),
          wavePaint,
        );
        canvas.restore();
      }

      // Spinning Central Star Core with Ethereal Corona
      canvas.save();
      canvas.translate(starPos.dx, starPos.dy);
      canvas.rotate(spinAngle);
      _drawRadiantStar(canvas, Offset.zero, radius: 26.0 + sin(sec * 14) * 4.0, alpha: (1.0 - (p2 * 0.3)).clamp(0.0, 1.0));
      canvas.restore();
    }

    // -------------------------------------------------------------------------
    // STAGE 3: Throne Formation (3.0 – 5.0s): Vertical Celestial Pillars of Light
    // -------------------------------------------------------------------------
    if (sec >= 2.8 && sec < 5.2) {
      final p3 = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
      final pillarAlpha = (sin(p3 * pi) * 0.85).clamp(0.0, 1.0);

      final pillarOffsets = [-0.35, -0.18, 0.0, 0.18, 0.35];
      for (int i = 0; i < pillarOffsets.length; i++) {
        final px = throneCenter.dx + (pillarOffsets[i] * throneWidth);
        final pWidth = 14.0 + (i == 2 ? 8.0 : 0.0);
        final pH = size.height * 0.65;

        final pillarPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFFFFD700).withValues(alpha: pillarAlpha * 0.8),
              const Color(0xFFFFF9C4).withValues(alpha: pillarAlpha * 0.6),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromLTWH(px - pWidth / 2, throneCenter.dy - pH * 0.7, pWidth, pH))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawRect(Rect.fromLTWH(px - pWidth / 2, throneCenter.dy - pH * 0.7, pWidth, pH), pillarPaint);
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 4: Rise to Power (5.0 – 7.0s): 3D Revolving Celestial Rings
    // -------------------------------------------------------------------------
    if (sec >= 4.8 && sec < 7.2) {
      final p4 = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);
      final ringAlpha = (sin(p4 * pi) * 0.90).clamp(0.0, 1.0);

      for (int rIdx = 0; rIdx < 3; rIdx++) {
        final rAngle = (sec * 2.5 + (rIdx * pi / 1.5));
        final ringW = throneWidth * (0.85 + (rIdx * 0.15));
        final ringH = throneHeight * (0.32 + (rIdx * 0.08));

        canvas.save();
        canvas.translate(throneCenter.dx, throneCenter.dy);
        canvas.rotate(sin(rAngle * 0.5) * 0.18);

        final ringPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: ringAlpha * 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: ringW, height: ringH),
          ringPaint,
        );
        canvas.restore();
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 5: Royal Accession (7.0 – 9.0s): Supernova Flare & Shockwave
    // -------------------------------------------------------------------------
    if (sec >= 7.0 && sec < 9.2) {
      final p5 = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);

      // Supernova Shockwave expansion
      if (p5 < 0.60) {
        final shockP = p5 / 0.60;
        final shockRadius = shockP * (size.width * 0.62);
        final shockAlpha = ((1.0 - shockP) * 0.85).clamp(0.0, 1.0);

        final shockPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: shockAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1.0 - shockP)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(throneCenter, shockRadius, shockPaint);
      }

      // Blazing Crown Supernova Ray Burst
      final rayCount = 12;
      final rayAlpha = (sin(p5 * pi) * 0.95).clamp(0.0, 1.0);
      final crownPos = Offset(throneCenter.dx, throneCenter.dy - throneHeight * 0.40);

      for (int r = 0; r < rayCount; r++) {
        final angle = (r * 2 * pi / rayCount) + (sec * 0.8);
        final rayLen = (r % 2 == 0 ? 55.0 : 35.0) * (1.0 + sin(p5 * pi) * 0.4);
        final pEnd = Offset(crownPos.dx + cos(angle) * rayLen, crownPos.dy + sin(angle) * rayLen);

        final rayPaint = Paint()
          ..color = const Color(0xFFFFF9C4).withValues(alpha: rayAlpha * 0.8)
          ..strokeWidth = (r % 2 == 0 ? 2.2 : 1.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        canvas.drawLine(crownPos, pEnd, rayPaint);
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 6 & ALL STAGES: Floating Golden Star Motes & Twinkling Sparkles
    // -------------------------------------------------------------------------
    for (final mote in _starMotes) {
      final mx = (mote.normX * size.width);
      final my = (mote.normY * size.height - (sec * mote.speed * 25.0)) % size.height;
      final mAlpha = (0.35 + 0.65 * sin(sec * 4.0 + mote.phase)).abs().clamp(0.0, 1.0);

      final motePaint = Paint()
        ..color = (mote.isGold ? const Color(0xFFFFD700) : Colors.white).withValues(alpha: mAlpha * 0.80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(mx, my), mote.size, motePaint);
    }
  }

  void _drawRadiantStar(Canvas canvas, Offset center, {required double radius, required double alpha}) {
    // 1. Core Halo Glow
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: alpha * 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius * 1.2, haloPaint);

    // 2. 8-Pointed Golden Star Diamond Path
    final path = Path();
    final points = 8;
    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : (radius * 0.38);
      final a = (i * pi / points) - (pi / 2);
      final x = center.dx + cos(a) * r;
      final y = center.dy + sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, starPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, borderPaint);

    // 3. Central Lens Flare Spark
    canvas.drawCircle(center, radius * 0.25, Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: alpha));
  }

  @override
  bool shouldRepaint(covariant _StarThroneCosmicPainter old) => true;
}

class _ThroneStarMote {
  final double normX;
  final double normY;
  final double speed;
  final double size;
  final double phase;
  final bool isGold;

  const _ThroneStarMote({
    required this.normX,
    required this.normY,
    required this.speed,
    required this.size,
    required this.phase,
    required this.isGold,
  });
}

// =============================================================================
// 👑✨ FULL-SCREEN STAR THRONE COSMIC BACKDROP PAINTER
// =============================================================================
class _FullStarThroneCosmicBackdropPainter extends CustomPainter {
  final double progress;

  const _FullStarThroneCosmicBackdropPainter({required this.progress});

  static final List<Offset> _fixedStars = List.generate(85, (i) {
    final rand = Random(i * 991 + 79);
    return Offset(rand.nextDouble(), rand.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cosmic Deep Indigo / Violet Nebula Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.1),
        radius: 1.1,
        colors: [
          const Color(0xFF1E1B4B).withValues(alpha: 0.55), // Indigo Deep Space
          const Color(0xFF0F172A).withValues(alpha: 0.70), // Midnight Abyss
          Colors.black.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Distant Twinkling Star Field
    for (int i = 0; i < _fixedStars.length; i++) {
      final pos = _fixedStars[i];
      final twinkle = (0.2 + 0.8 * sin(progress * 6 * pi + i)).abs();
      final p = Offset(pos.dx * size.width, pos.dy * size.height);
      final r = (i % 5 == 0) ? 2.2 : 1.2;

      final pColor = (i % 3 == 0) ? const Color(0xFFFFD700) : Colors.white;
      final pPaint = Paint()..color = pColor.withValues(alpha: twinkle * 0.75);
      canvas.drawCircle(p, r, pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullStarThroneCosmicBackdropPainter old) => true;
}
// =============================================================================
// 🏎️ 6. LUXURY CAR HIGHWAY, DRIFT, NEON PORTAL & CELEBRATION FIREWORKS PAINTER
// =============================================================================
class _SparklingCarHighwayPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset carCenter;
  final bool isDrifting;
  final bool isCelebration;
  final bool isExit;

  const _SparklingCarHighwayPainter({
    required this.progress,
    required this.sec,
    required this.carCenter,
    required this.isDrifting,
    required this.isCelebration,
    required this.isExit,
  });

  // 1. Pre-generated Speed Lines (24 horizontal streaks)
  static final List<_CarSpeedLine> _speedLines = List.generate(24, (i) {
    final rand = Random(i * 383 + 57);
    return _CarSpeedLine(
      yRatio: 0.44 + rand.nextDouble() * 0.36,
      length: 80.0 + rand.nextDouble() * 220.0,
      speed: 1.2 + rand.nextDouble() * 2.0,
      opacity: 0.35 + rand.nextDouble() * 0.45,
    );
  });

  // 2. Pre-generated Volumetric Tire Smoke Puffs (48 puffs)
  static final List<_CarSmokePuff> _smokePuffs = List.generate(48, (i) {
    final rand = Random(i * 919 + 17);
    return _CarSmokePuff(
      offsetX: (rand.nextDouble() - 0.5) * 160.0,
      offsetY: 25.0 + rand.nextDouble() * 45.0,
      maxRadius: 28.0 + rand.nextDouble() * 42.0,
      speed: 0.6 + rand.nextDouble() * 0.8,
      phase: rand.nextDouble() * 2 * pi,
      isAmber: i % 3 == 0,
    );
  });

  // 3. Pre-generated Drift Friction Sparks (60 ballistic sparks)
  static final List<_CarDriftSpark> _driftSparks = List.generate(60, (i) {
    final rand = Random(i * 1237 + 41);
    final angle = pi * 0.8 + rand.nextDouble() * (pi * 0.6); // backward spray
    return _CarDriftSpark(
      vx: cos(angle) * (140.0 + rand.nextDouble() * 260.0),
      vy: sin(angle) * (60.0 + rand.nextDouble() * 140.0),
      size: 2.0 + rand.nextDouble() * 3.5,
      lifetime: 0.4 + rand.nextDouble() * 0.6,
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  // 4. Pre-generated Celebration Fireworks Particles (320 stardust embers)
  static final List<_CarFireworkStar> _fireworkStars = List.generate(320, (i) {
    final rand = Random(i * 1871 + 63);
    final angle = rand.nextDouble() * 2 * pi;
    final burstIdx = i % 3; // 3 burst epicenters
    return _CarFireworkStar(
      burstIndex: burstIdx,
      angle: angle,
      speed: 120.0 + rand.nextDouble() * 360.0,
      size: 3.0 + rand.nextDouble() * 8.0,
      color: i % 4 == 0
          ? const Color(0xFFFFD700)
          : (i % 4 == 1
              ? const Color(0xFFFF2D78)
              : (i % 4 == 2 ? const Color(0xFF00E5FF) : Colors.white)),
      decay: 0.82 + rand.nextDouble() * 0.18,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final groundY = size.height * 0.48;

    // ① DARK ASPHALT HIGHWAY PLANE & WET GOLD REFLECTIONS (Stage 1 to 6)
    final roadRect = Rect.fromLTWH(0, groundY, size.width, size.height - groundY);
    final roadPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0x77080512),
          const Color(0xBB0D091B),
          const Color(0xEE090614),
        ],
      ).createShader(roadRect);
    canvas.drawRect(roadRect, roadPaint);

    // Wet Ground Reflection Underbody Glow
    if (sec < 8.2) {
      final underglowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x55FFD700),
            const Color(0x3300E5FF),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCenter(
          center: Offset(carCenter.dx, carCenter.dy + 72),
          width: 320,
          height: 70,
        ))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(carCenter.dx, carCenter.dy + 72), width: 320, height: 60),
        underglowPaint,
      );
    }

    // Horizontal Highway Speed Lines (Stage 1, 2, 3, 6)
    if (!isCelebration) {
      final lineAlpha = (isExit ? 0.85 : (isDrifting ? 0.65 : 0.45));
      for (int i = 0; i < _speedLines.length; i++) {
        final sl = _speedLines[i];
        final x = ((1.0 - (progress * sl.speed * 4.0 + i * 0.08) % 1.0) * (size.width + 200)) - 100;
        final y = size.height * sl.yRatio;
        final linePaint = Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF00E5FF))
                  .withValues(alpha: sl.opacity * lineAlpha),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(x, y, sl.length, 2))
          ..strokeWidth = 2.0;
        canvas.drawLine(Offset(x, y), Offset(x + sl.length, y), linePaint);
      }
    }

    // ② HEADLIGHT BEAM CONES & ANAMORPHIC FLARE (Stage 1, 2, 4, 5)
    if (sec < 7.8) {
      final beamAlpha = (sec < 0.8 ? sec / 0.8 : (isCelebration ? 0.75 : 0.90));
      final headlightCenter = Offset(carCenter.dx + 80, carCenter.dy + 15);
      final conePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0x9900E5FF).withValues(alpha: beamAlpha * 0.7),
            const Color(0x55FFD700).withValues(alpha: beamAlpha * 0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(headlightCenter.dx, headlightCenter.dy - 35, 260, 90))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      final conePath = Path();
      conePath.moveTo(headlightCenter.dx, headlightCenter.dy - 12);
      conePath.lineTo(headlightCenter.dx + 260, headlightCenter.dy - 45);
      conePath.lineTo(headlightCenter.dx + 260, headlightCenter.dy + 55);
      conePath.lineTo(headlightCenter.dx, headlightCenter.dy + 20);
      conePath.close();
      canvas.drawPath(conePath, conePaint);

      // Anamorphic Cyan Flare Streak
      final flarePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF00E5FF).withValues(alpha: beamAlpha * 0.85),
            Colors.white.withValues(alpha: beamAlpha),
            const Color(0xFFFFD700).withValues(alpha: beamAlpha * 0.85),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(headlightCenter.dx - 120, headlightCenter.dy - 3, 240, 6));
      canvas.drawRect(Rect.fromLTWH(headlightCenter.dx - 120, headlightCenter.dy - 2, 240, 4), flarePaint);
    }

    // ③ BILLOWING TIRE SMOKE PLUMES (Stage 2: Rev, Stage 3: Drift, Stage 4: Celebration)
    if (sec >= 1.0 && sec < 7.5) {
      final smokeIntensity = isDrifting ? 1.0 : (sec < 2.0 ? 0.65 : 0.50);
      for (int i = 0; i < _smokePuffs.length; i++) {
        final p = _smokePuffs[i];
        final puffP = ((sec * p.speed + p.phase) % 1.0);
        final radius = p.maxRadius * (0.3 + puffP * 0.7);
        final alpha = (sin(puffP * pi) * 0.55 * smokeIntensity).clamp(0.0, 1.0);
        if (alpha <= 0.02) continue;

        final px = carCenter.dx + p.offsetX - (isDrifting ? 40.0 : 70.0) * puffP;
        final py = carCenter.dy + p.offsetY - puffP * 15.0;

        final smokeColor = p.isAmber
            ? const Color(0xFFFFE082).withValues(alpha: alpha * 0.45)
            : const Color(0xFFEEEEEE).withValues(alpha: alpha * 0.55);

        final smokePaint = Paint()
          ..color = smokeColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(Offset(px, py), radius, smokePaint);
      }
    }

    // ④ ASPHALT FRICTION DRIFT SPARKS (Stage 3: 2 - 4 sec)
    if (isDrifting) {
      final driftP = ((sec - 2.0) / 2.0).clamp(0.0, 1.0);
      for (int i = 0; i < _driftSparks.length; i++) {
        final s = _driftSparks[i];
        final sparkAge = ((driftP * 3.5 + s.phase) % s.lifetime) / s.lifetime;
        final sparkX = carCenter.dx - 45.0 + s.vx * sparkAge;
        final sparkY = carCenter.dy + 48.0 + s.vy * sparkAge + 120.0 * sparkAge * sparkAge; // gravity
        final sparkAlpha = ((1.0 - sparkAge) * 0.95).clamp(0.0, 1.0);

        final sparkPaint = Paint()
          ..color = (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFFFFA000))
              .withValues(alpha: sparkAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
        canvas.drawCircle(Offset(sparkX, sparkY), s.size * (1.0 - sparkAge * 0.5), sparkPaint);
      }
    }

    // ⑤ CONCENTRIC GLOWING NEON PORTAL RINGS (Stage 4 & 5: 4 - 8 sec)
    if (isCelebration) {
      final portalP = ((sec - 4.0) / 1.5).clamp(0.0, 1.0);
      final portalCenter = Offset(size.width * 0.50, carCenter.dy - 10);
      final R = (size.width * 0.40).clamp(135.0, 205.0) * portalP;

      // Outer Golden Neon Ring
      final outerRingPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.85 * portalP)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(portalCenter, R, outerRingPaint);

      final outerCorePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95 * portalP)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(portalCenter, R, outerCorePaint);

      // Inner Magenta/Cyan Concentric Ring
      final innerRingPaint = Paint()
        ..color = const Color(0xFFFF2D78).withValues(alpha: 0.75 * portalP)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(portalCenter, R * 0.72, innerRingPaint);

      // 16 Rotating Radial Rays
      final rayLen = R * 1.35;
      for (int i = 0; i < 16; i++) {
        final angle = (i * 2 * pi / 16.0) + (sec * 0.75);
        final rayAlpha = ((sin(sec * 4 + i).abs() * 0.4 + 0.5) * portalP).clamp(0.0, 1.0);
        final p1 = Offset(portalCenter.dx + cos(angle) * (R * 0.65), portalCenter.dy + sin(angle) * (R * 0.65));
        final p2 = Offset(portalCenter.dx + cos(angle) * rayLen, portalCenter.dy + sin(angle) * rayLen);
        final rayPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFFFFD700).withValues(alpha: rayAlpha * 0.8),
              Colors.transparent,
            ],
          ).createShader(Rect.fromPoints(p1, p2))
          ..strokeWidth = (i % 2 == 0 ? 3.0 : 1.8);
        canvas.drawLine(p1, p2, rayPaint);
      }

      // ⑥ OVERHEAD CELEBRATION FIREWORKS (Stage 4 & 5: 4 - 8 sec)
      final burstCenters = [
        Offset(size.width * 0.28, size.height * 0.20),
        Offset(size.width * 0.72, size.height * 0.18),
        Offset(size.width * 0.50, size.height * 0.14),
      ];
      final burstTimes = [4.2, 4.9, 5.7];

      for (int b = 0; b < 3; b++) {
        final bTime = burstTimes[b];
        if (sec >= bTime) {
          final bProg = ((sec - bTime) / 1.6).clamp(0.0, 1.0);
          final bCenter = burstCenters[b];
          final shockRadius = bProg * 140.0;
          final shockAlpha = ((1.0 - bProg) * 0.8).clamp(0.0, 1.0);

          // Shockwave expansion ring
          final shockPaint = Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: shockAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * (1.0 - bProg);
          canvas.drawCircle(bCenter, shockRadius, shockPaint);

          // Fireworks stardust particles
          for (final sp in _fireworkStars) {
            if (sp.burstIndex != b) continue;
            final dist = bProg * sp.speed * sp.decay;
            final px = bCenter.dx + cos(sp.angle) * dist;
            final py = bCenter.dy + sin(sp.angle) * dist + 45.0 * bProg * bProg; // gravity drift
            final pAlpha = ((1.0 - bProg) * 0.95).clamp(0.0, 1.0);
            if (pAlpha <= 0.01) continue;

            final partPaint = Paint()
              ..color = sp.color.withValues(alpha: pAlpha)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
            canvas.drawCircle(Offset(px, py), sp.size * (1.0 - bProg * 0.4), partPaint);
          }
        }
      }
    }

    // ⑦ HYPERSPACE LAUNCH SHOCKWAVE & EXIT PARTICLES (Stage 6: 8 - 10 sec)
    if (isExit) {
      final exitP = ((sec - 8.0) / 2.0).clamp(0.0, 1.0);
      final shockCenter = Offset(size.width * 0.40, carCenter.dy);
      final shockR = exitP * (size.width * 0.55);
      final shockAlpha = ((1.0 - exitP) * 0.85).clamp(0.0, 1.0);

      final exitShockPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: shockAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * (1.0 - exitP);
      canvas.drawCircle(shockCenter, shockR, exitShockPaint);

      // Trailing Supersonic Exhaust Particles
      for (int i = 0; i < 40; i++) {
        final rand = Random(i * 439 + 19);
        final trailP = ((exitP * 2.5 + rand.nextDouble()) % 1.0);
        final tx = carCenter.dx - 120.0 * trailP - rand.nextDouble() * 80.0;
        final ty = carCenter.dy + (rand.nextDouble() - 0.5) * 50.0;
        final tAlpha = ((1.0 - trailP) * 0.85).clamp(0.0, 1.0);
        final tPaint = Paint()
          ..color = (i % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFF00E5FF))
              .withValues(alpha: tAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(Offset(tx, ty), 3.0 * (1.0 - trailP), tPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklingCarHighwayPainter old) => true;
}

class _CarSpeedLine {
  final double yRatio;
  final double length;
  final double speed;
  final double opacity;

  const _CarSpeedLine({
    required this.yRatio,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class _CarSmokePuff {
  final double offsetX;
  final double offsetY;
  final double maxRadius;
  final double speed;
  final double phase;
  final bool isAmber;

  const _CarSmokePuff({
    required this.offsetX,
    required this.offsetY,
    required this.maxRadius,
    required this.speed,
    required this.phase,
    required this.isAmber,
  });
}

class _CarDriftSpark {
  final double vx;
  final double vy;
  final double size;
  final double lifetime;
  final double phase;

  const _CarDriftSpark({
    required this.vx,
    required this.vy,
    required this.size,
    required this.lifetime,
    required this.phase,
  });
}

class _CarFireworkStar {
  final int burstIndex;
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double decay;

  const _CarFireworkStar({
    required this.burstIndex,
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.decay,
  });
}

// =============================================================================
// 💎 DIAMOND WINGS PRISMATIC CELESTIAL PAINTER (All 6 Storyboard Stages)
// =============================================================================
class _DiamondWingsPrismPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset wingsCenter;
  final double wingsWidth;
  final double wingsHeight;

  const _DiamondWingsPrismPainter({
    required this.progress,
    required this.sec,
    required this.wingsCenter,
    required this.wingsWidth,
    required this.wingsHeight,
  });

  static final List<_DiamondMote> _motes = List.generate(80, (i) {
    final rand = (i * 137.5) % 1.0;
    final randY = ((i * 223.7) % 1.0);
    final size = 2.0 + ((i % 5) * 1.4);
    final speed = 0.5 + ((i % 7) * 0.2);
    final colors = [
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFF80D8FF), // Light Sky Blue
      const Color(0xFFE1F5FE), // Pure Ice Diamond White
      const Color(0xFFB388FF), // Lavender Prismatic
    ];
    return _DiamondMote(
      xRatio: rand,
      yRatio: randY,
      size: size,
      speed: speed,
      phase: (i * 0.23) % (2 * pi),
      color: colors[i % colors.length],
    );
  });

  static final List<_FeatherShard> _assemblyFeathers = List.generate(50, (i) {
    final angle = (i * (2 * pi / 50)) + ((i % 3) * 0.1);
    final initialRadius = 140.0 + ((i * 17) % 120);
    final size = 3.0 + ((i % 4) * 2.0);
    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFF40C4FF),
      const Color(0xFFFFFFFF),
      const Color(0xFF82B1FF),
    ];
    return _FeatherShard(
      angle: angle,
      initialRadius: initialRadius,
      size: size,
      color: colors[i % colors.length],
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------------------
    // STAGE 1: Prism Awakening (0 - 1.0s)
    // Focused celestial light beam hitting the center prism and caustic glow
    // -------------------------------------------------------------------------
    if (sec < 1.0) {
      final p = (sec / 1.0).clamp(0.0, 1.0);

      // Narrow diagonal beam from top-left (0, 0) to prism center
      final beamPath = Path();
      beamPath.moveTo(0, 0);
      beamPath.lineTo(size.width * 0.22, 0);
      beamPath.lineTo(wingsCenter.dx + 25.0 * p, wingsCenter.dy + 25.0 * p);
      beamPath.lineTo(wingsCenter.dx - 25.0 * p, wingsCenter.dy - 25.0 * p);
      beamPath.close();

      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: (p * 0.65).clamp(0.0, 0.65)),
            const Color(0xFF00E5FF).withValues(alpha: (p * 0.35).clamp(0.0, 0.35)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, wingsCenter.dx + 50, wingsCenter.dy + 50));
      canvas.drawPath(beamPath, beamPaint);

      // Concentrated glowing caustic focal rings at center
      for (int r = 1; r <= 3; r++) {
        final radius = (20.0 * r) + (sin(p * 4 * pi) * 6.0);
        final ringPaint = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: (0.50 / r) * p)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawCircle(wingsCenter, radius, ringPaint);
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 2: Feather Assembly (1.0 - 2.5s)
    // Small faceted crystal feathers floating and snapping inwards
    // -------------------------------------------------------------------------
    if (sec >= 1.0 && sec < 2.5) {
      final p = ((sec - 1.0) / 1.5).clamp(0.0, 1.0);
      for (final feather in _assemblyFeathers) {
        final currentR = feather.initialRadius * (1.0 - p);
        final x = wingsCenter.dx + cos(feather.angle) * currentR;
        final y = wingsCenter.dy + sin(feather.angle) * currentR;
        final alpha = (0.3 + (p * 0.7)).clamp(0.0, 1.0);

        final pPaint = Paint()
          ..color = feather.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
        canvas.drawCircle(Offset(x, y), feather.size * (0.6 + p * 0.4), pPaint);

        if (feather.size > 5.0) {
          _drawStar(canvas, Offset(x, y), feather.size * 1.5, pPaint);
        }
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 3: Wings Unfold (2.5 - 4.0s)
    // Stereo air waves, expanding azure halo
    // -------------------------------------------------------------------------
    if (sec >= 2.5 && sec < 4.0) {
      final p = ((sec - 2.5) / 1.5).clamp(0.0, 1.0);
      for (int i = 0; i < 3; i++) {
        final wavePhase = ((p * 2.5) + (i * 0.33)) % 1.0;
        final waveRadius = (wingsWidth * 0.25) + (wavePhase * wingsWidth * 0.45);
        final waveAlpha = (1.0 - wavePhase).clamp(0.0, 1.0) * 0.55;

        final wavePaint = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: waveAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1.0 - wavePhase);
        canvas.drawOval(
          Rect.fromCenter(
            center: wingsCenter,
            width: waveRadius * 2.0,
            height: waveRadius * 1.2,
          ),
          wavePaint,
        );
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 4: Refraction Sweep (4.0 - 6.0s)
    // Travelling rainbow caustics streak sweeping across the facets
    // -------------------------------------------------------------------------
    if (sec >= 4.0 && sec < 6.0) {
      final p = ((sec - 4.0) / 2.0).clamp(0.0, 1.0);
      final sweepX = (wingsCenter.dx - wingsWidth * 0.5) + (p * wingsWidth);

      final sweepPath = Path();
      sweepPath.moveTo(sweepX - 40, wingsCenter.dy - wingsHeight * 0.45);
      sweepPath.lineTo(sweepX + 40, wingsCenter.dy - wingsHeight * 0.45);
      sweepPath.lineTo(sweepX + 60, wingsCenter.dy + wingsHeight * 0.45);
      sweepPath.lineTo(sweepX - 20, wingsCenter.dy + wingsHeight * 0.45);
      sweepPath.close();

      final sweepPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF00E5FF).withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.75),
            const Color(0xFFB388FF).withValues(alpha: 0.45),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(sweepX - 40, wingsCenter.dy - wingsHeight * 0.5, 100, wingsHeight));
      canvas.drawPath(sweepPath, sweepPaint);
    }

    // -------------------------------------------------------------------------
    // STAGE 5: Full Radiance (6.0 - 8.0s)
    // 12 rotating celestial god-rays beaming down, majestic soft halo
    // -------------------------------------------------------------------------
    if (sec >= 6.0 && sec < 8.0) {
      final p = ((sec - 6.0) / 2.0).clamp(0.0, 1.0);
      for (int g = 0; g < 12; g++) {
        final angle = (g * (2 * pi / 12)) + (p * 0.35);
        final rayLen = size.height * 0.65;
        final rayPath = Path();
        rayPath.moveTo(wingsCenter.dx, wingsCenter.dy);
        rayPath.lineTo(
          wingsCenter.dx + cos(angle - 0.07) * rayLen,
          wingsCenter.dy + sin(angle - 0.07) * rayLen,
        );
        rayPath.lineTo(
          wingsCenter.dx + cos(angle + 0.07) * rayLen,
          wingsCenter.dy + sin(angle + 0.07) * rayLen,
        );
        rayPath.close();

        final rayPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF00E5FF).withValues(alpha: 0.16),
              const Color(0xFF2979FF).withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(Rect.fromCircle(center: wingsCenter, radius: rayLen));
        canvas.drawPath(rayPath, rayPaint);
      }
    }

    // -------------------------------------------------------------------------
    // CONTINUOUS (All Stages): Floating Diamond Motes & Stardust
    // -------------------------------------------------------------------------
    for (final mote in _motes) {
      final my = ((mote.yRatio * size.height) - (progress * mote.speed * 60.0)) % size.height;
      final mx = (mote.xRatio * size.width) + (sin(progress * 3.0 + mote.phase) * 12.0);
      final alpha = (sin(progress * 5.0 + mote.phase).abs() * 0.70).clamp(0.0, 0.70);

      if (alpha > 0.05) {
        final mPaint = Paint()
          ..color = mote.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
        canvas.drawCircle(Offset(mx, my), mote.size, mPaint);

        if (mote.size > 3.0) {
          _drawStar(canvas, Offset(mx, my), mote.size * 1.6, mPaint);
        }
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final s = size * 0.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DiamondWingsPrismPainter old) => true;
}

class _DiamondMote {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _DiamondMote({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _FeatherShard {
  final double angle;
  final double initialRadius;
  final double size;
  final Color color;

  const _FeatherShard({
    required this.angle,
    required this.initialRadius,
    required this.size,
    required this.color,
  });
}

class _ScatteredRoseConfig {
  final double normX;
  final double normY;
  final double size;
  final bool isPink;
  final double bloomDelay;
  final double swaySpeed;
  final double swayAmp;
  final double curveT;
  final int layer;

  const _ScatteredRoseConfig(
    this.normX,
    this.normY,
    this.size,
    this.isPink,
    this.bloomDelay,
    this.swaySpeed,
    this.swayAmp,
    this.curveT,
    this.layer,
  );

  double get phase => (normX * 7.5 + normY * 13.2);
}

class _RosesStoryPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset bouquetCenter;
  final double bouquetWidth;
  final double bouquetHeight;

  const _RosesStoryPainter({
    required this.progress,
    required this.sec,
    required this.bouquetCenter,
    required this.bouquetWidth,
    required this.bouquetHeight,
  });

  // Deterministic seed generation for 3 depth layers of petals
  static final List<_StoryPetal> _petals = List.generate(110, (i) {
    final rand = Random(i * 929 + 67);
    final layer = i < 40 ? 0 : (i < 85 ? 1 : 2); // 0: bg small, 1: mid sharp, 2: fg large blurred
    return _StoryPetal(
      normX: rand.nextDouble(),
      speed: layer == 0 ? 0.5 + rand.nextDouble() * 0.4 : (layer == 1 ? 0.8 + rand.nextDouble() * 0.5 : 1.2 + rand.nextDouble() * 0.6),
      size: layer == 0 ? 7.0 + rand.nextDouble() * 5.0 : (layer == 1 ? 14.0 + rand.nextDouble() * 8.0 : 24.0 + rand.nextDouble() * 14.0),
      swayAmp: 15.0 + rand.nextDouble() * 25.0,
      swaySpeed: 1.5 + rand.nextDouble() * 2.5,
      phase: rand.nextDouble() * 2 * pi,
      layer: layer,
      burstAngle: rand.nextDouble() * 2 * pi,
      burstSpeed: 180.0 + rand.nextDouble() * 260.0,
      heartOffset: rand.nextDouble() * 2 * pi,
      color: i % 4 == 0
          ? const Color(0xFFE11D48) // Crimson Rose
          : (i % 4 == 1
              ? const Color(0xFFFF4081) // Blush Pink
              : (i % 4 == 2 ? const Color(0xFFFB7185) : const Color(0xFFFFF1F2))), // Cream Petal
    );
  });

  // Stage 1 gathering particles
  static final List<_GatherParticle> _gatherParticles = List.generate(60, (i) {
    final rand = Random(i * 431 + 19);
    final angle = rand.nextDouble() * 2 * pi;
    final dist = 180.0 + rand.nextDouble() * 240.0;
    return _GatherParticle(
      angle: angle,
      initialDist: dist,
      speed: 0.8 + rand.nextDouble() * 0.5,
      size: 2.0 + rand.nextDouble() * 3.5,
      isGold: i % 3 == 0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    // -------------------------------------------------------------------------
    // STEP 1: Bouquet Formation (0.0 – 1.5s): Light particles converge into center
    // -------------------------------------------------------------------------
    if (sec < 1.5) {
      final p1 = (sec / 1.5).clamp(0.0, 1.0);
      final alpha = (sin(p1 * pi * 0.95)).clamp(0.0, 1.0);

      for (final gp in _gatherParticles) {
        final currentDist = gp.initialDist * (1.0 - Curves.easeOutCubic.transform(p1));
        final px = bouquetCenter.dx + cos(gp.angle + (p1 * pi * 0.8)) * currentDist;
        final py = bouquetCenter.dy + sin(gp.angle + (p1 * pi * 0.8)) * currentDist;

        final paint = Paint()
          ..color = (gp.isGold ? const Color(0xFFFFD700) : const Color(0xFFFF80AB))
              .withValues(alpha: alpha * 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(Offset(px, py), gp.size, paint);
      }
    }

    // -------------------------------------------------------------------------
    // STEP 3: Petal Shower Begins (3.0 – 5.0s): 360° Radial Petal Burst Explosion
    // -------------------------------------------------------------------------
    if (sec >= 3.0 && sec < 5.0) {
      final p3 = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);
      final burstEase = Curves.easeOutCubic.transform(p3);
      final burstAlpha = ((1.0 - p3) * 0.95).clamp(0.0, 1.0);

      // Shockwave Ring
      final shockwaveR = burstEase * (size.width * 0.65);
      final shockPaint = Paint()
        ..color = const Color(0xFFFF80AB).withValues(alpha: burstAlpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - p3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(bouquetCenter, shockwaveR, shockPaint);

      // Bursting Petals Flying in All Directions
      for (final p in _petals) {
        final dist = p.burstSpeed * burstEase;
        final px = bouquetCenter.dx + cos(p.burstAngle) * dist;
        final py = bouquetCenter.dy + sin(p.burstAngle) * dist;

        final paint = Paint()
          ..color = p.color.withValues(alpha: burstAlpha)
          ..maskFilter = p.layer == 2 ? const MaskFilter.blur(BlurStyle.normal, 3) : null;
        _drawSinglePetal(canvas, Offset(px, py), p.size * 0.9, p.burstAngle + (sec * 4.0), paint);
      }
    }

    // -------------------------------------------------------------------------
    // STEP 4: Swirl & Romance (5.0 – 8.0s): Petals dancing in heart shapes & trails
    // -------------------------------------------------------------------------
    if (sec >= 5.0 && sec < 8.0) {
      final p4 = ((sec - 5.0) / 3.0).clamp(0.0, 1.0);
      final swirlAlpha = (sin(p4 * pi) * 0.95).clamp(0.0, 1.0);

      for (int i = 0; i < _petals.length; i++) {
        final p = _petals[i];
        final t = p.heartOffset + (sec * 2.2);

        // Parametric Heart Curve Formula
        final hX = 16 * pow(sin(t), 3);
        final hY = -(13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t));

        final heartScale = (size.width * 0.022) * (1.0 + (p.layer * 0.15));
        final px = bouquetCenter.dx + hX * heartScale + sin(t * 3.0) * 12.0;
        final py = bouquetCenter.dy + hY * heartScale + cos(t * 2.0) * 10.0;

        final paint = Paint()
          ..color = p.color.withValues(alpha: swirlAlpha)
          ..maskFilter = p.layer == 2 ? const MaskFilter.blur(BlurStyle.normal, 3) : null;
        _drawSinglePetal(canvas, Offset(px, py), p.size, t, paint);
      }
    }

    // -------------------------------------------------------------------------
    // STEP 5 & 6: Gentle Descent (8.0 – 12.0s): Full-Screen Multi-Layer Petal Shower
    // -------------------------------------------------------------------------
    if (sec >= 7.8) {
      final showerAlpha = (sec < 11.2 ? 1.0 : (12.0 - sec) / 0.8).clamp(0.0, 1.0);

      for (final p in _petals) {
        final px = (p.normX * size.width) + sin(sec * p.swaySpeed + p.phase) * p.swayAmp;
        final py = ((sec - 7.8) * p.speed * 110.0 + (p.phase * 40.0)) % (size.height + 60.0) - 30.0;

        final paint = Paint()
          ..color = p.color.withValues(alpha: showerAlpha * (p.layer == 0 ? 0.6 : 0.88))
          ..maskFilter = p.layer == 2 ? const MaskFilter.blur(BlurStyle.normal, 4) : null;
        _drawSinglePetal(canvas, Offset(px, py), p.size, sec * 2.5 + p.phase, paint);
      }
    }
  }

  void _drawSinglePetal(Canvas canvas, Offset center, double size, double rot, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rot);

    final path = Path();
    path.moveTo(0, -size * 0.55);
    path.cubicTo(size * 0.65, -size * 0.40, size * 0.55, size * 0.45, 0, size * 0.60);
    path.cubicTo(-size * 0.55, size * 0.45, -size * 0.65, -size * 0.40, 0, -size * 0.55);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RosesStoryPainter old) => true;
}

class _StoryPetal {
  final double normX;
  final double speed;
  final double size;
  final double swayAmp;
  final double swaySpeed;
  final double phase;
  final int layer;
  final double burstAngle;
  final double burstSpeed;
  final double heartOffset;
  final Color color;

  const _StoryPetal({
    required this.normX,
    required this.speed,
    required this.size,
    required this.swayAmp,
    required this.swaySpeed,
    required this.phase,
    required this.layer,
    required this.burstAngle,
    required this.burstSpeed,
    required this.heartOffset,
    required this.color,
  });
}

class _GatherParticle {
  final double angle;
  final double initialDist;
  final double speed;
  final double size;
  final bool isGold;

  const _GatherParticle({
    required this.angle,
    required this.initialDist,
    required this.speed,
    required this.size,
    required this.isGold,
  });
}

// =============================================================================
// 🌹 FULL-SCREEN ROSES ROMANTIC BACKDROP PAINTER
// =============================================================================
class _FullRosesRomanticBackdropPainter extends CustomPainter {
  final double progress;

  const _FullRosesRomanticBackdropPainter({required this.progress});

  static final List<Offset> _fixedFireflies = List.generate(65, (i) {
    final rand = Random(i * 883 + 53);
    return Offset(rand.nextDouble(), rand.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Romantic Deep Velvet Twilight Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 1.15,
        colors: [
          const Color(0xFF831843).withValues(alpha: 0.55), // Rose Velvet Twilight
          const Color(0xFF4C0519).withValues(alpha: 0.75), // Deep Wine Midnight
          Colors.black.withValues(alpha: 0.88),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Romantic Twilight Lake Fireflies / Light Orbs
    for (int i = 0; i < _fixedFireflies.length; i++) {
      final pos = _fixedFireflies[i];
      final floatY = (pos.dy * size.height - (progress * 45.0 + i * 2.0)) % size.height;
      final floatX = (pos.dx * size.width) + sin(progress * 4.0 + i) * 12.0;
      final alpha = (0.2 + 0.8 * sin(progress * 5 * pi + i)).abs();

      final pColor = (i % 2 == 0 ? const Color(0xFFFF4081) : const Color(0xFFFFD700));
      final pPaint = Paint()
        ..color = pColor.withValues(alpha: alpha * 0.70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(floatX, floatY), (i % 4 == 0 ? 3.0 : 1.8), pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullRosesRomanticBackdropPainter old) => true;
}
// ===========================================================================
// 🚀 GALAXY ROCKET CANVAS PAINTER (Full 6-Stage 10s Environmental Graphics)
// ===========================================================================
class _GalaxyRocketCanvasPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset rocketCenter;
  final double rocketAngle;

  static final List<_RocketCosmosStar> _stars = _generateStars();
  static final List<_RocketBurstParticle> _burstParticles = _generateBurstParticles();
  static final List<_RocketLaunchSpark> _launchSparks = _generateLaunchSparks();

  _GalaxyRocketCanvasPainter({
    required this.progress,
    required this.sec,
    required this.rocketCenter,
    required this.rocketAngle,
  });

  static List<_RocketCosmosStar> _generateStars() {
    final rng = Random(101);
    final colors = [
      Colors.white,
      const Color(0xFF80D8FF),
      const Color(0xFFFFD54F),
      const Color(0xFFFF80DF),
      const Color(0xFFB388FF),
    ];
    return List.generate(90, (i) {
      return _RocketCosmosStar(
        xRatio: rng.nextDouble(),
        yRatio: rng.nextDouble(),
        size: 1.2 + rng.nextDouble() * 2.8,
        speed: 1.5 + rng.nextDouble() * 3.5,
        phase: rng.nextDouble() * 2 * pi,
        color: colors[rng.nextInt(colors.length)],
      );
    });
  }

  static List<_RocketBurstParticle> _generateBurstParticles() {
    final rng = Random(202);
    final colors = [
      const Color(0xFFFF007F),
      const Color(0xFF00E5FF),
      const Color(0xFFFFD700),
      Colors.white,
      const Color(0xFFE040FB),
      const Color(0xFF00B0FF),
    ];
    return List.generate(320, (i) {
      return _RocketBurstParticle(
        angle: rng.nextDouble() * 2 * pi,
        speed: 0.35 + rng.nextDouble() * 0.95,
        size: 2.0 + rng.nextDouble() * 4.5,
        color: colors[rng.nextInt(colors.length)],
        isStar: rng.nextDouble() < 0.35,
        isDiamond: rng.nextDouble() < 0.25,
      );
    });
  }

  static List<_RocketLaunchSpark> _generateLaunchSparks() {
    final rng = Random(303);
    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFF80D8FF),
      Colors.white,
      const Color(0xFFFFD700),
    ];
    return List.generate(24, (i) {
      return _RocketLaunchSpark(
        xOffset: (rng.nextDouble() - 0.5) * 220,
        speed: 1.8 + rng.nextDouble() * 2.2,
        heightRatio: 0.3 + rng.nextDouble() * 0.7,
        color: colors[rng.nextInt(colors.length)],
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. LAUNCHPAD PLATFORM & PARTICLES (Stages 1 & 2: sec 0.0 - 3.2s)
    if (sec < 3.2) {
      final double padAlpha = (sec < 2.5 ? 1.0 : (3.2 - sec) / 0.7).clamp(0.0, 1.0);
      final padCenter = Offset(size.width * 0.5, size.height * 0.70);
      _paintLaunchpad(canvas, padCenter, size, padAlpha);
    }

    // 2. ATMOSPHERIC NIGHT CLOUDS (Stage 3: sec 2.8 - 5.5s)
    if (sec >= 2.8 && sec <= 5.5) {
      final double cloudAlpha = (sec < 3.5
              ? (sec - 2.8) / 0.7
              : (sec > 4.8 ? (5.5 - sec) / 0.7 : 1.0))
          .clamp(0.0, 1.0);
      _paintAtmosphericClouds(canvas, size, cloudAlpha);
    }

    // 3. DEEP COSMOS, STARS & CELESTIAL PLANET (Stages 4, 5, 6: sec 4.5 - 10.0s)
    if (sec >= 4.5) {
      final double spaceAlpha = (sec < 5.5 ? (sec - 4.5) / 1.0 : 1.0).clamp(0.0, 1.0);
      _paintCosmicSpace(canvas, size, spaceAlpha);
    }

    // 4. COSMIC SUPERNOVA BURST (Stage 5: sec 7.0 - 9.2s)
    if (sec >= 7.0 && sec <= 9.2) {
      final double p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);
      _paintCosmicBurst(canvas, size, rocketCenter, p);
    }

    // 5. WARP STAR TRAIL (Stage 6: sec 8.8 - 10.0s)
    if (sec >= 8.8) {
      final double p = ((sec - 8.8) / 1.2).clamp(0.0, 1.0);
      _paintWarpStarTrail(canvas, size, rocketCenter, rocketAngle, p);
    }
  }

  void _paintLaunchpad(Canvas canvas, Offset center, Size size, double alpha) {
    if (alpha <= 0.01) return;

    // Platform Dais Glowing Shadow / Aura
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.35 * alpha),
          const Color(0xFF7C4DFF).withValues(alpha: 0.15 * alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: 280, height: 90));
    canvas.drawOval(Rect.fromCenter(center: center, width: 280, height: 90), auraPaint);

    // Outer Neon Ring (Cyan)
    final outerRingPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawOval(Rect.fromCenter(center: center, width: 230, height: 62), outerRingPaint);

    // Rotating Tech Ticks along Outer Ring
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    const tickCount = 14;
    final tickAngleOffset = sec * 1.4;
    for (int i = 0; i < tickCount; i++) {
      final a = (i * (2 * pi / tickCount)) + tickAngleOffset;
      final rx1 = 115.0;
      final ry1 = 31.0;
      final rx2 = 122.0;
      final ry2 = 33.0;
      final p1 = center + Offset(cos(a) * rx1, sin(a) * ry1);
      final p2 = center + Offset(cos(a) * rx2, sin(a) * ry2);
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Middle Platform Ring (Purple)
    final midRingPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.80 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawOval(Rect.fromCenter(center: center, width: 175, height: 48), midRingPaint);

    // Inner Platform Core (Dark High-Tech Metal with Core Glow)
    final daisFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF132042).withValues(alpha: 0.95 * alpha),
          const Color(0xFF090E20).withValues(alpha: 0.95 * alpha),
        ],
      ).createShader(Rect.fromCenter(center: center, width: 125, height: 34));
    canvas.drawOval(Rect.fromCenter(center: center, width: 125, height: 34), daisFillPaint);

    // Core Cyan Thruster Ignition Target
    final coreGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (sec >= 1.0 ? Colors.white : const Color(0xFF00E5FF)).withValues(alpha: 0.90 * alpha),
          const Color(0xFF00E5FF).withValues(alpha: 0.50 * alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 1.0],
      ).createShader(Rect.fromCenter(center: center, width: 70, height: 20));
    canvas.drawOval(Rect.fromCenter(center: center, width: 70, height: 20), coreGlowPaint);

    // Guide Gantries / Launch Towers on left & right
    final gantryPaint = Paint()
      ..color = const Color(0xFF5C6BC0).withValues(alpha: 0.75 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    // Left gantry
    final gLeftX = center.dx - 110.0;
    canvas.drawLine(Offset(gLeftX, center.dy), Offset(gLeftX, center.dy - 35), gantryPaint);
    canvas.drawCircle(
      Offset(gLeftX, center.dy - 35),
      3.0,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.9 * alpha),
    );
    // Right gantry
    final gRightX = center.dx + 110.0;
    canvas.drawLine(Offset(gRightX, center.dy), Offset(gRightX, center.dy - 35), gantryPaint);
    canvas.drawCircle(
      Offset(gRightX, center.dy - 35),
      3.0,
      Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.9 * alpha),
    );

    // Rising Electric Energy Sparks
    for (final sp in _launchSparks) {
      final sparkCycle = ((sec * sp.speed) + sp.xOffset.abs() * 0.05) % 1.0;
      final sy = center.dy - (sparkCycle * 55.0 * sp.heightRatio);
      final sx = center.dx + sp.xOffset + sin(sparkCycle * 4 * pi) * 3.0;
      final sAlpha = ((1.0 - sparkCycle) * alpha * 0.85).clamp(0.0, 1.0);
      if (sAlpha > 0.05) {
        canvas.drawCircle(
          Offset(sx, sy),
          1.4,
          Paint()..color = sp.color.withValues(alpha: sAlpha),
        );
      }
    }

    // Billowing Launch Smoke Clouds (Stage 2: Lift Off sec >= 1.5)
    if (sec >= 1.5) {
      final smokeP = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);
      final smokePaint = Paint()
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 16; i++) {
        final dir = (i % 2 == 0) ? 1.0 : -1.0;
        final spread = ((i / 16.0) + smokeP * 0.8);
        final cx = center.dx + (dir * (40.0 + spread * 80.0));
        final cy = center.dy + 8.0 - (sin(spread * pi) * 12.0);
        final r = 16.0 + spread * 24.0;
        final sOpacity = ((1.0 - (smokeP * 0.85)) * 0.45 * alpha).clamp(0.0, 1.0);
        smokePaint.color = (i % 3 == 0
                ? const Color(0xFF90CAF9)
                : const Color(0xFFCFD8DC))
            .withValues(alpha: sOpacity);
        canvas.drawCircle(Offset(cx, cy), r, smokePaint);
      }
    }
  }

  void _paintAtmosphericClouds(Canvas canvas, Size size, double alpha) {
    if (alpha <= 0.01) return;
    final cloudPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    for (int i = 0; i < 7; i++) {
      final double yPos = size.height * (0.35 + (i * 0.08)) + sin((sec * 1.5) + i) * 15;
      final double xPos = size.width * (0.15 + (i * 0.12));
      final double r = 55.0 + (i * 8.0);
      cloudPaint.color = (i % 2 == 0
              ? const Color(0xFF1E1045)
              : const Color(0xFF121B4A))
          .withValues(alpha: 0.28 * alpha);
      canvas.drawCircle(Offset(xPos, yPos), r, cloudPaint);
    }
  }

  void _paintCosmicSpace(Canvas canvas, Size size, double alpha) {
    if (alpha <= 0.01) return;

    // Deep Nebula Glows
    final cyanNebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.18 * alpha),
          const Color(0xFF1A237E).withValues(alpha: 0.08 * alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.72, size.height * 0.35),
        radius: size.width * 0.55,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.35),
      size.width * 0.55,
      cyanNebula,
    );

    final violetNebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9C27B0).withValues(alpha: 0.16 * alpha),
          const Color(0xFF311B92).withValues(alpha: 0.06 * alpha),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.25, size.height * 0.55),
        radius: size.width * 0.50,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.55),
      size.width * 0.50,
      violetNebula,
    );

    // Celestial Planet with Rings (Upper-Left Background)
    final planetCenter = Offset(size.width * 0.20, size.height * 0.22);
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFF00B0FF).withValues(alpha: 0.85 * alpha),
          const Color(0xFF0D1B4E).withValues(alpha: 0.95 * alpha),
        ],
      ).createShader(Rect.fromCircle(center: planetCenter, radius: 26));
    canvas.drawCircle(planetCenter, 26, planetPaint);

    // Planet Atmospheric Rim
    canvas.drawCircle(
      planetCenter,
      26,
      Paint()
        ..color = const Color(0xFF80D8FF).withValues(alpha: 0.55 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Planetary Ring (Tilted Ellipse)
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.55 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.save();
    canvas.translate(planetCenter.dx, planetCenter.dy);
    canvas.rotate(-0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 85, height: 20), ringPaint);
    canvas.restore();

    // 90 Twinkling Galaxy Stars
    for (final s in _stars) {
      final sx = s.xRatio * size.width;
      final sy = s.yRatio * size.height;
      final twinkle = sin((sec * s.speed) + s.phase).abs();
      final starAlpha = (twinkle * alpha * 0.95).clamp(0.0, 1.0);
      if (starAlpha > 0.05) {
        if (s.size > 2.8) {
          _drawFourPointStar(canvas, Offset(sx, sy), s.size, s.color.withValues(alpha: starAlpha));
        } else {
          canvas.drawCircle(
            Offset(sx, sy),
            s.size * 0.5,
            Paint()..color = s.color.withValues(alpha: starAlpha),
          );
        }
      }
    }
  }

  void _paintCosmicBurst(Canvas canvas, Size size, Offset center, double p) {
    final burstAlpha = ((1.0 - p) * 0.95).clamp(0.0, 1.0);
    if (burstAlpha <= 0.01) return;

    // 1. Expanding Concentric Supernova Shockwaves
    // Ring 1 (Magenta Nova)
    final r1 = p * size.width * 1.15;
    final w1 = (8.0 * (1.0 - p)).clamp(1.0, 8.0);
    final ring1Paint = Paint()
      ..color = const Color(0xFFFF007F).withValues(alpha: burstAlpha * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w1;
    canvas.drawCircle(center, r1, ring1Paint);

    // Ring 2 (Electric Cyan Shockwave)
    final r2 = (p * size.width * 0.90) + 12.0;
    final w2 = (6.0 * (1.0 - p)).clamp(1.0, 6.0);
    final ring2Paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: burstAlpha * 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w2;
    canvas.drawCircle(center, r2, ring2Paint);

    // Ring 3 (Golden Celestial Core)
    final r3 = (p * size.width * 0.65) + 22.0;
    final w3 = (5.0 * (1.0 - p)).clamp(1.0, 5.0);
    final ring3Paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: burstAlpha * 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w3;
    canvas.drawCircle(center, r3, ring3Paint);

    // 2. 24 Volumetric Rotating Light Beams
    const rayCount = 24;
    final rayRot = p * 0.55;
    final rayLen = size.width * 0.95 * (1.0 - (p * 0.25));
    final rayPaint = Paint()
      ..style = PaintingStyle.fill;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * (2 * pi / rayCount)) + rayRot;
      final rayColor = (i % 3 == 0)
          ? const Color(0xFFFF007F)
          : (i % 3 == 1 ? const Color(0xFF00E5FF) : const Color(0xFFFFD700));
      final rAlpha = (burstAlpha * (i % 2 == 0 ? 0.30 : 0.18)).clamp(0.0, 1.0);
      rayPaint.color = rayColor.withValues(alpha: rAlpha);

      final pLeft = center + Offset(cos(angle - 0.05) * rayLen, sin(angle - 0.05) * rayLen);
      final pRight = center + Offset(cos(angle + 0.05) * rayLen, sin(angle + 0.05) * rayLen);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(pLeft.dx, pLeft.dy)
        ..lineTo(pRight.dx, pRight.dy)
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    // 3. Central Nova Core Starburst Glow
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: burstAlpha),
          const Color(0xFF00E5FF).withValues(alpha: burstAlpha * 0.75),
          const Color(0xFFFF007F).withValues(alpha: burstAlpha * 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.30, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 90 * (1.0 - (p * 0.3))));
    canvas.drawCircle(center, 90 * (1.0 - (p * 0.3)), corePaint);

    // 4. 300+ Radiant Cosmic Stardust Particles Bursting Outward
    final easeDist = Curves.easeOutCubic.transform(p);
    for (final bp in _burstParticles) {
      final dist = easeDist * bp.speed * 440.0;
      final px = center.dx + cos(bp.angle) * dist;
      final py = center.dy + sin(bp.angle) * dist;
      final pAlpha = (burstAlpha * (1.0 - p * 0.35)).clamp(0.0, 1.0);

      if (bp.isStar) {
        _drawFourPointStar(canvas, Offset(px, py), bp.size * (1.0 - p * 0.2), bp.color.withValues(alpha: pAlpha));
      } else if (bp.isDiamond) {
        _drawDiamond(canvas, Offset(px, py), bp.size * (1.0 - p * 0.2), bp.color.withValues(alpha: pAlpha));
      } else {
        canvas.drawCircle(
          Offset(px, py),
          bp.size * 0.45 * (1.0 - p * 0.2),
          Paint()..color = bp.color.withValues(alpha: pAlpha),
        );
      }
    }
  }

  void _paintWarpStarTrail(Canvas canvas, Size size, Offset center, double angle, double p) {
    final trailAlpha = ((1.0 - p) * 0.9).clamp(0.0, 1.0);
    if (trailAlpha <= 0.01) return;

    // Draw trailing stars behind the rocket nozzle (opposite direction to angle)
    final backAngle = angle + pi;
    for (int i = 0; i < 35; i++) {
      final tDist = (i * 12.0) + (p * 60.0);
      final px = center.dx + cos(backAngle) * tDist + sin(i * 3.5) * 8.0;
      final py = center.dy + sin(backAngle) * tDist + cos(i * 2.8) * 8.0;
      final s = (4.0 - (i * 0.08)).clamp(1.5, 4.0);
      final cAlpha = (trailAlpha * (1.0 - (i / 35.0))).clamp(0.0, 1.0);
      final color = (i % 2 == 0) ? const Color(0xFF00E5FF) : const Color(0xFFFFD700);

      if (i % 3 == 0) {
        _drawFourPointStar(canvas, Offset(px, py), s, color.withValues(alpha: cAlpha));
      } else {
        canvas.drawCircle(Offset(px, py), s * 0.45, Paint()..color = color.withValues(alpha: cAlpha));
      }
    }
  }

  void _drawFourPointStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size * 0.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - s)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size * 0.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - s * 0.8)
      ..lineTo(center.dx + s * 0.5, center.dy)
      ..lineTo(center.dx, center.dy + s * 0.8)
      ..lineTo(center.dx - s * 0.5, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GalaxyRocketCanvasPainter old) => true;
}

class _RocketCosmosStar {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _RocketCosmosStar({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _RocketBurstParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final bool isStar;
  final bool isDiamond;

  const _RocketBurstParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.isStar,
    required this.isDiamond,
  });
}

class _RocketLaunchSpark {
  final double xOffset;
  final double speed;
  final double heightRatio;
  final Color color;

  const _RocketLaunchSpark({
    required this.xOffset,
    required this.speed,
    required this.heightRatio,
    required this.color,
  });
}

class _GoldenLionCanvasPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset lionCenter;

  _GoldenLionCanvasPainter({
    required this.progress,
    required this.sec,
    required this.lionCenter,
  });

  static final List<_LionEmber> _embers = List.generate(120, (i) {
    final rand = (i * 137.5) % 1.0;
    final randY = ((i * 223.7) % 1.0);
    final size = 2.0 + ((i % 5) * 1.5);
    final speed = 0.6 + ((i % 7) * 0.25);
    final colors = [
      const Color(0xFFFFD700), // Royal Gold
      const Color(0xFFFFAB00), // Amber Gold
      const Color(0xFFFF6D00), // Fiery Orange
      const Color(0xFFFFF8E1), // Shimmering White Gold
    ];
    return _LionEmber(
      xRatio: rand,
      yRatio: randY,
      size: size,
      speed: speed,
      phase: (i * 0.17) % (2 * pi),
      color: colors[i % colors.length],
    );
  });

  static final List<_LionRoarSpark> _roarSparks = List.generate(260, (i) {
    final angle = (i * (2 * pi / 260)) + ((i % 3) * 0.08);
    final speed = 80.0 + ((i * 17) % 240);
    final size = 2.0 + ((i % 6) * 1.6);
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFF9100),
      const Color(0xFFFF3D00),
      const Color(0xFFFFF9C4),
      const Color(0xFFFFE082),
    ];
    return _LionRoarSpark(
      angle: angle,
      speed: speed,
      size: size,
      color: colors[i % colors.length],
      isStar: i % 4 == 0,
      isDiamond: i % 5 == 0,
    );
  });

  static final List<_LionMagmaSpark> _magmaSparks = List.generate(60, (i) {
    final xOffset = -140.0 + (i * 4.8);
    final speed = 25.0 + ((i * 7) % 35);
    final heightRatio = 0.5 + ((i % 4) * 0.2);
    final colors = [
      const Color(0xFFFF3D00),
      const Color(0xFFFF6D00),
      const Color(0xFFFFAB00),
      const Color(0xFFFFD700),
    ];
    return _LionMagmaSpark(
      xOffset: xOffset,
      speed: speed,
      heightRatio: heightRatio,
      color: colors[i % colors.length],
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    // -------------------------------------------------------------------------
    // STAGE 1: Golden Particles Emerge (0 - 1.5s)
    // Magical particles gather from across the screen into the lion center.
    // -------------------------------------------------------------------------
    if (sec < 1.5) {
      final p = (sec / 1.5).clamp(0.0, 1.0);
      final gatherRadius = (1.0 - p) * (size.width * 0.65) + 30.0;

      for (int i = 0; i < 90; i++) {
        final angle = (i * (2 * pi / 90)) + (p * 4.0 * pi);
        final r = gatherRadius * (0.3 + 0.7 * ((i % 10) / 10.0));
        final x = lionCenter.dx + cos(angle) * r;
        final y = lionCenter.dy + sin(angle) * r;

        final particlePaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: (p * 0.85).clamp(0.0, 0.85))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        canvas.drawCircle(Offset(x, y), 2.5 + ((i % 4) * 1.2), particlePaint);

        if (i % 3 == 0) {
          _drawFourPointStar(
            canvas,
            Offset(x, y),
            (6.0 + (i % 5)) * p,
            const Color(0xFFFFF9C4).withValues(alpha: (p * 0.9).clamp(0.0, 0.9)),
          );
        }
      }

      // Emerging central golden vortex core
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: (p * 0.7).clamp(0.0, 0.7)),
            const Color(0xFFFF6D00).withValues(alpha: (p * 0.4).clamp(0.0, 0.4)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: lionCenter, radius: 90.0 * p));
      canvas.drawCircle(lionCenter, 90.0 * p, corePaint);
    }

    // -------------------------------------------------------------------------
    // STAGE 2: Lion Takes Shape (1.5 - 3.0s)
    // The lion gradually forms with golden light, rising embers & glowing runes.
    // -------------------------------------------------------------------------
    if (sec >= 1.5 && sec < 3.0) {
      final p = ((sec - 1.5) / 1.5).clamp(0.0, 1.0);

      // Pulsing golden aura rings
      for (int r = 1; r <= 3; r++) {
        final waveRadius = (60.0 * r) + (sin(p * 2 * pi + r) * 12.0);
        final ringPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: (0.35 / r) * (1.0 - (p * 0.2)))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(lionCenter, waveRadius, ringPaint);
      }

      // Rising magma spark embers under lion paws
      final groundY = lionCenter.dy + 85.0;
      for (final spark in _magmaSparks) {
        final currentY = groundY - (p * spark.speed * spark.heightRatio * 2.5);
        final currentX = lionCenter.dx + spark.xOffset;
        final alpha = (1.0 - ((groundY - currentY) / 120.0)).clamp(0.0, 1.0) * 0.75;
        final paint = Paint()..color = spark.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(currentX, currentY), 2.2, paint);
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 3: Powerful Movement (3.0 - 5.0s)
    // The lion runs with majestic energy, stride shockwaves, paw dust, speed streaks.
    // -------------------------------------------------------------------------
    if (sec >= 3.0 && sec < 5.0) {
      final p = ((sec - 3.0) / 2.0).clamp(0.0, 1.0);

      // Paw impact ground shockwave ripples
      final groundY = lionCenter.dy + 75.0;
      for (int i = 0; i < 3; i++) {
        final ripplePhase = ((p * 4.0) + (i * 0.33)) % 1.0;
        final rippleRadius = ripplePhase * 110.0;
        final rippleAlpha = (1.0 - ripplePhase).clamp(0.0, 1.0) * 0.65;
        final shockPaint = Paint()
          ..color = const Color(0xFFFFAB00).withValues(alpha: rippleAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1.0 - ripplePhase);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(lionCenter.dx - 10.0, groundY),
            width: rippleRadius * 2.2,
            height: rippleRadius * 0.55,
          ),
          shockPaint,
        );
      }

      // Golden speed motion streaks trailing backwards
      final streakPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int s = 0; s < 18; s++) {
        final yOff = -50.0 + (s * 6.5);
        final streakLength = 40.0 + ((s % 5) * 16.0);
        final startX = lionCenter.dx - 40.0 - ((s % 3) * 12.0);
        streakPaint
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.45)
          ..strokeWidth = 1.6;
        canvas.drawLine(
          Offset(startX, lionCenter.dy + yOff),
          Offset(startX - streakLength, lionCenter.dy + yOff),
          streakPaint,
        );
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 4: Roar Effect (5.0 - 7.0s)
    // The lion roars with intense golden sparks, sonic shockwave rings, and thunder glow.
    // -------------------------------------------------------------------------
    if (sec >= 5.0 && sec < 7.0) {
      final p = ((sec - 5.0) / 2.0).clamp(0.0, 1.0);

      // Powerful sonic roar blast rings expanding outward from the lion's mouth
      for (int r = 0; r < 4; r++) {
        final ringPhase = ((p * 2.2) + (r * 0.25)) % 1.0;
        final ringRadius = ringPhase * (size.width * 0.72);
        final ringAlpha = (1.0 - ringPhase).clamp(0.0, 1.0) * 0.85;

        final roarWavePaint = Paint()
          ..color = (r % 2 == 0 ? const Color(0xFFFFD700) : const Color(0xFFFF3D00))
              .withValues(alpha: ringAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0 * (1.0 - ringPhase)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

        canvas.drawCircle(lionCenter, ringRadius, roarWavePaint);
      }

      // Volumetric golden roar rays piercing through the screen
      for (int b = 0; b < 20; b++) {
        final angle = (b * (2 * pi / 20)) + (p * 0.8);
        final rayLen = 90.0 + ((b % 4) * 55.0);
        final rayPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: (0.35 * (1.0 - p)).clamp(0.0, 0.35))
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          lionCenter,
          Offset(lionCenter.dx + cos(angle) * rayLen, lionCenter.dy + sin(angle) * rayLen),
          rayPaint,
        );
      }

      // Explosive roar sparks, stars, and diamonds radiating outward
      for (int i = 0; i < _roarSparks.length; i++) {
        final spark = _roarSparks[i];
        final dist = spark.speed * p * 1.7;
        final x = lionCenter.dx + cos(spark.angle) * dist;
        final y = lionCenter.dy + sin(spark.angle) * dist;
        final sparkAlpha = (1.0 - (p * 0.95)).clamp(0.0, 1.0);

        if (spark.isStar) {
          _drawFourPointStar(
            canvas,
            Offset(x, y),
            spark.size * 2.2,
            spark.color.withValues(alpha: sparkAlpha),
          );
        } else if (spark.isDiamond) {
          _drawDiamond(
            canvas,
            Offset(x, y),
            spark.size * 2.0,
            spark.color.withValues(alpha: sparkAlpha),
          );
        } else {
          final sparkPaint = Paint()
            ..color = spark.color.withValues(alpha: sparkAlpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
          canvas.drawCircle(Offset(x, y), spark.size, sparkPaint);
        }
      }
    }

    // -------------------------------------------------------------------------
    // STAGE 5: Cinematic Showcase (7.0 - 9.0s)
    // The lion moves with power, royal grace, celestial sunbeams, god-rays.
    // -------------------------------------------------------------------------
    if (sec >= 7.0 && sec < 9.0) {
      final p = ((sec - 7.0) / 2.0).clamp(0.0, 1.0);

      // Rotating celestial royal god-rays
      for (int g = 0; g < 12; g++) {
        final angle = (g * (2 * pi / 12)) + (p * 0.4);
        final rayPath = Path();
        final rayLen = size.height * 0.7;

        rayPath.moveTo(lionCenter.dx, lionCenter.dy);
        rayPath.lineTo(
          lionCenter.dx + cos(angle - 0.08) * rayLen,
          lionCenter.dy + sin(angle - 0.08) * rayLen,
        );
        rayPath.lineTo(
          lionCenter.dx + cos(angle + 0.08) * rayLen,
          lionCenter.dy + sin(angle + 0.08) * rayLen,
        );
        rayPath.close();

        final godRayPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFD700).withValues(alpha: 0.18),
              const Color(0xFFFFAB00).withValues(alpha: 0.06),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6, 1.0],
          ).createShader(Rect.fromCircle(center: lionCenter, radius: rayLen));
        canvas.drawPath(rayPath, godRayPaint);
      }
    }

    // -------------------------------------------------------------------------
    // STAGES 1 - 6 CONTINUOUS: Ambient Golden Floating Embers & Stardust
    // -------------------------------------------------------------------------
    for (final ember in _embers) {
      final emberY = ((ember.yRatio * size.height) - (progress * ember.speed * 80.0)) % size.height;
      final emberX = (ember.xRatio * size.width) + (sin(progress * 4.0 + ember.phase) * 15.0);
      final alpha = (sin(progress * 6.0 + ember.phase).abs() * 0.75).clamp(0.0, 0.75);

      if (alpha > 0.05) {
        final emberPaint = Paint()
          ..color = ember.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
        canvas.drawCircle(Offset(emberX, emberY), ember.size, emberPaint);

        if (ember.size > 3.0) {
          _drawFourPointStar(
            canvas,
            Offset(emberX, emberY),
            ember.size * 1.8,
            const Color(0xFFFFF9C4).withValues(alpha: alpha * 0.8),
          );
        }
      }
    }
  }

  void _drawFourPointStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size * 0.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + s)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - s, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - s, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final s = size * 0.5;
    final path = Path()
      ..moveTo(center.dx, center.dy - s * 0.8)
      ..lineTo(center.dx + s * 0.5, center.dy)
      ..lineTo(center.dx, center.dy + s * 0.8)
      ..lineTo(center.dx - s * 0.5, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenLionCanvasPainter old) => true;
}

class _LionEmber {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _LionEmber({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _LionRoarSpark {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final bool isStar;
  final bool isDiamond;

  const _LionRoarSpark({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.isStar,
    required this.isDiamond,
  });
}

class _LionMagmaSpark {
  final double xOffset;
  final double speed;
  final double heightRatio;
  final Color color;

  const _LionMagmaSpark({
    required this.xOffset,
    required this.speed,
    required this.heightRatio,
    required this.color,
  });
}

/// Dynamic Ocean Painter for Luxury Yacht:
/// Renders undulating waves, bow-wave foam spray, expanding wake trails,
/// upper sky fireworks bursts, and 3D concentric golden light rings.
class _LuxuryYachtOceanPainter extends CustomPainter {
  final double sec;
  final Offset yachtCenter;
  final double yachtWidth;
  final double fireworksAlpha;
  final double ringAlpha;

  const _LuxuryYachtOceanPainter({
    required this.sec,
    required this.yachtCenter,
    required this.yachtWidth,
    required this.fireworksAlpha,
    required this.ringAlpha,
  });

  static final List<_OceanSprayParticle> _sprayParticles = List.generate(45, (i) {
    final rand = Random(i * 389 + 17);
    return _OceanSprayParticle(
      xSpread: (rand.nextDouble() - 0.5) * 1.6,
      speed: 0.6 + rand.nextDouble() * 0.8,
      size: 2.5 + rand.nextDouble() * 4.5,
      phase: rand.nextDouble() * 2 * pi,
      isFoam: i % 2 == 0,
    );
  });

  static final List<_FireworkBurst> _fireworks = [
    _FireworkBurst(centerRatio: const Offset(0.25, 0.22), baseColor: const Color(0xFFFFD700), particleCount: 36),
    _FireworkBurst(centerRatio: const Offset(0.72, 0.18), baseColor: const Color(0xFFFF4081), particleCount: 32),
    _FireworkBurst(centerRatio: const Offset(0.50, 0.12), baseColor: const Color(0xFF00E5FF), particleCount: 40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final waterlineY = yachtCenter.dy + 8.0;

    // 1. Water Surface & Ambient Depth Glow
    final waterRect = Rect.fromLTWH(0, waterlineY - 20, size.width, size.height - waterlineY + 20);
    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0x6600E5FF),
          const Color(0x990A192F),
          const Color(0xEE020C1B),
        ],
      ).createShader(waterRect);
    canvas.drawRect(waterRect, waterPaint);

    // 2. Animated Undulating Waves & Water Ripples
    for (int w = 0; w < 3; w++) {
      final wavePath = Path();
      final waveY = waterlineY + (w * 16.0);
      wavePath.moveTo(0, waveY);
      for (double x = 0; x <= size.width; x += 15) {
        final waveOffset = sin((x / 60.0) + (sec * 3.5) + (w * 1.8)) * (5.0 - w);
        wavePath.lineTo(x, waveY + waveOffset);
      }
      wavePath.lineTo(size.width, size.height);
      wavePath.lineTo(0, size.height);
      wavePath.close();

      final waveStroke = Paint()
        ..color = (w == 0
                ? const Color(0x8800E5FF)
                : (w == 1 ? const Color(0x5580D8FF) : const Color(0x33FFD54F)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - (w * 0.4);
      canvas.drawPath(wavePath, waveStroke);
    }

    // 3. Bow Wave Spray Foam & Bubbling Wake
    final bowX = yachtCenter.dx + yachtWidth * 0.38;
    for (int i = 0; i < _sprayParticles.length; i++) {
      final p = _sprayParticles[i];
      final sprayProgress = ((sec * p.speed) + (p.phase / (2 * pi))) % 1.0;
      final px = bowX + (p.xSpread * yachtWidth * 0.45 * sprayProgress);
      final py = waterlineY - (sin(sprayProgress * pi) * 22.0) + (sprayProgress * 8.0);
      final pAlpha = (1.0 - sprayProgress) * 0.85;

      final sprayPaint = Paint()
        ..color = (p.isFoam ? Colors.white : const Color(0xFF80D8FF)).withValues(alpha: pAlpha);
      canvas.drawCircle(Offset(px, py), p.size * (1.0 - sprayProgress * 0.4), sprayPaint);
    }

    // 4. Upper Sky Fireworks Bursts (Stage 4 & 5)
    if (fireworksAlpha > 0.01) {
      for (final burst in _fireworks) {
        final bCenter = Offset(size.width * burst.centerRatio.dx, size.height * burst.centerRatio.dy);
        for (int i = 0; i < burst.particleCount; i++) {
          final angle = (i * 2 * pi) / burst.particleCount;
          final radius = 55.0 * sin(fireworksAlpha * pi);
          final fx = bCenter.dx + cos(angle) * radius;
          final fy = bCenter.dy + sin(angle) * radius + (fireworksAlpha * 12.0);

          final fPaint = Paint()
            ..color = (i % 2 == 0 ? burst.baseColor : const Color(0xFFFFD54F))
                .withValues(alpha: (1.0 - fireworksAlpha * 0.3) * fireworksAlpha);
          canvas.drawCircle(Offset(fx, fy), 2.8, fPaint);

          // Star trail spark line
          final tPaint = Paint()
            ..color = burst.baseColor.withValues(alpha: fireworksAlpha * 0.4)
            ..strokeWidth = 1.0;
          canvas.drawLine(
            Offset(fx, fy),
            Offset(fx - cos(angle) * 8.0, fy - sin(angle) * 8.0),
            tPaint,
          );
        }
      }
    }

    // 5. 3D Concentric Golden Light Rings (Stage 5 Circular Glow)
    if (ringAlpha > 0.01) {
      canvas.save();
      canvas.translate(yachtCenter.dx, yachtCenter.dy + 12.0);

      for (int r = 0; r < 3; r++) {
        final ringRadiusX = (yachtWidth * 0.48) + (r * 32.0) + (sin(sec * 3.0 + r) * 8.0);
        final ringRadiusY = ringRadiusX * 0.32; // Perspective oval tilt
        final ringRect = Rect.fromCenter(center: Offset.zero, width: ringRadiusX * 2, height: ringRadiusY * 2);

        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 - (r * 0.4)
          ..shader = SweepGradient(
            transform: GradientRotation(sec * (1.5 + r * 0.5)),
            colors: [
              const Color(0xFFFFD700).withValues(alpha: ringAlpha * 0.9),
              const Color(0xFFFFF9C4).withValues(alpha: ringAlpha),
              const Color(0xFFFF8F00).withValues(alpha: ringAlpha * 0.6),
              const Color(0xFFFFD700).withValues(alpha: ringAlpha * 0.9),
            ],
          ).createShader(ringRect);

        canvas.drawOval(ringRect, ringPaint);

        // Orbiting glowing star nodes on ring
        final orbitAngle = (sec * 2.2) + (r * 1.2);
        final nodeX = cos(orbitAngle) * ringRadiusX;
        final nodeY = sin(orbitAngle) * ringRadiusY;
        final nodePaint = Paint()
          ..color = Colors.white.withValues(alpha: ringAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
        canvas.drawCircle(Offset(nodeX, nodeY), 4.5, nodePaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _LuxuryYachtOceanPainter oldDelegate) {
    return oldDelegate.sec != sec ||
        oldDelegate.fireworksAlpha != fireworksAlpha ||
        oldDelegate.ringAlpha != ringAlpha;
  }
}

class _OceanSprayParticle {
  final double xSpread;
  final double speed;
  final double size;
  final double phase;
  final bool isFoam;

  const _OceanSprayParticle({
    required this.xSpread,
    required this.speed,
    required this.size,
    required this.phase,
    required this.isFoam,
  });
}

class _FireworkBurst {
  final Offset centerRatio;
  final Color baseColor;
  final int particleCount;

  const _FireworkBurst({
    required this.centerRatio,
    required this.baseColor,
    required this.particleCount,
  });
}


// ===========================================================================
// 🐬 OCEAN DOLPHIN CINEMATIC STORY PAINTER
// Multi-layer Luminous Vortex, Stardust Constellations, and Bioluminescent Bubbles
// ===========================================================================
class _OceanDolphinStoryPainter extends CustomPainter {
  final double progress;
  final double sec;
  final Offset whaleCenter;
  final double whaleWidth;
  final double whaleHeight;
  final bool toLeft;

  const _OceanDolphinStoryPainter({
    required this.progress,
    required this.sec,
    required this.whaleCenter,
    required this.whaleWidth,
    required this.whaleHeight,
    required this.toLeft,
  });

  static final List<_DolphinStarSpec> _stars = List.generate(80, (i) {
    final rand = Random(i * 733 + 41);
    return _DolphinStarSpec(
      normX: rand.nextDouble(),
      normY: rand.nextDouble() * 0.75,
      size: 1.5 + rand.nextDouble() * 3.5,
      twinkleSpeed: 2.0 + rand.nextDouble() * 3.0,
      phase: rand.nextDouble() * 2 * pi,
      isGold: i % 4 == 0,
    );
  });

  static final List<_VortexParticle> _vortexParticles = List.generate(65, (i) {
    final rand = Random(i * 317 + 89);
    return _VortexParticle(
      initialAngle: rand.nextDouble() * 2 * pi,
      radiusRatio: 0.20 + rand.nextDouble() * 0.80,
      speed: 1.5 + rand.nextDouble() * 2.5,
      size: 2.0 + rand.nextDouble() * 4.0,
      phase: rand.nextDouble() * 2 * pi,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    // -------------------------------------------------------------------------
    // 1. Ambient Starlight & Constellation Specks across Night Sky
    // -------------------------------------------------------------------------
    for (final s in _stars) {
      final twinkle = 0.4 + (sin(sec * s.twinkleSpeed + s.phase) * 0.6).abs();
      final p = Offset(s.normX * size.width, s.normY * size.height);
      final paint = Paint()
        ..color = (s.isGold ? const Color(0xFFFFD700) : const Color(0xFFE0F7FA))
            .withValues(alpha: twinkle * 0.85);
      canvas.drawCircle(p, s.size, paint);
    }

    // -------------------------------------------------------------------------
    // 2. Step 1 & 2: Rising Luminous Water Vortex Particles (0.0 - 3.0s)
    // -------------------------------------------------------------------------
    if (sec < 3.0) {
      final vortexAlpha = (sec < 1.5 ? (sec / 1.5) : (3.0 - sec) / 1.5).clamp(0.0, 1.0);
      final vortexR = whaleWidth * 0.45;

      for (final vp in _vortexParticles) {
        final currentR = vortexR * vp.radiusRatio * (0.8 + sin(sec * 3.0 + vp.phase) * 0.2);
        final angle = vp.initialAngle + (sec * vp.speed);
        final px = whaleCenter.dx + cos(angle) * currentR;
        final py = whaleCenter.dy + sin(angle) * currentR * 0.45 - (sec * 25.0);

        final paint = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: vortexAlpha * 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(Offset(px, py), vp.size, paint);
      }
    }

    // -------------------------------------------------------------------------
    // 3. Step 4 & 5: Bioluminescent Wake Ribbon & Sparkling Water Waves (5.0 - 9.0s)
    // -------------------------------------------------------------------------
    if (sec >= 5.0 && sec < 9.0) {
      final wakeAlpha = (sec < 7.0 ? (sec - 5.0) / 2.0 : (9.0 - sec) / 2.0).clamp(0.0, 1.0);

      // Trailing wake path
      final wakePath = Path();
      final startWake = Offset(whaleCenter.dx - whaleWidth * 0.45, whaleCenter.dy + whaleHeight * 0.15);
      wakePath.moveTo(startWake.dx, startWake.dy);

      for (int w = 1; w <= 8; w++) {
        final wx = startWake.dx - (w * 35.0);
        final wy = startWake.dy + sin((sec * 4.0) + w) * 16.0 + (w * 8.0);
        wakePath.lineTo(wx, wy);
      }

      final wakePaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: wakeAlpha * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(wakePath, wakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OceanDolphinStoryPainter old) => true;
}

class _DolphinStarSpec {
  final double normX;
  final double normY;
  final double size;
  final double twinkleSpeed;
  final double phase;
  final bool isGold;

  const _DolphinStarSpec({
    required this.normX,
    required this.normY,
    required this.size,
    required this.twinkleSpeed,
    required this.phase,
    required this.isGold,
  });
}

class _VortexParticle {
  final double initialAngle;
  final double radiusRatio;
  final double speed;
  final double size;
  final double phase;

  const _VortexParticle({
    required this.initialAngle,
    required this.radiusRatio,
    required this.speed,
    required this.size,
    required this.phase,
  });
}
