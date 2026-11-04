import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../utils/constants.dart';
import 'sensor_card.dart';

/// Dua gauge (air dan pakan) berdampingan.
/// Dipakai di halaman Monitoring DAN Kontrol, jadi ditulis sekali di sini.
class SensorGaugeRow extends StatelessWidget {
  final SensorData sensor;
  final Device device;

  const SensorGaugeRow({
    super.key,
    required this.sensor,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    final airLow = sensor.levelAir < device.airMin;
    final pakanLow = sensor.beratPakan < device.pakanMin;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SensorCard(
            title: 'Air Minum',
            value: sensor.airLabel,
            icon: Icons.water_drop,
            color: AppColors.water,
            progress: sensor.levelAir / 100,
            isWarning: airLow,
            caption: airLow ? 'Di bawah batas' : 'Aman',
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: SensorCard(
            title: 'Pakan',
            value: sensor.pakanLabel,
            icon: Icons.grass,
            color: AppColors.accentDark,
            progress: sensor.beratPakan / AppLimits.pakanKapasitas,
            isWarning: pakanLow,
            caption: pakanLow ? 'Di bawah batas' : 'Aman',
          ),
        ),
      ],
    );
  }
}
