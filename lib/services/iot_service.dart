import 'dart:math';

import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../utils/constants.dart';

/// SEMENTARA: mensimulasikan perangkat IoT.
/// Nanti diganti koneksi sungguhan (MQTT / Firebase / HTTP ke server).
class IotService {
  final Random _random = Random();

  SensorData readInitial() {
    return SensorData(levelAir: 60, beratPakan: 1000, waktu: DateTime.now());
  }

  /// Menghasilkan pembacaan berikutnya dari pembacaan sebelumnya:
  /// pompa menyala -> air naik, katup terbuka -> pakan naik,
  /// selain itu keduanya turun pelan (dikonsumsi bebek).
  SensorData simulate(SensorData prev, Device device) {
    double air = prev.levelAir;
    double pakan = prev.beratPakan;

    air += device.pumpOn ? 8 : -(1 + _random.nextDouble() * 3);
    pakan += device.servoOpen ? 150 : -(10 + _random.nextDouble() * 40);

    return SensorData(
      levelAir: air.clamp(0, 100).toDouble(),
      beratPakan: pakan.clamp(0, AppLimits.pakanKapasitas).toDouble(),
      waktu: DateTime.now(),
    );
  }

  /// Mengirim perintah ke perangkat. Sementara selalu berhasil.
  Future<bool> sendCommand(String perintah) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
