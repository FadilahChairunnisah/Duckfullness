import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

/// Tab "Akun Saya": setiap pengguna (Peternak maupun Admin) dapat mengubah
/// nama dan kata sandinya. Hasilnya dilaporkan ke Home lewat callback
/// onUserChanged (pola yang sama dengan onDeviceChanged di halaman Kontrol).
class AccountPage extends StatefulWidget {
  final User user;
  final ValueChanged<User> onUserChanged;

  const AccountPage({
    super.key,
    required this.user,
    required this.onUserChanged,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final formKey = GlobalKey<FormState>();
  final databaseService = DatabaseService();
  late final TextEditingController nameController;
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    var updated = widget.user.copyWith(name: nameController.text.trim());
    if (newPasswordController.text.isNotEmpty) {
      updated = updated.copyWith(password: newPasswordController.text);
    }
    await databaseService.updateUser(updated);
    databaseService.addActivity(updated.username, 'Memperbarui akun sendiri');

    if (!context.mounted) return;

    setState(() => isSaving = false);
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    widget.onUserChanged(updated); // laporkan ke Home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil diperbarui')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wantsNewPassword = newPasswordController.text.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.secondary,
                          child: Text(
                            widget.user.initial,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      // Username dan role tidak bisa diubah oleh pengguna sendiri
                      TextFormField(
                        initialValue: widget.user.username,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        initialValue: widget.user.role,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.verified_user),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: validateNameInput,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      Text(
                        'Ubah Kata Sandi (opsional)',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Kata Sandi Lama',
                          prefixIcon: Icon(Icons.lock_clock),
                        ),
                        validator: (value) {
                          if (newPasswordController.text.isEmpty) return null;
                          // Ambil data terbaru, siapa tahu sandi sudah direset admin
                          final current =
                              databaseService.getUser(widget.user.username) ??
                                  widget.user;
                          if (value != current.password) {
                            return 'Kata sandi lama salah';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscurePassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          return validatePasswordInput(value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Kata Sandi Baru',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (!wantsNewPassword) return null;
                          return validateConfirmPassword(
                            value,
                            newPasswordController.text,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.large),
                      ElevatedButton(
                        onPressed: isSaving ? null : save,
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
