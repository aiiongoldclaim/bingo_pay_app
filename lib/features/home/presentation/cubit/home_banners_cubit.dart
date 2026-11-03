import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasource/banner_remote_data_source.dart';
import '../widgets/home_banner_data.dart';

/// The home carousel's slides: the live API banners, or the bundled defaults
/// when there are none or the request fails. Empty until the first load.
///
/// One instance lives as long as one home screen view, so each banner's
/// impression is counted at most once per view.
@injectable
class HomeBannersCubit extends Cubit<List<HomeBannerData>> {
  HomeBannersCubit(this._source) : super(const []);

  final BannerRemoteDataSource _source;
  final Set<String> _viewed = {};

  Future<void> load() async {
    List<HomeBannerData> banners;
    try {
      banners = await _source.getHomeBanners();
    } catch (_) {
      banners = const [];
    }
    if (isClosed) return;
    emit(banners.isEmpty ? HomeBanners.defaults : banners);
  }

  /// A slide came into view.
  void viewed(HomeBannerData banner) {
    if (banner.isRemote && _viewed.add(banner.id)) {
      unawaited(_source.trackImpression(banner.id));
    }
  }

  void tapped(HomeBannerData banner) {
    if (banner.isRemote) unawaited(_source.trackClick(banner.id));
  }
}
