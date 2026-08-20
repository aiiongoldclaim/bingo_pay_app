import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/help_metrics.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'support@bingosg.com';

  static const List<_Faq> _faqs = [
    _Faq(
      question: 'How do I reset my password?',
      answer:
      'Go to the login screen and tap "Forgot Password". Enter your '
          'registered email and follow the instructions sent to you to '
          'reset your password.',
    ),
    _Faq(
      question: 'How can I track my order?',
      answer:
      'Open the Account tab and select "Transactions" to view the '
          'status of all your recent orders and payments.',
    ),
    _Faq(
      question: 'How do I add or update my payment method?',
      answer:
      'Payment methods can be managed from the Account section under '
          '"Payment Methods". You can add, remove, or set a default option.',
    ),
    _Faq(
      question: 'What should I do if a payment fails?',
      answer:
      'If a payment fails, any deducted amount is automatically refunded '
          'within 3-5 business days. If you don\'t see a refund, please '
          'contact our support team with your transaction details.',
    ),
    _Faq(
      question: 'How do I contact customer support?',
      answer:
      'You can reach us anytime at support@bingosg.com and our team '
          'will get back to you as soon as possible.',
    ),
  ];

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    AppSnackbar.showSuccess(context, 'Email address copied');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Builder(
          builder: (context) {
            final m = HelpMetrics.of(context);

            final hero = _HeroCard(
              metrics: m,
              onContact: () => _copyEmail(context),
            );

            final supportTiles = _SupportTiles(
              metrics: m,
              onEmail: () => _copyEmail(context),
            );

            final faqSection = _FaqSection(metrics: m, faqs: _faqs);

            final footer = _FooterNote(metrics: m);

            return Column(
              children: [
                _HelpTopBar(metrics: m),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                      child: m.isLandscape
                          ? _LandscapeBody(
                        metrics: m,
                        hero: hero,
                        supportTiles: supportTiles,
                        faqSection: faqSection,
                        footer: footer,
                      )
                          : _PortraitBody(
                        metrics: m,
                        hero: hero,
                        supportTiles: supportTiles,
                        faqSection: faqSection,
                        footer: footer,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _HelpTopBar extends StatelessWidget {
  final HelpMetrics metrics;

  const _HelpTopBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.4,
        m.pageHPad * 0.6,
        m.pageVPad * 0.4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoutes.account),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Help & Support',
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.bold,
                  fontSize: m.titleSize,
                  height: 1.2,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final HelpMetrics metrics;
  final Widget hero;
  final Widget supportTiles;
  final Widget faqSection;
  final Widget footer;

  const _PortraitBody({
    required this.metrics,
    required this.hero,
    required this.supportTiles,
    required this.faqSection,
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
          faqSection,
          SizedBox(height: m.gapLg),
          footer,
        ],
      ),
    );
  }
}

// ── Landscape: hero + tiles left, FAQ rail right ───────────────────────────
class _LandscapeBody extends StatelessWidget {
  final HelpMetrics metrics;
  final Widget hero;
  final Widget supportTiles;
  final Widget faqSection;
  final Widget footer;

  const _LandscapeBody({
    required this.metrics,
    required this.hero,
    required this.supportTiles,
    required this.faqSection,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
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
            ),
          ),

          SizedBox(width: m.gapLg),

          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: faqSection,
            ),
          ),
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
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
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
                      color: c.brand,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.linkSize,
                    ),
                  ),
                  SizedBox(width: m.gapXs),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: m.linkSize + 6,
                    color: c.brand,
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
  final VoidCallback onContact;

  const _HeroCard({required this.metrics, required this.onContact});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.heroPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.heroRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Need Help?\nWe\u2019re here for you!',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
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
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.heroBodySize,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: m.gapLg),

                SizedBox(
                  height: m.heroBtnHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: c.brand,
                      borderRadius: BorderRadius.circular(10),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: (){},
                        // onTap: onContact,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.heroPad * 0.9,
                            vertical: m.gapSm * 1.2,
                          ),
                          child: Text(
                            'Contact Support',
                            style: AppTextStyles.buttonText.copyWith(
                              color: c.surface,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: m.heroBtnFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
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

/// Headset illustration placeholder — SVG asset mile to swap kar denge
class _HeadsetArt extends StatelessWidget {
  final HelpMetrics metrics;

  const _HeadsetArt({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
              color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.75),
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
              color: c.brand.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            bottom: m.heroArtSize * 0.10,
            left: m.heroArtSize * 0.04,
            child: Icon(
              Icons.auto_awesome,
              size: m.heroArtSize * 0.10,
              color: c.brand.withValues(alpha: 0.40),
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
  final VoidCallback onEmail;

  const _SupportTiles({required this.metrics, required this.onEmail});

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _SupportTile(
              metrics: m,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat with Us',
              subtitle: 'Get instant support',
              onTap: null,
            ),
          ),
          SizedBox(width: m.tileGap),
          Expanded(
            child: _SupportTile(
              metrics: m,
              icon: Icons.mail_outline_rounded,
              title: 'Email Us',
              subtitle: 'We\u2019ll respond within 24 hrs',
              onTap: onEmail,
            ),
          ),
          SizedBox(width: m.tileGap),
          Expanded(
            child: _SupportTile(
              metrics: m,
              icon: Icons.phone_outlined,
              title: 'Call Us',
              subtitle: 'Mon\u2013Sun 9 AM \u2013 9 PM',
              onTap: null,
            ),
          ),
        ],
      ),
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
    final c = context.c;
    final m = metrics;

    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(m.tileRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: m.tilePad * 0.7,
            vertical: m.tilePad,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.tileRadius),
            border: Border.all(color: c.border, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.tileIconBox,
                height: m.tileIconBox,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.tileIconSize, color: c.brand),
              ),

              SizedBox(height: m.gapMd),

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.tileTitleSize,
                  height: 1.25,
                ),
              ),

              SizedBox(height: m.gapXs * 1.4),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.tileSubSize,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAQ ────────────────────────────────────────────────────────────────────
class _FaqSection extends StatelessWidget {
  final HelpMetrics metrics;
  final List<_Faq> faqs;

  const _FaqSection({required this.metrics, required this.faqs});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(metrics: m, title: 'Popular Questions'),

        SizedBox(height: m.gapMd),

        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.faqRadius),
            border: Border.all(color: c.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(faqs.length, (index) {
              final isLast = index == faqs.length - 1;
              return Column(
                children: [
                  _FaqTile(faq: faqs[index], metrics: m),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: m.faqHPad,
                      endIndent: m.faqHPad,
                      color: c.border,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _Faq {
  final String question;
  final String answer;

  const _Faq({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final HelpMetrics metrics;

  const _FaqTile({required this.faq, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(
          horizontal: m.faqHPad,
          vertical: m.faqVPad,
        ),
        childrenPadding: EdgeInsets.fromLTRB(
          m.faqHPad,
          0,
          m.faqHPad,
          m.gapMd,
        ),
        expandedAlignment: Alignment.topLeft,
        iconColor: c.brand,
        collapsedIconColor: c.textSecondary,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Text(
          faq.question,
          style: AppTextStyles.labelLarge.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: m.faqQuestionSize,
            height: 1.35,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down_rounded, size: m.faqIconSize),
        children: [
          Text(
            faq.answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.faqAnswerSize,
              height: 1.5,
            ),
          ),
        ],
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
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.footerPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.footerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: m.footerIconBox,
            height: m.footerIconBox,
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.7),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.verified_user_outlined,
              size: m.footerIconSize,
              color: c.brand,
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
                    color: c.brand,
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
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.footerBodySize,
                    height: 1.45,
                  ),
                ),

                SizedBox(height: m.gapXs * 0.6),

                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.footerBodySize,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'Thank you for shopping with '),
                      TextSpan(
                        text: 'TheVaults.',
                        style: TextStyle(
                          color: c.brand,
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