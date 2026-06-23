import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.titleLarge);
  }
}
