import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/home_banner_model.dart';

/// Storefront banners (public, no login needed) and their view/click counts.
@lazySingleton
class BannerRemoteDataSource {
  BannerRemoteDataSource(this._client);

  final ApiClient _client;

  /// The live home banners for phones, highest priority first.
  Future<List<HomeBannerData>> getHomeBanners() async {
    final response = await _client.dio.get(
      ApiEndpoints.banners,
      queryParameters: const {'placement': 'HOME', 'device': 'MOBILE'},
    );
    // { success, data: [...] }; tolerate a second { data: [...] } wrap.
    var list = (response.data as Map?)?['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return const [];
    return list
        .whereType<Map>()
        .map(HomeBannerData.fromJson)
        .whereType<HomeBannerData>()
        .toList();
  }

  Future<void> trackImpression(String uuid) =>
      _track(ApiEndpoints.bannerImpression(uuid));

  Future<void> trackClick(String uuid) => _track(ApiEndpoints.bannerClick(uuid));

  // A lost count must never reach the user.
  Future<void> _track(String path) async {
    try {
      await _client.dio.post(path);
    } catch (_) {}
  }
}
