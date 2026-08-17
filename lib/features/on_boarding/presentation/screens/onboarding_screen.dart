import 'package:flutter/material.dart';
import '../../data/model/on_boarding_feature.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_bottom_bar.dart';
import '../widgets/onboarding_metrics.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_top_bar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNextPage() {
    if (_currentPage == OnBoardingContent.contents.length - 1) {
      widget.onFinish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleBackPage() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          OnboardingBackground(isDark: isDark),
          LayoutBuilder(
            builder: (context, constraints) {
              final m = OnboardingMetrics.of(context, constraints);

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: m.hPad),
                  child: Column(
                    children: [
                      OnboardingTopBar(m: m, onSkip: widget.onFinish),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: OnBoardingContent.contents.length,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemBuilder: (context, index) {
                            return OnboardingPageContent(
                              content: OnBoardingContent.contents[index],
                              m: m,
                            );
                          },
                        ),
                      ),
                      OnboardingBottomBar(
                        m: m,
                        currentPage: _currentPage,
                        total: OnBoardingContent.contents.length,
                        onBack: _handleBackPage,
                        onNext: _handleNextPage,
                      ),
                      SizedBox(height: m.bottomGap),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
