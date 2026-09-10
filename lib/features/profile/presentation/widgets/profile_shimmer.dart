import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer_loading.dart';

class ProfileShimmerContent extends StatelessWidget {
  const ProfileShimmerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ShimmerBox(
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.all(Radius.circular(36)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 150, height: 20),
                      SizedBox(height: 10),
                      ShimmerBox(width: 200, height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 155,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 90,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),

          const SizedBox(height: 28),

          _ShimmerSection(titleWidth: 180),

          const SizedBox(height: 20),

          _ShimmerSection(titleWidth: 160),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ShimmerSection extends StatelessWidget {
  const _ShimmerSection({required this.titleWidth});

  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ShimmerBox(width: titleWidth, height: 20),
          ),

          const SizedBox(height: 14),

          ...List.generate(3, (index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ShimmerBox(
                width: double.infinity,
                height: 72,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            );
          }),
        ],
      ),
    );
  }
}
