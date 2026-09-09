import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/bookings_entity.dart';

class ServiceThumb extends StatelessWidget {
  const ServiceThumb({super.key, required this.booking});

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 18.97.w,
      height: 10.9.h,
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      alignment: Alignment.center,
      child: Icon(
        _serviceIcon(booking.service.title),
        color: colors.brand,
        size: 30.sp,
      ),
    );
  }

  IconData _serviceIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('hair') ||
        value.contains('salon') ||
        value.contains('cut')) {
      return Icons.content_cut_rounded;
    }

    if (value.contains('spa') || value.contains('massage')) {
      return Icons.spa_outlined;
    }

    if (value.contains('doctor') ||
        value.contains('health') ||
        value.contains('clinic') ||
        value.contains('teeth') ||
        value.contains('dental')) {
      return Icons.medical_services_outlined;
    }

    if (value.contains('yoga') || value.contains('fitness')) {
      return Icons.self_improvement_rounded;
    }

    if (value.contains('clean')) {
      return Icons.cleaning_services_outlined;
    }

    if (value.contains('repair')) {
      return Icons.build_outlined;
    }

    return Icons.auto_awesome_rounded;
  }
}
