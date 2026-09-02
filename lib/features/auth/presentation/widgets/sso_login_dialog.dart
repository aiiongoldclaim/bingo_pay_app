import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SsoLoginDialog extends StatelessWidget {
  final String email;
  final VoidCallback onSendOtp;
  final VoidCallback onUseDifferentEmail;

  const SsoLoginDialog({
    super.key,
    required this.email,
    required this.onSendOtp,
    required this.onUseDifferentEmail,
  });

  static Future<void> show(
      BuildContext context, {
        required String email,
        required VoidCallback onSendOtp,
        required VoidCallback onUseDifferentEmail,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.colors.scrim,
      builder: (_) => SsoLoginDialog(
        email: email,
        onSendOtp: onSendOtp,
        onUseDifferentEmail: onUseDifferentEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _DialogMetrics.get();
    final colors = context.colors;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is SsoOtpRequired,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) {
        final isSending = state is SsoOtpSending;

        return PopScope(
          canPop: !isSending,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: metrics.insetH,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: metrics.maxWidth),
              child: SingleChildScrollView(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
                    border: Border.all(color: colors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: colors.dialogShadow,
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(
                        metrics: metrics,
                        onClose: isSending ? null : onUseDifferentEmail,
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          metrics.padH,
                          metrics.padTop,
                          metrics.padH,
                          metrics.padBottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back!',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontSize: metrics.titleFont,
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            SizedBox(height: metrics.gapSm),

                            Text.rich(
                              textAlign: TextAlign.center,
                              TextSpan(
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: metrics.bodyFont,
                                  color: colors.textSecondary,
                                  height: 1.55,
                                ),
                                children: [
                                  const TextSpan(text: 'An account for '),
                                  TextSpan(
                                    text: email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: colors.brand,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                    ' already exists with BinGold. Verify with a one-time code to sign in securely.',
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: metrics.gapLg),

                            AppButton(
                              label: 'Send OTP to Sign In',
                              prefixIcon: Icons.mark_email_read_rounded,
                              isLoading: isSending,
                              onPressed: isSending ? null : onSendOtp,
                              variant: AppButtonVariant.primary,
                            ),

                            SizedBox(height: metrics.gapSm),

                            AppButton(
                              label: 'Use a different email',
                              onPressed:
                              isSending ? null : onUseDifferentEmail,
                              variant: AppButtonVariant.outlined,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final _DialogMetrics metrics;
  final VoidCallback? onClose;

  const _Header({required this.metrics, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        metrics.padH * 0.7,
        metrics.gapMd,
        metrics.padH * 0.7,
        metrics.gapMd,
      ),
      decoration: BoxDecoration(gradient: colors.heroBanner),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.heroBannerOverlay,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.heroBannerOverlay),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: metrics.closeIcon,
                  color: colors.onHeroBanner,
                ),
              ),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: metrics.badgeBox,
                height: metrics.badgeBox,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.heroBannerOverlay,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onHeroBanner.withValues(alpha: 0.30),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: colors.onHeroBanner,
                  size: metrics.badgeBox * 0.46,
                ),
              ),

              SizedBox(height: metrics.gapSm),

              Text(
                'BINGOLD SSO',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: metrics.labelFont,
                  letterSpacing: 1.6,
                  color: colors.onHeroBanner.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogMetrics {
  const _DialogMetrics({
    required this.maxWidth,
    required this.insetH,
    required this.padH,
    required this.padTop,
    required this.padBottom,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.titleFont,
    required this.bodyFont,
    required this.labelFont,
    required this.buttonFont,
    required this.buttonHeight,
    required this.buttonIcon,
    required this.badgeBox,
    required this.closeIcon,
    required this.loaderSize,
  });

  final double maxWidth;
  final double insetH;
  final double padH;
  final double padTop;
  final double padBottom;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double titleFont;
  final double bodyFont;
  final double labelFont;
  final double buttonFont;
  final double buttonHeight;
  final double buttonIcon;
  final double badgeBox;
  final double closeIcon;
  final double loaderSize;

  factory _DialogMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _DialogMetrics(
        maxWidth: 480,
        insetH: 40,
        padH: 32,
        padTop: 26,
        padBottom: 26,
        gapSm: 12,
        gapMd: 14,
        gapLg: 26,
        titleFont: 24,
        bodyFont: 15,
        labelFont: 14,
        buttonFont: 16,
        buttonHeight: 54,
        buttonIcon: 20,
        badgeBox: 60,
        closeIcon: 18,
        loaderSize: 22,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _DialogMetrics(
        maxWidth: 520,
        insetH: 48,
        padH: 34,
        padTop: 28,
        padBottom: 28,
        gapSm: 13,
        gapMd: 16,
        gapLg: 28,
        titleFont: 26,
        bodyFont: 16,
        labelFont: 15,
        buttonFont: 17,
        buttonHeight: 58,
        buttonIcon: 21,
        badgeBox: 66,
        closeIcon: 19,
        loaderSize: 24,
      );
    }

    return const _DialogMetrics(
      maxWidth: 420,
      insetH: 24,
      padH: 24,
      padTop: 22,
      padBottom: 22,
      gapSm: 11,
      gapMd: 13,
      gapLg: 24,
      titleFont: 22,
      bodyFont: 14,
      labelFont: 13,
      buttonFont: 15,
      buttonHeight: 54,
      buttonIcon: 19,
      badgeBox: 56,
      closeIcon: 17,
      loaderSize: 22,
    );
  }
}