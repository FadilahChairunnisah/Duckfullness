import 'package:flutter/material.dart';

/// Semua warna aplikasi disimpan di sini (pola yang sama dengan Praktikum 4).
class AppColors {
  // Palet utama kelompok
  static const Color primary = Color(0xFF87B6BC); // teal lembut
  static const Color secondary = Color(0xFFBED4CB); // sage
  static const Color accent = Color(0xFFF6F09F); // kuning pucat
  static const Color danger = Color(0xFFB35656); // merah bata

  // Turunan agar teks dan latar tetap terbaca jelas
  static const Color primaryDark = Color(0xFF4F8A91);
  static const Color accentDark = Color(0xFFD9CE4F);
  static const Color background = Color(0xFFF2F7F5);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF1F3A3D);
  static const Color secondaryText = Color(0xFF5F7A7D);
  static const Color border = Color(0xFFDCE8E4);
  static const Color water = primaryDark;
  static const Color success = Color(0xFF3E8E7E);
}

/// Gradasi yang dipakai ulang di beberapa halaman.
class AppGradients {
  static const LinearGradient header = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Jarak standar (kelipatan 8) agar ritme visual teratur.
class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
}

/// Batas fisik kandang. Nanti diganti sesuai kalibrasi load cell dan sensor air.
class AppLimits {
  static const double pakanKapasitas = 2000; // gram
}
