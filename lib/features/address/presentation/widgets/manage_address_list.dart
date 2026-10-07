import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/address_entity.dart';
import 'address_metrics.dart';

class ManageAddressList extends StatelessWidget {
  final AddressMetrics metrics;
  final List<AddressEntity> addresses;
  final VoidCallback onAdd;
  final ValueChanged<AddressEntity> onEdit;
  final ValueChanged<AddressEntity> onDelete;

  const ManageAddressList({
    super.key,
    required this.metrics,
    required this.addresses,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final count = addresses.length;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            m.pageHPad,
            m.gapMd,
            m.pageHPad,
            m.gapLg + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Material(
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(m.cardRadius),
                side: BorderSide(color: colors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onAdd,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: m.cardPad,
                    vertical: m.gapMd,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: colors.brand,
                        size: m.actionIconSize + 4,
                      ),
                      SizedBox(width: m.gapSm),
                      Expanded(
                        child: Text(
                          'Add a new address',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: colors.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: m.nameSize,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.brand,
                        size: m.actionIconSize + 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: m.gapLg, bottom: m.gapSm),
              child: Text(
                'Saved Addresses',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.nameSize * 1.1,
                ),
              ),
            ),
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(height: m.gapMd),
              _ManageAddressCard(
                metrics: m,
                address: addresses[i],
                onEdit: () => onEdit(addresses[i]),
                onDelete: () => onDelete(addresses[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ManageAddressListShimmer extends StatelessWidget {
  final AddressMetrics metrics;

  const ManageAddressListShimmer({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final radius = BorderRadius.circular(m.cardRadius);
    final iconBox = m.actionIconSize * 4.5;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: ShimmerLoading(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              m.pageHPad,
              m.gapMd,
              m.pageHPad,
              m.gapLg,
            ),
            children: [
              ShimmerBox(height: m.addBtnHeight, borderRadius: radius),
              SizedBox(height: m.gapLg),
              ShimmerBox(width: m.nameSize * 9, height: m.nameSize * 1.2),
              SizedBox(height: m.gapSm),
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) SizedBox(height: m.gapMd),
                Container(
                  padding: EdgeInsets.all(m.cardPad),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        width: iconBox,
                        height: iconBox,
                        borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
                      ),
                      SizedBox(width: m.gapSm * 1.4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(
                              width: m.nameSize * 7,
                              height: m.nameSize,
                            ),
                            SizedBox(height: m.gapSm),
                            ShimmerBox(
                              width: double.infinity,
                              height: m.bodySize * 0.9,
                            ),
                            SizedBox(height: m.gapXs),
                            ShimmerBox(
                              width: m.bodySize * 10,
                              height: m.bodySize * 0.9,
                            ),
                            SizedBox(height: m.gapSm),
                            ShimmerBox(
                              width: m.bodySize * 6,
                              height: m.bodySize * 0.9,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _AddressMenuAction { edit, delete }

class _ManageAddressCard extends StatelessWidget {
  final AddressMetrics metrics;
  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManageAddressCard({
    required this.metrics,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatted() {
    final line = [
      address.addressLine1,
      address.addressLine2 ?? '',
      address.landmark ?? '',
      address.city,
      address.state,
    ].where((p) => p.trim().isNotEmpty).join(', ');
    return address.postalCode.trim().isEmpty
        ? line
        : '$line - ${address.postalCode}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border),
      ),
      padding: EdgeInsets.fromLTRB(
        m.cardPad,
        m.gapMd,
        m.cardPad * 0.2,
        m.gapMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: m.actionIconSize * 4.5,
            child: Container(
              decoration: BoxDecoration(
                color: colors.brandSoft,
                borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.home_outlined,
                color: colors.brand,
                size: m.actionIconSize * 2.4,
              ),
            ),
          ),
          SizedBox(width: m.gapSm * 1.4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.isDefaultAddress) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: m.gapSm * 0.8,
                      vertical: m.gapXs * 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brandSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colors.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.tagFontSize * 0.85,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: m.gapSm),
                ],
                Text(
                  address.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.nameSize * 1.15,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: m.gapXs * 1.2),
                Text(
                  _formatted(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.bodySize * 1.1,
                    height: 1.45,
                  ),
                ),
                if (address.phoneNumber.trim().isNotEmpty) ...[
                  SizedBox(height: m.gapSm),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        color: colors.textSecondary,
                        size: m.actionIconSize * 1.1,
                      ),
                      SizedBox(width: m.gapXs * 1.5),
                      Flexible(
                        child: Text(
                          address.phoneNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: m.bodySize * 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_AddressMenuAction>(
            icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
            tooltip: 'More options',
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: colors.border),
            ),
            onSelected: (action) => switch (action) {
              _AddressMenuAction.edit => onEdit(),
              _AddressMenuAction.delete => onDelete(),
            },
            itemBuilder: (_) => [
              _menuItem(
                value: _AddressMenuAction.edit,
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: colors.textPrimary,
              ),
              const PopupMenuDivider(height: 1),
              _menuItem(
                value: _AddressMenuAction.delete,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                color: colors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_AddressMenuAction> _menuItem({
    required _AddressMenuAction value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: metrics.actionIconSize),
          SizedBox(width: metrics.gapSm),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
