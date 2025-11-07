import 'package:flutter/material.dart';
import '../../services/preferences_services.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  bool get isDark => _isDark;

  ThemeProvider(this._isDark);

  void toggleTheme(bool value) {
    _isDark = value;
    PreferencesService.setDarkMode(value);
    notifyListeners();
  }
}
