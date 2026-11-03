import 'package:bingo_pay/features/home/data/models/home_banner_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prefers the mobile image and keeps the link', () {
    final b = HomeBannerData.fromJson({
      'uuid': 'b-1',
      'imageUrl': 'https://cdn/desktop.png',
      'mobileImageUrl': 'https://cdn/mobile.png',
      'ctaUrl': ' /products/p-1 ',
    })!;

    expect(b.id, 'b-1');
    expect(b.imageUrl, 'https://cdn/mobile.png');
    expect(b.link, '/products/p-1');
    expect(b.isRemote, isTrue);
  });

  test('falls back to the desktop image; blank link is no link', () {
    final b = HomeBannerData.fromJson({
      'uuid': 'b-1',
      'imageUrl': 'https://cdn/desktop.png',
      'mobileImageUrl': '',
      'ctaUrl': null,
    })!;

    expect(b.imageUrl, 'https://cdn/desktop.png');
    expect(b.link, isNull);
  });

  test('skips a banner with no image or no uuid', () {
    expect(HomeBannerData.fromJson({'uuid': 'b-1', 'title': 'Sale'}), isNull);
    expect(HomeBannerData.fromJson({'imageUrl': 'https://cdn/x.png'}), isNull);
  });

  test('bundled defaults are not remote', () {
    expect(
      const HomeBannerData(id: 'x', imageAsset: 'assets/a.png').isRemote,
      isFalse,
    );
  });
}
