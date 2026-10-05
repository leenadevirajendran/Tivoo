import 'dart:math';
import 'package:flutter/material.dart';
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

  const ActiveGiftAnimationOverlay({
    super.key,
    required this.child,
    this.isSuppressed = false,
    this.showTopBanner = true,
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

  // Bonus extra controllers
  late final AnimationController _horseController;
  late final AnimationController _whaleController;
  late final AnimationController _angelVehicleController;
  late final AnimationController _shakeController;
  late final AnimationController _flightController;

  GiftItem? _activeGift;
  String _currentSenderName = 'You';
  int _currentGiftCount = 1;
  String _currentRecipient = 'Neha ✨';

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
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_carController);
      });

    _yachtController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_yachtController);
      });

    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_rocketController);
      });

    _wingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_wingsController);
      });

    _roseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_roseController);
      });

    _crownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_crownController);
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
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_castleController);
      });

    _horseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_horseController);
      });

    _whaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_whaleController);
      });

    _angelVehicleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) onComplete(_angelVehicleController);
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
    _wingsController.reset();
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
    _horseController.reset();
    _whaleController.reset();
    _angelVehicleController.reset();
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
    });

    _flightController.forward(from: 0.0);

    final soundCat = _getActiveGiftCategory();
    GiftSoundService.instance.playGiftSound(soundCat);

    final nameLower = gift.name.toLowerCase();
    final idLower = gift.id.toLowerCase();

    if (idLower.contains('car') || nameLower.contains('car')) {
      _carController.forward(from: 0.0);
    } else if (idLower.contains('yacht') || nameLower.contains('yacht')) {
      _yachtController.forward(from: 0.0);
    } else if (idLower.contains('rocket') || nameLower.contains('rocket')) {
      _rocketController.forward(from: 0.0);
    } else if (idLower.contains('wing') || nameLower.contains('wing')) {
      _wingsController.forward(from: 0.0);
    } else if (idLower.contains('rose') || nameLower.contains('rose')) {
      _roseController.forward(from: 0.0);
    } else if (idLower.contains('crown') || nameLower.contains('crown')) {
      _crownController.forward(from: 0.0);
    } else if (idLower.contains('diamond') || nameLower.contains('diamond') || idLower.contains('meteor')) {
      _diamondController.forward(from: 0.0);
    } else if (idLower.contains('cake') || nameLower.contains('cake')) {
      _cakeController.forward(from: 0.0);
    } else if (idLower.contains('teddy') ||
        nameLower.contains('teddy') ||
        idLower.contains('panda') ||
        nameLower.contains('panda')) {
      _teddyController.forward(from: 0.0);
    } else if (idLower.contains('kitty') ||
        nameLower.contains('kitty') ||
        idLower.contains('cat') ||
        nameLower.contains('cat')) {
      _kittyController.forward(from: 0.0);
    } else if (idLower.contains('tiki') || nameLower.contains('tiki')) {
      _tikiLoveController.forward(from: 0.0);
    } else if (idLower.contains('love') ||
        nameLower.contains('love') ||
        idLower.contains('heart') ||
        nameLower.contains('heart')) {
      _loveController.forward(from: 0.0);
    } else if (idLower.contains('flower') ||
        nameLower.contains('flower') ||
        idLower.contains('bouquet') ||
        nameLower.contains('bouquet') ||
        idLower.contains('chariot') ||
        nameLower.contains('chariot')) {
      _flowersController.forward(from: 0.0);
    } else if (idLower.contains('world') ||
        nameLower.contains('world') ||
        idLower.contains('tour') ||
        nameLower.contains('tour') ||
        idLower.contains('earth') ||
        nameLower.contains('earth')) {
      _worldTourController.forward(from: 0.0);
    } else if (idLower.contains('castle') || nameLower.contains('castle')) {
      _castleController.forward(from: 0.0);
    } else if (idLower.contains('horse') || nameLower.contains('horse')) {
      _horseController.forward(from: 0.0);
    } else if (idLower.contains('whale') || nameLower.contains('whale')) {
      _whaleController.forward(from: 0.0);
    } else if (idLower.contains('angel_vehicle') ||
        (nameLower.contains('angel') && nameLower.contains('vehicle'))) {
      _angelVehicleController.forward(from: 0.0);
    } else {
      _shakeController.forward(from: 0.0);
    }
  }

  AnimationController? _getActiveController() {
    if (_isActive(_carController)) return _carController;
    if (_isActive(_yachtController)) return _yachtController;
    if (_isActive(_rocketController)) return _rocketController;
    if (_isActive(_wingsController)) return _wingsController;
    if (_isActive(_roseController)) return _roseController;
    if (_isActive(_crownController)) return _crownController;
    if (_isActive(_diamondController)) return _diamondController;
    if (_isActive(_cakeController)) return _cakeController;
    if (_isActive(_teddyController)) return _teddyController;
    if (_isActive(_kittyController)) return _kittyController;
    if (_isActive(_tikiLoveController)) return _tikiLoveController;
    if (_isActive(_loveController)) return _loveController;
    if (_isActive(_flowersController)) return _flowersController;
    if (_isActive(_worldTourController)) return _worldTourController;
    if (_isActive(_castleController)) return _castleController;
    if (_isActive(_horseController)) return _horseController;
    if (_isActive(_whaleController)) return _whaleController;
    if (_isActive(_angelVehicleController)) return _angelVehicleController;
    if (_isActive(_shakeController)) return _shakeController;
    return null;
  }

  String _getActiveGiftCategory() {
    if (_activeGift == null) return '';
    final nameLower = _activeGift!.name.toLowerCase();
    final idLower = _activeGift!.id.toLowerCase();
    if (idLower.contains('rocket') || nameLower.contains('rocket')) return 'rocket';
    if (idLower.contains('car') || nameLower.contains('car')) return 'car';
    if (idLower.contains('yacht') || nameLower.contains('yacht')) return 'yacht';
    if (idLower.contains('whale') || nameLower.contains('whale')) return 'whale';
    if (idLower.contains('wing') || nameLower.contains('wing')) return 'wings';
    if (idLower.contains('angel_vehicle') || (nameLower.contains('angel') && nameLower.contains('vehicle'))) {
      return 'angel_vehicle';
    }
    if (idLower.contains('rose') || nameLower.contains('rose')) return 'rose';
    if (idLower.contains('flower') ||
        nameLower.contains('flower') ||
        idLower.contains('bouquet') ||
        idLower.contains('chariot')) {
      return 'flowers';
    }
    if (idLower.contains('crown') || nameLower.contains('crown')) return 'crown';
    if (idLower.contains('diamond') || nameLower.contains('diamond') || idLower.contains('meteor')) return 'diamond';
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

  @override
  Widget build(BuildContext context) {
    if (widget.isSuppressed) {
      return widget.child;
    }

    final activeController = _getActiveController();
    final giftCategory = _getActiveGiftCategory();

    return Stack(
      children: [
        widget.child,

        // Full-Screen Atmospheric Environmental Engine Layer
        if (activeController != null && giftCategory.isNotEmpty)
          _buildAtmosphericBackdrop(activeController, giftCategory),

        // 15 User-Specified Gift Animations (Transparent Isolated Overlays)
        if (_isActive(_carController)) _buildSuperCarAnimation(),
        if (_isActive(_yachtController)) _buildYachtAnimation(),
        if (_isActive(_rocketController)) _buildRocketAnimation(),
        if (_isActive(_wingsController)) _buildAngelWingsAnimation(),
        if (_isActive(_roseController)) _buildRoseAnimation(),
        if (_isActive(_crownController)) _buildCrownAnimation(),
        if (_isActive(_diamondController)) _buildDiamondAnimation(),
        if (_isActive(_cakeController)) _buildCakeAnimation(),
        if (_isActive(_teddyController)) _buildTeddyAnimation(),
        if (_isActive(_kittyController)) _buildKittyAnimation(),
        if (_isActive(_tikiLoveController)) _buildTikiLoveAnimation(),
        if (_isActive(_loveController)) _buildLoveHeartAnimation(),
        if (_isActive(_flowersController)) _buildFlowersAnimation(),
        if (_isActive(_worldTourController)) _buildWorldTourAnimation(),
        if (_isActive(_castleController)) _buildCastleAnimation(),

        // Extra Luxury Gifts
        if (_isActive(_horseController)) _buildGoldenHorseAnimation(),
        if (_isActive(_whaleController)) _buildOceanWhaleAnimation(),
        if (_isActive(_angelVehicleController)) _buildAngelVehicleAnimation(),
        if (_isActive(_shakeController)) _buildStandardGiftAnimation(),

        // Step 4: Flying Animation from Sender to Creator
        if (_flightController.isAnimating && _activeGift != null)
          _buildSendingFlightAnimation(),

        // Step 5: Gift Received Banner matching Screenshot 2
        if (widget.showTopBanner && _activeGift != null && activeController != null)
          _buildGiftReceivedBanner(),
      ],
    );
  }

  Widget _buildSendingFlightAnimation() {
    final size = MediaQuery.sizeOf(context);
    final startX = 60.0;
    final startY = size.height - 110.0;
    final endX = size.width * 0.45;
    final endY = 120.0;

    return AnimatedBuilder(
      animation: _flightController,
      builder: (context, child) {
        final t = _flightController.value;
        final cpX = size.width * 0.82;
        final cpY = size.height * 0.45;
        final curX = (1 - t) * (1 - t) * startX + 2 * (1 - t) * t * cpX + t * t * endX;
        final curY = (1 - t) * (1 - t) * startY + 2 * (1 - t) * t * cpY + t * t * endY;
        final scale = 0.7 + sin(t * pi) * 0.6;

        return Positioned(
          left: curX - 24,
          top: curY - 24,
          child: Opacity(
            opacity: (1.0 - t * 0.25).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2D78).withValues(alpha: 0.7),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: _activeGift!.imageAssetPath != null
                      ? Image.asset(
                          _activeGift!.imageAssetPath!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        )
                      : Text(
                          _activeGift!.icon,
                          style: const TextStyle(fontSize: 30),
                        ),
                ),
              ),
            ),
          ),
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

                  // 6. 🐋 OCEAN WHALE & YACHT: Deep Ocean Caustics & Ascending Bioluminescent Bubbles!
                  if (category == 'whale' || category == 'yacht')
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
            // Top Luxury Gift Sender Banner
            Positioned(
              top: screenHeight * 0.18,
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2E1238).withValues(alpha: 0.85),
                            const Color(0xFF140D26).withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFFFD600).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x55FFB300),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌹', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'You ',
                                  style: TextStyle(
                                    color: Color(0xFFFFD600),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: 'sent ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Cosmic Fire Rose',
                                  style: TextStyle(
                                    color: Color(0xFFFF80AB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ✨',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

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
                            AppAssets.giftSuperCar,
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
  // 6. 🚀 GALAXY ROCKET ("To the Stars - Galaxy Effect")
  // Sequence: ① Appear ➔ ② Launch ➔ ③ Fly to Sky ➔ ④ Galaxy Effect
  // ===========================================================================
  Widget _buildRocketAnimation() {
    return AnimatedBuilder(
      animation: _rocketController,
      builder: (context, child) {
        final val = _rocketController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double startX = screenWidth * 0.12;
        final double startY = screenHeight * 0.65;
        final double exitX = screenWidth + 180.0;
        final double exitY = -180.0;

        double posX;
        double posY;
        double scale;
        double vibration = 0.0;

        if (val < 0.20) {
          final p = val / 0.20;
          vibration = sin(p * 48 * pi) * 2.2;
          posX = startX;
          posY = startY - (p * 18);
          scale = 0.94 + (p * 0.06);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.20) / 0.80);
          posX = startX + (p * (exitX - startX));
          posY = (startY - 18) + (p * (exitY - (startY - 18)));
          scale = 1.00 + (sin(p * pi) * 0.22);
          vibration = sin(p * 20 * pi) * (1.5 * (1.0 - p));
        }

        posX += vibration;
        const double rocketAngle = -0.58;

        return Stack(
          children: [
            if (val >= 0.08)
              _buildRocketSmokePlume(
                tailX: posX + 38,
                tailY: posY + 115,
                progress: val,
              ),
            if (val >= 0.05)
              Positioned(
                left: posX + 26,
                top: posY + 106,
                child: IgnorePointer(
                  child: Transform.rotate(
                    angle: rocketAngle,
                    child: _buildDualRocketThrusterFlames(progress: val),
                  ),
                ),
              ),
            if (val >= 0.10)
              Positioned(
                left: posX - 10,
                top: posY + 104,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (sin(val * 24 * pi).abs() * 0.35 + 0.65).clamp(0.0, 1.0),
                    child: Container(
                      width: 120,
                      height: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0x8800E5FF),
                            Colors.white,
                            Color(0x8800E5FF),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.25, 0.50, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: posX,
              top: posY,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rocketAngle,
                    child: SizedBox(
                      width: 160,
                      height: 160,
                      child: _buildRealisticSpecularSheen(
                        progress: val,
                        lightColor: const Color(0xFFCFD8DC),
                        child: Image.asset(
                          AppAssets.giftRocket,
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
                            AppAssets.giftCrown,
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
                          AppAssets.giftCastle,
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
                            AppAssets.giftAngelWings,
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
  // 3. 🐎 GOLDEN HORSE ("Power & Success - Final Effect")
  // Sequence: ① Appear ➔ ② Run ➔ ③ Full Speed ➔ ④ Final Effect
  // ===========================================================================
  Widget _buildGoldenHorseAnimation() {
    return AnimatedBuilder(
      animation: _horseController,
      builder: (context, child) {
        final val = _horseController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double centerX = (screenWidth - 230) / 2;
        final double centerY = screenHeight * 0.56;

        final double scale = 0.94 + (sin(val * pi) * 0.14);
        final double tiltAngle = sin(val * 2 * pi) * 0.03;
        final double opacity = val > 0.85 ? ((1.0 - val) / 0.15).clamp(0.0, 1.0) : (val / 0.12).clamp(0.0, 1.0);

        return Stack(
          children: [
            _buildRealisticGroundShadow(
              centerX: centerX + 115,
              groundY: centerY + 175,
              scale: scale,
              width: 200,
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
                      angle: tiltAngle,
                      child: SizedBox(
                        width: 230,
                        height: 210,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFFFFD54F),
                          child: Image.asset(
                            AppAssets.giftGoldenHorse,
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
  // 9. 🐋 OCEAN WHALE ("Big Dreams - Water Effect")
  // Sequence: ① Appear ➔ ② Swim In ➔ ③ Full View ➔ ④ Water Effect
  // ===========================================================================
  Widget _buildOceanWhaleAnimation() {
    return AnimatedBuilder(
      animation: _whaleController,
      builder: (context, child) {
        final val = _whaleController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double waterY = screenHeight * 0.62; // Surface line near comments
        final double startRightX = screenWidth * 0.72;
        final double midApexX = (screenWidth - 240) / 2;
        final double endLeftX = screenWidth * 0.10;

        double posX;
        double posY;
        double scale;
        double tiltAngle;
        double opacity = 1.0;
        bool isBreachingSplash = false;
        bool isDivingSplash = false;

        if (val < 0.18) {
          // ① Preparing beneath surface on right with ripples
          final p = val / 0.18;
          posX = startRightX;
          posY = waterY + 40 - (p * 20);
          scale = 0.80 + (p * 0.15);
          tiltAngle = -0.30;
          opacity = (p * 0.75).clamp(0.0, 1.0);
          isBreachingSplash = true;
        } else if (val < 0.50) {
          // ② Jumping out of the water! Leaping in upward parabolic arc!
          final p = (val - 0.18) / 0.32;
          posX = startRightX - (p * (startRightX - midApexX));
          posY = (waterY + 20) - (sin(p * pi * 0.5) * (screenHeight * 0.16));
          scale = 0.95 + (p * 0.20);
          tiltAngle = -0.42 + (p * 0.32); // Leaping up ~24 degrees
          isBreachingSplash = p < 0.35;
        } else if (val < 0.75) {
          // ③ Apex curve & turning down into dive!
          final p = (val - 0.50) / 0.25;
          posX = midApexX - (p * (midApexX - endLeftX));
          posY = (waterY + 20 - (screenHeight * 0.16)) + (pow(p, 1.8) * (screenHeight * 0.14));
          scale = 1.15;
          tiltAngle = -0.10 + (p * 0.52); // Curves over and tilts into downward dive
        } else {
          // ④ Head-first dive into water with foaming splashdown!
          final p = (val - 0.75) / 0.25;
          posX = endLeftX - (p * 45);
          posY = (waterY - 10) + (p * 70);
          scale = 1.15 - (p * 0.25);
          tiltAngle = 0.42;
          opacity = (1.0 - p).clamp(0.0, 1.0);
          isDivingSplash = true;
        }

        return Stack(
          children: [
            // Emergence splash ripples on right
            if (isBreachingSplash)
              _buildRealisticWaterRipples(
                left: startRightX - 20,
                top: waterY + 30,
                width: 200,
                progress: val * 2.5,
                opacity: 0.85,
              ),

            // Splashdown ripples on left
            if (isDivingSplash)
              _buildRealisticWaterRipples(
                left: endLeftX - 30,
                top: waterY + 30,
                width: 240,
                progress: (val - 0.75) * 4.0,
                opacity: 0.90,
              ),

            // Airborne Leaping Ocean Whale / Fish
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
                        width: 240,
                        height: 210,
                        child: _buildRealisticSpecularSheen(
                          progress: val,
                          lightColor: const Color(0xFF80D8FF),
                          child: Image.asset(
                            AppAssets.giftOceanWhale,
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
                            AppAssets.giftAngelVehicle,
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
                            AppAssets.giftDiamond,
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
  // 5. 🛥️ YACHT
  // ===========================================================================
  Widget _buildYachtAnimation() {
    return AnimatedBuilder(
      animation: _yachtController,
      builder: (context, child) {
        final val = _yachtController.value;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final screenHeight = MediaQuery.sizeOf(context).height;

        final double targetCenterX = (screenWidth - 230) / 2;
        final double targetCenterY = screenHeight * 0.58;

        final double offscreenLeft = -280.0;
        final double offscreenRight = screenWidth + 280.0;

        double posX;
        double scale;

        if (val < 0.28) {
          final p = Curves.easeOutCubic.transform(val / 0.28);
          posX = offscreenLeft + (p * (targetCenterX - 45 - offscreenLeft));
          scale = 0.90 + (p * 0.10);
        } else if (val < 0.72) {
          final p = (val - 0.28) / 0.44;
          posX = (targetCenterX - 45) + (p * 60);
          scale = 1.00 + (sin(p * pi) * 0.18);
        } else {
          final p = Curves.easeInCubic.transform((val - 0.72) / 0.28);
          posX = (targetCenterX + 15) + (p * (offscreenRight - (targetCenterX + 15)));
          scale = 1.18 - (p * 0.12);
        }

        final double waveHeave = sin(val * 8 * pi) * 4.5;
        final double waveRoll = sin(val * 4 * pi) * 0.035;
        final double posY = targetCenterY + waveHeave;

        return Stack(
          children: [
            _buildRealisticWaterRipples(
              left: posX - 15,
              top: posY + 88,
              width: 260 * scale,
              progress: val,
              opacity: 0.75,
            ),
            Positioned(
              left: posX,
              top: posY,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: waveRoll,
                    child: SizedBox(
                      width: 230,
                      height: 125,
                      child: _buildRealisticSpecularSheen(
                        progress: val,
                        lightColor: const Color(0xFF00E5FF),
                        child: Image.asset(
                          AppAssets.giftYacht,
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
                            AppAssets.giftFlowers,
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
    return Stack(
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
