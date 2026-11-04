import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Kartu satu sensor berbentuk gauge melingkar.
/// Stack menumpuk angka di tengah CircularProgressIndicator.
class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  final double progress; // 0.0 - 1.0
  final bool isWarning;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.color,
    required this.progress,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeColor = isWarning ? AppColors.danger : color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: gaugeColor, size: 20),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0).toDouble(),
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: gaugeColor,
                      backgroundColor: AppColors.border,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isWarning
                    ? AppColors.danger.withValues(alpha: 0.12)
                    : AppColors.secondary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? AppColors.danger : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
