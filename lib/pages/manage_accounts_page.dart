import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'register_page.dart';

/// Tab "Kelola Akun" (khusus Admin): tambah akun baru, ubah role,
/// reset kata sandi, dan hapus akun. Akun milik admin sendiri dilindungi
/// (role dan hapus dinonaktifkan) agar tidak ada kondisi tanpa admin.
class ManageAccountsPage extends StatefulWidget {
  final User currentUser;

  const ManageAccountsPage({super.key, required this.currentUser});

  @override
  State<ManageAccountsPage> createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  final DatabaseService databaseService = DatabaseService();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Dialog Ya/Batal yang dipakai berulang. Mengembalikan true jika "Ya".
  Future<bool> confirm(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(minimumSize: const Size(88, 40)),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  /// Buka halaman Tambah Akun dan tunggu akun barunya (pola Praktikum 6).
  Future<void> addAccount() async {
    final newUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(createdBy: widget.currentUser.username),
      ),
    );

    if (!context.mounted || newUser == null) return;
    setState(() {}); // bangun ulang agar daftar membaca data terbaru
    showMessage('Akun ${newUser.name} berhasil dibuat');
  }

  Future<void> changeRole(User target) async {
    final newRole = target.isAdmin ? User.rolePeternak : User.roleAdmin;
    final ok = await confirm(
      'Ubah Role',
      'Ubah role ${target.name} dari ${target.role} menjadi $newRole?',
    );
    if (!ok) return;

    await databaseService.updateUser(target.copyWith(role: newRole));
    databaseService.addActivity(
      widget.currentUser.username,
      'Mengubah role @${target.username} menjadi $newRole',
    );
    if (!mounted) return;
    setState(() {});
    showMessage('Role ${target.name} diubah menjadi $newRole');
  }

  Future<void> resetPassword(User target) async {
    final newPassword = await showDialog<String>(
      context: context,
      builder: (context) => _ResetPasswordDialog(userName: target.name),
    );
    if (newPassword == null) return;

    await databaseService.updateUser(target.copyWith(password: newPassword));
    databaseService.addActivity(
      widget.currentUser.username,
      'Mereset kata sandi @${target.username}',
    );
    if (!mounted) return;
    showMessage('Kata sandi ${target.name} berhasil direset');
  }

  Future<void> deleteAccount(User target) async {
    final ok = await confirm(
      'Hapus Akun',
      'Hapus akun ${target.name} (@${target.username})? Tindakan ini tidak bisa dibatalkan.',
    );
    if (!ok) return;

    await databaseService.deleteUser(target.username);
    databaseService.addActivity(
      widget.currentUser.username,
      'Menghapus akun @${target.username}',
    );
    if (!mounted) return;
    setState(() {});
    showMessage('Akun ${target.name} dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final users = databaseService.getUsers();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: addAccount,
                  icon: const Icon(Icons.person_add),
                  label: const Text(
                    'Tambah Akun',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                ...users.map((user) {
                  final isSelf = user.username == widget.currentUser.username;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              user.isAdmin ? AppColors.accent : AppColors.secondary,
                          child: Text(
                            user.initial,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        title: Text(isSelf ? '${user.name} (Anda)' : user.name),
                        subtitle: Text('@${user.username} • ${user.role}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'role') {
                              changeRole(user);
                            } else if (value == 'password') {
                              resetPassword(user);
                            } else {
                              deleteAccount(user);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'role',
                              enabled: !isSelf,
                              child: Text(
                                user.isAdmin ? 'Jadikan Peternak' : 'Jadikan Admin',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'password',
                              child: Text('Reset Kata Sandi'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              enabled: !isSelf,
                              child: const Text(
                                'Hapus Akun',
                                style: TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog input kata sandi baru. Dibuat sebagai widget sendiri supaya
/// controller-nya punya dispose() sendiri.
class _ResetPasswordDialog extends StatefulWidget {
  final String userName;

  const _ResetPasswordDialog({required this.userName});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset sandi ${widget.userName}'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: 'Kata sandi baru',
            suffixIcon: IconButton(
              onPressed: () => setState(() => obscure = !obscure),
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: validatePasswordInput,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, controller.text);
            }
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(88, 40)),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
