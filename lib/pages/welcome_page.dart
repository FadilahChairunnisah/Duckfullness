import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradasi tiga warna dari palet (teknik sama seperti Praktikum 4)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.egg_alt,
                        size: 80,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Kandang Bebek Pintar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Pantau dan otomatisasi pakan serta air kandang bebek dengan mudah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.text, fontSize: 15),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      // Menimpa gaya dari tema hanya untuk tombol ini
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.text,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
