import 'package:flutter/material.dart';

import '../../../../core/constants/image_constants.dart';

class OnBoardingPerk {
  final IconData icon;
  final String label;

  const OnBoardingPerk(this.icon, this.label);
}

class OnBoardingContent {
  final String image;
  final String? imageDark;
  final String title;
  final String titleHighlight;

  final String titleSuffix;
  final String subTitle;

  final bool darkPage;

  final bool showBrand;

  final bool showMark;

  final IconData fallbackIcon;
  final List<OnBoardingPerk> perks;

  final String cta;

  const OnBoardingContent({
    required this.image,
    this.imageDark,
    required this.title,
    required this.titleHighlight,
    this.titleSuffix = '',
    required this.subTitle,
    this.darkPage = false,
    this.showBrand = false,
    this.showMark = false,
    this.fallbackIcon = Icons.diamond_outlined,
    this.perks = const [],
    this.cta = 'Next',
  });

  /// Picks the correct asset for the current theme.
  String imageFor(bool isDark) => isDark ? (imageDark ?? image) : image;

  static List<OnBoardingContent> contents = [
    const OnBoardingContent(
      image: AppImages.vaultOnboarding1,
      title: 'Explore\nTop Brands',
      titleHighlight: '',
      subTitle: 'Fashion, beauty, electronics\nand more — all in one place.',
      showMark: true,
      fallbackIcon: Icons.shopping_bag_outlined,
    ),
    const OnBoardingContent(
      image: AppImages.vaultOnboarding2,
      title: 'Exclusive',
      titleHighlight: 'Deals',
      titleSuffix: ' for You',
      subTitle:
          'Get member-only offers,\nseasonal sales and new arrivals.',
      darkPage: true,
      fallbackIcon: Icons.local_offer_outlined,
    ),
    const OnBoardingContent(
      image: AppImages.vaultOnboarding3,
      title: 'A Seamless\nShopping Experience',
      titleHighlight: '',
      subTitle: 'Secure payments, easy returns\nand premium products.',
      fallbackIcon: Icons.card_giftcard_outlined,
      perks: [
        OnBoardingPerk(Icons.lock_outline_rounded, 'Secure\nPayments'),
        OnBoardingPerk(Icons.inventory_2_outlined, 'Easy\nReturns'),
        OnBoardingPerk(Icons.verified_outlined, 'Genuine\nProducts'),
        OnBoardingPerk(Icons.local_shipping_outlined, 'Fast\nDelivery'),
      ],
      cta: 'Get Started',
    ),
  ];

}
