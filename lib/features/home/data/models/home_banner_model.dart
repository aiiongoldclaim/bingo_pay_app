import 'package:flutter/foundation.dart';

/// One home carousel slide: a bundled asset (the fallback set) or a live
/// banner from GET /banners, which has [imageUrl] and is the only kind whose
/// views and taps are counted.
@immutable
class HomeBannerData {
  /// The banner's uuid for API banners.
  final String id;
  final String imageAsset;
  final String? imageUrl;

  /// The banner's ctaUrl: an app path ("/products/…") or a full URL.
  final String? link;

  const HomeBannerData({
    required this.id,
    this.imageAsset = '',
    this.imageUrl,
    this.link,
  });

  bool get isRemote => imageUrl != null;

  /// A public banner; null when it has no artwork to show.
  // shortcut: text-only banners (no image) are skipped, render title/description if marketing starts using them.
  static HomeBannerData? fromJson(Map json) {
    final uuid = _text(json['uuid']);
    final image = _text(json['mobileImageUrl']) ?? _text(json['imageUrl']);
    if (uuid == null || image == null) return null;
    return HomeBannerData(id: uuid, imageUrl: image, link: _text(json['ctaUrl']));
  }
}

String? _text(Object? value) {
  final s = value?.toString().trim() ?? '';
  return s.isEmpty ? null : s;
}
