/// Satu pembacaan sensor (tabel DATA_SENSOR di ERD).
class SensorData {
  final double levelAir; // persen, 0-100
  final double beratPakan; // gram
  final DateTime waktu;

  const SensorData({
    required this.levelAir,
    required this.beratPakan,
    required this.waktu,
  });

  String get airLabel => '${levelAir.toStringAsFixed(0)} %';
  String get pakanLabel => '${beratPakan.toStringAsFixed(0)} g';

  String get waktuLabel {
    final h = waktu.hour.toString().padLeft(2, '0');
    final m = waktu.minute.toString().padLeft(2, '0');
    final s = waktu.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// Satu titik data untuk grafik riwayat.
class HistoryPoint {
  final String label;
  final double pakanGram;
  final double airLiter;

  const HistoryPoint({
    required this.label,
    required this.pakanGram,
    required this.airLiter,
  });
}
