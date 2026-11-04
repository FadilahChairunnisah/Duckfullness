import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';

/// Tambah akun baru. Halaman ini HANYA dibuka oleh Admin dari tab Kelola Akun.
/// Hasilnya dikirim balik lewat Navigator.pop(context, user) (pola Praktikum 6).
class RegisterPage extends StatefulWidget {
  final String createdBy; // username admin yang membuat akun

  const RegisterPage({super.key, required this.createdBy});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final databaseService = DatabaseService();

  final List<String> roles = const [User.rolePeternak, User.roleAdmin];
  String selectedRole = User.rolePeternak;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String message = '';

  Future<void> submitRegistration() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = '';
    });

    final username = usernameController.text.trim();
    final error = await databaseService.register(
      name: nameController.text.trim(),
      username: username,
      password: passwordController.text,
      role: selectedRole,
      createdBy: widget.createdBy,
    );

    if (!context.mounted) return;

    if (error != null) {
      setState(() {
        isLoading = false;
        message = error;
      });
      return;
    }

    // Tutup halaman ini sekaligus mengirim akun baru ke Kelola Akun
    Navigator.pop(context, databaseService.getUser(username));
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Akun')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const AuthHeader(
                      icon: Icons.person_add,
                      title: 'Buat Akun Baru',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              validator: validateNameInput,
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: validateUsernameInput,
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            const Text('Role'),
                            const SizedBox(height: AppSpacing.small),
                            Wrap(
                              spacing: AppSpacing.small,
                              children: roles.map((role) {
                                return ChoiceChip(
                                  label: Text(role),
                                  selected: selectedRole == role,
                                  selectedColor: AppColors.secondary,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: AppColors.border),
                                  onSelected: (_) {
                                    setState(() => selectedRole = role);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: validatePasswordInput,
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Kata Sandi',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirmPassword = !obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                return validateConfirmPassword(
                                  value,
                                  passwordController.text,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.large),
                            ElevatedButton(
                              onPressed: isLoading ? null : submitRegistration,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Buat Akun',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                            if (message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.medium),
                                child: Center(
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
