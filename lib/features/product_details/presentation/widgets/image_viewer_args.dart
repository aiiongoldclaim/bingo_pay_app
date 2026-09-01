class ImageViewerArgs {
  final List<String> images;
  final int initialIndex;

  const ImageViewerArgs({
    required this.images,
    this.initialIndex = 0,
  });
}