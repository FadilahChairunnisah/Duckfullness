import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Riwayat aktivitas untuk ADMIN: login, perubahan akun, dan
/// perintah yang dikirim peternak ke perangkat.
class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final DatabaseService databaseService = DatabaseService();
  final List<String> filters = const ['Semua', 'Sesi', 'Akun', 'Perangkat'];
  String selectedFilter = 'Semua';

  IconData iconFor(String kategori) {
    switch (kategori) {
      case 'sesi':
        return Icons.login;
      case 'perangkat':
        return Icons.settings_remote;
      default:
        return Icons.manage_accounts;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = databaseService
        .getActivities()
        .where((log) =>
            selectedFilter == 'Semua' ||
            log.kategori == selectedFilter.toLowerCase())
        .take(100)
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.small,
                  children: filters.map((filter) {
                    return ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      selectedColor: AppColors.secondary,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.border),
                      onSelected: (_) => setState(() => selectedFilter = filter),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.medium),
                Card(
                  child: logs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.large),
                          child: Center(child: Text('Belum ada aktivitas')),
                        )
                      : Column(
                          children: logs.map((log) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.secondary.withValues(alpha: 0.5),
                                child: Icon(
                                  iconFor(log.kategori),
                                  color: AppColors.text,
                                  size: 20,
                                ),
                              ),
                              title: Text(log.aksi),
                              subtitle: Text(
                                '@${log.username} • ${formatWaktu(log.waktu)}',
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
