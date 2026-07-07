import 'package:flutter/material.dart';

/// Wraps [child] with an animated shimmer sweep, used to indicate a
/// loading skeleton. Pass grey placeholder boxes (e.g. [ShimmerBox]) as
/// the child tree; the sweep animates over all of them at once.
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = _controller.value * 2 - 1;
            return LinearGradient(
              colors: const [
                Color(0xFFE4E6EB),
                Color(0xFFF6F7F9),
                Color(0xFFE4E6EB),
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment(dx - 1, 0),
              end: Alignment(dx + 1, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// A solid placeholder block used inside [ShimmerLoading] to represent
/// text lines, images, or cards while content is loading.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE4E6EB),
        borderRadius: borderRadius,
      ),
    );
  }
}
