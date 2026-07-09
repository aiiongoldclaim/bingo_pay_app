import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Premium confirmation dialog shown when the entered email belongs to an
/// existing BinGold account with no local password — the user must verify
/// via OTP to sign in, or switch to a different email to register.
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
      barrierColor: ThemeColors.ink.withValues(alpha: 0.55),
      builder: (_) => SsoLoginDialog(
        email: email,
        onSendOtp: onSendOtp,
        onUseDifferentEmail: onUseDifferentEmail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is SsoOtpRequired,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) {
        final isSending = state is SsoOtpSending;
        return PopScope(
          canPop: !isSending,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: ThemeColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.blueDeep.withValues(alpha: 0.3),
                    blurRadius: AppSizes.shadowBlurLg,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(onClose: isSending ? null : onUseDifferentEmail),
                  Padding(
                    padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome back!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 19.sp,
                          ),
                        ),
                        SizedBox(height: 1.2.h),
                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.5.sp,
                            ),
                            children: [
                              const TextSpan(
                                text: 'An account for ',
                              ),
                              TextSpan(
                                text: email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.blue,
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
                        SizedBox(height: 3.h),
                        _PrimaryButton(
                          label: 'Send OTP to Sign In',
                          icon: Icons.mark_email_read_rounded,
                          isLoading: isSending,
                          onTap: isSending ? null : onSendOtp,
                        ),
                        SizedBox(height: 1.2.h),
                        _SecondaryButton(
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
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
      decoration: BoxDecoration(gradient: ThemeColors.primaryGradient),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: ThemeColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: ThemeColors.white,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ThemeColors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColors.white.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: ThemeColors.white,
                  size: 26,
                ),
              ),
              SizedBox(height: 1.4.h),
              Text(
                'BINGOLD SSO',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 14.5.sp,
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
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.2.h,
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
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: ThemeColors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18, color: ThemeColors.white),
                      SizedBox(width: 2.w),
                      Text(
                        label,
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: 14.5.sp,
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
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.2.h,
      child: Material(
        color: ThemeColors.surface2,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: ThemeColors.line),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: ThemeColors.inkMid,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
