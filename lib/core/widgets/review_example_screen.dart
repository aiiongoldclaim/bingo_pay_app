import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/in_app_review_cubit.dart';
import '../utils/review_helper.dart';

/// Example screen showing different ways to trigger in-app reviews
/// Remove this file in production - it's for reference only
class ReviewExampleScreen extends StatelessWidget {
  const ReviewExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Feature Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Dialog Examples',
              children: [
                ElevatedButton(
                  onPressed: () {
                    ReviewHelper.showReviewDialog(context);
                  },
                  child: const Text('Show Default Dialog'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ReviewHelper.showReviewDialog(
                      context,
                      title: 'How was your purchase?',
                      subtitle:
                          'Your honest feedback helps us improve our service',
                      positiveRatingMessage:
                          'Excellent! Please share your positive experience on the Play Store',
                      negativeRatingMessage:
                          'Thank you for your feedback. We\' ll work on improvement',
                    );
                  },
                  child: const Text('Show Custom Dialog'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Bottom Sheet Examples',
              children: [
                ElevatedButton(
                  onPressed: () {
                    ReviewHelper.showReviewBottomSheet(context);
                  },
                  child: const Text('Show Default Bottom Sheet'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ReviewHelper.showReviewBottomSheet(
                      context,
                      title: 'Rate Your Experience',
                      subtitle: 'Help us serve you better',
                      onDismiss: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review dismissed'),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Show Bottom Sheet with Callback'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Direct Request (No UI)',
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<InAppReviewCubit>().requestReview();
                  },
                  child: const Text('Request Review Directly'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<InAppReviewCubit>().openAppStore();
                  },
                  child: const Text('Open App Store (Fallback)'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Using Extension Method',
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Using the extension method on BuildContext
                    context.showReviewDialog(
                      title: 'Extension Method Example',
                      subtitle: 'This uses the context extension',
                    );
                  },
                  child: const Text('Show Dialog (Extension)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.showReviewBottomSheet(
                      title: 'Extension Method Example',
                      subtitle: 'This uses the context extension',
                    );
                  },
                  child: const Text('Show Bottom Sheet (Extension)'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'State Listener Example',
              children: [
                BlocListener<InAppReviewCubit, InAppReviewState>(
                  listener: (context, state) {
                    if (state is ReviewRequestedState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Review requested successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is ReviewNotAvailableState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Review not available on this device'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else if (state is ErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${state.message}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      // This will show snackbar based on state
                      context.read<InAppReviewCubit>().requestReview();
                    },
                    child: const Text('Request Review (with listener)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Real-World Implementation Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip(
                    'After payment success: Show dialog on payment success page',
                  ),
                  _buildTip(
                    'After Nth purchase: Show after 3rd or 5th purchase',
                  ),
                  _buildTip(
                    'After service completion: Trigger after booking completion',
                  ),
                  _buildTip(
                    'Avoid showing: On app first open, after errors, multiple times per session',
                  ),
                  _buildTip(
                    'Customize messages: Update title, subtitle for context relevance',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8, top: 2),
            child: Text('•', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
