import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class AppColors {
  // Classic Theme Colors (Dark)
  static const Color primaryClassic = Color(0xFFFF0050);
  static const Color secondaryClassic = Color(0xFF00F2EA);
  static const Color backgroundDarkClassic = Color(0xFF000000);
  static const Color surfaceDarkClassic = Color(0xFF1A1A1A);
  static const Color textPrimaryDarkClassic = Color(0xFFFFFFFF);
  static const Color textSecondaryDarkClassic = Color(0xFFB3B3B3);

  // Classic Theme Colors (Light)
  static const Color backgroundLightClassic = Color(0xFFFFFFFF);
  static const Color surfaceLightClassic = Color(0xFFF8F9FA);
  static const Color textPrimaryLightClassic = Color(0xFF000000);
  static const Color textSecondaryLightClassic = Color(0xFF6C757D);

  // Neon Theme Colors (Dark)
  static const Color primaryNeon = Color(0xFF00FFFF);
  static const Color secondaryNeon = Color(0xFFFF00FF);
  static const Color backgroundDarkNeon = Color(0xFF0A0A0A);
  static const Color surfaceDarkNeon = Color(0xFF1F1F1F);
  static const Color textPrimaryDarkNeon = Color(0xFF00FFFF);
  static const Color textSecondaryDarkNeon = Color(0xFF80FFFF);

  // Pastel Theme Colors (Light)
  static const Color primaryPastel = Color(0xFFFF6B6B);
  static const Color secondaryPastel = Color(0xFF4ECDC4);
  static const Color backgroundLightPastel = Color(0xFFFFF8F8);
  static const Color surfaceLightPastel = Color(0xFFF0F8FF);
  static const Color textPrimaryLightPastel = Color(0xFF2C3E50);
  static const Color textSecondaryLightPastel = Color(0xFF7F8C8D);

  // Purple Theme Colors (Dark)
  static const Color primaryPurple = Color(0xFF9B59B6);
  static const Color secondaryPurple = Color(0xFFE74C3C);
  static const Color backgroundDarkPurple = Color(0xFF2C3E50);
  static const Color surfaceDarkPurple = Color(0xFF34495E);
  static const Color textPrimaryDarkPurple = Color(0xFFECF0F1);
  static const Color textSecondaryDarkPurple = Color(0xFFBDC3C7);

  // Green Theme Colors (Light)
  static const Color primaryGreen = Color(0xFF27AE60);
  static const Color secondaryGreen = Color(0xFF2ECC71);
  static const Color backgroundLightGreen = Color(0xFFF8FFF8);
  static const Color surfaceLightGreen = Color(0xFFE8F5E8);
  static const Color textPrimaryLightGreen = Color(0xFF2C3E50);
  static const Color textSecondaryLightGreen = Color(0xFF7F8C8D);

  // Orange Theme Colors (Dark)
  static const Color primaryOrange = Color(0xFFE67E22);
  static const Color secondaryOrange = Color(0xFFD35400);
  static const Color backgroundDarkOrange = Color(0xFF34495E);
  static const Color surfaceDarkOrange = Color(0xFF2C3E50);
  static const Color textPrimaryDarkOrange = Color(0xFFECF0F1);
  static const Color textSecondaryDarkOrange = Color(0xFFBDC3C7);

  // Blue Theme Colors (Light)
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color secondaryBlue = Color(0xFF2980B9);
  static const Color backgroundLightBlue = Color(0xFFF8FBFF);
  static const Color surfaceLightBlue = Color(0xFFE8F4FD);
  static const Color textPrimaryLightBlue = Color(0xFF2C3E50);
  static const Color textSecondaryLightBlue = Color(0xFF7F8C8D);

  // Common Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  static const Color like = Color(0xFFFF1744); // Like/heart color
  static const Color accent = Color(0xFFFFD700); // Gold accent color

  // Border Colors
  static const Color borderDark = Color(0xFF333333);
  static const Color borderLight = Color(0xFFDEE2E6);

  // Legacy colors for backward compatibility - now const
  static const Color primary = primaryClassic;
  static const Color secondary = secondaryClassic;
  static const Color background = backgroundDarkClassic;
  static const Color surface = surfaceDarkClassic;
  static const Color surfaceVariant = Color(0xFF2A2A2A); // Slightly lighter than surface
  static const Color textPrimary = textPrimaryDarkClassic;
  static const Color textSecondary = textSecondaryDarkClassic;
  static const Color border = borderDark;

  // Card colors
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // Additional text styles used throughout the app
  static TextStyle get headline4 => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
      );

  static TextStyle get headline5 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get username => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get displayName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get counter => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  static TextStyle get timestamp => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );
}

class AppTheme {
  static ThemeData getThemeData(AppThemeType themeType) {
    final themeColors = _getThemeColors(themeType);
    final isDark = themeType.name.startsWith('dark');
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColors['primary']!,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: themeColors['primary']!,
        secondary: themeColors['secondary']!,
        surface: themeColors['surface']!,
        background: themeColors['background']!,
        onPrimary: isDark ? Colors.white : Colors.black,
        onSecondary: isDark ? Colors.white : Colors.black,
        onSurface: themeColors['textPrimary']!,
        onBackground: themeColors['textPrimary']!,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: themeColors['background']!,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: themeColors['textPrimary']!,
        displayColor: themeColors['textPrimary']!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeColors['surface']!,
        foregroundColor: themeColors['textPrimary']!,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeColors['surface']!,
        selectedItemColor: themeColors['primary']!,
        unselectedItemColor: themeColors['textSecondary']!,
        type: BottomNavigationBarType.fixed,
        elevation: isDark ? 0 : 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColors['primary']!,
          foregroundColor: isDark ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: isDark ? 0 : 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeColors['primary']!,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeColors['surface']!,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: themeColors['primary']!, width: 2),
        ),
        hintStyle: TextStyle(color: themeColors['textSecondary']!),
        labelStyle: TextStyle(color: themeColors['textSecondary']!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: themeColors['surface']!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: themeColors['surface']!,
      ),
      iconTheme: IconThemeData(
        color: themeColors['textPrimary']!,
      ),
    );
  }

  static Map<String, Color> _getThemeColors(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.darkClassic:
        return {
          'primary': AppColors.primaryClassic,
          'secondary': AppColors.secondaryClassic,
          'background': AppColors.backgroundDarkClassic,
          'surface': AppColors.surfaceDarkClassic,
          'textPrimary': AppColors.textPrimaryDarkClassic,
          'textSecondary': AppColors.textSecondaryDarkClassic,
        };
      case AppThemeType.lightClassic:
        return {
          'primary': AppColors.primaryClassic,
          'secondary': AppColors.secondaryClassic,
          'background': AppColors.backgroundLightClassic,
          'surface': AppColors.surfaceLightClassic,
          'textPrimary': AppColors.textPrimaryLightClassic,
          'textSecondary': AppColors.textSecondaryLightClassic,
        };
      case AppThemeType.darkNeon:
        return {
          'primary': AppColors.primaryNeon,
          'secondary': AppColors.secondaryNeon,
          'background': AppColors.backgroundDarkNeon,
          'surface': AppColors.surfaceDarkNeon,
          'textPrimary': AppColors.textPrimaryDarkNeon,
          'textSecondary': AppColors.textSecondaryDarkNeon,
        };
      case AppThemeType.lightPastel:
        return {
          'primary': AppColors.primaryPastel,
          'secondary': AppColors.secondaryPastel,
          'background': AppColors.backgroundLightPastel,
          'surface': AppColors.surfaceLightPastel,
          'textPrimary': AppColors.textPrimaryLightPastel,
          'textSecondary': AppColors.textSecondaryLightPastel,
        };
      case AppThemeType.darkPurple:
        return {
          'primary': AppColors.primaryPurple,
          'secondary': AppColors.secondaryPurple,
          'background': AppColors.backgroundDarkPurple,
          'surface': AppColors.surfaceDarkPurple,
          'textPrimary': AppColors.textPrimaryDarkPurple,
          'textSecondary': AppColors.textSecondaryDarkPurple,
        };
      case AppThemeType.lightGreen:
        return {
          'primary': AppColors.primaryGreen,
          'secondary': AppColors.secondaryGreen,
          'background': AppColors.backgroundLightGreen,
          'surface': AppColors.surfaceLightGreen,
          'textPrimary': AppColors.textPrimaryLightGreen,
          'textSecondary': AppColors.textSecondaryLightGreen,
        };
      case AppThemeType.darkOrange:
        return {
          'primary': AppColors.primaryOrange,
          'secondary': AppColors.secondaryOrange,
          'background': AppColors.backgroundDarkOrange,
          'surface': AppColors.surfaceDarkOrange,
          'textPrimary': AppColors.textPrimaryDarkOrange,
          'textSecondary': AppColors.textSecondaryDarkOrange,
        };
      case AppThemeType.lightBlue:
        return {
          'primary': AppColors.primaryBlue,
          'secondary': AppColors.secondaryBlue,
          'background': AppColors.backgroundLightBlue,
          'surface': AppColors.surfaceLightBlue,
          'textPrimary': AppColors.textPrimaryLightBlue,
          'textSecondary': AppColors.textSecondaryLightBlue,
        };
    }
  }

  static LinearGradient getThemeGradient(AppThemeType themeType) {
    final colors = _getThemeColors(themeType);
    return LinearGradient(
      colors: [colors['primary']!, colors['secondary']!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getStoryGradient(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.darkNeon:
        return const LinearGradient(
          colors: [
            Color(0xFF00FFFF),
            Color(0xFF00FF80),
            Color(0xFF80FF00),
            Color(0xFFFF00FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeType.lightPastel:
        return const LinearGradient(
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFFE66D),
            Color(0xFF4ECDC4),
            Color(0xFF95E1D3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [
            _getThemeColors(themeType)['primary']!,
            _getThemeColors(themeType)['secondary']!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

// Extension for getting current theme colors
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  Color get primaryBackground => colorScheme.background;
  Color get primarySurface => colorScheme.surface;
  Color get primaryText => colorScheme.onBackground;
  Color get secondaryText => colorScheme.onSurface.withOpacity(0.7);
  Color get primaryBorder => theme.brightness == Brightness.dark 
      ? AppColors.borderDark 
      : AppColors.borderLight;
}