import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'tema_gelap';

  // Mengambil pengaturan tema
  Future<bool> ambilTema() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_themeKey) ?? false;
  }

  // Menyimpan pengaturan tema
  Future<void> simpanTema(bool gelap) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_themeKey, gelap);
  }

  // Menghapus pengaturan tema
  Future<void> hapusPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_themeKey);
  }
}