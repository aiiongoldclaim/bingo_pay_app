# Rate Limit (429) Error Handling

This document explains how the app now handles API rate limiting (429 Too Many Requests) errors with user-friendly UI.

## What Changed

### New Components

1. **RateLimitException** - Exception thrown when API returns 429 status
2. **RateLimitFailure** - Failure object with retry countdown information
3. **RateLimitErrorWidget** - Beautiful, e-commerce-optimized UI for rate limit errors
4. **ErrorWidgetBuilder** - Extension for easy error widget creation

### How It Works

When an API call returns a 429 status:

1. **ErrorInterceptor** catches the response and creates a `RateLimitException`
2. **ErrorHandler** maps it to a `RateLimitFailure`
3. Your BLoC/screen receives the failure
4. UI displays the rate limit error widget with countdown timer

## Usage in Your Screens

### Option 1: Using the Builder Extension (Recommended)

```dart
BlocBuilder<YourBloc, YourState>(
  builder: (context, state) {
    if (state is ErrorState) {
      return state.failure.buildErrorWidget(
        onRetry: () => context.read<YourBloc>().add(RetryEvent()),
        fullScreen: true, // or false for embedded errors
      );
    }
    return YourContentWidget();
  },
);
```

### Option 2: Direct Widget Usage

```dart
import 'package:your_app/core/widgets/rate_limit_error_widget.dart';

if (failure is RateLimitFailure) {
  return RateLimitErrorWidget(
    failure: failure,
    onRetry: () => _retry(),
    fullScreen: true,
  );
}
```

### Option 3: Using AppErrorWidget (for all error types)

```dart
return AppErrorWidget(
  failure: failure,
  onRetry: () => _retry(),
);
```

The AppErrorWidget automatically adapts based on failure type:
- Shows rate limit UI with countdown for `RateLimitFailure`
- Shows standard error UI for other failures

## Features

### Rate Limit Widget Features

- ✅ **Friendly messaging**: "High Demand" instead of technical error
- ✅ **Automatic countdown**: Shows seconds until retry is enabled
- ✅ **Reassuring copy**: "Your items are safe in your cart"
- ✅ **Shopping cart icon**: Visually relevant to e-commerce context
- ✅ **Disabled retry button**: Can't retry until countdown finishes
- ✅ **Full-screen option**: Works as full screen or embedded in scrollable views
- ✅ **Auto-disposal**: Timer is properly cleaned up

### Retry-After Header

The error interceptor automatically extracts the `Retry-After` header from the response if available:

```dart
// API returns: Retry-After: 60
// UI shows: "Next attempt in 60 seconds"
```

If `Retry-After` header is not provided, defaults to 60 seconds.

## Example Integration in Product Details Screen

```dart
// In your BLoC or state management
state.whenOrNull(
  error: (failure) => failure.buildErrorWidget(
    onRetry: () {
      context.read<ProductBloc>().add(FetchProductEvent(productId));
    },
    fullScreen: false, // embedded in scrollable area
  ),
);
```

## UI Appearance

### Rate Limit Error Screen

```
┌─────────────────────────────────┐
│                                 │
│        🛒 (in circle)            │
│                                 │
│      High Demand                │
│  Too many people are shopping   │
│     right now                   │
│                                 │
│  ┌──────────────────────────┐   │
│  │  Next attempt in         │   │
│  │         60               │   │
│  │      seconds             │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────────────────────┐   │
│  │  Retrying in 60 s        │   │
│  └──────────────────────────┘   │
│                                 │
│  Your items are safe in cart    │
│                                 │
└─────────────────────────────────┘
```

When countdown reaches 0:

```
┌─────────────────────────────────┐
│  ┌──────────────────────────┐   │
│  │  Continue Shopping       │   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

## Error Messages

The error message is extracted from the API response:

```dart
// API returns:
{
  "statusCode": 429,
  "message": "ThrottlerException: Too Many Requests"
}

// User sees:
// "High Demand"
// "Too many people are shopping right now"
// [The message from API is logged but not shown in main error widget]
```

## Testing

To test rate limit errors:

1. Mock an API response with status 429:

```dart
final mockResponse = Response(
  requestOptions: RequestOptions(path: '/api/products'),
  statusCode: 429,
  data: {
    'statusCode': 429,
    'message': 'Too Many Requests',
  },
);
```

2. Or use your API with actual rate limiting enabled

## Integration Points

These files handle the rate limiting:

- `lib/core/api/interceptors/error_interceptor.dart` - Catches 429 responses
- `lib/core/error/exceptions.dart` - Defines RateLimitException
- `lib/core/error/failures.dart` - Defines RateLimitFailure
- `lib/core/error/error_handler.dart` - Maps exception to failure
- `lib/core/widgets/rate_limit_error_widget.dart` - UI for rate limit errors
- `lib/core/widgets/app_error_widget.dart` - Generic error UI (updated)
- `lib/core/widgets/error_widget_builder.dart` - Helper extension

## Best Practices

1. **Use full-screen for main flows**: Product browsing, checkout, payments
2. **Use embedded for filters/sorts**: Smaller operations that don't need full screen
3. **Keep the retry button**: Let users retry as soon as the timer runs out
4. **Don't add more messaging**: The UI is self-explanatory
5. **Test with slow networks**: Verify countdown works correctly on slow connections

## Future Enhancements

Possible improvements:

- Add exponential backoff for automatic retries
- Log rate limit events for analytics
- Add rate limit recovery suggestion (e.g., "Check back in 2 minutes")
- Implement client-side request queuing to prevent rate limits
- Add haptic feedback when timer reaches zero
