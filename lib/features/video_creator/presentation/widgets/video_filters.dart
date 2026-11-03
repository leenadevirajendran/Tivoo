import 'package:flutter/material.dart';

class VideoFilterItem {
  final String id;
  final String name;
  final List<double> matrix;

  const VideoFilterItem({
    required this.id,
    required this.name,
    required this.matrix,
  });

  bool get isOriginal => id == 'original';

  /// Generates an interpolated ColorFilter based on user-selected intensity (0.0 to 1.0).
  ColorFilter? getColorFilter(double intensity) {
    if (isOriginal) return null;
    final clamped = intensity.clamp(0.0, 1.0);
    if (clamped <= 0.01) return null;

    final identity = VideoFilterRepository.identityMatrix;
    final blended = List<double>.generate(20, (i) {
      return identity[i] + (matrix[i] - identity[i]) * clamped;
    });

    return ColorFilter.matrix(blended);
  }
}

class VideoFilterRepository {
  VideoFilterRepository._();

  static const List<double> identityMatrix = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<VideoFilterItem> filters = [
    VideoFilterItem(
      id: 'original',
      name: 'Original',
      matrix: identityMatrix,
    ),
    VideoFilterItem(
      id: 'natural',
      name: 'Natural',
      matrix: [
        1.08, 0, 0, 0, 6,
        0, 1.05, 0, 0, 6,
        0, 0, 0.98, 0, 0,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'paris',
      name: 'Paris',
      matrix: [
        1.14, 0, 0, 0, 12,
        0, 1.04, 0, 0, 6,
        0, 0, 1.08, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'warm',
      name: 'Warm',
      matrix: [
        1.18, 0, 0, 0, 15,
        0, 1.08, 0, 0, 8,
        0, 0, 0.88, 0, -8,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'vintage',
      name: 'Vintage',
      matrix: [
        1.12, 0.05, 0, 0, 12,
        0.05, 0.95, 0, 0, 5,
        0, 0.05, 0.78, 0, -10,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'cool',
      name: 'Cool',
      matrix: [
        0.88, 0, 0, 0, -6,
        0, 1.04, 0, 0, 4,
        0, 0, 1.25, 0, 18,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'golden',
      name: 'Golden',
      matrix: [
        1.22, 0, 0, 0, 18,
        0, 1.12, 0, 0, 12,
        0, 0, 0.75, 0, -15,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'cinema',
      name: 'Cinema',
      matrix: [
        1.20, 0, 0, 0, 10,
        0, 1.02, 0, 0, 2,
        0, 0, 1.15, 0, 12,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'dreamy',
      name: 'Dreamy',
      matrix: [
        1.12, 0, 0.05, 0, 10,
        0, 0.98, 0.05, 0, 4,
        0.05, 0, 1.20, 0, 14,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'noir',
      name: 'Noir',
      matrix: [
        0.33, 0.59, 0.11, 0, 5,
        0.33, 0.59, 0.11, 0, 5,
        0.33, 0.59, 0.11, 0, 5,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'sunset',
      name: 'Sunset',
      matrix: [
        1.25, 0, 0, 0, 16,
        0, 0.92, 0, 0, 0,
        0, 0, 0.85, 0, -8,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'emerald',
      name: 'Emerald',
      matrix: [
        0.90, 0, 0, 0, -4,
        0, 1.20, 0, 0, 12,
        0, 0, 1.02, 0, 2,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'cyberpunk',
      name: 'Cyberpunk',
      matrix: [
        1.25, 0, 0.1, 0, 15,
        0, 0.85, 0.1, 0, -5,
        0.1, 0, 1.35, 0, 20,
        0, 0, 0, 1, 0,
      ],
    ),
    VideoFilterItem(
      id: 'blush',
      name: 'Blush',
      matrix: [
        1.15, 0, 0, 0, 14,
        0, 1.06, 0, 0, 8,
        0, 0, 1.02, 0, 4,
        0, 0, 0, 1, 0,
      ],
    ),
  ];
}

