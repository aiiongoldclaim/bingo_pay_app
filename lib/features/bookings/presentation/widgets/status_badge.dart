import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.31.w, vertical: 0.59.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 1.28.w),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 23.59.w),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 10.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
