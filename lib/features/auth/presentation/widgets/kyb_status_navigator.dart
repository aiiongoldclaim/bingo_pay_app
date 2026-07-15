import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/helpers/dialog_helper.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/entities/user_entity.dart';

/// Routes a freshly-authenticated vendor based on their KYB status.
///
/// Only an approved vendor reaches the dashboard. Every other status shows
/// a status dialog first (except `none`, which has nothing to explain yet)
/// before landing on the KYC form or back at login.
Future<void> handlePostAuthKybNavigation(
  BuildContext context,
  UserEntity user,
) async {
  final status = kybStatusFromString(user.effectiveKybStatus);

  switch (status) {
    case KybStatus.approved:
      context.go(AppRoutes.vendorHome);
    case KybStatus.none:
      context.go(AppRoutes.registerKyc);
    case KybStatus.inProgress:
      await DialogHelper.showInfo(
        context: context,
        title: 'KYC Under Review',
        message:
            'Your KYC is pending review. It will take 24-48 hours to process.',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.login);
    case KybStatus.rejected:
      await DialogHelper.showError(
        context: context,
        title: 'KYC Rejected',
        message: 'Your KYC was rejected. Please resubmit your documents.',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.registerKyc);
    case KybStatus.recheck:
      await DialogHelper.showError(
        context: context,
        title: 'KYC Recheck Required',
        message:
            'Your KYC documents need to be rechecked. Please resubmit your documents.',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.registerKyc);
    case KybStatus.expired:
      await DialogHelper.showError(
        context: context,
        title: 'KYC Expired',
        message: 'Your KYC has expired. Please resubmit your documents.',
      );
      if (!context.mounted) return;
      context.go(AppRoutes.registerKyc);
  }
}
