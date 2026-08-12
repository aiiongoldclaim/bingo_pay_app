import 'package:flutter/foundation.dart';

@immutable
class HomeBannerData {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imageAsset;

  const HomeBannerData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imageAsset,
  });
}

/// Local fallback banners. Jab banner API ready ho jaye, `HomeState` me
/// `List<HomeBannerData> banners` add karke wahan se feed kar dena —
/// widget layer me koi change nahi lagega.
class HomeBanners {
  const HomeBanners._();

  static const String _dir = 'assets/images/banners';

  static const List<HomeBannerData> defaults = [
    HomeBannerData(
      eyebrow: 'New Season',
      title: 'YOUR STYLE,\nYOUR VAULT',
      subtitle: 'Explore latest fashion\nCurated for you',
      ctaLabel: 'Shop Now',
      imageAsset: 'assets/images/banner3.png',
    ),
    HomeBannerData(
      eyebrow: 'Festive Edit',
      title: 'UP TO 60% OFF\nON EVERYTHING',
      subtitle: 'Limited period offer\nGrab them fast',
      ctaLabel: 'Shop the Sale',
      imageAsset: 'assets/images/banner5.png',
    ),
    HomeBannerData(
      eyebrow: 'Just Dropped',
      title: 'FRESH ARRIVALS\nEVERY WEEK',
      subtitle: 'Handpicked pieces\nfrom top brands',
      ctaLabel: 'Explore Now',
      imageAsset: 'assets/images/banner6.png',
    ),
    HomeBannerData(
      eyebrow: 'Members Only',
      title: 'EXTRA 10% OFF\nFIRST ORDER',
      subtitle: 'Sign up today and\nunlock your reward',
      ctaLabel: 'Claim Offer',
      imageAsset: 'assets/images/banner7.png',
    ),
  ];
}
