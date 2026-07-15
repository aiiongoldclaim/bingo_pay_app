import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/error/error_messages.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit() : super(const AnalyticsInitial());

  Future<void> load([AnalyticsPeriod period = AnalyticsPeriod.month]) async {
    final current = state;
    if (current is AnalyticsLoaded) {
      emit(current.copyWith(period: period, refreshing: true));
    } else {
      emit(AnalyticsLoading(period));
    }

    try {
      final analytics = await GetIt.I<AnalyticsRemoteDataSource>()
          .getAnalytics(period: period.query);
      emit(AnalyticsLoaded(analytics: analytics, period: period));
    } catch (e) {
      emit(AnalyticsError(friendlyErrorMessage(e), period));
    }
  }
}
