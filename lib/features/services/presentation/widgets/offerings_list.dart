import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/service_entity.dart';

class OfferingsList extends StatelessWidget {
  final List<OfferingEntity> offerings;
  final String selectedUuid;
  final Function(OfferingEntity) onOfferingSelected;

  const OfferingsList({
    super.key,
    required this.offerings,
    required this.selectedUuid,
    required this.onOfferingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service Option',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Column(
          children: offerings.map((offering) {
            final isSelected = offering.uuid == selectedUuid;
            return GestureDetector(
              onTap: () => onOfferingSelected(offering),
              child: Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? colors.brand : colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected ? colors.brandSoft : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering.title,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            offering.offeringName,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatPrice(
                            offering.salePrice ?? offering.basePrice,
                            offering.currency,
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: colors.brand,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 15.sp,
                              color: colors.textSecondary,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${offering.durationMinutes}m',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
