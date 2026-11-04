/// Satu baris riwayat aktivitas pengguna (dilihat oleh Admin).
class ActivityLog {
  final String username; // siapa yang melakukan
  final String aksi;
  final String kategori; // 'sesi' | 'akun' | 'perangkat'
  final DateTime waktu;

  const ActivityLog({
    required this.username,
    required this.aksi,
    required this.kategori,
    required this.waktu,
  });
}
