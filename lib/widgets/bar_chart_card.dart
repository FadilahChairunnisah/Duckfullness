import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Grafik batang sederhana dari Row + Container (tanpa package tambahan).
class BarChartCard extends StatelessWidget {
  final String title;
  final List<String> labels;
  final List<double> values;
  final Color color;

  const BarChartCard({
    super.key,
    required this.title,
    required this.labels,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.fold<double>(0, (a, b) => b > a ? b : a);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.medium),
            SizedBox(
              height: 170,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(values.length, (i) {
                  final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            values[i].toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 110 * ratio,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(labels[i], style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
