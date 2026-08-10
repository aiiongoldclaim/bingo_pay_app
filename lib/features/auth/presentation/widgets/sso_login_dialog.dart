import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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
      barrierColor: ThemeColors.black.withValues(alpha: 0.6),
      builder: (_) => SsoLoginDialog(
        email: email,
        onSendOtp: onSendOtp,
        onUseDifferentEmail: onUseDifferentEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _DialogMetrics.get();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? ThemeColors.surface2 : ThemeColors.white;
    final titleColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final bodyColor = isDark ? ThemeColors.inkDim : ThemeColors.inkMid;
    final accent = isDark ? ThemeColors.gold1 : ThemeColors.blue;

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
              horizontal: m.insetH,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.maxWidth),
              child: SingleChildScrollView(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
                    border: isDark
                        ? Border.all(
                            color: ThemeColors.white.withValues(alpha: 0.10),
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? ThemeColors.black.withValues(alpha: 0.5)
                            : ThemeColors.blueDeep.withValues(alpha: 0.3),
                        blurRadius: AppSizes.shadowBlurLg,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(
                        m: m,
                        onClose: isSending ? null : onUseDifferentEmail,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          m.padH,
                          m.padTop,
                          m.padH,
                          m.padBottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back!',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontSize: m.titleFont,
                                color: titleColor,
                              ),
                            ),
                            SizedBox(height: m.gapSm),
                            Text.rich(
                              TextSpan(
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: m.bodyFont,
                                  color: bodyColor,
                                ),
                                children: [
                                  const TextSpan(text: 'An account for '),
                                  TextSpan(
                                    text: email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: accent,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' already exists with BinGold. Verify with a '
                                        'one-time code to sign in securely.',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: m.gapLg),
                            _PrimaryButton(
                              m: m,
                              label: 'Send OTP to Sign In',
                              icon: Icons.mark_email_read_rounded,
                              isLoading: isSending,
                              onTap: isSending ? null : onSendOtp,
                            ),
                            SizedBox(height: m.gapSm),
                            _SecondaryButton(
                              m: m,
                              label: 'Use a different email',
                              onTap: isSending ? null : onUseDifferentEmail,
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
  final _DialogMetrics m;
  final VoidCallback? onClose;

  const _Header({required this.m, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        m.padH * 0.7,
        m.gapMd,
        m.padH * 0.7,
        m.gapMd,
      ),
      decoration: BoxDecoration(gradient: ThemeColors.primaryGradient),
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
                  color: ThemeColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: m.closeIcon,
                  color: ThemeColors.white,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.badgeBox,
                height: m.badgeBox,
                decoration: BoxDecoration(
                  color: ThemeColors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.verified_user_rounded,
                  color: ThemeColors.white,
                  size: m.badgeBox * 0.46,
                ),
              ),
              SizedBox(height: m.gapSm),
              Text(
                'BINGOLD SSO',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: m.labelFont,
                  letterSpacing: 1.6,
                  color: ThemeColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final _DialogMetrics m;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PrimaryButton({
    required this.m,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: m.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: ThemeColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.blue.withValues(alpha: 0.32),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: onTap,
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: m.loaderSize,
                      height: m.loaderSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(ThemeColors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: m.buttonIcon, color: ThemeColors.white),
                      SizedBox(width: m.gapSm * 0.6),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: m.buttonFont,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final _DialogMetrics m;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.m,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fill = isDark
        ? ThemeColors.white.withValues(alpha: 0.05)
        : ThemeColors.surface2;
    final border = isDark
        ? ThemeColors.white.withValues(alpha: 0.12)
        : ThemeColors.line;
    final textColor = isDark ? ThemeColors.white : ThemeColors.inkMid;

    return SizedBox(
      width: double.infinity,
      height: m.buttonHeight,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: m.buttonFont,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phone / tablet-portrait / tablet-landscape sizing.
/// Saari values REAL dp hain — Sizer `.sp` / `.h` / `.w` nahi.
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

    // phone
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
