import 'package:flutter/material.dart';
import 'dart:async';
import '../error/failures.dart';
import 'app_button.dart';

class AppErrorWidget extends StatefulWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.failure, this.onRetry});

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget> {
  late Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    if (widget.failure is RateLimitFailure) {
      final rateLimitFailure = widget.failure as RateLimitFailure;
      _secondsRemaining = rateLimitFailure.retryAfterSeconds ?? 60;
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final isRateLimit = widget.failure is RateLimitFailure;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRateLimit ? Icons.schedule : Icons.error_outline,
              size: 48,
              color: isRateLimit ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isRateLimit ? 'Server Busy' : 'Error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.failure.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isRateLimit && _secondsRemaining > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Retrying in $_secondsRemaining seconds...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
            if (widget.onRetry != null) ...[
              const SizedBox(height: 24),
              if (_secondsRemaining <= 0)
                AppButton(label: 'Try Again', onPressed: widget.onRetry)
              else
                ElevatedButton(
                  onPressed: null,
                  child: Text(
                    'Try Again ($_secondsRemaining)',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
