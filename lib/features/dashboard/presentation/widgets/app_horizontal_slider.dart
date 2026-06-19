import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppHorizontalSlider extends StatelessWidget {
  const AppHorizontalSlider({
    super.key,
    this.value = 0.8,
    this.height,
    this.backgroundColor,
    this.progressColor,
    this.showArrows = true,
  });

  final double value; // 0.0 - 1.0
  final double? height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showArrows;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showArrows) Icon(Icons.arrow_left, size: 18.sp, color: Colors.grey),

        Expanded(
          child: Container(
            height: height ?? 1.h,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? Colors.grey,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
        ),

        if (showArrows)
          Icon(Icons.arrow_right, size: 18.sp, color: Colors.grey),
      ],
    );
  }
}
