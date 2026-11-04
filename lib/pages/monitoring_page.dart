import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../utils/constants.dart';
import '../widgets/sensor_gauge_row.dart';
import '../widgets/status_indicator.dart';

/// Dashboard (FR-15). Tidak punya state sendiri: semua data datang dari Home.
class MonitoringPage extends StatelessWidget {
  final String userName;
  final SensorData sensor;
  final Device device;

  const MonitoringPage({
    super.key,
    required this.userName,
    required this.sensor,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final airLow = sensor.levelAir < device.airMin;
    final pakanLow = sensor.beratPakan < device.pakanMin;

    final warnings = <String>[
      if (!device.isOnline) 'Perangkat IoT terputus (offline)',
      if (airLow) 'Air hampir habis',
      if (pakanLow) 'Pakan cadangan menipis',
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header sapaan + chip status koneksi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.header,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $userName!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device.name,
                              style: const TextStyle(color: AppColors.text),
                            ),
                            Text(
                              'Diperbarui ${sensor.waktuLabel}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: device.isOnline ? AppColors.accent : AppColors.danger,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: device.isOnline ? AppColors.text : Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              device.connectionLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: device.isOnline ? AppColors.text : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                if (warnings.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            warnings.join('\n'),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
                SensorGaugeRow(sensor: sensor, device: device),
                const SizedBox(height: AppSpacing.medium),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Perangkat',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        StatusIndicator(
                          label: 'Pompa air',
                          statusText: device.pumpOn ? 'Menyala' : 'Mati',
                          isActive: device.pumpOn,
                        ),
                        const Divider(height: 1),
                        StatusIndicator(
                          label: 'Katup pakan (servo)',
                          statusText: device.servoOpen ? 'Terbuka' : 'Tertutup',
                          isActive: device.servoOpen,
                        ),
                        const Divider(height: 1),
                        StatusIndicator(
                          label: 'Koneksi perangkat',
                          statusText: device.connectionLabel,
                          isActive: device.isOnline,
                          inactiveColor: AppColors.danger,
                        ),
                        const Divider(height: 1),
                        StatusIndicator(
                          label: 'Mode',
                          statusText: device.modeLabel,
                          isActive: device.isAutoMode,
                          activeColor: AppColors.primaryDark,
                        ),
                      ],
                    ),
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
