import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 0-based
  final int totalSteps;
  final List<String>? stepLabels;
  final ValueChanged<int>? onStepTapped;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.stepLabels,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                height: 2,
                color: index ~/ 2 < currentStep ? color : color.withAlpha(60),
              ),
            ),
          );
        }
        final step = index ~/ 2;
        final isDone = step < currentStep;
        final isCurrent = step == currentStep;
        final circle = AnimatedContainer(
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
        final tappable = isDone && onStepTapped != null;
        final wrappedCircle = tappable
            ? GestureDetector(onTap: () => onStepTapped!(step), child: circle)
            : circle;
        if (stepLabels == null) return wrappedCircle;
        return Column(
          children: [
            wrappedCircle,
            const SizedBox(height: 4),
            Text(
              stepLabels![step],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? color : Colors.grey[600],
              ),
            ),
          ],
        );
      }),
    );
  }
}
