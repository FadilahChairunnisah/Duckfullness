import 'dart:async';

import 'package:flutter/material.dart';

import '../models/device_model.dart';
import '../models/sensor_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/iot_service.dart';
import '../utils/constants.dart';
import 'account_monitoring_page.dart';
import 'account_page.dart';
import 'activity_history_page.dart';
import 'control_page.dart';
import 'history_page.dart';
import 'manage_accounts_page.dart';
import 'monitoring_page.dart';

/// Home = "rumah" bagi tab di bar bawah. Isi tab bergantung pada ROLE:
///   Peternak: Monitoring, Kontrol, Riwayat, Akun Saya
///   Admin   : Monitoring (akun), Riwayat (aktivitas), Kelola Akun, Akun Saya
/// State bersama (data sensor, status perangkat, user) disimpan DI SINI,
/// lalu dikirim ke tab lewat constructor.
class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final IotService iotService = IotService();
  final DatabaseService databaseService = DatabaseService();

  int selectedIndex = 0;
  Timer? timer;
  late SensorData sensor;
  late User currentUser; // salinan user yang bisa berubah (mis. setelah ganti nama)
  Device device = const Device(
    name: 'Kandang Utama',
    isAutoMode: true,
    isOnline: true,
    pumpOn: false,
    servoOpen: false,
    airMin: 30,
    airMaks: 90,
    pakanMin: 500,
    pakanMaks: 1500,
  );

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    sensor = iotService.readInitial();
    // Data kandang hanya relevan untuk Peternak, jadi Admin tidak
    // perlu menjalankan simulasi sensor.
    if (!currentUser.isAdmin) {
      // Setiap 3 detik, ambil pembacaan baru (mensimulasikan data real-time).
      timer = Timer.periodic(const Duration(seconds: 3), (_) => refreshData());
    }
  }

  void refreshData() {
    final data = iotService.simulate(sensor, device);
    bool pump = device.pumpOn;
    bool servo = device.servoOpen;

    // Logika mode otomatis (sesuai activity diagram di SRS).
    if (device.isAutoMode) {
      if (data.levelAir < device.airMin) pump = true;
      if (data.beratPakan < device.pakanMin) servo = true;
      if (data.beratPakan >= device.pakanMaks) servo = false;
    }
    // Pengaman FR-16: pompa selalu mati saat air mencapai batas maksimum.
    if (data.levelAir >= device.airMaks) pump = false;

    setState(() {
      sensor = data;
      device = device.copyWith(pumpOn: pump, servoOpen: servo);
    });
  }

  void updateDevice(Device newDevice) {
    setState(() {
      device = newDevice;
    });
  }

  void updateUser(User newUser) {
    setState(() {
      currentUser = newUser;
    });
  }

  Future<void> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(minimumSize: const Size(88, 40)),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      databaseService.markOffline(currentUser.username);
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // wajib: hentikan timer saat halaman ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = currentUser.isAdmin;

    // Judul, isi, dan item bar bawah disusun berdasarkan role.
    // Urutan ketiganya HARUS sama.
    final titles = isAdmin
        ? const ['Monitoring Akun', 'Riwayat Aktivitas', 'Kelola Akun', 'Akun Saya']
        : const ['Monitoring', 'Kontrol', 'Riwayat', 'Akun Saya'];

    final pages = isAdmin
        ? [
            AccountMonitoringPage(currentUser: currentUser),
            const ActivityHistoryPage(),
            ManageAccountsPage(currentUser: currentUser),
            AccountPage(user: currentUser, onUserChanged: updateUser),
          ]
        : [
            MonitoringPage(
              userName: currentUser.name,
              sensor: sensor,
              device: device,
            ),
            ControlPage(
              device: device,
              sensor: sensor,
              username: currentUser.username,
              onDeviceChanged: updateDevice,
            ),
            const HistoryPage(),
            AccountPage(user: currentUser, onUserChanged: updateUser),
          ];

    final navItems = isAdmin
        ? const [
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Kelola Akun',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun Saya'),
          ]
        : const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Kontrol'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun Saya'),
          ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[selectedIndex])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(gradient: AppGradients.header),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primaryDark),
              ),
              accountName: Text(
                currentUser.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              accountEmail: Text(
                '${currentUser.username} | ${currentUser.role}',
                style: const TextStyle(color: AppColors.text),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context); // tutup Drawer
                confirmLogout(context);
              },
            ),
          ],
        ),
      ),
      // IndexedStack menyimpan semua tab, jadi isian di satu tab
      // tidak hilang saat berpindah tab.
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.secondaryText,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}
