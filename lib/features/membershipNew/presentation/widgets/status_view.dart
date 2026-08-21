import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'membership_metrices.dart';

// ---------------------------------------------------------------------------
// loading skeleton
// ---------------------------------------------------------------------------

class MembershipLoadingView extends StatefulWidget {
  const MembershipLoadingView({super.key, required this.metrics});

  final MembershipMetrics metrics;

  @override
  State<MembershipLoadingView> createState() => _MembershipLoadingViewState();
}

class _MembershipLoadingViewState extends State<MembershipLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(m.hPad, m.vPad, m.hPad, m.sectionGap),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxContentWidth),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Block(height: m.iconBox * 3.2, radius: m.radiusLg),
                SizedBox(height: m.sectionGap),
                _Block(height: m.sectionTitleSize * 1.4, radius: m.radiusSm),
                SizedBox(height: m.tileGap),
                _Block(height: m.iconBox * 4.6, radius: m.radiusMd),
                SizedBox(height: m.sectionGap),
                _Block(height: m.sectionTitleSize * 1.4, radius: m.radiusSm),
                SizedBox(height: m.tileGap),
                for (var i = 0; i < 4; i++) ...[
                  _Block(height: m.iconBox * 1.7, radius: m.radiusMd),
                  SizedBox(height: m.tileGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// error
// ---------------------------------------------------------------------------

class MembershipErrorView extends StatelessWidget {
  const MembershipErrorView({
    super.key,
    required this.metrics,
    required this.message,
    required this.onRetry,
  });

  final MembershipMetrics metrics;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: m.hPad, vertical: m.vPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.iconBox * 1.7,
              height: m.iconBox * 1.7,
              decoration: BoxDecoration(
                color: c.statusWarningSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_tethering_error_rounded,
                size: m.iconSize * 1.5,
                color: c.statusWarning,
              ),
            ),
            SizedBox(height: m.rowGap),
            Text(
              'Could not load membership',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: m.sectionTitleSize,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            SizedBox(height: m.rowGap * 0.4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: m.sectionGap),
            SizedBox(
              width: m.isTablet ? m.iconBox * 5 : double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: m.badgeIcon),
                label: Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: m.labelSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// no membership
// ---------------------------------------------------------------------------

class MembershipEmptyView extends StatelessWidget {
  const MembershipEmptyView({super.key, required this.metrics});

  final MembershipMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height * 0.62,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: m.iconBox * 2,
            height: m.iconBox * 2,
            decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
            child: Icon(
              Icons.workspace_premium_outlined,
              size: m.iconSize * 1.8,
              color: c.brand,
            ),
          ),
          SizedBox(height: m.rowGap),
          Text(
            'No active membership',
            style: TextStyle(
              fontSize: m.sectionTitleSize,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: m.rowGap * 0.4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: Text(
              'You are not subscribed to any plan right now. Membership unlocks member discounts, early access and exclusive products.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: m.labelSize,
                fontWeight: FontWeight.w500,
                color: c.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}