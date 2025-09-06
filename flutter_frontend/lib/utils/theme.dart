import 'package:flutter/material.dart';

class AppColors {
  // Primary TikTok Colors
  static const Color primary = Color(0xFFFF0050);          // TikTok Pink/Red
  static const Color primaryLight = Color(0xFFFF3D71);
  static const Color primaryDark = Color(0xFFE6004A);
  
  static const Color secondary = Color(0xFF00F2EA);         // TikTok Cyan
  static const Color secondaryLight = Color(0xFF4DF5EE);
  static const Color secondaryDark = Color(0xFF00DAD3);
  
  // Background Colors (Dark Theme)
  static const Color background = Color(0xFF000000);        // Pure Black
  static const Color surface = Color(0xFF161823);           // Dark Surface
  static const Color surfaceVariant = Color(0xFF1E1E2E);    // Slightly Lighter
  static const Color surfaceContainer = Color(0xFF2A2A3A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);       // White
  static const Color textSecondary = Color(0xFFA1A1AA);     // Light Gray
  static const Color textTertiary = Color(0xFF6B7280);      // Darker Gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Accent Colors
  static const Color accent = Color(0xFFFEBD38);            // Golden Yellow
  static const Color accentLight = Color(0xFFFFC947);
  static const Color accentDark = Color(0xFFE5A821);
  
  // Status Colors
  static const Color success = Color(0xFF22C55E);           // Green
  static const Color warning = Color(0xFFF59E0B);           // Orange
  static const Color error = Color(0xFFEF4444);             // Red
  static const Color info = Color(0xFF3B82F6);              // Blue
  
  // Interaction Colors
  static const Color like = Color(0xFFFF0050);              // Heart Red
  static const Color comment = Color(0xFFFFFFFF);           // White
  static const Color share = Color(0xFFFFFFFF);             // White
  static const Color bookmark = Color(0xFFFFBD03);          // Yellow
  
  // Video Player Colors
  static const Color videoOverlay = Color(0x80000000);      // Semi-transparent Black
  static const Color playButton = Color(0xFFFFFFFF);
  static const Color progressBar = Color(0xFFFF0050);
  static const Color progressBackground = Color(0x33FFFFFF);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFFFF0050);
  static const Color buttonSecondary = Color(0xFF161823);
  static const Color buttonOutline = Color(0xFF374151);
  static const Color buttonDisabled = Color(0xFF4B5563);
  
  // Border Colors
  static const Color border = Color(0xFF374151);
  static const Color borderLight = Color(0xFF4B5563);
  static const Color borderFocus = Color(0xFFFF0050);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowStrong = Color(0x40000000);
  
  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF0050), Color(0xFFFF3D71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF00F2EA), Color(0xFF4DF5EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient videoOverlayGradient = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x66000000),
      Color(0xCC000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Special Effect Colors
  static const Color neon = Color(0xFF00FF94);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonBlue = Color(0xFF0066FF);
  static const Color neonPurple = Color(0xFF8B00FF);
}

class AppTextStyles {
  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.2,
  );
  
  // Buttons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
  );
  
  // Special Styles
  static const TextStyle username = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle displayName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.2,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle hashtag = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.4,
  );
  
  static const TextStyle mention = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    height: 1.4,
  );
  
  static const TextStyle timestamp = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.2,
  );
  
  static const TextStyle counter = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
}

class AppDimensions {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(4.0);
  static const EdgeInsets paddingS = EdgeInsets.all(8.0);
  static const EdgeInsets paddingM = EdgeInsets.all(16.0);
  static const EdgeInsets paddingL = EdgeInsets.all(24.0);
  
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: 24.0);
  
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: 24.0);
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 50.0;
  
  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Button Heights
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 56.0;
  
  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 96.0;
  
  // Video Player
  static const double videoControlsHeight = 60.0;
  static const double videoProgressHeight = 4.0;
  static const double videoSidebarWidth = 80.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 80.0;
  static const double bottomNavIconSize = 28.0;
}