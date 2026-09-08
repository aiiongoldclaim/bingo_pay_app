import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

class BookingsLoadingView extends StatelessWidget {
  const BookingsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                BookingSkeleton(width: 130, height: 18),
                SizedBox(height: 6),
                BookingSkeleton(width: 200, height: 12),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: const [
                BookingSkeleton(width: 66, height: 34),
                SizedBox(width: 9),
                BookingSkeleton(width: 96, height: 34),
                SizedBox(width: 9),
                BookingSkeleton(width: 104, height: 34),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, __) {
              return Container(
                height: 196,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BookingSkeleton(width: 74, height: 92),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              BookingSkeleton(height: 16),
                              SizedBox(height: 8),
                              BookingSkeleton(width: 120, height: 12),
                              SizedBox(height: 14),
                              BookingSkeleton(height: 12),
                              SizedBox(height: 8),
                              BookingSkeleton(width: 140, height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const BookingSkeleton(height: 42),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BookingSkeleton extends StatelessWidget {
  const BookingSkeleton({super.key, this.width = double.infinity, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.border.withValues(alpha: colors.isDark ? 0.35 : 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
