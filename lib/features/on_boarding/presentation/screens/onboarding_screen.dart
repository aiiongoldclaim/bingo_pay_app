import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/model/on_boarding_feature.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_background.dart';
import '../widgets/onboarding_bottom_bar.dart';
import '../widgets/onboarding_metrics.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/onboarding_top_bar.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>(),
      child: _OnboardingView(onFinish: onFinish),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView({required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();

  static const _animationDuration = Duration(milliseconds: 300);
  static const _animationCurve = Curves.easeOutCubic;

  // Guards against a fast double/triple tap racing ahead of the in-flight
  // PageView animation — without this, the cubit's page counter can reach
  // the last page (and call onFinish) before the PageView has visually
  // caught up to the first tap.
  bool _isAnimating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _animateTo(int Function() targetPage) async {
    _isAnimating = true;
    await _pageController.animateToPage(
      targetPage(),
      duration: _animationDuration,
      curve: _animationCurve,
    );
    if (mounted) _isAnimating = false;
  }

  void _handleNext() {
    if (_isAnimating) return;

    final isFinished = context.read<OnboardingCubit>().goNext();

    if (isFinished) {
      widget.onFinish();
      return;
    }

    _animateTo(() => context.read<OnboardingCubit>().state.currentPage);
  }

  void _handleBack() {
    if (_isAnimating) return;

    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.isFirstPage) return;

    cubit.goBack();
    _animateTo(() => cubit.state.currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(),

          LayoutBuilder(
            builder: (context, constraints) {
              final metrics = OnboardingMetrics.of(context, constraints);

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
                  child: Column(
                    children: [
                      OnboardingTopBar(
                        metrics: metrics,
                        onSkip: widget.onFinish,
                      ),

                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: OnBoardingContent.contents.length,
                          onPageChanged:
                          context.read<OnboardingCubit>().onPageChanged,
                          itemBuilder: (context, index) =>
                              OnboardingPageContent(
                                content: OnBoardingContent.contents[index],
                                metrics: metrics,
                              ),
                        ),
                      ),

                      BlocBuilder<OnboardingCubit, OnboardingState>(
                        builder: (context, state) => OnboardingBottomBar(
                          metrics: metrics,
                          currentPage: state.currentPage,
                          total: state.totalPages,
                          onBack: _handleBack,
                          onNext: _handleNext,
                        ),
                      ),

                      SizedBox(height: metrics.bottomGap),
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