import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/theme_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service Option',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: ThemeColors.black,
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
                    color: isSelected
                        ? ThemeColors.blue
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? ThemeColors.blue.withValues(alpha: 0.05)
                      : Colors.transparent,
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
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.black,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            offering.offeringName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
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
                            color: ThemeColors.blue,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${offering.durationMinutes}m',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
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
