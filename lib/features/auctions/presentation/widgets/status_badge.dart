import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'LIVE':
        return Colors.green;

      case 'ENDING_SOON':
        return Colors.orange;

      case 'STARTING_SOON':
        return Colors.blue;

      case 'CLOSED':
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }
}