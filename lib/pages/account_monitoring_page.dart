import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/stat_card.dart';

/// Monitoring untuk ADMIN: memantau akun-akun yang ada
/// (siapa online, kapan terakhir login). Bukan monitoring kandang.
class AccountMonitoringPage extends StatelessWidget {
  final User currentUser;

  const AccountMonitoringPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final users = databaseService.getUsers();
    final adminCount = users.where((u) => u.isAdmin).length;
    final onlineCount =
        users.where((u) => databaseService.isOnline(u.username)).length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.header,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${currentUser.name}!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pantau akun pengguna aplikasi',
                        style: TextStyle(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Total Akun',
                        value: '${users.length}',
                        icon: Icons.groups,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: StatCard(
                        label: 'Sedang Online',
                        value: '$onlineCount',
                        icon: Icons.wifi,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Admin',
                        value: '$adminCount',
                        icon: Icons.admin_panel_settings,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: StatCard(
                        label: 'Peternak',
                        value: '${users.length - adminCount}',
                        icon: Icons.agriculture,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Status Akun',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.small),
                Card(
                  child: Column(
                    children: users.map((user) {
                      final online = databaseService.isOnline(user.username);
                      final last = databaseService.getLastLogin(user.username);
                      return ListTile(
                        isThreeLine: true,
                        leading: CircleAvatar(
                          backgroundColor:
                              user.isAdmin ? AppColors.accent : AppColors.secondary,
                          child: Text(
                            user.initial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          '@${user.username} • ${user.role}\n'
                          '${last == null ? 'Belum pernah login' : 'Terakhir login: ${formatWaktu(last)}'}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: online
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            online ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: online
                                  ? AppColors.success
                                  : AppColors.secondaryText,
                            ),
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
