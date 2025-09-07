import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType {
  darkClassic,
  lightClassic,
  darkNeon,
  lightPastel,
  darkPurple,
  lightGreen,
  darkOrange,
  lightBlue,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  AppThemeType _currentTheme = AppThemeType.darkClassic;
  
  AppThemeType get currentTheme => _currentTheme;
  
  bool get isDarkMode => _currentTheme.name.startsWith('dark');
  bool get isLightMode => !isDarkMode;

  String get themeName {
    switch (_currentTheme) {
      case AppThemeType.darkClassic:
        return 'Dark Classic';
      case AppThemeType.lightClassic:
        return 'Light Classic';
      case AppThemeType.darkNeon:
        return 'Dark Neon';
      case AppThemeType.lightPastel:
        return 'Light Pastel';
      case AppThemeType.darkPurple:
        return 'Dark Purple';
      case AppThemeType.lightGreen:
        return 'Light Green';
      case AppThemeType.darkOrange:
        return 'Dark Orange';
      case AppThemeType.lightBlue:
        return 'Light Blue';
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    if (themeIndex < AppThemeType.values.length) {
      _currentTheme = AppThemeType.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  Future<void> toggleDarkLight() async {
    AppThemeType newTheme;
    switch (_currentTheme) {
      case AppThemeType.darkClassic:
        newTheme = AppThemeType.lightClassic;
        break;
      case AppThemeType.lightClassic:
        newTheme = AppThemeType.darkClassic;
        break;
      case AppThemeType.darkNeon:
        newTheme = AppThemeType.lightPastel;
        break;
      case AppThemeType.lightPastel:
        newTheme = AppThemeType.darkNeon;
        break;
      case AppThemeType.darkPurple:
        newTheme = AppThemeType.lightGreen;
        break;
      case AppThemeType.lightGreen:
        newTheme = AppThemeType.darkPurple;
        break;
      case AppThemeType.darkOrange:
        newTheme = AppThemeType.lightBlue;
        break;
      case AppThemeType.lightBlue:
        newTheme = AppThemeType.darkOrange;
        break;
    }
    await setTheme(newTheme);
  }

  List<AppThemeType> get availableThemes => AppThemeType.values;
}