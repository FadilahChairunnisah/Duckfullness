String? validateNameInput(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Nama tidak boleh kosong';
  }
  return null;
}

String? validateUsernameInput(String? value) {
  final username = value?.trim() ?? '';
  if (username.isEmpty) return 'Username tidak boleh kosong';
  if (username.length < 3) return 'Username minimal 3 karakter';
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
    return 'Username hanya huruf, angka, dan _';
  }
  return null;
}

String? validatePasswordInput(String? value) {
  if (value == null || value.isEmpty) {
    return 'Kata sandi tidak boleh kosong';
  }
  if (value.length < 6) return 'Kata sandi minimal 6 karakter';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Konfirmasi kata sandi tidak boleh kosong';
  }
  if (value != password) return 'Konfirmasi kata sandi tidak sama';
  return null;
}
