import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'tvs_format.dart';

// Small pieces shared by the TVS Wallet screens.

TextStyle tvsText(
  Color color, {
  double size = 14,
  FontWeight weight = FontWeight.w500,
}) => AppTextStyles.bodyMedium.copyWith(
  color: color,
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
);

// A rounded, bordered group of rows, divided like the profile menu.
class TvsCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const TvsCard({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: colors.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class TvsEmpty extends StatelessWidget {
  final String text;
  final IconData icon;

  const TvsEmpty(this.text, {super.key, this.icon = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 36, color: colors.textMuted),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: tvsText(colors.textSecondary, size: 13),
          ),
        ],
      ),
    );
  }
}

// Placeholder rows while a list loads.
class TvsListShimmer extends StatelessWidget {
  final int rows;

  const TvsListShimmer({super.key, this.rows = 4});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          for (var i = 0; i < rows; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  ShimmerBox(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 160, height: 14),
                        SizedBox(height: 8),
                        ShimmerBox(width: 110, height: 11),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 64, height: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// A status word (ACTIVE, PENDING, CREDITED…) on a soft tint of its meaning.
class TvsPill extends StatelessWidget {
  final Object? status;

  const TvsPill(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = '${status ?? ''}'.toUpperCase();
    final color = switch (s) {
      'ACTIVE' || 'COMPLETED' || 'CREDITED' || 'PAID' => colors.statusSuccess,
      'PENDING' || 'INACTIVE' || 'ON_HOLD' => colors.statusWarning,
      'FROZEN' || 'FAILED' || 'CANCELLED' || 'REJECTED' => colors.error,
      _ => colors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tvsHuman(s),
        style: tvsText(color, size: 11, weight: FontWeight.w600),
      ),
    );
  }
}

// A QR code, drawn from the `qr` package's modules on a white tile.
class TvsQr extends StatelessWidget {
  final String data;
  final double size;

  const TvsQr(this.data, {super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    return Semantics(
      label: 'QR code',
      image: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(size: Size.square(size), painter: _QrPainter(image)),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final QrImage image;

  _QrPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount;
    final cell = size.width / n;
    final ink = Paint()..color = Colors.black;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (image.isDark(r, c)) {
          // A hair wider, so neighbouring cells don't show seams.
          canvas.drawRect(
            Rect.fromLTWH(c * cell, r * cell, cell + 0.4, cell + 0.4),
            ink,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}
