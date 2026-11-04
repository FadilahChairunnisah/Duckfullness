import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/auth_header.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final databaseService = DatabaseService();

  bool obscurePassword = true;
  bool isLoading = false;
  String message = '';

  Future<void> submitLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = '';
    });

    final user = await databaseService.login(
      usernameController.text.trim(),
      passwordController.text,
    );

    // Setelah await, halaman bisa saja sudah ditutup. Cek dulu.
    if (!context.mounted) return;

    if (user == null) {
      setState(() {
        isLoading = false;
        message = 'Username atau kata sandi salah';
      });
      return;
    }

    // pushReplacement: tombol Back dari Home tidak kembali ke Login.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage(user: user)),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                    const AuthHeader(icon: Icons.egg_alt, title: 'Masuk ke Akun'),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: validateUsernameInput,
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
                            const SizedBox(height: AppSpacing.large),
                            ElevatedButton(
                              onPressed: isLoading ? null : submitLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                            if (message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.medium),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.medium),
                            const Text(
                              'Akun contoh:\npeternak / bebek123\nadmin / admin123\n(akun baru dibuat oleh Admin)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
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
