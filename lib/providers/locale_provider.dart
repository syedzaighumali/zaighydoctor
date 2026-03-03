import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';
  Locale _locale = const Locale('en');

  LocaleProvider() {
    _loadFromPrefs();
  }

  Locale get locale => _locale;

  bool get isRtl => _locale.languageCode == 'ur';

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _locale.languageCode);
  }
}
