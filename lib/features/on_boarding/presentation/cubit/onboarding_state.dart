import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final int totalPages;

  const OnboardingState({
    this.currentPage = 0,
    required this.totalPages,
  });

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == totalPages - 1;

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalPages];
}