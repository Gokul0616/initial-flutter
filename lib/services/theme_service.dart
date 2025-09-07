import 'dart:convert';
import 'package:dio/dio.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class ThemeService {
  static final ApiService _apiService = ApiService();

  static Future<AppThemeType?> getUserTheme() async {
    try {
      final response = await _apiService.get('/users/theme');
      
      if (response.statusCode == 200) {
        final themePreference = response.data['themePreference'] as String;
        return _parseThemeType(themePreference);
      }
    } catch (e) {
      print('Error fetching user theme: $e');
    }
    return null;
  }

  static Future<bool> updateUserTheme(AppThemeType theme) async {
    try {
      final response = await _apiService.put(
        '/users/theme',
        data: {
          'themePreference': theme.name,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating user theme: $e');
      return false;
    }
  }

  static AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'darkClassic':
        return AppThemeType.darkClassic;
      case 'lightClassic':
        return AppThemeType.lightClassic;
      case 'darkNeon':
        return AppThemeType.darkNeon;
      case 'lightPastel':
        return AppThemeType.lightPastel;
      case 'darkPurple':
        return AppThemeType.darkPurple;
      case 'lightGreen':
        return AppThemeType.lightGreen;
      case 'darkOrange':
        return AppThemeType.darkOrange;
      case 'lightBlue':
        return AppThemeType.lightBlue;
      default:
        return AppThemeType.darkClassic;
    }
  }
}