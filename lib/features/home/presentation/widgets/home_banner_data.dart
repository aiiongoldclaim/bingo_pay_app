// import 'package:flutter/foundation.dart';
//
// @immutable
// class HomeBannerData {
//   final String eyebrow;
//   final String title;
//   final String subtitle;
//   final String ctaLabel;
//   final String imageAsset;
//
//   const HomeBannerData({
//     required this.eyebrow,
//     required this.title,
//     required this.subtitle,
//     required this.ctaLabel,
//     required this.imageAsset,
//   });
// }
//
// class HomeBanners {
//   const HomeBanners._();
//
//
//   static const List<HomeBannerData> defaults = [
//     HomeBannerData(
//       eyebrow: 'New Season',
//       title: 'YOUR STYLE,\nYOUR VAULT',
//       subtitle: 'Explore latest fashion\nCurated for you',
//       ctaLabel: 'Shop Now',
//       imageAsset: 'assets/images/banner3.png',
//     ),
//     HomeBannerData(
//       eyebrow: 'Festive Edit',
//       title: 'UP TO 60% OFF\nON EVERYTHING',
//       subtitle: 'Limited period offer\nGrab them fast',
//       ctaLabel: 'Shop the Sale',
//       imageAsset: 'assets/images/banner5.png',
//     ),
//     HomeBannerData(
//       eyebrow: 'Just Dropped',
//       title: 'FRESH ARRIVALS\nEVERY WEEK',
//       subtitle: 'Handpicked pieces\nfrom top brands',
//       ctaLabel: 'Explore Now',
//       imageAsset: 'assets/images/banner6.png',
//     ),
//     HomeBannerData(
//       eyebrow: 'Members Only',
//       title: 'EXTRA 10% OFF\nFIRST ORDER',
//       subtitle: 'Sign up today and\nunlock your reward',
//       ctaLabel: 'Claim Offer',
//       imageAsset: 'assets/images/banner7.png',
//     ),
//   ];
// }
import 'package:flutter/foundation.dart';

@immutable
class HomeBannerData {
  final String imageAsset;

  /// Analytics / navigation ke liye identifier — text render nahi hota
  final String id;

  const HomeBannerData({required this.id, required this.imageAsset});
}

class HomeBanners {
  const HomeBanners._();

  static const String _dir = 'assets/images';

  static const List<HomeBannerData> defaults = [
    HomeBannerData(
      id: 'new_season',
      imageAsset: '$_dir/TheVaults_Banner_1.png',
    ),
    HomeBannerData(
      id: 'festive_sale',
      imageAsset: '$_dir/TheVaults_Banner_2.png',
    ),
    HomeBannerData(
      id: 'new_arrivals',
      imageAsset: '$_dir/TheVaults_Banner_3.png',
    ),
    HomeBannerData(
      id: 'member_offer',
      imageAsset: '$_dir/TheVaults_Banner_4.png',
    ),
  ];
}
