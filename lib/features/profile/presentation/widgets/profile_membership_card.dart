import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/image_constants.dart';

class ProfileMembershipCard extends StatelessWidget {
  const ProfileMembershipCard({super.key, required this.maxWidth, this.onTap});

  final double maxWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GestureDetector(
            onTap:
                onTap ??
                () {
                  context.push(AppRoutes.membership);
                },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.sp),
              child: Image.asset(
                AppImages.profileMembershipCard,
                width: double.infinity,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: colors.brandSoft,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.card_membership_outlined,
                      color: colors.brand,
                      size: 42,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
