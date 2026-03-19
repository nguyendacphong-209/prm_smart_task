import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'app_theme_mode';

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController();
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModeKey);

    if (saved == 'light') {
      state = ThemeMode.light;
      return;
    }

    if (saved == 'dark') {
      state = ThemeMode.dark;
      return;
    }

    state = ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();

    if (mode == ThemeMode.light) {
      await prefs.setString(_themeModeKey, 'light');
      return;
    }

    if (mode == ThemeMode.dark) {
      await prefs.setString(_themeModeKey, 'dark');
      return;
    }

    await prefs.remove(_themeModeKey);
  }

  Future<void> toggleLightDark() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
