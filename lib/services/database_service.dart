import 'dart:math';

import '../models/activity_model.dart';
import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/user_model.dart';

/// SEMENTARA: semua data masih palsu (dummy) dan disimpan di memori.
/// Daftar bersifat static supaya SEMUA halaman yang membuat
/// DatabaseService() melihat data yang sama. Data hilang saat aplikasi
/// ditutup. Nanti isi method ini diganti pemanggilan API / database sungguhan
/// (password di database asli wajib di-hash, sesuai SRS).
class DatabaseService {
  static final List<User> _users = [
    const User(
      username: 'peternak',
      name: 'Pak Budi',
      password: 'bebek123',
      role: User.rolePeternak,
    ),
    const User(
      username: 'admin',
      name: 'Teknisi Rudi',
      password: 'admin123',
      role: User.roleAdmin,
    ),
  ];

  static final List<ActivityLog> _activities = [];
  static final Map<String, DateTime> _lastLogin = {};
  static final Set<String> _online = {};

  // ---------- Akun ----------

  User? getUser(String username) {
    for (final user in _users) {
      if (user.username.toLowerCase() == username.toLowerCase()) return user;
    }
    return null;
  }

  List<User> getUsers() => List.unmodifiable(_users);

  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = getUser(username);
    if (user == null || user.password != password) return null;

    _online.add(user.username);
    _lastLogin[user.username] = DateTime.now();
    addActivity(user.username, 'Login ke aplikasi', kategori: 'sesi');
    return user;
  }

  /// Dipanggil saat pengguna keluar dari aplikasi.
  void markOffline(String username) {
    _online.remove(username);
    addActivity(username, 'Keluar dari aplikasi', kategori: 'sesi');
  }

  bool isOnline(String username) => _online.contains(username);
  DateTime? getLastLogin(String username) => _lastLogin[username];

  /// Akun baru HANYA dibuat oleh Admin (createdBy = username admin).
  /// Mengembalikan pesan error, atau null jika berhasil.
  Future<String?> register({
    required String name,
    required String username,
    required String password,
    required String role,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (getUser(username) != null) return 'Username sudah dipakai';

    _users.add(
      User(username: username, name: name, password: password, role: role),
    );
    addActivity(createdBy, 'Mendaftarkan akun @$username ($role)');
    return null;
  }

  Future<void> updateUser(User updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _users.indexWhere((u) => u.username == updated.username);
    if (index != -1) _users[index] = updated;
  }

  Future<void> deleteUser(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((u) => u.username == username);
    _online.remove(username);
    _lastLogin.remove(username);
  }

  // ---------- Riwayat aktivitas (untuk Admin) ----------

  /// Mencatat satu aktivitas. Yang terbaru disimpan paling depan.
  void addActivity(String username, String aksi, {String kategori = 'akun'}) {
    _activities.insert(
      0,
      ActivityLog(
        username: username,
        aksi: aksi,
        kategori: kategori,
        waktu: DateTime.now(),
      ),
    );
  }

  List<ActivityLog> getActivities() => List.unmodifiable(_activities);

  // ---------- Riwayat kandang (untuk Peternak) ----------

  List<HistoryPoint> getHistory(String range) {
    final random = Random(42); // seed tetap agar grafik tidak berubah-ubah
    final labels = range == 'Hari'
        ? ['00-04', '04-08', '08-12', '12-16', '16-20', '20-24']
        : range == 'Minggu'
            ? ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
            : ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4'];
    final scale = range == 'Hari' ? 1.0 : (range == 'Minggu' ? 6.0 : 42.0);

    return labels.map((label) {
      return HistoryPoint(
        label: label,
        pakanGram: (150 + random.nextInt(100)) * scale,
        airLiter: (3 + random.nextDouble() * 2) * scale,
      );
    }).toList();
  }

  List<ActuatorLog> getLogs() {
    return const [
      ActuatorLog(
        aksi: 'Katup pakan dibuka',
        pemicu: 'Otomatis',
        status: 'berhasil',
        waktu: 'Hari ini, 07:12',
      ),
      ActuatorLog(
        aksi: 'Pompa air dinyalakan',
        pemicu: 'Manual',
        status: 'berhasil',
        waktu: 'Hari ini, 06:40',
      ),
      ActuatorLog(
        aksi: 'Pompa air dinyalakan',
        pemicu: 'Otomatis',
        status: 'gagal',
        waktu: 'Kemarin, 18:05',
      ),
      ActuatorLog(
        aksi: 'Katup pakan ditutup',
        pemicu: 'Otomatis',
        status: 'berhasil',
        waktu: 'Kemarin, 17:30',
      ),
    ];
  }
}
