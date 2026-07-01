import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.ink.withValues(alpha: 0.28),
              blurRadius: AppSizes.shadowBlurLg,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(onClose: onUseDifferentEmail),
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
                        fontSize: 12.5.sp,
                      ),
                      children: [
                        const TextSpan(
                          text: 'An account for ',
                        ),
                        TextSpan(
                          text: email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.ink,
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
                  _GoldButton(
                    label: 'Send OTP to Sign In',
                    icon: Icons.mark_email_read_rounded,
                    onTap: onSendOtp,
                  ),
                  SizedBox(height: .8.h),
                  TextButton(
                    onPressed: onUseDifferentEmail,
                    style: TextButton.styleFrom(
                      foregroundColor: ThemeColors.inkMid,
                    ),
                    child: const Text('Use a different email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 3.5.h, 4.w, 3.5.h),
      decoration: BoxDecoration(gradient: ThemeColors.goldGradient),
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
                  color: ThemeColors.white.withValues(alpha: 0.18),
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
                  color: ThemeColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColors.white.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: ThemeColors.white,
                  size: 28,
                ),
              ),
              SizedBox(height: 1.4.h),
              Text(
                'BinGold SSO',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 12.sp,
                  letterSpacing: 1.4,
                  color: ThemeColors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.2.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: ThemeColors.goldGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.accent.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: ThemeColors.white),
                SizedBox(width: 2.w),
                Text(
                  label,
                  style: AppTextStyles.buttonText.copyWith(fontSize: 14.5.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
