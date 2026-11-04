import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/bar_chart_card.dart';

/// Riwayat dan grafik (FR-19) + riwayat aksi aktuator.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseService databaseService = DatabaseService();
  final List<String> ranges = const ['Hari', 'Minggu', 'Bulan'];
  String selectedRange = 'Minggu';

  @override
  Widget build(BuildContext context) {
    final data = databaseService.getHistory(selectedRange);
    final logs = databaseService.getLogs();
    final labels = data.map((d) => d.label).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: ranges.map((range) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.small),
                      child: ChoiceChip(
                        label: Text(range),
                        selected: selectedRange == range,
                        selectedColor: AppColors.secondary,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        onSelected: (_) => setState(() => selectedRange = range),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.medium),
                BarChartCard(
                  title: 'Konsumsi Pakan (gram)',
                  labels: labels,
                  values: data.map((d) => d.pakanGram).toList(),
                  color: AppColors.accentDark,
                ),
                const SizedBox(height: AppSpacing.medium),
                BarChartCard(
                  title: 'Konsumsi Air (liter)',
                  labels: labels,
                  values: data.map((d) => d.airLiter).toList(),
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Riwayat Aksi Aktuator',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.small),
                Card(
                  child: Column(
                    children: logs.map((log) {
                      final ok = log.status == 'berhasil';
                      return ListTile(
                        leading: Icon(
                          ok ? Icons.check_circle : Icons.error,
                          color: ok ? AppColors.success : AppColors.danger,
                        ),
                        title: Text(log.aksi),
                        subtitle: Text('${log.pemicu} • ${log.waktu}'),
                        trailing: Text(
                          log.status,
                          style: TextStyle(
                            color: ok ? AppColors.success : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
