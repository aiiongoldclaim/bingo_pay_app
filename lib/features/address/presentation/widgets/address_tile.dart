import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/address_entity.dart';

/// Sizing for [AddressTile] / [AddressAddNewButton] — self-contained so
/// either screen can drop these widgets in without threading its own
/// metrics class through.
class AddressTileMetrics {
  final double cardRadius;
  final double cardPad;
  final double radioSize;
  final double nameSize;
  final double tagFontSize;
  final double phoneSize;
  final double bodySize;
  final double actionFontSize;
  final double actionHeight;
  final double actionIconSize;
  final double addBtnHeight;
  final double addBtnFontSize;
  final double gapXs;
  final double gapSm;
  final double gapMd;

  const AddressTileMetrics({
    required this.cardRadius,
    required this.cardPad,
    required this.radioSize,
    required this.nameSize,
    required this.tagFontSize,
    required this.phoneSize,
    required this.bodySize,
    required this.actionFontSize,
    required this.actionHeight,
    required this.actionIconSize,
    required this.addBtnHeight,
    required this.addBtnFontSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
  });

  static AddressTileMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return AddressTileMetrics.phone();
    return isLandscape
        ? AddressTileMetrics.tabletLandscape()
        : AddressTileMetrics.tabletPortrait();
  }

  factory AddressTileMetrics.phone() => AddressTileMetrics(
    cardRadius: 16,
    cardPad: 4.w,
    radioSize: 5.5.w,
    nameSize: 15.sp,
    tagFontSize: 10.sp,
    phoneSize: 13.sp,
    bodySize: 13.sp,
    actionFontSize: 12.sp,
    actionHeight: 4.4.h,
    actionIconSize: 14.sp,
    addBtnHeight: 6.2.h,
    addBtnFontSize: 14.sp,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
  );

  factory AddressTileMetrics.tabletPortrait() => const AddressTileMetrics(
    cardRadius: 18,
    cardPad: 20,
    radioSize: 24,
    nameSize: 19,
    tagFontSize: 12,
    phoneSize: 16,
    bodySize: 16,
    actionFontSize: 15,
    actionHeight: 42,
    actionIconSize: 18,
    addBtnHeight: 56,
    addBtnFontSize: 17,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
  );

  factory AddressTileMetrics.tabletLandscape() => const AddressTileMetrics(
    cardRadius: 18,
    cardPad: 16,
    radioSize: 22,
    nameSize: 18,
    tagFontSize: 11,
    phoneSize: 15,
    bodySize: 15,
    actionFontSize: 14,
    actionHeight: 38,
    actionIconSize: 17,
    addBtnHeight: 52,
    addBtnFontSize: 16,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
  );
}

/// Shared address card — used both when picking a delivery address
/// (Payment, Address List) and when just managing saved addresses.
class AddressTile extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressTile({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatted() {
    final parts = [
      address.addressLine1,
      address.addressLine2 ?? '',
      address.city,
      address.state,
      address.postalCode,
    ].where((p) => p.trim().isNotEmpty);
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = AddressTileMetrics.of(context);

    return Material(
      color: isSelected ? colors.brandSoft : colors.surface,
      borderRadius: BorderRadius.circular(m.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
        child: Container(
          padding: EdgeInsets.all(m.cardPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(
              color: isSelected ? colors.brand : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: m.gapXs * 0.6),
                    child: Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: m.radioSize,
                      color: isSelected ? colors.brand : colors.textMuted,
                    ),
                  ),

                  SizedBox(width: m.cardPad * 0.7),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                address.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: colors.textPrimary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: m.nameSize,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (address.isDefaultAddress) ...[
                              SizedBox(width: m.gapSm * 0.8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: m.gapSm * 0.9,
                                  vertical: m.gapXs * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.brand.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: colors.brand,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: m.tagFontSize,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: m.gapXs),

                        Text(
                          address.phoneNumber,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: m.phoneSize,
                            height: 1.35,
                          ),
                        ),

                        SizedBox(height: m.gapXs * 0.8),

                        Text(
                          _formatted(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: m.bodySize,
                            height: 1.45,
                          ),
                        ),

                        if (isSelected) ...[
                          SizedBox(height: m.gapXs),
                          Text(
                            'Deliver to this address',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: colors.brand,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: m.tagFontSize + 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: m.gapMd),
              Divider(height: 1, thickness: 1, color: colors.border),
              SizedBox(height: m.gapSm),

              Row(
                children: [
                  _AddressTileAction(
                    metrics: m,
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: onEdit,
                  ),
                  SizedBox(width: m.gapSm),
                  _AddressTileAction(
                    metrics: m,
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    isDestructive: true,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressTileAction extends StatelessWidget {
  final AddressTileMetrics metrics;
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _AddressTileAction({
    required this.metrics,
    required this.icon,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final color = isDestructive ? colors.statusWarning : colors.brand;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: m.actionHeight,
          padding: EdgeInsets.symmetric(horizontal: m.gapSm * 1.2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: m.actionIconSize, color: color),
              SizedBox(width: m.gapXs * 1.2),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.actionFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Add New Address" call-to-action row.
class AddressAddNewButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddressAddNewButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = AddressTileMetrics.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(m.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: m.addBtnHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(
              color: colors.brand.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: m.addBtnFontSize + 5,
                color: colors.brand,
              ),
              SizedBox(width: m.gapSm * 0.8),
              Text(
                'ADD NEW ADDRESS',
                style: AppTextStyles.buttonText.copyWith(
                  color: colors.brand,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.addBtnFontSize,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
