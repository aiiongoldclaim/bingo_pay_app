import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/review_models.dart';
import '../cubit/review_form_cubit.dart';
import '../cubit/reviews_cubits.dart';
import '../widgets/review_widgets.dart';

/// The customer's product reviews and delivery ratings: edit or delete.
/// New reviews start from a delivered order.
class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MyReviewsCubit>()..load(),
      child: Builder(
        builder: (context) {
          final c = context.c;
          final cubit = context.read<MyReviewsCubit>();
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: c.background,
              appBar: const CustomAppBar(title: 'My Reviews'),
              body: BlocBuilder<MyReviewsCubit, ReviewsLoad<MyReviews>>(
                builder: (context, state) {
                  if (state.error != null) {
                    return AppErrorWidget(
                      failure: UnknownFailure(state.error!),
                      onRetry: cubit.load,
                    );
                  }
                  final data = state.data;
                  if (data == null) return const _ListShimmer();
                  return Column(
                    children: [
                      TabBar(
                        labelColor: c.brand,
                        indicatorColor: c.brand,
                        unselectedLabelColor: c.textSecondary,
                        tabs: [
                          Tab(text: 'Products (${data.products.length})'),
                          Tab(text: 'Deliveries (${data.agents.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _ReviewList(
                              reviews: data.products,
                              empty:
                                  'No product reviews yet.\nYou can review items from a delivered order.',
                            ),
                            _ReviewList(
                              reviews: data.agents,
                              empty:
                                  'No delivery ratings yet.\nYou can rate a delivery from a delivered order.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final String empty;

  const _ReviewList({required this.reviews, required this.empty});

  Future<void> _edit(BuildContext context, Review review) async {
    final cubit = context.read<MyReviewsCubit>();
    final changed = await context.push<bool>(
      AppRoutes.reviewForm,
      extra: ReviewFormArgs(
        kind: review.kind,
        subject: review.subject,
        review: review,
      ),
    );
    if (changed == true && context.mounted) cubit.load();
  }

  Future<void> _delete(BuildContext context, Review review) async {
    final cubit = context.read<MyReviewsCubit>();
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete this review?',
      message: 'It will no longer show or count in the rating.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    final error = await cubit.delete(review);
    if (!context.mounted) return;
    error == null
        ? AppSnackbar.showSuccess(context, 'Review deleted')
        : AppSnackbar.showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cubit = context.read<MyReviewsCubit>();
    return RefreshIndicator(
      color: c.brand,
      onRefresh: cubit.load,
      child: reviews.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(32),
              children: [
                Icon(Icons.rate_review_outlined, size: 40, color: c.textMuted),
                const SizedBox(height: 12),
                Text(
                  empty,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = reviews[i];
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: ReviewTile(
                    review: r,
                    showSubject: true,
                    actions: [
                      if (r.canEdit)
                        TextButton(
                          onPressed: () => _edit(context, r),
                          child: const Text('Edit'),
                        ),
                      TextButton(
                        onPressed: () => _delete(context, r),
                        style: TextButton.styleFrom(foregroundColor: c.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: 110,
          decoration: BoxDecoration(
            color: context.c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
