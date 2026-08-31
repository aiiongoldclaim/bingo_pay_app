import 'package:bingo_pay/features/product_details/presentation/widgets/product_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../data/models/product_details_model.dart';


// ── Top bar ────────────────────────────────────────────────────────────────
class ProductTopBar extends StatelessWidget {
  final ProductMetrics metrics;
  final int cartCount;
  final VoidCallback onBack;
  final VoidCallback onWishlist;
  final VoidCallback onCart;

  const ProductTopBar({
    super.key,
    required this.metrics,
    required this.cartCount,
    required this.onBack,
    required this.onWishlist,
    required this.onCart,
  });

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
            onPressed: onBack,
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
                'TheVaults',
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.brand,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w600,
                  fontSize: m.logoSize,
                  height: 1.1,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onWishlist,
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.favorite_border_rounded,
              size: m.topIconSize,
              color: c.textPrimary,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: onCart,
                splashRadius: m.topIconSize * 1.2,
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  size: m.topIconSize,
                  color: c.textPrimary,
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: m.topIconSize * 0.25,
                  top: m.topIconSize * 0.18,
                  child: Container(
                    width: m.badgeSize,
                    height: m.badgeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.background, width: 1.5),
                    ),
                    child: Text(
                      '$cartCount',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontSize: m.badgeFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gallery: hero + horizontal thumbnail rail ──────────────────────────────
class ProductGallery extends StatefulWidget {
  final ProductMetrics metrics;
  final List<String> images;
  final IconData fallbackIcon;
  final String? badge;
  final void Function(int index) onImageTap;

  const ProductGallery({
    super.key,
    required this.metrics,
    required this.images,
    required this.fallbackIcon,
    this.badge,
    required this.onImageTap,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = widget.metrics;
    final images = widget.images;

    /// Rail me max 4 thumbnails, 5th slot "+N More"
    const railSlots = 4;
    final extra = images.length - railSlots;
    final visibleCount = images.length <= railSlots ? images.length : railSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Hero ────────────────────────────────────────────────────────
        SizedBox(
          height: m.heroHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(m.heroRadius),
            child: Container(
              color: c.surfaceAlt,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    GestureDetector(
                      onTap: () => widget.onImageTap(_index),
                      child: Image.network(
                        images[_index.clamp(0, images.length - 1)],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            widget.fallbackIcon,
                            size: m.floatBtnSize * 1.4,
                            color: c.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(
                        widget.fallbackIcon,
                        size: m.floatBtnSize * 1.4,
                        color: c.textMuted,
                      ),
                    ),

                  if (widget.badge != null)
                    Positioned(
                      top: m.gapMd,
                      left: m.gapMd,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: m.gapMd * 0.7,
                          vertical: m.gapXs * 1.4,
                        ),
                        decoration: BoxDecoration(
                          color: c.brand,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.badge!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: c.surface,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.captionSize,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        if (images.length > 1) ...[
          SizedBox(height: m.gapSm * 1.2),

          // ── Horizontal thumbnail rail ─────────────────────────────────
          SizedBox(
            height: m.railHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: extra > 0 ? visibleCount + 1 : visibleCount,
              separatorBuilder: (_, __) => SizedBox(width: m.thumbGap),
              itemBuilder: (context, i) {
                // Last slot = "+N More"
                if (extra > 0 && i == visibleCount) {
                  return GestureDetector(
                    onTap: () => widget.onImageTap(railSlots),
                    child: Container(
                      width: m.thumbSize,
                      decoration: BoxDecoration(
                        color: c.brandSoft,
                        borderRadius: BorderRadius.circular(m.thumbRadius),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+$extra\nMore',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: c.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.sizeChipSubSize + 2,
                          height: 1.25,
                        ),
                      ),
                    ),
                  );
                }

                final isSelected = i == _index;

                return GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: Container(
                    width: m.thumbSize,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(m.thumbRadius),
                      border: Border.all(
                        color: isSelected ? c.brand : c.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        widget.fallbackIcon,
                        size: m.thumbSize * 0.34,
                        color: c.textMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}



// ── Brand + title + rating + price ─────────────────────────────────────────
class ProductInfoBlock extends StatelessWidget {
  final ProductMetrics metrics;
  final ProductDetailModel product;

  const ProductInfoBlock({
    super.key,
    required this.metrics,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                product.brand.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.brandSize,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            SizedBox(width: m.gapXs),
            Icon(
              Icons.chevron_right_rounded,
              size: m.brandSize + 6,
              color: c.textSecondary,
            ),
          ],
        ),

        SizedBox(height: m.gapSm),

        Text(
          product.productName,
          style: AppTextStyles.titleLarge.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: m.titleSize,
            height: 1.3,
          ),
        ),

        SizedBox(height: m.gapMd),

        // Rating chip
        Container(
          height: m.ratingChipHeight,
          padding: EdgeInsets.symmetric(horizontal: m.gapMd * 0.8),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: m.ratingFontSize + 5,
                color: c.brand,
              ),
              SizedBox(width: m.gapXs * 1.2),
              Text(
                product.rating,
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.ratingFontSize,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.gapSm),
                child: Container(
                  width: 1,
                  height: m.ratingChipHeight * 0.42,
                  color: c.border,
                ),
              ),
              Text(
                '${product.reviewCount} Ratings',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.ratingFontSize,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: m.gapMd),

        // Price row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.price,
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.priceSize,
                height: 1.1,
              ),
            ),
            if (product.oldPrice.isNotEmpty) ...[
              SizedBox(width: m.gapSm),
              Padding(
                padding: EdgeInsets.only(bottom: m.gapXs * 0.8),
                child: Text(
                  product.oldPrice,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.strikeSize,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
            if (product.discount > 0) ...[
              SizedBox(width: m.gapSm),
              Padding(
                padding: EdgeInsets.only(bottom: m.gapXs * 0.8),
                child: Text(
                  '${product.discount}% OFF',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: c.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.discountSize,
                  ),
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: m.gapXs),

        Text(
          'Inclusive of all taxes',
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.captionSize,
          ),
        ),
      ],
    );
  }
}

// ── Variants as size chips ─────────────────────────────────────────────────
class ProductSizeSelector extends StatelessWidget {
  final ProductMetrics metrics;
  final List<ProductVariant> variants;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onSizeGuide;

  const ProductSizeSelector({
    super.key,
    required this.metrics,
    required this.variants,
    required this.selectedIndex,
    required this.onSelect,
    this.onSizeGuide,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (variants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row(
        //   children: [
        //     Expanded(
        //       child: Text(
        //         'Select Size',
        //         style: AppTextStyles.titleMedium.copyWith(
        //           color: c.textPrimary,
        //           fontFamily: 'Inter',
        //           fontWeight: FontWeight.w700,
        //           fontSize: m.sectionTitleSize,
        //         ),
        //       ),
        //     ),
        //     InkWell(
        //       onTap: onSizeGuide,
        //       borderRadius: BorderRadius.circular(8),
        //       child: Padding(
        //         padding: EdgeInsets.all(m.gapXs),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Text(
        //               'Size Guide',
        //               style: AppTextStyles.labelMedium.copyWith(
        //                 color: c.brand,
        //                 fontFamily: 'Inter',
        //                 fontWeight: FontWeight.w600,
        //                 fontSize: m.linkSize,
        //               ),
        //             ),
        //             SizedBox(width: m.gapXs * 1.2),
        //             Icon(
        //               Icons.straighten_rounded,
        //               size: m.linkSize + 4,
        //               color: c.brand,
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        //
        // SizedBox(height: m.gapMd),
        //
        // SizedBox(
        //   height: m.sizeChipHeight,
        //   child: ListView.separated(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: variants.length,
        //     separatorBuilder: (_, __) => SizedBox(width: m.gapSm),
        //     itemBuilder: (context, i) {
        //       final v = variants[i];
        //       final isSelected = i == selectedIndex;
        //       final isDisabled = v.availableStock <= 0;
        //
        //       final label = v.variantName.isNotEmpty
        //           ? v.variantName
        //           : v.title.isNotEmpty
        //           ? v.title
        //           : '${i + 1}';
        //
        //       final sub = v.attributes.isNotEmpty
        //           ? v.attributes.first.value
        //           : null;
        //
        //       return Material(
        //         color: c.surface,
        //         borderRadius: BorderRadius.circular(10),
        //         clipBehavior: Clip.antiAlias,
        //         child: InkWell(
        //           onTap: isDisabled ? null : () => onSelect(i),
        //           child: Container(
        //             constraints: BoxConstraints(
        //               minWidth: m.sizeChipMinWidth,
        //             ),
        //             padding: EdgeInsets.symmetric(horizontal: m.gapMd * 0.8),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(10),
        //               border: Border.all(
        //                 color: isSelected ? c.brand : c.border,
        //                 width: isSelected ? 1.5 : 1,
        //               ),
        //             ),
        //             child: Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Text(
        //                   label,
        //                   maxLines: 1,
        //                   overflow: TextOverflow.ellipsis,
        //                   style: AppTextStyles.labelLarge.copyWith(
        //                     color: isDisabled
        //                         ? c.textMuted
        //                         : isSelected
        //                         ? c.brand
        //                         : c.textPrimary,
        //                     fontFamily: 'Inter',
        //                     fontWeight: FontWeight.w600,
        //                     fontSize: m.sizeChipFontSize,
        //                     decoration: isDisabled
        //                         ? TextDecoration.lineThrough
        //                         : null,
        //                   ),
        //                 ),
        //                 if (sub != null) ...[
        //                   SizedBox(height: m.gapXs * 0.6),
        //                   Text(
        //                     '($sub)',
        //                     maxLines: 1,
        //                     overflow: TextOverflow.ellipsis,
        //                     style: AppTextStyles.bodySmall.copyWith(
        //                       color: c.textSecondary,
        //                       fontFamily: 'Inter',
        //                       fontSize: m.sizeChipSubSize,
        //                     ),
        //                   ),
        //                 ],
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}

// ── Generic section card ───────────────────────────────────────────────────
class ProductSectionCard extends StatelessWidget {
  final ProductMetrics metrics;
  final Widget child;
  final EdgeInsets? padding;

  const ProductSectionCard({
    super.key,
    required this.metrics,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: padding ?? EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: child,
    );
  }
}

// ── Tappable row (Check Delivery / offers) ─────────────────────────────────
class ProductActionRow extends StatelessWidget {
  final ProductMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ProductActionRow({
    super.key,
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(m.cardRadius),
        child: Row(
          children: [
            Container(
              width: m.rowIconBox,
              height: m.rowIconBox,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: m.rowIconSize, color: c.brand),
            ),
            SizedBox(width: m.gapMd * 0.8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.rowTitleSize,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.rowSubSize,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: m.rowTitleSize + 10,
              color: c.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Policies strip ─────────────────────────────────────────────────────────
class ProductPoliciesStrip extends StatelessWidget {
  final ProductMetrics metrics;
  final DeliveryInfo info;

  const ProductPoliciesStrip({
    super.key,
    required this.metrics,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    Widget item(IconData icon, String title, String sub) => Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: m.policyIconBox,
            height: m.policyIconBox,
            decoration: BoxDecoration(
              color: c.brandSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: m.policyIconSize, color: c.brand),
          ),
          SizedBox(width: m.gapSm * 0.7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.policyTitleSize,
                    height: 1.25,
                  ),
                ),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.policySubSize,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget divider() => Container(
      width: 1,
      height: m.policyIconBox * 0.9,
      color: c.border,
    );

    return ProductSectionCard(
      metrics: m,
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad * 0.6,
        vertical: m.cardPad * 0.8,
      ),
      child: Row(
        children: [
          item(
            Icons.local_shipping_outlined,
            info.deliveryLabel,
            info.deliverySubtitle,
          ),
          divider(),
          item(
            Icons.autorenew_rounded,
            info.returnLabel,
            info.returnSubtitle,
          ),
          divider(),
          item(
            Icons.verified_user_outlined,
            info.warrantyLabel,
            info.warrantySubtitle,
          ),
        ],
      ),
    );
  }
}

// ── Offers For You ─────────────────────────────────────────────────────────
class ProductOffer {
  final String title;
  final String subtitle;

  const ProductOffer({required this.title, required this.subtitle});
}

class ProductOffersCard extends StatelessWidget {
  final ProductMetrics metrics;
  final List<ProductOffer> offers;
  final VoidCallback? onViewAll;

  const ProductOffersCard({
    super.key,
    required this.metrics,
    required this.offers,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (offers.isEmpty) return const SizedBox.shrink();

    return ProductSectionCard(
      metrics: m,
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad,
        vertical: m.cardPad * 0.8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: m.sectionTitleSize + 4,
                color: c.brand,
              ),
              SizedBox(width: m.gapSm * 0.8),
              Text(
                'Offers For You',
                style: AppTextStyles.titleMedium.copyWith(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.sectionTitleSize,
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          ...List.generate(offers.length, (i) {
            final offer = offers[i];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: m.gapSm * 0.8),
                      child: Row(
                        children: [
                          Container(
                            width: m.rowIconBox * 0.85,
                            height: m.rowIconBox * 0.85,
                            decoration: BoxDecoration(
                              color: c.brandSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.percent_rounded,
                              size: m.rowIconSize * 0.85,
                              color: c.brand,
                            ),
                          ),
                          SizedBox(width: m.gapMd * 0.8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  offer.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: c.textPrimary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: m.rowTitleSize,
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: m.gapXs * 0.6),
                                Text(
                                  offer.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: c.textSecondary,
                                    fontFamily: 'Inter',
                                    fontSize: m.rowSubSize,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: m.rowTitleSize + 10,
                            color: c.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: c.border),
              ],
            );
          }),

          SizedBox(height: m.gapSm * 0.8),

          Center(
            child: InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(m.gapXs * 1.4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Offers (${offers.length})',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}

// ── Highlights ─────────────────────────────────────────────────────────────
class ProductHighlightsBlock extends StatelessWidget {
  final ProductMetrics metrics;
  final List<String> highlights;

  const ProductHighlightsBlock({
    super.key,
    required this.metrics,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (highlights.isEmpty) return const SizedBox.shrink();

    return ProductSectionCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Product Details',
            style: AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),
          SizedBox(height: m.gapMd),
          ...highlights.map(
                (h) => Padding(
              padding: EdgeInsets.only(bottom: m.gapSm),
              child: Text(
                h,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.rowSubSize,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
