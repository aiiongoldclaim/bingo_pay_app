import 'package:flutter/material.dart';
import '../error/failures.dart';
import 'app_error_widget.dart';
import 'rate_limit_error_widget.dart';

extension ErrorWidgetBuilder on Failure {
  Widget buildErrorWidget({
    VoidCallback? onRetry,
    bool fullScreen = true,
  }) {
    if (this is RateLimitFailure) {
      return RateLimitErrorWidget(
        failure: this as RateLimitFailure,
        onRetry: onRetry,
        fullScreen: fullScreen,
      );
    }

    return AppErrorWidget(
      failure: this,
      onRetry: onRetry,
    );
  }
}
