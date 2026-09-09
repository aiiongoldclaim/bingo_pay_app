import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';

class MetaBlock extends StatelessWidget {
  const MetaBlock({
    super.key,
    required this.label,
    required this.value,
    this.leading,
    this.pill,
  });

  final String label;
  final String value;
  final IconData? leading;
  final String? pill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.textMuted,
            fontFamily: 'Inter',
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 0.36.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 13.sp, color: colors.brand),
              SizedBox(width: 1.03.w),
            ],
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (pill != null && pill!.trim().isNotEmpty) ...[
              SizedBox(width: 1.28.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.54.w,
                    vertical: 0.3.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.statusSuccessSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pill!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.statusSuccess,
                      fontFamily: 'Inter',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class MetaDivider extends StatelessWidget {
  const MetaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 1,
      height: 4.03.h,
      margin: EdgeInsets.symmetric(horizontal: 2.56.w),
      color: colors.border,
    );
  }
}
