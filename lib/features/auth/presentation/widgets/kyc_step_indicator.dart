import 'package:flutter/material.dart';

class KycStepIndicator extends StatelessWidget {
  final int currentStep; // 0-based
  final int totalSteps;

  const KycStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < currentStep ? color : color.withAlpha(60),
            ),
          );
        }
        final step = index ~/ 2;
        final isDone = step < currentStep;
        final isCurrent = step == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isCurrent ? color : color.withAlpha(30),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
