library flareline_uikit;

import 'package:flutter/material.dart';

/// FlareLine UI Kit Color Scheme
class FlarelineColors {
  // Primary Colors
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF6B7280);
  static const Color secondaryLight = Color(0xFF9CA3AF);
  static const Color secondaryDark = Color(0xFF374151);
  
  // Success Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  // Warning Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  // Error Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  // Info Colors
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);
  static const Color infoDark = Color(0xFF0891B2);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  
  // Gray Scale
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Background Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);
  
  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Legacy Colors (for backward compatibility)
  static const Color darkBackgroundColor = Color(0xFF1A1A1A);
  static const Color darkAppBar = Color(0xFF2D2D2D);
  static const Color darkBlackText = Color(0xFF000000);
  static const Color darkTextBody = Color(0xFF666666);
  
  // Additional legacy colors for backward compatibility
  static const Color darkBackground = Color(0xFF1C2434);
  static const Color darkBorder = Color(0xFF8A99AF);
  static const Color gray = Color(0xFFEFF4FB);
  static const Color sideBar = Color(0xFF1C2434);
  
  // Button Colors (for backward compatibility)
  static const Color buttonPrimary = Color(0xFF3C50E0);
  static const Color buttonNormal = Color(0xFF606266);
  static const Color buttonInfo = Color(0xFF8A99AF);
  static const Color buttonSuccess = Color(0xFF10B981);
  static const Color buttonWarn = Color(0xFFF0950C);
  static const Color buttonDanger = Color(0xFFFB5454);
  static const Color buttonDark = Color(0xFF1C2434);
  static const Color buttonSecondary = Color(0xFF80CAEE);
  
  // Semantic Colors
  static const Color link = Color(0xFF2563EB);
  static const Color linkHover = Color(0xFF1D4ED8);
  static const Color focus = Color(0xFF3B82F6);
  static const Color selection = Color(0xFFDBEAFE);
  
  // Status Colors
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF6B7280);
  static const Color busy = Color(0xFFEF4444);
  static const Color away = Color(0xFFF59E0B);
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF84CC16),
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, warningLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, errorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Button Colors class for backward compatibility
class ButtonColors {
  static const Color primary = Color(0xFF3C50E0);
  static const Color normal = Color(0xFF606266);
  static const Color info = Color(0xFF8A99AF);
  static const Color success = Color(0xFF10B981);
  static const Color warn = Color(0xFFF0950C);
  static const Color danger = Color(0xFFFB5454);
  static const Color dark = Color(0xFF1C2434);
  static const Color secondary = Color(0xFF80CAEE);
}