import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingDetailsLoadingView extends StatelessWidget {
  const BookingDetailsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final m = BookingDetailsMetrics.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            m.loadingHeaderPadH,
            m.loadingHeaderPadTop,
            m.loadingHeaderPadH,
            m.loadingHeaderPadBottom,
          ),
          child: Row(
            children: [
              BookingDetailsLoadingBox(
                width: m.loadingAvatarBox,
                height: m.loadingAvatarBox,
                radius: m.loadingAvatarRadius,
              ),
              SizedBox(width: m.loadingAvatarGapW),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    BookingDetailsLoadingBox(
                      width: m.loadingTitleWidth,
                      height: m.loadingTitleHeight,
                      radius: m.loadingTitleRadius,
                    ),
                    SizedBox(height: m.loadingTitleGapH),
                    BookingDetailsLoadingBox(
                      width: m.loadingSubWidth,
                      height: m.loadingSubHeight,
                      radius: m.loadingSubRadius,
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.loadingAvatarGapW),
              BookingDetailsLoadingBox(
                width: m.loadingAvatarBox,
                height: m.loadingAvatarBox,
                radius: m.loadingAvatarRadius,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              m.loadingListPadH,
              m.loadingListPadTop,
              m.loadingListPadH,
              m.loadingListPadBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BookingDetailsLoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const BookingDetailsLoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const BookingDetailsLoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const BookingDetailsLoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const BookingDetailsLoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const BookingDetailsLoadingCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BookingDetailsLoadingCard extends StatelessWidget {
  const BookingDetailsLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.loadingCardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.loadingCardRadius),
        border: Border.all(
          color: c.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          BookingDetailsLoadingBox(
            width: m.loadingLine1Width,
            height: m.loadingLine1Height,
            radius: m.loadingLine1Radius,
          ),
          SizedBox(height: m.loadingGap1),
          BookingDetailsLoadingBox(
            width: double.infinity,
            height: m.loadingLine2Height,
            radius: m.loadingLine2Radius,
          ),
          SizedBox(height: m.loadingGap2),
          BookingDetailsLoadingBox(
            width: m.loadingLine3Width,
            height: m.loadingLine2Height,
            radius: m.loadingLine2Radius,
          ),
          SizedBox(height: m.loadingGap3),
          BookingDetailsLoadingBox(
            width: double.infinity,
            height: 1,
            radius: 1,
          ),
          SizedBox(height: m.loadingGap4),
          BookingDetailsLoadingBox(
            width: m.loadingLine4Width,
            height: m.loadingLine4Height,
            radius: m.loadingLine4Radius,
          ),
        ],
      ),
    );
  }
}

class BookingDetailsLoadingBox extends StatelessWidget {
  const BookingDetailsLoadingBox({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.border.withValues(
          alpha: 0.45,
        ),
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}
