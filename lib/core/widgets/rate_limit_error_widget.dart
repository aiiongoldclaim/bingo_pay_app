import 'package:flutter/material.dart';
import 'dart:async';
import '../error/failures.dart';
import 'app_button.dart';

class RateLimitErrorWidget extends StatefulWidget {
  final RateLimitFailure failure;
  final VoidCallback? onRetry;
  final bool fullScreen;

  const RateLimitErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.fullScreen = true,
  });

  @override
  State<RateLimitErrorWidget> createState() => _RateLimitErrorWidgetState();
}

class _RateLimitErrorWidgetState extends State<RateLimitErrorWidget> {
  late Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.failure.retryAfterSeconds ?? 60;
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.shopping_cart_outlined,
            size: 40,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'High Demand',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[900],
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Too many people are shopping right now',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait a moment and try again',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            border: Border.all(
              color: Colors.orange[200]!,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Next attempt in',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_secondsRemaining',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
              ),
              Text(
                'seconds',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (widget.onRetry != null)
          SizedBox(
            width: double.infinity,
            child: _secondsRemaining <= 0
                ? AppButton(
                    label: 'Continue Shopping',
                    onPressed: widget.onRetry,
                  )
                : ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Retrying in $_secondsRemaining s',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
          ),
        const SizedBox(height: 16),
        Text(
          'Your items are safe in your cart',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );

    if (widget.fullScreen) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: content,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: content,
      ),
    );
  }
}
