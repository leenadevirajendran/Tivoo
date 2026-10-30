import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/video_creation_state.dart';
import '../widgets/editor_trim_timeline.dart';
import '../widgets/music_picker_sheet.dart';
import 'post_video_screen.dart';

class VideoEditorScreen extends StatefulWidget {
  final VideoCreationState creationState;

  const VideoEditorScreen({super.key, required this.creationState});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late final VideoCreationState _state;
  VideoPlayerController? _controller;
  bool _isPlaying = true;
  bool _isInitialized = false;

  // Overlays
  String? _activeText;
  Color _activeTextColor = const Color(0xFFFFD700);
  String? _activeSticker;
  String _activeFilter = 'Natural';
  String? _activeEffect;

  // Adjustments
  double _brightness = 0.0;
  double _contrast = 1.0;

  static const List<({String name, ColorFilter? filter, Color previewColor})> _filters = [
    (name: 'Original', filter: null, previewColor: Colors.grey),
    (
      name: 'Natural',
      filter: ColorFilter.matrix([
        1.05, 0, 0, 0, 5,
        0, 1.02, 0, 0, 5,
        0, 0, 0.98, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      previewColor: Color(0xFFFFB74D),
    ),
    (
      name: 'Warm Sunset',
      filter: ColorFilter.matrix([
        1.2, 0, 0, 0, 10,
        0, 1.0, 0, 0, 0,
        0, 0, 0.8, 0, -10,
        0, 0, 0, 1, 0,
      ]),
      previewColor: Color(0xFFFF7043),
    ),
    (
      name: 'Cool Cyber',
      filter: ColorFilter.matrix([
        0.8, 0, 0, 0, -5,
        0, 1.05, 0, 0, 5,
        0, 0, 1.25, 0, 15,
        0, 0, 0, 1, 0,
      ]),
      previewColor: Color(0xFF00E5FF),
    ),
    (
      name: 'Golden Glow',
      filter: ColorFilter.matrix([
        1.2, 0, 0, 0, 15,
        0, 1.15, 0, 0, 10,
        0, 0, 0.7, 0, -20,
        0, 0, 0, 1, 0,
      ]),
      previewColor: Color(0xFFFFD700),
    ),
    (
      name: 'Noir B&W',
      filter: ColorFilter.matrix([
        0.33, 0.33, 0.33, 0, 0,
        0.33, 0.33, 0.33, 0, 0,
        0.33, 0.33, 0.33, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      previewColor: Colors.white60,
    ),
  ];

  static const List<String> _stickers = [
    '🔥', '👑', '⭐', '💖', '💃', '🎉', '🚀', '💎', '✨', '🎧', '⚡', '💯',
  ];

  @override
  void initState() {
    super.initState();
    _state = widget.creationState;
    _activeText = _state.textOverlay;
    _activeTextColor = _state.textOverlayColor;
    _activeSticker = _state.stickerEmoji;
    _activeFilter = _state.filterName;
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      if (await _state.videoFile.exists() && (await _state.videoFile.length()) > 0) {
        _controller = VideoPlayerController.file(_state.videoFile);
      } else {
        _controller = VideoPlayerController.asset(AppAssets.video1);
      }

      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setPlaybackSpeed(_state.playbackSpeed);
      await _controller!.play();

      _controller!.addListener(_onVideoTick);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
          _state.duration = _controller!.value.duration;
          if (_state.trimEnd == Duration.zero || _state.trimEnd > _state.duration) {
            _state.trimEnd = _state.duration;
          }
        });
      }
    } catch (e) {
      debugPrint('VideoEditorScreen init error: $e');
      // Fallback to sample asset
      _controller = VideoPlayerController.asset(AppAssets.video1);
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.play();
      _controller!.addListener(_onVideoTick);
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _state.duration = _controller!.value.duration;
          _state.trimEnd = _state.duration;
        });
      }
    }
  }

  void _onVideoTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    // Loop within trim boundaries
    if (c.value.position >= _state.trimEnd) {
      c.seekTo(_state.trimStart);
    } else if (c.value.position < _state.trimStart) {
      c.seekTo(_state.trimStart);
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _isPlaying = false;
      } else {
        c.play();
        _isPlaying = true;
      }
    });
  }

  // Tool Modals
  void _openMusic() {
    MusicPickerSheet.show(
      context,
      initialSelectedTitle: _state.selectedMusicTitle,
      initialOriginalVolume: _state.originalVolume,
      initialMusicVolume: _state.musicVolume,
      onApply: (title, artist, origVol, musicVol) {
        setState(() {
          _state.selectedMusicTitle = title;
          _state.selectedMusicArtist = artist;
          _state.originalVolume = origVol;
          _state.musicVolume = musicVol;
        });
      },
    );
  }

  void _openTextDialog() {
    final textCtl = TextEditingController(text: _activeText ?? '');
    Color pickedColor = _activeTextColor;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161338),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Add Text Overlay', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtl,
                    autofocus: true,
                    style: TextStyle(color: pickedColor, fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Type something cool...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (final c in [
                        const Color(0xFFFFD700),
                        Colors.white,
                        const Color(0xFFFF2A85),
                        const Color(0xFF00E5FF),
                        const Color(0xFF9D4EDD),
                      ])
                        GestureDetector(
                          onTap: () => setDlgState(() => pickedColor = c),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(color: pickedColor == c ? Colors.white : Colors.transparent, width: 2.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (_activeText != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _activeText = null;
                        _state.textOverlay = null;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final t = textCtl.text.trim();
                    setState(() {
                      _activeText = t.isEmpty ? null : t;
                      _activeTextColor = pickedColor;
                      _state.textOverlay = _activeText;
                      _state.textOverlayColor = pickedColor;
                    });
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D4EDD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openStickersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Choose a Sticker', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _stickers.length,
                  itemBuilder: (context, i) {
                    final s = _stickers[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeSticker = s;
                          _state.stickerEmoji = s;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text(s, style: const TextStyle(fontSize: 26))),
                      ),
                    );
                  },
                ),
                if (_activeSticker != null) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _activeSticker = null;
                        _state.stickerEmoji = null;
                      });
                      Navigator.of(ctx).pop();
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    label: const Text('Remove Current Sticker', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFiltersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Color Grade & Filters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, i) {
                      final item = _filters[i];
                      final isSelected = _activeFilter == item.name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeFilter = item.name;
                            _state.filterName = item.name;
                            _state.colorFilter = item.filter;
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.previewColor.withValues(alpha: 0.3),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFF2A85) : Colors.white24,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Icon(Icons.palette_rounded, color: item.previewColor, size: 24),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFFFF2A85) : Colors.white70,
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEffectsSheet() {
    final effects = ['None', 'Sparkles ✨', 'Glitch ⚡', 'Cyber Neon 🟣', 'Vignette 🎬', 'Soft Glow 🌟'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Visual Effects', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final eff in effects)
                      ChoiceChip(
                        label: Text(eff, style: const TextStyle(fontWeight: FontWeight.w700)),
                        selected: _activeEffect == eff || (eff == 'None' && _activeEffect == null),
                        selectedColor: const Color(0xFF9D4EDD),
                        backgroundColor: const Color(0x331E1A3C),
                        labelStyle: TextStyle(
                          color: (_activeEffect == eff || (eff == 'None' && _activeEffect == null)) ? Colors.white : Colors.white70,
                        ),
                        onSelected: (val) {
                          setState(() {
                            _activeEffect = eff == 'None' ? null : eff;
                            _state.activeEffectName = _activeEffect;
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSpeedSelector() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Playback Speed', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final s in speeds)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _state.playbackSpeed = s;
                            _controller?.setPlaybackSpeed(s);
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          width: 48,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _state.playbackSpeed == s
                                ? const LinearGradient(colors: [Color(0xFF9D4EDD), Color(0xFFFF2A85)])
                                : null,
                            color: _state.playbackSpeed == s ? null : Colors.white10,
                            border: Border.all(
                              color: _state.playbackSpeed == s ? const Color(0xFFFF2A85) : Colors.white24,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${s}x',
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAdjustDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setAdjState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 14),
                    const Text('Adjust Video Attributes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.brightness_6_rounded, color: LuxeColors.gold, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Brightness', style: TextStyle(color: Colors.white, fontSize: 13))),
                        Text('${(_brightness * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: _brightness,
                      min: -0.5,
                      max: 0.5,
                      activeColor: LuxeColors.gold,
                      onChanged: (v) {
                        setAdjState(() => _brightness = v);
                        setState(() => _state.brightness = v);
                      },
                    ),
                    Row(
                      children: [
                        const Icon(Icons.contrast_rounded, color: Color(0xFF00E5FF), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(child: Text('Contrast', style: TextStyle(color: Colors.white, fontSize: 13))),
                        Text('${(_contrast * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: _contrast,
                      min: 0.5,
                      max: 1.5,
                      activeColor: const Color(0xFF00E5FF),
                      onChanged: (v) {
                        setAdjState(() => _contrast = v);
                        setState(() => _state.contrast = v);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openVoiceoverSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131526),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Record Voice-over', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Tap & hold the microphone to record commentary', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Voice-over recorded and mixed to video! 🎙️')),
                    );
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFFF2A85), Color(0xFFFF8F00)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF2A85).withValues(alpha: 0.4), blurRadius: 18, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNext() {
    _controller?.pause();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostVideoScreen(creationState: _state)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final isReady = _isInitialized && c != null && c.value.isInitialized;

    final filter = _filters.firstWhere(
      (f) => f.name == _activeFilter,
      orElse: () => _filters[0],
    ).filter;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E17),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: _onNext,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9D4EDD), Color(0xFFFF2A85)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2A85).withValues(alpha: 0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center Video Preview with interactive overlays (Matching Image 3)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x449D4EDD), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9D4EDD).withValues(alpha: 0.22),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isReady)
                                ColorFiltered(
                                  colorFilter: filter ?? const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: c.value.size.width > 0 ? c.value.size.width : 360,
                                      height: c.value.size.height > 0 ? c.value.size.height : 640,
                                      child: VideoPlayer(c),
                                    ),
                                  ),
                                )
                              else
                                const Center(
                                  child: CircularProgressIndicator(color: Color(0xFFFF2A85)),
                                ),

                              // Play/Pause Overlay Icon
                              if (!_isPlaying)
                                Center(
                                  child: Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.65),
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                                  ),
                                ),

                              // Text Overlay Badge
                              if (_activeText != null && _activeText!.isNotEmpty)
                                Positioned(
                                  top: 40,
                                  left: 20,
                                  right: 20,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: _activeTextColor.withValues(alpha: 0.7), width: 1.2),
                                      ),
                                      child: Text(
                                        _activeText!,
                                        style: TextStyle(
                                          color: _activeTextColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),

                              // Sticker Overlay
                              if (_activeSticker != null)
                                Positioned(
                                  bottom: 40,
                                  right: 24,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(_activeSticker!, style: const TextStyle(fontSize: 34)),
                                  ),
                                ),

                              // Music Pill Badge (if music attached)
                              if (_state.selectedMusicTitle != null)
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xCC131526),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.6)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.music_note_rounded, color: LuxeColors.gold, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          _state.selectedMusicTitle!,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // Active Effect Overlay indicator
                              if (_activeEffect != null)
                                Positioned(
                                  top: 10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xCC9D4EDD),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _activeEffect!,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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

            // Timeline & Trim Section (Matching Image 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: EditorTrimTimeline(
                totalDuration: _state.duration,
                currentPosition: c?.value.position ?? Duration.zero,
                trimStart: _state.trimStart,
                trimEnd: _state.trimEnd,
                onTrimChanged: (start, end) {
                  setState(() {
                    _state.trimStart = start;
                    _state.trimEnd = end;
                  });
                  _controller?.seekTo(start);
                },
              ),
            ),

            // 10 Editing Tools in 2 Rows of 5 (Exact Match to Image 3)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF101222),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Trim, Music, Text, Stickers, Effects
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildToolButton(
                        icon: Icons.content_cut_rounded,
                        label: 'Trim',
                        iconColor: const Color(0xFFFF2A85),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Drag left and right handles on the timeline strip above to trim.'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      _buildToolButton(
                        icon: Icons.music_note_rounded,
                        label: 'Music',
                        iconColor: const Color(0xFF00E5FF),
                        badge: _state.selectedMusicTitle != null ? 'ON' : null,
                        onTap: _openMusic,
                      ),
                      _buildToolButton(
                        icon: Icons.title_rounded,
                        label: 'Text',
                        iconColor: const Color(0xFFFFD700),
                        badge: _activeText != null ? '✓' : null,
                        onTap: _openTextDialog,
                      ),
                      _buildToolButton(
                        icon: Icons.sentiment_satisfied_alt_rounded,
                        label: 'Stickers',
                        iconColor: const Color(0xFFFF8F00),
                        badge: _activeSticker,
                        onTap: _openStickersSheet,
                      ),
                      _buildToolButton(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Effects',
                        iconColor: const Color(0xFF9D4EDD),
                        badge: _activeEffect != null ? 'ON' : null,
                        onTap: _openEffectsSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Row 2: Filters, Adjust, Volume, Voice-over, Speed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildToolButton(
                        icon: Icons.palette_outlined,
                        label: 'Filters',
                        iconColor: const Color(0xFF00E676),
                        onTap: _openFiltersSheet,
                      ),
                      _buildToolButton(
                        icon: Icons.tune_rounded,
                        label: 'Adjust',
                        iconColor: const Color(0xFF40C4FF),
                        onTap: _openAdjustDialog,
                      ),
                      _buildToolButton(
                        icon: Icons.volume_up_rounded,
                        label: 'Volume',
                        iconColor: const Color(0xFFFFD700),
                        onTap: _openMusic,
                      ),
                      _buildToolButton(
                        icon: Icons.mic_rounded,
                        label: 'Voice-over',
                        iconColor: const Color(0xFFFF5252),
                        onTap: _openVoiceoverSheet,
                      ),
                      _buildToolButton(
                        icon: Icons.speed_rounded,
                        label: 'Speed',
                        iconColor: const Color(0xFFE040FB),
                        badge: '${_state.playbackSpeed}x',
                        onTap: _openSpeedSelector,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    String? badge,
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
              color: const Color(0x441E1A3C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: badge != null ? iconColor : Colors.white12,
                width: badge != null ? 1.4 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: iconColor, size: 21),
                if (badge != null)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2A85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
