import 'package:flutter/material.dart';

/// Font utility class for consistent font usage throughout the system
class FontUtils {
  /// The primary font family used throughout the application
  static const String primaryFont = 'Tajawal';
  
  /// Default font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  /// Helper method to create TextStyle with Tajawal font
  static TextStyle textStyle({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? height,
    TextOverflow? overflow,
    int? maxLines,
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontWeight: fontWeight ?? regular,
      fontSize: fontSize ?? 14.0,
      color: color,
      decoration: decoration,
      height: height,
      overflow: overflow,
    );
  }
  
  /// Predefined text styles for common use cases
  static TextStyle get headlineLarge => textStyle(
    fontWeight: bold,
    fontSize: 32.0,
  );
  
  static TextStyle get headlineMedium => textStyle(
    fontWeight: bold,
    fontSize: 28.0,
  );
  
  static TextStyle get headlineSmall => textStyle(
    fontWeight: bold,
    fontSize: 24.0,
  );
  
  static TextStyle get titleLarge => textStyle(
    fontWeight: bold,
    fontSize: 20.0,
  );
  
  static TextStyle get titleMedium => textStyle(
    fontWeight: semiBold,
    fontSize: 18.0,
  );
  
  static TextStyle get titleSmall => textStyle(
    fontWeight: semiBold,
    fontSize: 16.0,
  );
  
  static TextStyle get bodyLarge => textStyle(
    fontWeight: regular,
    fontSize: 16.0,
  );
  
  static TextStyle get bodyMedium => textStyle(
    fontWeight: regular,
    fontSize: 14.0,
  );
  
  static TextStyle get bodySmall => textStyle(
    fontWeight: regular,
    fontSize: 12.0,
  );
  
  static TextStyle get labelLarge => textStyle(
    fontWeight: medium,
    fontSize: 14.0,
  );
  
  static TextStyle get labelMedium => textStyle(
    fontWeight: medium,
    fontSize: 12.0,
  );
  
  static TextStyle get labelSmall => textStyle(
    fontWeight: medium,
    fontSize: 11.0,
  );
  
  /// Button text styles
  static TextStyle get buttonLarge => textStyle(
    fontWeight: semiBold,
    fontSize: 16.0,
  );
  
  static TextStyle get buttonMedium => textStyle(
    fontWeight: semiBold,
    fontSize: 14.0,
  );
  
  static TextStyle get buttonSmall => textStyle(
    fontWeight: semiBold,
    fontSize: 12.0,
  );
  
  /// Form text styles
  static TextStyle get formLabel => textStyle(
    fontWeight: medium,
    fontSize: 14.0,
  );
  
  static TextStyle get formInput => textStyle(
    fontWeight: regular,
    fontSize: 14.0,
  );
  
  static TextStyle get formError => textStyle(
    fontWeight: regular,
    fontSize: 12.0,
    color: Colors.red,
  );
  
  /// Table text styles
  static TextStyle get tableHeader => textStyle(
    fontWeight: semiBold,
    fontSize: 14.0,
  );
  
  static TextStyle get tableCell => textStyle(
    fontWeight: regular,
    fontSize: 14.0,
  );
  
  /// Navigation text styles
  static TextStyle get navigationTitle => textStyle(
    fontWeight: bold,
    fontSize: 20.0,
  );
  
  static TextStyle get navigationItem => textStyle(
    fontWeight: medium,
    fontSize: 14.0,
  );
}
