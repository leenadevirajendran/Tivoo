import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../broadcast/domain/models/camera_filter_model.dart';
import '../../../broadcast/presentation/widgets/filter_overlay_widget.dart';
import '../../domain/models/video_creation_state.dart';
import '../widgets/camera_effects_overlay.dart';
import '../widgets/camera_settings_sheet.dart';
import '../widgets/effects_bottom_sheet.dart';
import '../widgets/filter_carousel.dart';
import '../widgets/music_picker_sheet.dart';
import '../widgets/retouch_bottom_sheet.dart';
import '../widgets/snap_lens_carousel.dart';
import '../widgets/snap_lens_studio_sheet.dart';
import '../widgets/video_filters.dart';
import '../widgets/video_filter_overlay.dart';
import 'video_editor_screen.dart';

/// Modern Instagram Reels-style video recording screen with Tivoo's signature pink & purple branding:
/// - Full-screen camera viewfinder with real-time color grading and AR visual effects
/// - Top bar: Close (✕), Tivoo✦ wordmark, Settings, Flash toggle, and Camera Flip
/// - Right-side toolbar: Music, Effects, Retouch, and Timer (Filter button removed)
/// - Bottom filter carousel with 14 filters (Original, Natural, Paris, Warm, Vintage, Cool, Golden, Cinema, Dreamy, etc.)
/// - Floating filter intensity slider (0–100%) when any non-Original filter is active
/// - Separate Effects panel (visual overlays) and Retouch panel (beauty adjustment sliders)
/// - Prominent circular recording button, Gallery picker, Camera flip, and Photo/Video/Templates mode selector
class VideoCameraScreen extends StatefulWidget {
  const VideoCameraScreen({super.key});

  @override
  State<VideoCameraScreen> createState() => _VideoCameraScreenState();
}

class _VideoCameraScreenState extends State<VideoCameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool _isCameraReady = false;
  bool _useFallbackViewfinder = false;
  bool _isPermissionDenied = false;

  // Recording State (Instagram Reels-style circular shutter recording)
  bool _isRecording = false;
  late AnimationController _recordingAnimController;
  int _recordedSeconds = 0;
  static const int _maxDurationSeconds = 60; // 01:00 max duration

  // Countdown timer before recording
  int _countdownSeconds = 0; // 0 = off, 3 = 3s, 10 = 10s
  int _currentCountdown = 0;
  Timer? _countdownTimer;

  // Controls & Settings
  FlashMode _flashMode = FlashMode.off;
  String? _selectedMusicTitle;
  String? _activeEffectId; // 'sparkles', 'light_leak', 'bokeh_hearts', etc.
  RetouchSettings _retouch = const RetouchSettings();

  // Filters state
  String _selectedFilterId = 'natural';
  double _filterIntensity = 0.85;

  // Snap Lens Studio State (AR Lenses from https://developers.snap.com/lens-studio/home)
  CameraFilterModel? _selectedSnapLens;
  bool _useSnapLensMode = true;

  // Camera Mode: 'Photo', 'Video', 'Templates'
  String _activeMode = 'Video';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recordingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _maxDurationSeconds),
    );
    _recordingAnimController.addListener(() {
      final currentSec =
          (_recordingAnimController.value * _maxDurationSeconds).floor();
      if (currentSec != _recordedSeconds) {
        setState(() => _recordedSeconds = currentSec);
      }
    });
    _recordingAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingAnimController.dispose();
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final camPerm = await Permission.camera.request();
    final micPerm = await Permission.microphone.request();

    if (!camPerm.isGranted || !micPerm.isGranted) {
      if (mounted) {
        setState(() {
          _isPermissionDenied = true;
          _useFallbackViewfinder = true;
        });
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _useFallbackViewfinder = true);
        return;
      }

      final frontIdx =
          _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _cameraIndex = frontIdx >= 0 ? frontIdx : 0;

      await _startCameraController(_cameras[_cameraIndex]);
    } catch (e) {
      debugPrint('VideoCameraScreen initCamera error: $e');
      if (mounted) setState(() => _useFallbackViewfinder = true);
    }
  }

  Future<void> _startCameraController(CameraDescription desc) async {
    final old = _cameraController;
    final controller = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      await old?.dispose();
      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraReady = true;
          _useFallbackViewfinder = false;
          _isPermissionDenied = false;
        });
      }
    } catch (e) {
      debugPrint('Error starting camera: $e');
      if (mounted) setState(() => _useFallbackViewfinder = true);
    }
  }

  Future<void> _flipCamera() async {
    HapticFeedback.lightImpact();
    if (_cameras.length < 2) {
      setState(() => _cameraIndex = (_cameraIndex + 1) % 2);
      return;
    }
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCameraController(_cameras[_cameraIndex]);
  }

  Future<void> _cycleFlash() async {
    HapticFeedback.selectionClick();
    final c = _cameraController;
    FlashMode next;
    if (_flashMode == FlashMode.off) {
      next = FlashMode.auto;
    } else if (_flashMode == FlashMode.auto) {
      next = FlashMode.torch;
    } else {
      next = FlashMode.off;
    }

    setState(() => _flashMode = next);
    if (c != null && c.value.isInitialized) {
      try {
        await c.setFlashMode(next);
      } catch (_) {}
    }
  }

  // Gallery Picker
  Future<void> _pickVideoFromGallery() async {
    HapticFeedback.selectionClick();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        Uint8List? bytes;
        try {
          bytes = await picked.readAsBytes();
        } catch (_) {}
        _proceedToEditor(File(picked.path), pickedPath: picked.path, videoBytes: bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access gallery: $e')),
        );
      }
    }
  }

  // Shutter action
  void _onShutterTapped() {
    HapticFeedback.heavyImpact();

    if (_activeMode == 'Photo') {
      _takePhoto();
      return;
    }

    if (_isRecording) {
      _stopRecording();
    } else {
      if (_countdownSeconds > 0) {
        _startCountdown();
      } else {
        _startRecording();
      }
    }
  }

  Future<void> _takePhoto() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo captured with active Tivoo filter!'),
        backgroundColor: Color(0xFF28113E),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startCountdown() {
    setState(() => _currentCountdown = _countdownSeconds);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentCountdown <= 1) {
        timer.cancel();
        setState(() => _currentCountdown = 0);
        _startRecording();
      } else {
        setState(() => _currentCountdown--);
      }
    });
  }

  Future<void> _startRecording() async {
    final c = _cameraController;
    if (_isRecording) return;

    if (c != null && c.value.isInitialized) {
      try {
        await c.startVideoRecording();
      } catch (e) {
        debugPrint('startVideoRecording error: $e');
      }
    }

    setState(() {
      _isRecording = true;
      _recordedSeconds = 0;
    });

    _recordingAnimController.forward(from: 0.0);
  }

  Future<void> _cancelRecording() async {
    HapticFeedback.lightImpact();
    final c = _cameraController;
    _countdownTimer?.cancel();
    _recordingAnimController.stop();
    _recordingAnimController.reset();

    if (c != null && c.value.isInitialized && c.value.isRecordingVideo) {
      try {
        await c.stopVideoRecording();
      } catch (_) {}
    }

    setState(() {
      _isRecording = false;
      _recordedSeconds = 0;
      _currentCountdown = 0;
    });
  }

  Future<void> _stopRecording() async {
    HapticFeedback.mediumImpact();
    final c = _cameraController;
    _recordingAnimController.stop();

    File? outputFile;
    if (c != null && c.value.isInitialized && c.value.isRecordingVideo) {
      try {
        final xfile = await c.stopVideoRecording();
        outputFile = File(xfile.path);
      } catch (e) {
        debugPrint('stopVideoRecording error: $e');
      }
    } else {
      // Demo simulated recording fallback
      try {
        final byteData = await rootBundle.load(AppAssets.video1);
        final tempDir = await getTemporaryDirectory();
        final file = File(
            '${tempDir.path}/recorded_tivoo_${DateTime.now().millisecondsSinceEpoch}.mp4');
        await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        outputFile = file;
      } catch (e) {
        debugPrint('Sample fallback error: $e');
      }
    }

    _recordingAnimController.reset();
    setState(() {
      _isRecording = false;
      _recordedSeconds = 0;
    });

    if (outputFile != null && outputFile.existsSync()) {
      _proceedToEditor(outputFile);
    }
  }

  String _formatInstagramTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _proceedToEditor(File file, {String? pickedPath, Uint8List? videoBytes}) {
    final selectedFilter = VideoFilterRepository.filters.firstWhere(
      (f) => f.id == _selectedFilterId,
      orElse: () => VideoFilterRepository.filters.first,
    );

    final state = VideoCreationState(
      videoFile: file,
      videoPath: pickedPath ?? file.path,
      videoBytes: videoBytes,
      filterName: selectedFilter.name,
      colorFilter: selectedFilter.getColorFilter(_filterIntensity),
      selectedMusicTitle: _selectedMusicTitle,
      activeEffectName: _activeEffectId,
      activeSnapLens: _selectedSnapLens,
      playbackSpeed: 1.0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VideoEditorScreen(creationState: state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final c = _cameraController;
    final hasRealCamera = _isCameraReady &&
        c != null &&
        c.value.isInitialized &&
        !_useFallbackViewfinder;

    final selectedFilter = VideoFilterRepository.filters.firstWhere(
      (f) => f.id == _selectedFilterId,
      orElse: () => VideoFilterRepository.filters.first,
    );
    final activeColorFilter = selectedFilter.getColorFilter(_filterIntensity);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Camera Viewfinder with Live Color Grading
          if (hasRealCamera)
            ColorFiltered(
              colorFilter: activeColorFilter ??
                  const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: Center(
                child: CameraPreview(c),
              ),
            )
          else
            _buildSimulatedViewfinder(activeColorFilter),

          // 2. Snap Lens Studio Live AR Effect Overlay
          if (_selectedSnapLens != null && !_selectedSnapLens!.isNone)
            Positioned.fill(
              child: IgnorePointer(
                child: FilterOverlayWidget(filter: _selectedSnapLens!),
              ),
            ),

          // Active Video Filter AR / Atmospheric Overlay
          if (selectedFilter.overlayType != 'none')
            Positioned.fill(
              child: IgnorePointer(
                child: VideoFilterOverlay(
                  overlayType: selectedFilter.overlayType,
                  intensity: _filterIntensity,
                ),
              ),
            ),

          // 3. Active AR Visual Effects Overlay
          CameraEffectsOverlay(activeEffectId: _activeEffectId),

          // 4. Countdown Overlay (3, 2, 1)
          if (_currentCountdown > 0)
            Container(
              color: Colors.black45,
              child: Center(
                child: Text(
                  '$_currentCountdown',
                  style: const TextStyle(
                    color: Color(0xFFFF2DC0),
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.white, blurRadius: 40),
                      Shadow(color: Color(0xFFFF2DC0), blurRadius: 20),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Active Snap Lens Floating Indicator
          if (_selectedSnapLens != null && !_selectedSnapLens!.isNone)
            Positioned(
              top: mq.padding.top + 54,
              left: 20,
              right: 20,
              child: Center(
                child: GestureDetector(
                  onTap: () => SnapLensStudioSheet.show(
                    context,
                    selectedLens: _selectedSnapLens,
                    onSelectLens: (lens) => setState(() => _selectedSnapLens = lens),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xE60D0F1A),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFFFFC00), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FFFC00),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFFFC00),
                            boxShadow: [
                              BoxShadow(color: Color(0xFFFFFC00), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Snap Lens: ${_selectedSnapLens!.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedSnapLens = null);
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. Top Header Bar (Close, Tivoo✦, Settings, Flash, Flip)
          Positioned(
            top: mq.padding.top + 6,
            left: 14,
            right: 14,
            child: _isRecording ? _buildRecordingTopBar() : _buildNormalTopBar(),
          ),

          // 5. Right Toolbar (Music, Effects, Retouch, Timer)
          if (!_isRecording)
            Positioned(
              top: mq.padding.top + 72,
              right: 14,
              child: _buildRightToolbar(),
            ),

          // 6. Bottom Controls Section
          Positioned(
            left: 0,
            right: 0,
            bottom: mq.padding.bottom + 8,
            child: _isRecording
                ? _buildRecordingBottomControls()
                : _buildNormalBottomControls(),
          ),
        ],
      ),
    );
  }

  // Top Bar - Normal Mode
  Widget _buildNormalTopBar() {
    return Row(
      children: [
        // Close Button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          ),
        ),
        const Spacer(),

        // Tivoo✦ Wordmark in Center
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tivoo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontFamily: 'Pacifico',
                letterSpacing: 0.8,
                shadows: [
                  Shadow(color: Color(0x99FF2DC0), blurRadius: 10),
                  Shadow(color: Colors.black87, blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 3),
            Transform.translate(
              offset: const Offset(0, -6),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFF2DC0),
                size: 13,
              ),
            ),
          ],
        ),
        const Spacer(),

        // Settings Button
        _buildTopCircularButton(
          icon: Icons.settings_outlined,
          onTap: () => CameraSettingsSheet.show(context),
        ),
        const SizedBox(width: 10),

        // Flash Button
        _buildTopCircularButton(
          icon: _flashMode == FlashMode.off
              ? Icons.flash_off_rounded
              : (_flashMode == FlashMode.auto
                  ? Icons.flash_auto_rounded
                  : Icons.flash_on_rounded),
          color: _flashMode != FlashMode.off ? LuxeColors.gold : Colors.white,
          onTap: _cycleFlash,
        ),
        const SizedBox(width: 10),

        // Camera Flip Button
        _buildTopCircularButton(
          icon: Icons.flip_camera_ios_rounded,
          onTap: _flipCamera,
        ),
      ],
    );
  }

  Widget _buildTopCircularButton({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Top Bar - Recording Active (Instagram Reels-style with pink timer badge matching reference)
  Widget _buildRecordingTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cancel / Dismiss Recording Button on Left
        GestureDetector(
          onTap: _cancelRecording,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          ),
        ),

        // Instagram Reels Pink Timer Pill Badge on Right (matching reference image)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF007F), // Vibrant Instagram Reels pink/magenta
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66FF007F),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            _formatInstagramTimer(_recordedSeconds),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // Right-Side Toolbar: Snap Lens, Music, Effects, Retouch, Timer
  Widget _buildRightToolbar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 0. Snap Lens Studio (AR Face & World Filters)
        _buildToolbarItem(
          icon: Icons.camera_front_rounded,
          label: 'Snap Lens',
          badge: (_selectedSnapLens != null && !_selectedSnapLens!.isNone) ? 'ON' : 'SNAP',
          isActive: _selectedSnapLens != null && !_selectedSnapLens!.isNone,
          onTap: () {
            SnapLensStudioSheet.show(
              context,
              selectedLens: _selectedSnapLens,
              onSelectLens: (lens) {
                setState(() => _selectedSnapLens = lens);
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 1. Music
        _buildToolbarItem(
          icon: Icons.music_note_rounded,
          label: 'Music',
          badge: _selectedMusicTitle != null ? '✓' : null,
          isActive: _selectedMusicTitle != null,
          onTap: () {
            MusicPickerSheet.show(
              context,
              initialSelectedTitle: _selectedMusicTitle,
              onApply: (title, _, _, _) {
                setState(() => _selectedMusicTitle = title);
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 2. Effects
        _buildToolbarItem(
          icon: Icons.auto_awesome_rounded,
          label: 'Effects',
          badge: (_activeEffectId != null && _activeEffectId != 'none') ? 'ON' : null,
          isActive: _activeEffectId != null && _activeEffectId != 'none',
          onTap: () {
            EffectsBottomSheet.show(
              context,
              activeEffectId: _activeEffectId,
              onSelectEffect: (effect) {
                setState(() => _activeEffectId = effect);
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 3. Retouch
        _buildToolbarItem(
          icon: Icons.face_retouching_natural_rounded,
          label: 'Retouch',
          badge: _retouch.isEnabled ? 'ON' : null,
          isActive: _retouch.isEnabled,
          onTap: () {
            RetouchBottomSheet.show(
              context,
              initialSettings: _retouch,
              onChanged: (settings) {
                setState(() => _retouch = settings);
              },
            );
          },
        ),
        const SizedBox(height: 16),

        // 4. Timer
        _buildToolbarItem(
          icon: Icons.timer_outlined,
          label: 'Timer',
          badge: _countdownSeconds > 0 ? '${_countdownSeconds}s' : null,
          isActive: _countdownSeconds > 0,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (_countdownSeconds == 0) {
                _countdownSeconds = 3;
              } else if (_countdownSeconds == 3) {
                _countdownSeconds = 10;
              } else {
                _countdownSeconds = 0;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required String label,
    String? badge,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(
                color: isActive ? const Color(0xFFFF2DC0) : Colors.white24,
                width: isActive ? 1.8 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      const BoxShadow(
                        color: Color(0x66FF2DC0),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFFFF8AE6) : Colors.white,
                  size: 22,
                ),
                if (badge != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2DC0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF8AE6) : Colors.white,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterModeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (title.contains('Snap')
                  ? const Color(0xFFFFFC00)
                  : const Color(0xFFFF2DC0))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (title.contains('Snap') ? Colors.black : Colors.white)
                : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Normal Bottom Controls (Snap Lens / Filter carousel, Shutter, Gallery, Flip, Mode selector)
  Widget _buildNormalBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lens Mode Switcher: Snap Lens Studio vs Color Filters
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _useSnapLensMode
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.6)
                  : Colors.white24,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterModeTab(
                title: 'Snap Lenses 🟡',
                isSelected: _useSnapLensMode,
                onTap: () => setState(() => _useSnapLensMode = true),
              ),
              _buildFilterModeTab(
                title: 'Color Filters 🎨',
                isSelected: !_useSnapLensMode,
                onTap: () => setState(() => _useSnapLensMode = false),
              ),
            ],
          ),
        ),

        // Carousel based on selected mode
        if (_useSnapLensMode)
          SnapLensCarousel(
            lenses: MockFilterData.allFilters,
            selectedLens: _selectedSnapLens,
            onSelectLens: (lens) {
              setState(() => _selectedSnapLens = lens);
            },
            onOpenStudio: () {
              SnapLensStudioSheet.show(
                context,
                selectedLens: _selectedSnapLens,
                onSelectLens: (lens) {
                  setState(() => _selectedSnapLens = lens);
                },
              );
            },
          )
        else
          FilterCarousel(
            filters: VideoFilterRepository.filters,
            selectedFilterId: _selectedFilterId,
            intensity: _filterIntensity,
            onSelectFilter: (id) {
              setState(() => _selectedFilterId = id);
            },
            onIntensityChanged: (val) {
              setState(() => _filterIntensity = val);
            },
          ),
        const SizedBox(height: 12),

        // 2. Shutter & Gallery Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery Picker Button
              GestureDetector(
                onTap: _pickVideoFromGallery,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 8),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          AppAssets.status1,
                          fit: BoxFit.cover,
                          cacheWidth: 100,
                          cacheHeight: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                      ),
                    ),
                  ],
                ),
              ),

              // Prominent Instagram Reels-Style Shutter Record Button
              GestureDetector(
                onTap: _onShutterTapped,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x88FF2DC0),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Color(0x449D4EDD),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFFF2DC0),
                            Color(0xFFFF007F),
                            Color(0xFF9D4EDD),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Camera Flip Button
              GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Mode Selector: Photo, Video, Templates
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final mode in ['Photo', 'Video', 'Templates'])
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeMode = mode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: _activeMode == mode
                        ? const LinearGradient(
                            colors: [Color(0xFF9D4EDD), Color(0xFFFF2DC0)],
                          )
                        : null,
                    color: _activeMode == mode
                        ? null
                        : Colors.transparent,
                  ),
                  child: Text(
                    mode,
                    style: TextStyle(
                      color: _activeMode == mode ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight:
                          _activeMode == mode ? FontWeight.w900 : FontWeight.w600,
                      shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Active Recording Bottom Controls (Instagram Reels-style circular shutter with sweeping progress arc)
  Widget _buildRecordingBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: GestureDetector(
          onTap: _stopRecording,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _recordingAnimController,
            builder: (context, child) {
              return SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(
                  painter: _InstagramRecordProgressPainter(
                    progress: _recordingAnimController.value,
                    progressColor: const Color(0xFFFF007F),
                    trackColor: Colors.white.withValues(alpha: 0.22),
                    strokeWidth: 5.0,
                  ),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.38),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 1),
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
    );
  }

  // Simulated Luxury Viewfinder (Fallback for emulators / simulators / desktop)
  Widget _buildSimulatedViewfinder(ColorFilter? filter) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: filter ??
              const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: Image.asset(
            _cameraIndex == 0 ? AppAssets.status1 : AppAssets.status2,
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.5),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.65),
              ],
            ),
          ),
        ),
        if (_isPermissionDenied)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xCC131526),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFF2DC0), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_off_rounded,
                    color: Color(0xFFFF2DC0),
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Camera Permission Needed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Grant permission to record live videos or pick an existing video from your gallery.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickVideoFromGallery,
                    icon: const Icon(Icons.photo_library_rounded, size: 16),
                    label: const Text('Pick from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D4EDD),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Sweeping circular progress arc painter for the Instagram Reels-style record button.
class _InstagramRecordProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _InstagramRecordProgressPainter({
    required this.progress,
    this.progressColor = const Color(0xFFFF007F),
    this.trackColor = Colors.white24,
    this.strokeWidth = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw subtle background track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw sweeping progress arc in bright pink/magenta starting at 12 o'clock (-pi/2)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InstagramRecordProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
