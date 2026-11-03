import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/home/presentation/widgets/home_banner_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the website paths to app routes', () {
    expect(bannerRoute('/products/p-1'), (
      location: AppRoutes.productDetails,
      extra: 'p-1',
    ));
    expect(bannerRoute('/products'), (
      location: AppRoutes.allProducts,
      extra: null,
    ));
    expect(bannerRoute('/products?category=c-1&categoryName=Gold%20Coins'), (
      location: AppRoutes.productListingPath('Gold Coins'),
      extra: 'c-1',
    ));
    // A category without its name can't open the listing screen.
    expect(bannerRoute('/products?category=gold'), (
      location: AppRoutes.allProducts,
      extra: null,
    ));
    expect(bannerRoute('/services/'), (
      location: AppRoutes.services,
      extra: null,
    ));
    expect(bannerRoute('/services/s-1'), (
      location: AppRoutes.serviceDetailPath('s-1'),
      extra: null,
    ));
    expect(bannerRoute('/auctions/a-1'), (
      location: AppRoutes.auctionScreen,
      extra: null,
    ));
    expect(bannerRoute('/membership'), (
      location: AppRoutes.membership,
      extra: null,
    ));
    expect(bannerRoute('/cart'), (location: AppRoutes.cart, extra: null));
  });

  test('full URLs and unknown pages are not in-app', () {
    expect(bannerRoute('https://example.com/products/p-1'), isNull);
    expect(bannerRoute('/luxe'), isNull);
    expect(bannerRoute('/'), isNull);
  });
}
