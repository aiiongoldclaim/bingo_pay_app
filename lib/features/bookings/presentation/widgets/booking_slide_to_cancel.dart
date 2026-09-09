import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingSlideToCancel extends StatefulWidget {
  const BookingSlideToCancel({
    super.key,
    required this.onCompleted,
  });

  final VoidCallback onCompleted;

  @override
  State<BookingSlideToCancel> createState() =>
      _BookingSlideToCancelState();
}

class _BookingSlideToCancelState
    extends State<BookingSlideToCancel>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completed = false;

  late final AnimationController _resetController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();

    _resetController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 420),
    );

    _resetController.addListener(_onResetAnimation);
  }

  void _onResetAnimation() {
    final animation = _resetAnimation;

    if (!mounted || animation == null) {
      return;
    }

    setState(() {
      _dragX = animation.value;
    });
  }

  @override
  void dispose() {
    _resetController
      ..removeListener(_onResetAnimation)
      ..dispose();

    super.dispose();
  }

  void _animateBack() {
    if (!mounted) return;

    _resetController.stop();

    final animation = Tween<double>(
      begin: _dragX,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _resetController,
        curve: Curves.elasticOut,
      ),
    );

    _resetAnimation = animation;

    _resetController
      ..reset()
      ..forward();
  }

  void _finish(double maxDrag) {
    if (_completed || !mounted) {
      return;
    }

    setState(() {
      _completed = true;
      _dragX = maxDrag;
    });

    Future.delayed(
      const Duration(milliseconds: 220),
      () {
        if (!mounted) return;

        widget.onCompleted();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);
    final handleSize = m.slideHandleSize;
    final horizontalPadding = m.slideHPad;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        final maxDrag = (trackWidth -
                handleSize -
                (horizontalPadding * 2))
            .clamp(0.0, double.infinity);

        final progress = maxDrag <= 0
            ? 0.0
            : (_dragX / maxDrag)
                .clamp(0.0, 1.0);

        return Container(
          height: m.slideHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius:
                BorderRadius.circular(m.slideRadius),
            border: Border.all(
              color: c.border,
            ),
            boxShadow: c.isDark
                ? null
                : [
                    BoxShadow(
                      color: c.textPrimary.withValues(
                        alpha: 0.045,
                      ),
                      blurRadius: m.slideShadowBlur,
                      offset: Offset(0, m.slideShadowOffsetY),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(m.slideRadius),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.all(
                      horizontalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius:
                          BorderRadius.circular(m.slideInnerRadius),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedOpacity(
                    duration:
                        const Duration(milliseconds: 100),
                    opacity: (1 - progress * 2)
                        .clamp(0.0, 1.0),
                    child: Text(
                      AppStrings.slideToCancel,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.slideTextSize,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: m.slideChevronRightPad,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity:
                          (1 - progress).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          BookingSlideChevron(
                            color: c.textMuted,
                            opacity: 0.25,
                          ),
                          BookingSlideChevron(
                            color: c.textMuted,
                            opacity: 0.45,
                          ),
                          BookingSlideChevron(
                            color: c.brand,
                            opacity: 0.75,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left:
                      horizontalPadding + _dragX,
                  top: horizontalPadding,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onHorizontalDragUpdate:
                        _completed
                            ? null
                            : (details) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _dragX =
                                      (_dragX +
                                              details
                                                  .delta
                                                  .dx)
                                          .clamp(
                                    0.0,
                                    maxDrag,
                                  );
                                });
                              },
                    onHorizontalDragEnd:
                        _completed
                            ? null
                            : (_) {
                                if (!mounted) {
                                  return;
                                }

                                final currentProgress =
                                    maxDrag <= 0
                                        ? 0.0
                                        : _dragX /
                                            maxDrag;

                                if (currentProgress >=
                                    0.82) {
                                  _finish(maxDrag);
                                } else {
                                  _animateBack();
                                }
                              },
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 120,
                      ),
                      width: handleSize,
                      height: handleSize,
                      decoration:
                          BoxDecoration(
                        color: c.brand,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.brand.withValues(
                              alpha: 0.22,
                            ),
                            blurRadius: m.slideHandleShadowBlur,
                            offset:
                                Offset(0, m.slideHandleShadowOffsetY),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 150,
                        ),
                        child: _completed
                            ? Icon(
                                Icons.check_rounded,
                                key: const ValueKey(
                                  'completed',
                                ),
                                color: c.surface,
                                size: m.slideCheckIconSize,
                              )
                            : Icon(
                                Icons
                                    .arrow_forward_rounded,
                                key: const ValueKey(
                                  'arrow',
                                ),
                                color: c.surface,
                                size: m.slideArrowIconSize,
                              ),
                      ),
                    ),
                  ),
                ),
                if (_completed)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            m.slideRadius,
                          ),
                          border: Border.all(
                            color: c.brand.withValues(
                              alpha: 0.35,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookingSlideChevron extends StatelessWidget {
  const BookingSlideChevron({
    super.key,
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final m = BookingDetailsMetrics.of(context);

    return Opacity(
      opacity: opacity,
      child: Icon(
        Icons.chevron_right_rounded,
        size: m.chevronIconSize,
        color: color,
      ),
    );
  }
}
