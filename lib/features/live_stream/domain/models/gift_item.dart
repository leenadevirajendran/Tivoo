class GiftItem {
  final String id;
  final String name;
  final String icon;
  final String? imageAssetPath;
  final int diamonds;

  const GiftItem({
    required this.id,
    required this.name,
    required this.icon,
    this.imageAssetPath,
    required this.diamonds,
  });
}
