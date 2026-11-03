import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/review_models.dart';
import '../cubit/review_form_cubit.dart';
import '../widgets/review_widgets.dart';

/// Write, edit or delete a review. Pops `true` once something changed.
class ReviewFormScreen extends StatelessWidget {
  final ReviewFormArgs args;

  const ReviewFormScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReviewFormCubit>()..start(args),
      child: _ReviewFormView(args: args),
    );
  }
}

class _ReviewFormView extends StatefulWidget {
  final ReviewFormArgs args;

  const _ReviewFormView({required this.args});

  @override
  State<_ReviewFormView> createState() => _ReviewFormViewState();
}

class _ReviewFormViewState extends State<_ReviewFormView> {
  final _title = TextEditingController();
  final _comment = TextEditingController();
  bool _prefilled = false;

  bool get _isProduct => widget.args.kind == ReviewKind.product;

  @override
  void initState() {
    super.initState();
    _prefill(widget.args.review);
  }

  /// Once: from the args, or from the lookup when only the uuid was known.
  void _prefill(Review? review) {
    if (_prefilled || review == null) return;
    _prefilled = true;
    _title.text = review.title ?? '';
    _comment.text = review.comment ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final cubit = context.read<ReviewFormCubit>();
    // Small enough for the 1 MB-per-photo limit.
    final file = await ImagePickerHelper.pick(
      context,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (file != null) await cubit.addPhotos([file]);
  }

  Future<void> _delete() async {
    final cubit = context.read<ReviewFormCubit>();
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete this review?',
      message: 'It will no longer show on the product or count in its rating.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final cubit = context.read<ReviewFormCubit>();

    return BlocConsumer<ReviewFormCubit, ReviewFormState>(
      listenWhen: (prev, next) =>
          next.error != null ||
          next.doneMessage != null ||
          (prev.loading && !next.loading),
      listener: (context, state) {
        _prefill(state.existing);
        if (state.error != null) AppSnackbar.showError(context, state.error!);
        if (state.doneMessage != null) {
          AppSnackbar.showSuccess(context, state.doneMessage!);
          context.pop(true);
        }
      },
      builder: (context, state) {
        final existing = state.existing;
        final Widget body;
        if (state.loadError != null) {
          body = AppErrorWidget(
            failure: UnknownFailure(state.loadError!),
            onRetry: () => cubit.start(widget.args),
          );
        } else if (state.loading) {
          body = Center(child: CircularProgressIndicator(color: c.brand));
        } else {
          final heading = AppTextStyles.bodyLarge.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          );
          final muted = AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
          );
          body = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.args.subject, style: heading),
              const SizedBox(height: 16),
              Text('Your rating', style: muted),
              ReviewStars(
                value: state.rating,
                size: 34,
                onChanged: state.canSave ? cubit.setRating : null,
              ),
              if (!state.canSave)
                Text(
                  'Reviews can be edited for 30 days after they are written.',
                  style: muted,
                ),
              const SizedBox(height: 16),
              if (_isProduct) ...[
                TextField(
                  controller: _title,
                  enabled: state.canSave,
                  maxLength: 120,
                  decoration: _decoration('Title (optional)'),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _comment,
                enabled: state.canSave,
                maxLines: 4,
                maxLength: _isProduct ? 2000 : 1000,
                decoration: _decoration(
                  _isProduct
                      ? 'What did you like or dislike? (optional)'
                      : 'How was the delivery? (optional)',
                ),
              ),
              if (_isProduct) ...[
                const SizedBox(height: 8),
                Text(
                  'Photos (optional) · up to $maxReviewPhotos · 1 MB each',
                  style: muted,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.canSave && state.images.length < maxReviewPhotos)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: state.uploading ? null : _addPhoto,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.border),
                            ),
                            child: state.uploading
                                ? Center(
                                    child: SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: c.brand,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo_outlined,
                                    color: c.textSecondary,
                                  ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: ReviewPhotoStrip(
                        urls: state.images,
                        onRemove: state.canSave ? cubit.removePhoto : null,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        }

        return Scaffold(
          backgroundColor: c.background,
          appBar: CustomAppBar(
            title: existing != null
                ? 'Your review'
                : _isProduct
                ? 'Write a review'
                : 'Rate your delivery',
          ),
          body: body,
          bottomNavigationBar: state.loading || state.loadError != null
              ? null
              : AppBottomActionBar(
                  primaryLabel: existing != null ? 'Update' : 'Submit',
                  primaryLoading: state.busy,
                  onPrimaryPressed: state.canSave && !state.uploading
                      ? () => cubit.submit(
                          title: _title.text,
                          comment: _comment.text,
                        )
                      : null,
                  secondaryLabel: existing != null ? 'Delete' : null,
                  secondaryIcon: Icons.delete_outline_rounded,
                  onSecondaryPressed: state.busy ? null : _delete,
                ),
        );
      },
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}
