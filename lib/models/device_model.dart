/// Satu unit IoT di kandang (tabel PERANGKAT di ERD).
class Device {
  final String name;
  final bool isAutoMode;
  final bool isOnline;
  final bool pumpOn;
  final bool servoOpen;
  final double airMin;
  final double airMaks;
  final double pakanMin;
  final double pakanMaks;

  const Device({
    required this.name,
    required this.isAutoMode,
    required this.isOnline,
    required this.pumpOn,
    required this.servoOpen,
    required this.airMin,
    required this.airMaks,
    required this.pakanMin,
    required this.pakanMaks,
  });

  String get modeLabel => isAutoMode ? 'Otomatis' : 'Manual';
  String get connectionLabel => isOnline ? 'Online' : 'Offline';

  /// Field bersifat final, jadi untuk "mengubah" kita buat Device baru
  /// dengan sebagian nilai diganti.
  Device copyWith({
    bool? isAutoMode,
    bool? isOnline,
    bool? pumpOn,
    bool? servoOpen,
    double? airMin,
    double? airMaks,
    double? pakanMin,
    double? pakanMaks,
  }) {
    return Device(
      name: name,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      isOnline: isOnline ?? this.isOnline,
      pumpOn: pumpOn ?? this.pumpOn,
      servoOpen: servoOpen ?? this.servoOpen,
      airMin: airMin ?? this.airMin,
      airMaks: airMaks ?? this.airMaks,
      pakanMin: pakanMin ?? this.pakanMin,
      pakanMaks: pakanMaks ?? this.pakanMaks,
    );
  }
}

/// Satu baris riwayat aksi aktuator (tabel LOG_AKTUATOR di ERD).
class ActuatorLog {
  final String aksi;
  final String pemicu; // Otomatis / Manual
  final String status; // menunggu / berhasil / gagal
  final String waktu;

  const ActuatorLog({
    required this.aksi,
    required this.pemicu,
    required this.status,
    required this.waktu,
  });
}
