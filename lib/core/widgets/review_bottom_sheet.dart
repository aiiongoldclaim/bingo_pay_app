import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/in_app_review_cubit.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String positiveRatingMessage;
  final String negativeRatingMessage;
  final VoidCallback? onDismiss;

  const ReviewBottomSheet({
    super.key,
    this.title = 'Rate This App',
    this.subtitle =
        'Help us improve by sharing your feedback and rating this app',
    this.positiveRatingMessage =
        'Thanks for rating us! Help us improve by sharing your review.',
    this.negativeRatingMessage = 'We appreciate your feedback!',
    this.onDismiss,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _selectedRating = 0;
  bool _showReviewPrompt = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Star Rating Widget
              _buildStarRating(context),
              const SizedBox(height: 24),
              // Show review prompt after rating >= 4
              if (_showReviewPrompt && _selectedRating >= 4)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        widget.positiveRatingMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber[800],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // Show lower rating message
              if (_showReviewPrompt && _selectedRating > 0 && _selectedRating < 4)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        widget.negativeRatingMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue[800],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          final ratingValue = index + 1;
          final isSelected = _selectedRating >= ratingValue;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRating = ratingValue;
                _showReviewPrompt = true;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_outline,
                  color: isSelected ? Colors.amber : Colors.grey[400],
                  size: 40,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocListener<InAppReviewCubit, InAppReviewState>(
      listener: (context, state) {
        if (state is ReviewRequestedState || state is AppStoreOpenedState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thank you for your review!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            if (_selectedRating > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRating > 0
                      ? () {
                          context.read<InAppReviewCubit>().requestReview();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    _selectedRating >= 4
                        ? 'Share Your Review'
                        : 'Submit Rating',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  widget.onDismiss?.call();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
