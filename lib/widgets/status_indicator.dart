import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Satu baris status: titik berwarna, label, dan teks status.
class StatusIndicator extends StatelessWidget {
  final String label;
  final String statusText;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.statusText,
    required this.isActive,
    this.activeColor = AppColors.success,
    this.inactiveColor = AppColors.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            statusText,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
