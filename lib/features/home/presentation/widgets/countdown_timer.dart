import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    this.duration = const Duration(hours: 2, minutes: 14, seconds: 38),
  });

  final Duration duration;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remaining;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    remaining = widget.duration;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining.inSeconds > 0) {
        setState(() {
          remaining -= const Duration(seconds: 1);
        });
      } else {
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _format(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(remaining),
      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
    );
  }
}
