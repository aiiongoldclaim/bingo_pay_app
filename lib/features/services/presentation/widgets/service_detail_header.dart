import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/entities/service_entity.dart';

class ServiceDetailHeader extends StatelessWidget {
  final ServiceEntity service;

  const ServiceDetailHeader({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: service.imageUrl.isNotEmpty
              ? Image.network(
                  service.imageUrl,
                  height: 25.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 25.h,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported),
                  ),
                )
              : Container(
                  height: 25.h,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                ),
        ),

        SizedBox(height: 2.h),

        // Title
        Text(
          service.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: ThemeColors.black,
          ),
        ),

        SizedBox(height: 1.h),

        // Vendor & Category
        Row(
          children: [
            Expanded(
              child: Text(
                service.vendorName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 0.5.h,
              ),
              decoration: BoxDecoration(
                color: ThemeColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                service.categoryName,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ThemeColors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 1.5.h),

        // Rating & Reviews & Duration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 16.sp,
                  color: Colors.amber,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '${service.averageRating}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '(${service.totalReviews} reviews)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14.sp,
                  color: ThemeColors.blue,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  '${service.durationMinutes}m',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 1.5.h),

        // Location
        if (service.locationLabel != null && service.locationLabel!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14.sp,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  service.locationLabel!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
