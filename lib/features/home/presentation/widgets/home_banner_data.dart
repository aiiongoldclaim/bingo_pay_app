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
import 'package:flutter/widgets.dart';

import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/models/home_banner_model.dart';

export '../../data/models/home_banner_model.dart';

extension HomeBannerImage on HomeBannerData {
  ImageProvider get image {
    final url = imageUrl;
    return url != null ? NetworkImage(url) : AssetImage(imageAsset);
  }
}

/// Where a banner link opens inside the app, using the website's paths: a
/// go_router location and its `extra`. Null when it is a full URL or a page
/// the app doesn't have.
({String location, Object? extra})? bannerRoute(String link) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.hasScheme) return null;
  final q = uri.queryParameters;
  return switch (uri.pathSegments.where((s) => s.isNotEmpty).toList()) {
    ['products'] when q['category'] != null && q['categoryName'] != null => (
      location: AppRoutes.productListingPath(q['categoryName']!),
      extra: q['category'],
    ),
    ['products'] => (location: AppRoutes.allProducts, extra: null),
    ['products', final uuid] => (
      location: AppRoutes.productDetails,
      extra: uuid,
    ),
    ['services'] => (location: AppRoutes.services, extra: null),
    ['services', final uuid] => (
      location: AppRoutes.serviceDetailPath(uuid),
      extra: null,
    ),
    ['auctions'] => (location: AppRoutes.auctionScreen, extra: null),
    ['membership'] => (location: AppRoutes.membership, extra: null),
    ['cart'] => (location: AppRoutes.cart, extra: null),
    _ => null,
  };
}

/// The auction of an `/auctions/:uuid` link. Its detail screen is pushed with
/// Navigator (it has no go_router route), so [bannerRoute] leaves it out.
String? bannerAuctionId(String link) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.hasScheme) return null;
  return switch (uri.pathSegments.where((s) => s.isNotEmpty).toList()) {
    ['auctions', final uuid] => uuid,
    _ => null,
  };
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

  static const List<HomeBannerData> ultraLuxe = [
    HomeBannerData(id: 'ultra_luxe_1', imageAsset: AppImages.ultraLuxeBanner1),
    HomeBannerData(id: 'ultra_luxe_2', imageAsset: AppImages.ultraLuxeBanner2),
    HomeBannerData(id: 'ultra_luxe_3', imageAsset: AppImages.ultraLuxeBanner3),
  ];
}
