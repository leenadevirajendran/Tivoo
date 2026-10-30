import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';

class CoverPickerDialog extends StatefulWidget {
  final File? currentCover;
  final Duration videoDuration;
  final ValueChanged<File> onCoverSelected;

  const CoverPickerDialog({
    super.key,
    this.currentCover,
    required this.videoDuration,
    required this.onCoverSelected,
  });

  static Future<void> show(
    BuildContext context, {
    File? currentCover,
    required Duration videoDuration,
    required ValueChanged<File> onCoverSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CoverPickerDialog(
        currentCover: currentCover,
        videoDuration: videoDuration,
        onCoverSelected: onCoverSelected,
      ),
    );
  }

  @override
  State<CoverPickerDialog> createState() => _CoverPickerDialogState();
}

class _CoverPickerDialogState extends State<CoverPickerDialog> {
  File? _selectedFile;

  static const List<String> _sampleFrames = [
    AppAssets.status1,
    AppAssets.status2,
    AppAssets.status3,
    AppAssets.status4,
    AppAssets.status5,
    AppAssets.avatarDiya,
    AppAssets.avatarSneha,
    AppAssets.avatarPriya,
  ];

  late int _selectedFrameIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.currentCover;
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (img != null) {
        final f = File(img.path);
        setState(() => _selectedFile = f);
        widget.onCoverSelected(f);
        if (mounted) Navigator.of(context).pop();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.75),
      padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + mq.padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF131526),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x3300E5FF), width: 1.2)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 28, offset: Offset(0, -6)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Video Cover',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedFile != null) widget.onCoverSelected(_selectedFile!);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save', style: TextStyle(color: LuxeColors.gold, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cover Preview Box
            Container(
              width: 140,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF2A85), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FF2A85), blurRadius: 14, spreadRadius: 1),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _selectedFile != null
                    ? Image.file(_selectedFile!, fit: BoxFit.cover)
                    : Image.asset(_sampleFrames[_selectedFrameIndex], fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a frame from your video',
              style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Frame filmstrip
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _sampleFrames.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSelected = _selectedFile == null && _selectedFrameIndex == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFile = null;
                        _selectedFrameIndex = i;
                      });
                    },
                    child: Container(
                      width: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF2A85) : Colors.white24,
                          width: isSelected ? 2.2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(_sampleFrames[i], fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined, color: LuxeColors.gold, size: 18),
              label: const Text('Upload Cover from Gallery', style: TextStyle(color: Colors.white, fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
