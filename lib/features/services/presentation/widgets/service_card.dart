import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/service_entity.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: service.imageUrl.isNotEmpty
                  ? Image.network(
                      service.imageUrl,
                      height: 13.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 13.h,
                        color: colors.surfaceAlt,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colors.textMuted,
                        ),
                      ),
                    )
                  : Container(
                      height: 13.h,
                      color: colors.surfaceAlt,
                      child: Icon(
                        Icons.image_not_supported,
                        color: colors.textMuted,
                      ),
                    ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    service.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  // Vendor name
                  Text(
                    service.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),

                  SizedBox(height: 0.8.h),

                  // Rating
                  if (service.totalReviews > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14.sp,
                          color: colors.brand,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          '${service.averageRating}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          '(${service.totalReviews})',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),


                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        service.displayPrice,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.brand,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.5.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.brandSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${service.durationMinutes}m',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.brand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
