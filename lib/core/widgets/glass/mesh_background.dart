import 'package:flutter/material.dart';

import '../../theme/app_glass.dart';

/// The Liquid Glass "wallpaper": a soft diagonal gradient with colour blobs.
///
/// Blobs are radial gradients fading to transparent, which reads as blurred
/// colour without paying for an ImageFilter on every frame.
class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.meshTop, glass.meshMid, glass.meshBottom],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -90,
            child: _Blob(color: glass.blobBlue, size: 320),
          ),
          Positioned(
            top: 300,
            left: -120,
            child: _Blob(color: glass.blobPink, size: 280),
          ),
          Positioned(
            bottom: -60,
            right: -40,
            child: _Blob(color: glass.blobGreen, size: 260),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;

  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
