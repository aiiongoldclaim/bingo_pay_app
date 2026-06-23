import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/custom_container.dart';

class ProductImageSection extends StatefulWidget {
  const ProductImageSection({
    super.key,
    required this.icon,
    required this.images,
    required this.isFavourite,
    required this.onBack,
    required this.onShare,
    required this.onToggleFavourite,
  });

  final IconData icon;
  final List<String> images;

  final bool isFavourite;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFavourite;

  @override
  State<ProductImageSection> createState() => _ProductImageSectionState();
}

class _ProductImageSectionState extends State<ProductImageSection> {
  final PageController _pageController = PageController();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.accent.withOpacity(.10),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// App Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBarSearchAction(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: widget.onBack,
                  ),

                  Row(
                    children: [
                      AppBarSearchAction(
                        icon: Icons.ios_share_outlined,
                        onTap: widget.onShare,
                      ),

                      AppBarSearchAction(
                        icon: widget.isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        onTap: widget.onToggleFavourite,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Product Slider
            SizedBox(
              height: 32.h,
              width: double.infinity,
              child: widget.images.isEmpty
                  ? Center(
                      child: Icon(
                        widget.icon,
                        size: 40.w,
                        color: ThemeColors.blue,
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (_, index) {
                        return Padding(
                          padding: EdgeInsets.all(5.w),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) {
                              return Icon(
                                widget.icon,
                                size: 40.w,
                                color: ThemeColors.blue,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 1.h),

            /// Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.isEmpty ? 1 : widget.images.length,
                (index) {
                  final selected = currentIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: selected ? 6.w : 2.w,
                    height: .8.h,
                    decoration: BoxDecoration(
                      color: selected ? ThemeColors.blue : ThemeColors.line,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
