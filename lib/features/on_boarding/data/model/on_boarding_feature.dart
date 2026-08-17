import '../../../../core/constants/image_constants.dart';

class OnBoardingContent {
  final String image;
  final String? imageDark;
  final String title;
  final String titleHighlight;
  final String subTitle;

  const OnBoardingContent({
    required this.image,
    this.imageDark,
    required this.title,
    required this.titleHighlight,
    required this.subTitle,
  });

  /// theme ke hisaab se sahi asset
  String imageFor(bool isDark) => isDark ? (imageDark ?? image) : image;

  static List<OnBoardingContent> contents = [
    OnBoardingContent(
      image: AppImages.onboard1,
      imageDark: AppImages.onboard1Dark,
      titleHighlight: 'In One App',
      title: 'Everything You Need',
      subTitle:
          'Shop products, book services and manage\nyour payments — all from a single place.',
    ),
    OnBoardingContent(
      image: AppImages.onboard2,
      imageDark: AppImages.onboard2Dark,
      title: 'Fast. Easy. Secure',
      titleHighlight: 'Payments',
      subTitle:
          'Book services, shop, pay bills or\nsend money instantly with\nenterprise-grade security.',
    ),
    OnBoardingContent(
      image: AppImages.onboard3,
      imageDark: AppImages.onboard3Dark,
      titleHighlight: 'Favorites',
      title: 'Shop Your',
      subTitle:
          'Explore a wide range of products, exclusive deals and secure checkout all in one place.',
    ),
  ];
}
