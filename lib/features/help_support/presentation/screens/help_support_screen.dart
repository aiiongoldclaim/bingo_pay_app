import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../chat/presentation/widgets/support_chat_fab.dart';
import '../widgets/help_metrics.dart';
import '../widgets/raise_ticket_sheet.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: 'Help & Support',
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.profile),
      ),
      floatingActionButton: SupportChatFab(
        onTap: () => context.push(AppRoutes.chatSession),
      ),
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final m = HelpMetrics.of(context);

            final hero = _HeroCard(metrics: m);

            final supportTiles = _SupportTiles(
              metrics: m,
              onContact: () => RaiseTicketSheet.show(context),
              onChat: () => context.push(AppRoutes.chatSession),
              onMyTicket: () => context.push(AppRoutes.myTickets),
            );

            final footer = _FooterNote(metrics: m);

            return  ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                child: m.isLandscape
                    ? _LandscapeBody(
                        metrics: m,
                        hero: hero,
                        supportTiles: supportTiles,
                        footer: footer,
                      )
                    : _PortraitBody(
                        metrics: m,
                        hero: hero,
                        supportTiles: supportTiles,
                        footer: footer,
                      ),
              );
            
          },
        ),
      ),
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final HelpMetrics metrics;
  final Widget hero;
  final Widget supportTiles;
  final Widget footer;

  const _PortraitBody({
    required this.metrics,
    required this.hero,
    required this.supportTiles,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hero,
          SizedBox(height: m.gapLg),
          _SectionHeading(metrics: m, title: 'Still Need Help?'),
          SizedBox(height: m.gapMd),
          supportTiles,
          SizedBox(height: m.gapLg),
          footer,
        ],
      ),
    );
  }
}

// ── Landscape ────────────────────────────────────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final HelpMetrics metrics;
  final Widget hero;
  final Widget supportTiles;
  final Widget footer;

  const _LandscapeBody({
    required this.metrics,
    required this.hero,
    required this.supportTiles,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          hero,
          SizedBox(height: m.gapLg),
          _SectionHeading(metrics: m, title: 'Still Need Help?'),
          SizedBox(height: m.gapMd),
          supportTiles,
          SizedBox(height: m.gapLg),
          footer,
        ],
      ),
    );
  }
}

// ── Section heading ────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final HelpMetrics metrics;
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeading({
    required this.metrics,
    required this.title,
  }) : onViewAll = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'CormorantGaramond',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.gapXs,
                vertical: m.gapXs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: colors.brand,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.linkSize,
                    ),
                  ),
                  SizedBox(width: m.gapXs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: m.linkSize + 6,
                    color: colors.brand,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Hero card ──────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final HelpMetrics metrics;

  const _HeroCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.heroPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.heroRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Need Help?\nWe're here for you!",
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.heroTitleSize,
                    height: 1.25,
                  ),
                ),

                SizedBox(height: m.gapMd),

                Text(
                  'Find quick solutions to common issues or connect with our support team.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.heroBodySize,
                    height: 1.5,
                  ),
                ),

              ],
            ),
          ),

          SizedBox(width: m.gapSm),

          _HeadsetArt(metrics: m),
        ],
      ),
    );
  }
}


class _HeadsetArt extends StatelessWidget {
  final HelpMetrics metrics;

  const _HeadsetArt({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return SizedBox(
      width: m.heroArtSize,
      height: m.heroArtSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: m.heroArtSize * 0.78,
            height: m.heroArtSize * 0.78,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.75),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: m.heroArtSize * 0.58,
            height: m.heroArtSize * 0.58,
            child: Image.asset(
              AppImages.help,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: m.heroArtSize * 0.08,
            right: m.heroArtSize * 0.06,
            child: Icon(
              Icons.auto_awesome,
              size: m.heroArtSize * 0.13,
              color: colors.brand.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            bottom: m.heroArtSize * 0.10,
            left: m.heroArtSize * 0.04,
            child: Icon(
              Icons.auto_awesome,
              size: m.heroArtSize * 0.10,
              color: colors.brand.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Support tiles: Chat / Email / Call ─────────────────────────────────────
class _SupportTiles extends StatelessWidget {
  final HelpMetrics metrics;
  final VoidCallback onContact;
  final VoidCallback onChat;
  final VoidCallback onMyTicket;

  const _SupportTiles({
    required this.metrics,
    required this.onContact,
    required this.onChat,
    required this.onMyTicket,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SupportTile(
          metrics: m,
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat with Us',
          subtitle: 'Get instant support',
          onTap: onChat,
        ),
        SizedBox(height: m.tileGap),
        _SupportTile(
          metrics: m,
          icon: Icons.support_agent_rounded,
          title: 'Contact Support',
          subtitle: 'Raise a support ticket',
          onTap: onContact,
        ),
        SizedBox(height: m.tileGap),
        _SupportTile(
          metrics: m,
          icon: Icons.confirmation_num_outlined,
          title: 'My Ticket',
          subtitle: 'Track your requests',
          onTap: onMyTicket,
        ),
      ],
    );
  }
}

class _SupportTile extends StatelessWidget {
  final HelpMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SupportTile({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(m.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: m.tilePad * 0.8,
            vertical: m.tilePad * 0.75,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.tileRadius),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: m.tileIconBox,
                height: m.tileIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.tileIconSize, color: colors.brand),
              ),

              SizedBox(width: m.gapMd),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.tileTitleSize,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.tileSubSize,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              Icon(
                Icons.chevron_right_rounded,
                size: m.tileIconSize * 0.8,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Footer note ────────────────────────────────────────────────────────────
class _FooterNote extends StatelessWidget {
  final HelpMetrics metrics;

  const _FooterNote({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.footerPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(m.footerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: m.footerIconBox,
            height: m.footerIconBox,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.verified_user_outlined,
              size: m.footerIconSize,
              color: colors.brand,
            ),
          ),

          SizedBox(width: m.footerPad * 0.7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Satisfaction is Important',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.footerTitleSize,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: m.gapXs),

                Text(
                  'We are committed to providing the best experience.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.footerBodySize,
                    height: 1.45,
                  ),
                ),

                SizedBox(height: m.gapXs * 0.6),

                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.footerBodySize,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'Thank you for shopping with '),
                      TextSpan(
                        text: 'TheVaults.',
                        style: TextStyle(
                          color: colors.brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}