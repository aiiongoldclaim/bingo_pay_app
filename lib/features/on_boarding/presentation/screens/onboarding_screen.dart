import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../../data/model/on_boarding_feature.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_metrics.dart';
import '../widgets/vault_onboarding_page.dart';

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
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final page = OnBoardingContent.contents[state.currentPage];
        final tone = VaultOnboardingTone(page.darkPage);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (page.darkPage
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = OnboardingMetrics.of(context, constraints);
                final padding = MediaQuery.paddingOf(context);
                final buttonHeight = metrics.isRow ? 46.0 : 54.0;
                const topBarHeight = 52.0;
                final controlsHeight = buttonHeight + metrics.gapImage * 0.6;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: OnBoardingContent.contents.length,
                      onPageChanged:
                      context.read<OnboardingCubit>().onPageChanged,
                      itemBuilder: (context, index) => VaultOnboardingPage(
                        content: OnBoardingContent.contents[index],
                        metrics: metrics,
                        topInset: padding.top + topBarHeight,
                        bottomInset: padding.bottom +
                            controlsHeight +
                            metrics.bottomGap * 1.5,
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: metrics.hPad * 0.6),
                        child: Column(
                          children: [
                            SizedBox(
                              height: topBarHeight,
                              child: Row(
                                children: [
                                  const Spacer(),
                                  Semantics(
                                    button: true,
                                    label: 'Skip onboarding',
                                    child: TextButton(
                                      onPressed: widget.onFinish,
                                      child: Text(
                                        'Skip',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: metrics.skipFont,
                                          fontWeight: FontWeight.w600,
                                          color: tone.title,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            VaultOnboardingDots(
                              count: state.totalPages,
                              currentPage: state.currentPage,
                              tone: tone,
                              dotSize: metrics.dotSize,
                            ),

                            SizedBox(height: metrics.gapImage),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: metrics.hPad * 0.4,
                              ),
                              child: ConstrainedBox(
                                constraints:
                                const BoxConstraints(maxWidth: 480),
                                child: VaultPillButton(
                                  label: page.cta,
                                  height: buttonHeight,
                                  style: !page.darkPage
                                      ? VaultPillStyle.plum
                                      : state.isLastPage
                                      ? VaultPillStyle.gold
                                      : VaultPillStyle.outlineGold,
                                  showArrow: true,
                                  onPressed: _handleNext,
                                ),
                              ),
                            ),

                            SizedBox(height: metrics.bottomGap * 1.5),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

