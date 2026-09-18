# In-App Review & Rating Feature Guide

## Overview
This guide explains how to implement and use the in-app review and rating feature in the Bingo Pay app. This feature allows users to rate and review your app directly within the app, with the reviews being submitted to Google Play Console (Android) and App Store (iOS).

## Installation
The feature uses the `in_app_review` package which is already added to `pubspec.yaml`. Make sure to run:
```bash
flutter pub get
```

## Components

### 1. **InAppReviewService** (`lib/core/services/in_app_review_service.dart`)
Core service that handles interaction with native review APIs.

**Methods:**
- `isReviewAvailable()` - Check if in-app review is available
- `requestReview()` - Request in-app review from Play Store/App Store
- `openAppStoreReview()` - Fallback to open app store review page
- `requestReviewWithRating()` - Request review with rating (for future enhancements)

### 2. **InAppReviewCubit** (`lib/core/cubit/in_app_review_cubit.dart`)
State management for review UI interactions.

**Methods:**
- `requestReview()` - Async method to request review
- `openAppStore()` - Fallback to open app store
- `reset()` - Reset state

**States:**
- `initial()` - Initial state
- `loading()` - Loading state while requesting review
- `reviewRequested()` - Review dialog opened successfully
- `reviewNotAvailable()` - Review not available on device
- `appStoreOpened()` - App store opened
- `error(message)` - Error occurred

### 3. **UI Widgets**

#### ReviewDialog (`lib/core/widgets/review_dialog.dart`)
A dialog-based review interface with:
- 5-star rating selector
- Animated star transitions
- Custom messages for different ratings
- Submit and "Maybe Later" buttons

#### ReviewBottomSheet (`lib/core/widgets/review_bottom_sheet.dart`)
Alternative bottom sheet implementation, often preferred on mobile:
- Same functionality as dialog
- Better mobile UX with drag handle
- Responsive to keyboard

### 4. **ReviewHelper** (`lib/core/utils/review_helper.dart`)
Utility class and extensions for easy access to review features.

## Usage Examples

### Example 1: Show Review Dialog After Payment Success
```dart
// In your payment success screen
import 'package:bingo_pay/core/utils/review_helper.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Payment Successful!'),
          ElevatedButton(
            onPressed: () {
              // Show review dialog after successful payment
              ReviewHelper.showReviewDialog(
                context,
                title: 'How was your experience?',
                subtitle: 'Your feedback helps us improve our service',
                positiveRatingMessage: 
                  'Thank you! Please share your detailed review on Play Store',
                negativeRatingMessage: 
                  'We appreciate your feedback. Please let us know how we can improve',
                onDismiss: () {
                  // Optional: Do something when user dismisses
                  print('Review dialog dismissed');
                },
              );
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Using Extension Method (Simpler)
```dart
// In any screen with BuildContext available
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Using the extension method
        context.showReviewDialog(
          title: 'Rate Bingo Pay',
          subtitle: 'Help us serve you better',
        );
      },
      child: Text('Rate App'),
    );
  }
}
```

### Example 3: Show Bottom Sheet Instead
```dart
class OrderDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Bottom sheet variant - often better UX
        ReviewHelper.showReviewBottomSheet(
          context,
          title: 'Love this order?',
          subtitle: 'Share your experience with our community',
        );
      },
      child: Text('Feedback'),
    );
  }
}
```

### Example 4: Auto-trigger After Nth Purchase
```dart
// In your order confirmation logic
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  Future<void> _onOrderCompleted(event, emit) async {
    // Your order completion logic
    
    // Check if this is the user's 3rd or 5th purchase
    final purchaseCount = await _repo.getUserPurchaseCount();
    
    if (purchaseCount == 3 || purchaseCount == 5) {
      // Emit event to show review - handle in UI layer
      emit(OrderState.reviewPromptNeeded());
    }
  }
}

// In the UI:
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    if (state is ReviewPromptNeeded) {
      // Wait a moment for UX, then show review
      Future.delayed(Duration(milliseconds: 500), () {
        context.showReviewDialog();
      });
    }
  },
  child: OrderConfirmationScreen(),
);
```

### Example 5: Request Review Without UI (Direct)
```dart
// In scenarios where you want to directly request review
class MyService {
  final InAppReviewCubit _reviewCubit;
  
  Future<void> triggerReviewFlow() async {
    // This will directly open the review flow without custom UI
    await _reviewCubit.requestReview();
  }
}
```

### Example 6: Handle Review States in Listener
```dart
BlocListener<InAppReviewCubit, InAppReviewState>(
  listener: (context, state) {
    if (state is _ReviewRequestedState) {
      // User submitted review
      print('Review submitted!');
      showSnackBar('Thank you for your review!');
    } else if (state is _ReviewNotAvailableState) {
      // Review not available - fallback
      openAppStore();
    } else if (state is _ErrorState) {
      // Error occurred
      showErrorSnackBar(state.message);
    }
  },
  child: YourWidget(),
);
```

## Best Practices

### When to Trigger Review Prompt
1. **After Payment Success** - When user completes a payment
2. **After Nth Purchase** - After 3rd, 5th, 10th purchase
3. **After Successful Service Booking** - Service completed
4. **After Milestone Achievement** - User reaches certain points/levels
5. **After Support Resolution** - After customer support helps user
6. **NOT on First Use** - Don't ask for review immediately
7. **NOT on Negative Events** - Don't ask after errors/crashes

### UI/UX Guidelines
- Use bottom sheet for mobile-first design
- Use dialog for tablet/web
- Wait 1-2 seconds after success before showing
- Provide customizable messages for context
- Always offer "Maybe Later" option
- Don't show multiple times per session
- Show at most once per 7-14 days

## Platform-Specific Behavior

### Android (Google Play)
- Opens Play Store's in-app review dialog
- User can rate and optionally submit review
- Review is posted to Play Console
- Dialog appears in-app, doesn't leave app

### iOS (App Store)
- Opens App Store Review prompt within the app
- User rates the app
- Prompts for review in a sheet
- Similar in-app experience

## Troubleshooting

### Review Not Showing?
1. Make sure app is released on Play Store/App Store
2. Check if review dialog is already shown in session
3. On Android: App must be installed via Play Store
4. On iOS: App must be built with release configuration

### Always Shows Fallback?
- This might mean review flow is not available
- Check device Play Store/App Store installation
- Try on a physical device if testing on emulator

### Test Mode
To test without real Play Store installation:
```dart
// In development, you can test the UI directly
ReviewHelper.showReviewDialog(context);
```

## Integration Checklist

- [ ] Run `flutter pub get`
- [ ] Check that `in_app_review: ^0.2.1` is in pubspec.yaml
- [ ] Verify InAppReviewCubit is provided in app.dart
- [ ] Choose where to trigger review (payment success, order completion, etc.)
- [ ] Customize review dialog messages for your use case
- [ ] Test on physical Android and iOS devices
- [ ] Implement proper state management if showing multiple times
- [ ] Add analytics to track review submissions

## Real-World Implementation Examples

### Example 1: Auto-trigger After Payment Success (1-2 seconds delay)
```dart
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Show review dialog 2 seconds after payment success
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ReviewHelper.showReviewDialog(
          context,
          title: 'Great Transaction!',
          subtitle: 'Your payment was successful. Help us improve!',
          positiveRatingMessage:
              'Thank you! Your positive feedback helps us grow.',
          negativeRatingMessage:
              'We appreciate your feedback. Let us know how we can serve better.',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const Text('Payment Successful!'),
          ],
        ),
      ),
    );
  }
}
```

### Example 2: Smart Trigger Based on Purchase Count
```dart
class SmartReviewTrigger {
  final UserRepository _userRepository;
  
  SmartReviewTrigger(this._userRepository);

  Future<void> handleOrderCompletion(BuildContext context) async {
    final purchaseCount = await _userRepository.getUserPurchaseCount();
    
    // Show review on specific milestones
    if (purchaseCount == 3 || purchaseCount == 5 || purchaseCount == 10) {
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          _showContextualReview(context, purchaseCount);
        }
      });
    }
  }

  void _showContextualReview(BuildContext context, int count) {
    final messages = {
      3: {
        'title': 'Loving Bingo Pay?',
        'subtitle': 'You\'ve made 3 purchases! Share your experience.',
      },
      5: {
        'title': 'Thanks for 5 Purchases!',
        'subtitle': 'We value your loyalty. Your feedback matters.',
      },
      10: {
        'title': 'You\'re Awesome!',
        'subtitle': 'Thanks for 10 purchases! Help us continue improving.',
      },
    };

    final msg = messages[count] ?? messages[3]!;
    
    ReviewHelper.showReviewBottomSheet(
      context,
      title: msg['title']!,
      subtitle: msg['subtitle']!,
    );
  }
}
```

### Example 3: Integration with Payment Success Screen
```dart
class CompletePaymentSuccessHandler {
  final InAppReviewCubit _reviewCubit;
  final UserRepository _userRepository;
  
  Future<void> handlePaymentSuccess(
    BuildContext context,
    Payment payment,
  ) async {
    // Mark as seen
    await _userRepository.markPaymentSuccessShown();
    
    // Get user purchase count
    final purchaseCount = await _userRepository.getUserPurchaseCount();
    
    // Decide when to show review based on purchase history
    if (_shouldTriggerReview(purchaseCount)) {
      await Future.delayed(const Duration(seconds: 1));
      
      if (context.mounted) {
        ReviewHelper.showReviewDialog(
          context,
          title: 'How was your experience?',
          subtitle: 'Your feedback helps us improve',
          positiveRatingMessage: purchaseCount >= 5
              ? 'Thank you! Your loyalty means a lot to us.'
              : 'Awesome! Please share your experience.',
        );
      }
    }
  }

  bool _shouldTriggerReview(int purchaseCount) {
    // Show on 3rd, 5th, 10th purchase, then every 5th after that
    return purchaseCount == 3 ||
        purchaseCount == 5 ||
        purchaseCount == 10 ||
        (purchaseCount > 10 && purchaseCount % 5 == 0);
  }
}

// Usage in payment success:
BlocListener<PaymentBloc, PaymentState>(
  listener: (context, state) {
    if (state is PaymentSuccessState) {
      final handler = CompletePaymentSuccessHandler(
        context.read<InAppReviewCubit>(),
        context.read<UserRepository>(),
      );
      handler.handlePaymentSuccess(context, state.payment);
    }
  },
  child: PaymentSuccessScreen(),
);
```

### Example 4: Settings Page with Rating Option
```dart
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ... other settings
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Rate This App'),
            subtitle: const Text('Share your feedback with us'),
            onTap: () {
              context.showReviewDialog(
                title: 'Rate Bingo Pay',
                subtitle: 'Your feedback helps us improve',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            onTap: () => _sendFeedback(context),
          ),
          // ... more settings
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    // Your feedback logic
  }
}
```

### Example 5: Using State Listeners for Advanced Control
```dart
BlocListener<InAppReviewCubit, InAppReviewState>(
  listener: (context, state) {
    if (state is _ReviewRequestedState) {
      // Review was successfully triggered
      print('✓ Review requested successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is _ReviewNotAvailableState) {
      // Fallback for devices that don't support in-app review
      print('Review not available - opening app store');
      context.read<InAppReviewCubit>().openAppStore();
    } else if (state is _ErrorState) {
      // Handle errors
      print('Error: ${state.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: YourWidget(),
);
```

## Advanced Usage

### Skip Review Prompt for Certain Users
```dart
class SmartReviewTrigger {
  final UserRepository _userRepo;
  
  Future<bool> shouldShowReview() async {
    final user = await _userRepo.getCurrentUser();
    
    // Don't show for power users
    if (user.isSuperUser) return false;
    
    // Don't show if already rated recently
    if (user.lastReviewDate != null) {
      final daysSinceReview = DateTime.now().difference(user.lastReviewDate!).inDays;
      if (daysSinceReview < 7) return false;
    }
    
    return true;
  }
}
```

## Files Location
- Service: `lib/core/services/in_app_review_service.dart`
- Cubit: `lib/core/cubit/in_app_review_cubit.dart`
- State: `lib/core/cubit/in_app_review_state.dart`
- Dialog: `lib/core/widgets/review_dialog.dart`
- Bottom Sheet: `lib/core/widgets/review_bottom_sheet.dart`
- Helper: `lib/core/utils/review_helper.dart`

## Next Steps

1. Run `flutter pub get`
2. Run `flutter pub run build_runner build` to regenerate DI
3. Test the feature on a physical device
4. Integrate into your payment/order success screens
5. Monitor review submissions in Play Console/App Store
