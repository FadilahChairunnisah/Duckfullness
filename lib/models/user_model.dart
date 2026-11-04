class User {
  // Dua role sesuai SRS: Peternak dan Teknisi/Admin
  static const String rolePeternak = 'Peternak';
  static const String roleAdmin = 'Admin';

  final String username; // dipakai sebagai ID akun (tidak bisa diubah)
  final String name;
  final String password;
  final String role;

  const User({
    required this.username,
    required this.name,
    required this.password,
    required this.role,
  });

  bool get isAdmin => role == roleAdmin;
  String get greeting => 'Halo, $name!';
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  /// Field bersifat final, jadi "mengubah" = membuat User baru
  /// dengan sebagian nilai diganti (pola yang sama dengan Device).
  User copyWith({String? name, String? password, String? role}) {
    return User(
      username: username,
      name: name ?? this.name,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
