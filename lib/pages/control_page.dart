import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../services/database_service.dart';
import '../services/iot_service.dart';
import '../utils/constants.dart';
import '../widgets/sensor_gauge_row.dart';

/// Halaman Kontrol (FR-16, FR-17, FR-18).
/// Alur: lihat indikator -> pilih mode -> panel sesuai mode baru muncul.
class ControlPage extends StatefulWidget {
  final Device device;
  final SensorData sensor;
  final String username; // untuk mencatat siapa yang mengirim perintah
  final ValueChanged<Device> onDeviceChanged; // dipanggil untuk melapor ke Home

  const ControlPage({
    super.key,
    required this.device,
    required this.sensor,
    required this.username,
    required this.onDeviceChanged,
  });

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  final IotService iotService = IotService();
  final DatabaseService databaseService = DatabaseService();
  bool isSending = false;

  // false = panel mode belum ditampilkan. Berubah true setelah
  // pengguna menekan salah satu tombol mode.
  bool modeChosen = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Kirim perintah ke perangkat; kalau berhasil, laporkan ke Home.
  /// Mengembalikan true jika perintah berhasil.
  Future<bool> sendAndUpdate(String pesan, Device newDevice) async {
    setState(() => isSending = true);
    final ok = await iotService.sendCommand(pesan);
    if (!mounted) return false;
    setState(() => isSending = false);

    if (ok) {
      databaseService.addActivity(widget.username, pesan, kategori: 'perangkat');
      widget.onDeviceChanged(newDevice);
      showMessage('$pesan: berhasil');
    } else {
      showMessage('$pesan: gagal dikirim');
    }
    return ok;
  }

  Future<void> selectMode(bool wantAuto) async {
    // Mode yang dipilih sudah aktif: cukup tampilkan panelnya.
    if (widget.device.isAutoMode == wantAuto) {
      setState(() => modeChosen = true);
      return;
    }

    final ok = await sendAndUpdate(
      'Mode ${wantAuto ? 'otomatis' : 'manual'} diaktifkan',
      widget.device.copyWith(isAutoMode: wantAuto),
    );
    if (ok && mounted) {
      setState(() => modeChosen = true);
    }
  }

  Future<void> togglePump(bool value) async {
    if (value == widget.device.pumpOn) return;
    if (value && widget.sensor.levelAir >= widget.device.airMaks) {
      showMessage('Pompa tidak dinyalakan: air sudah mencapai batas maksimum');
      return;
    }
    await sendAndUpdate(
      'Pompa air ${value ? 'dinyalakan' : 'dimatikan'}',
      widget.device.copyWith(pumpOn: value),
    );
  }

  Future<void> toggleServo(bool value) async {
    if (value == widget.device.servoOpen) return;
    await sendAndUpdate(
      'Katup pakan ${value ? 'dibuka' : 'ditutup'}',
      widget.device.copyWith(servoOpen: value),
    );
  }

  Future<void> sendThreshold() async {
    await iotService.sendCommand('Ambang batas');
    if (!mounted) return;
    databaseService.addActivity(
      widget.username,
      'Mengatur ambang batas otomatis',
      kategori: 'perangkat',
    );
    showMessage('Ambang batas dikirim ke perangkat');
  }

  // ---------- Potongan UI kecil yang dipakai berulang ----------

  /// Tombol pilihan: terisi kalau dipilih, hanya garis tepi kalau tidak.
  Widget buildChoiceButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.small),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );

    if (isSelected) {
      return ElevatedButton(onPressed: onPressed, child: content);
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: content,
    );
  }

  Widget buildSlider({
    required String label,
    required double value,
    required double max,
    required double step,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)} $unit'),
        Slider(
          value: value,
          min: 0,
          max: max,
          divisions: (max / step).round(),
          onChanged: onChanged,
          onChangeEnd: (_) => sendThreshold(),
        ),
      ],
    );
  }

  /// Satu aktuator = judul + status + dua tombol (aktif / nonaktif).
  Widget buildActuatorControl({
    required String title,
    required IconData icon,
    required String statusText,
    required bool isOn,
    required String onLabel,
    required IconData onIcon,
    required String offLabel,
    required IconData offIcon,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryDark),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              statusText,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildChoiceButton(
                label: onLabel,
                icon: onIcon,
                isSelected: isOn,
                onPressed: isSending ? null : () => onChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildChoiceButton(
                label: offLabel,
                icon: offIcon,
                isSelected: !isOn,
                onPressed: isSending ? null : () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Tiga area utama halaman ----------

  /// Area 1: status mode + tombol pilih mode (selalu tampil).
  Widget buildModeCard() {
    final device = widget.device;
    final isAuto = device.isAutoMode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_suggest, color: AppColors.primaryDark),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    'Mode Operasi',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Saat ini: ${device.modeLabel}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              !modeChosen
                  ? 'Pilih mode untuk menampilkan pengaturannya.'
                  : isAuto
                      ? 'Perangkat mengatur pompa dan katup sendiri sesuai ambang batas.'
                      : 'Pompa dan katup hanya bergerak lewat perintah dari aplikasi.',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: buildChoiceButton(
                    label: 'Manual',
                    icon: Icons.touch_app,
                    isSelected: modeChosen && !isAuto,
                    onPressed: isSending ? null : () => selectMode(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildChoiceButton(
                    label: 'Otomatis',
                    icon: Icons.autorenew,
                    isSelected: modeChosen && isAuto,
                    onPressed: isSending ? null : () => selectMode(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Area 2: hanya muncul di mode Otomatis.
  Widget buildAutoPanel() {
    final device = widget.device;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ambang Batas Otomatis',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.small),
            buildSlider(
              label: 'Pompa menyala jika air di bawah',
              value: device.airMin,
              max: 100,
              step: 5,
              unit: '%',
              onChanged: (v) {
                if (v < device.airMaks) {
                  widget.onDeviceChanged(device.copyWith(airMin: v));
                }
              },
            ),
            buildSlider(
              label: 'Pompa berhenti saat air mencapai',
              value: device.airMaks,
              max: 100,
              step: 5,
              unit: '%',
              onChanged: (v) {
                if (v > device.airMin) {
                  widget.onDeviceChanged(device.copyWith(airMaks: v));
                }
              },
            ),
            buildSlider(
              label: 'Katup terbuka jika pakan di bawah',
              value: device.pakanMin,
              max: AppLimits.pakanKapasitas,
              step: 50,
              unit: 'g',
              onChanged: (v) {
                if (v < device.pakanMaks) {
                  widget.onDeviceChanged(device.copyWith(pakanMin: v));
                }
              },
            ),
            buildSlider(
              label: 'Katup tertutup saat pakan mencapai',
              value: device.pakanMaks,
              max: AppLimits.pakanKapasitas,
              step: 50,
              unit: 'g',
              onChanged: (v) {
                if (v > device.pakanMin) {
                  widget.onDeviceChanged(device.copyWith(pakanMaks: v));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Area 3: hanya muncul di mode Manual. Terpisah dari slider.
  Widget buildManualPanel() {
    final device = widget.device;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kontrol Manual',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.medium),
            buildActuatorControl(
              title: 'Pompa Air',
              icon: Icons.water_drop,
              statusText: device.pumpOn ? 'Menyala' : 'Mati',
              isOn: device.pumpOn,
              onLabel: 'ON',
              onIcon: Icons.power_settings_new,
              offLabel: 'OFF',
              offIcon: Icons.power_off,
              onChanged: togglePump,
            ),
            const SizedBox(height: AppSpacing.large),
            buildActuatorControl(
              title: 'Katup Pakan',
              icon: Icons.grass,
              statusText: device.servoOpen ? 'Terbuka' : 'Tertutup',
              isOn: device.servoOpen,
              onLabel: 'Buka',
              onIcon: Icons.lock_open,
              offLabel: 'Tutup',
              offIcon: Icons.lock,
              onChanged: toggleServo,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuto = widget.device.isAutoMode;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSending) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: AppSpacing.small),
                ],
                SensorGaugeRow(sensor: widget.sensor, device: widget.device),
                const SizedBox(height: AppSpacing.medium),
                buildModeCard(),
                // Panel baru muncul setelah mode dipilih
                if (modeChosen) ...[
                  const SizedBox(height: AppSpacing.medium),
                  if (isAuto) buildAutoPanel() else buildManualPanel(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
