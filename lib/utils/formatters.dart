/// Mengubah DateTime menjadi teks pendek, contoh: 04/11 09:30
String formatWaktu(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)} ${two(t.hour)}:${two(t.minute)}';
}
