import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, night }

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'app_theme';
  AppTheme _theme = AppTheme.light;

  ThemeProvider() {
    _loadFromPrefs();
  }

  AppTheme get theme => _theme;

  ThemeData get themeData {
    switch (_theme) {
      case AppTheme.dark:
        return _darkTheme;
      case AppTheme.night:
        return _nightTheme;
      case AppTheme.light:
      default:
        return _lightTheme;
    }
  }

  void setTheme(AppTheme newTheme) {
    _theme = newTheme;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      _theme = AppTheme.values.firstWhere((e) => e.name == saved);
    } else {
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      _theme = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _theme.name);
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF1976D2),
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1976D2),
    secondary: Color(0xFF4CAF50),
    error: Color(0xFFE53935),
  ),
  cardColor: Colors.white,
  shadowColor: Colors.black.withValues(alpha: 0.05),
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF4FC3F7),
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4FC3F7),
    secondary: Color(0xFF81C784),
    error: Color(0xFFEF5350),
  ),
  cardColor: const Color(0xFF1E1E1E),
  shadowColor: Colors.black.withValues(alpha: 0.2),
);

final ThemeData _nightTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF8AB4F8),
  scaffoldBackgroundColor: const Color(0xFF1C1B29),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8AB4F8),
    secondary: Color(0xFFA5D6A7),
    error: Color(0xFFEF5350),
  ),
  cardColor: const Color(0xFF25243A),
  shadowColor: Colors.black.withValues(alpha: 0.2),
);
