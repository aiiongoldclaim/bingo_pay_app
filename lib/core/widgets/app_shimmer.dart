import 'package:flutter/material.dart';

import 'shimmer_loading.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      child: ShimmerLoading(
        child: child,
      ),
    );
  }
}