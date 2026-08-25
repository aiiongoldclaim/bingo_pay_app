import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';

import '../../../../core/constants/image_constants.dart';


class AccountMembershipCard extends StatelessWidget {
  const AccountMembershipCard({
    super.key,
    required this.maxWidth,
    this.onTap,
  });

  final double maxWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: GestureDetector(
            onTap: onTap ??
                    () {
                  context.push(
                    AppRoutes.membership,
                  );
                },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: c.textPrimary
                        .withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 2.55,
                  child: Image.asset(
                    AppImages.membershipProfileCard,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: c.brandSoft,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons
                              .card_membership_outlined,
                          color: c.brand,
                          size: 42,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}