import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Banner gradasi di bagian atas kartu Login / Registrasi.
class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const AuthHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
      decoration: const BoxDecoration(gradient: AppGradients.header),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
          ),
        ],
      ),
    );
  }
}
