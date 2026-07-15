import '../../data/models/vendor_analytics_model.dart';

enum AnalyticsPeriod {
  week('7d', '7D'),
  month('30d', '30D'),
  quarter('90d', '90D');

  final String query;
  final String label;

  const AnalyticsPeriod(this.query, this.label);
}

sealed class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  final AnalyticsPeriod period;

  const AnalyticsLoading(this.period);
}

class AnalyticsLoaded extends AnalyticsState {
  final VendorAnalytics analytics;
  final AnalyticsPeriod period;

  /// True while a period switch or pull-refresh is in flight — the previous
  /// data stays on screen (dimmed) instead of flashing a loader.
  final bool refreshing;

  const AnalyticsLoaded({
    required this.analytics,
    required this.period,
    this.refreshing = false,
  });

  AnalyticsLoaded copyWith({
    VendorAnalytics? analytics,
    AnalyticsPeriod? period,
    bool? refreshing,
  }) {
    return AnalyticsLoaded(
      analytics: analytics ?? this.analytics,
      period: period ?? this.period,
      refreshing: refreshing ?? this.refreshing,
    );
  }
}

class AnalyticsError extends AnalyticsState {
  final String message;
  final AnalyticsPeriod period;

  const AnalyticsError(this.message, this.period);
}
