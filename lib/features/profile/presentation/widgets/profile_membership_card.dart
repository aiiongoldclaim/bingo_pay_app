import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../membershipNew/data/models/member_ship_model.dart';
import 'profile_metrics.dart';

// The member's plan: its name, how long is left, and a bar of time remaining.
// Shown only to members, so `membership.subscription` is set.
class ProfileMembershipCard extends StatelessWidget {
  const ProfileMembershipCard({
    super.key,
    required this.metrics,
    required this.membership,
    required this.onTap,
  });

  final ProfileMetrics metrics;
  final MembershipModel membership;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = metrics;
    final sub = membership.subscription!;
    final gold = colors.auctionAccent;
    final radius = BorderRadius.circular(m.menuRadius);

    final days = sub.daysRemaining;
    final left = sub.isExpired
        ? 'Expired'
        : days == 0
        ? 'Ends today'
        : '$days ${days == 1 ? 'day' : 'days'} left';
    final until = sub.endAt == null
        ? ''
        : ' · Valid till ${DateFormat('d MMM y').format(sub.endAt!.toLocal())}';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
          child: Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: colors.border),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(
                padding: EdgeInsets.all(m.menuItemHPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: m.menuIconBox,
                          height: m.menuIconBox,
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            size: m.menuIconSize,
                            color: gold,
                          ),
                        ),
                        SizedBox(width: m.menuIconGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                membership.plan?.name ?? 'Membership',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: m.menuTitleSize,
                                ),
                              ),
                              SizedBox(height: m.gapXs * 0.5),
                              Text(
                                '$left$until',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: sub.isExpired
                                      ? colors.error
                                      : colors.textSecondary,
                                  fontFamily: 'Inter',
                                  fontSize: m.menuSubtitleSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: m.chevronSize + 6,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                    if (sub.totalDays > 0 && !sub.isExpired) ...[
                      SizedBox(height: m.gapSm * 1.2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 1 - sub.progress,
                          minHeight: 5,
                          backgroundColor: colors.surfaceAlt,
                          color: gold,
                          semanticsLabel: 'Time left on membership',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
