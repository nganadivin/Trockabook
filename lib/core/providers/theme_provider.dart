import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the user's preferred ThemeMode and persists it across sessions.
class ThemeProvider extends ChangeNotifier {
  static const _storageKey = 'themeMode';
  final _storage = const FlutterSecureStorage();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSavedTheme() async {
    final saved = await _storage.read(key: _storageKey);
    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _storage.write(key: _storageKey, value: isDark ? 'dark' : 'light');
  }
}
