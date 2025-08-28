import 'package:flareline/core/theme/global_colors.dart';
import 'package:flutter/material.dart';

class GlobalTheme {
  static const _lightFillColor = GlobalColors.darkBackgroundColor;
  static const _darkFillColor = GlobalColors.gray;

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  // Custom font family - made public for use throughout the system
  static const String fontFamily = 'Tajawal';

  static ThemeData lightThemeData = theme(lightColorScheme, _lightFocusColor,
      lightAppBarTheme, GlobalColors.darkText, lightCardTheme);
  static ThemeData darkThemeData = theme(darkColorScheme, _darkFocusColor,
      darkAppBarThemd, GlobalColors.darkText, darkCardTheme);

  static ThemeData theme(ColorScheme colorScheme, Color focusColor,
      AppBarTheme appBarTheme, Color hintColor, CardThemeData cardTheme) {
    return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        focusColor: focusColor,
        appBarTheme: appBarTheme,
        textTheme: _textTheme,
        hintColor: hintColor,
        cardTheme: cardTheme,
        fontFamily: fontFamily,
        // Ensure all text uses the custom font by default
        primaryTextTheme: _textTheme.apply(fontFamily: fontFamily));
  }

  static CardThemeData lightCardTheme = const CardThemeData(
    margin: EdgeInsets.zero,
    color: Colors.white,
    surfaceTintColor:  Color(0xFFE2E8F0),
    shadowColor: Color(0x11000000),
    elevation: 0,
  );

  static CardThemeData darkCardTheme = CardThemeData(
    margin: EdgeInsets.zero,
    color: GlobalColors.darkAppBar,
    surfaceTintColor: GlobalColors.border.withOpacity(0.05),
    shadowColor: GlobalColors.darkAppBar.withOpacity(0.2),
    elevation: 0,
  );

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
  );

  static const AppBarTheme darkAppBarThemd =
      AppBarTheme(backgroundColor: GlobalColors.sideBar);

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: GlobalColors.primary,
    primaryContainer: GlobalColors.gray,
    secondary: GlobalColors.border,
    secondaryContainer: GlobalColors.border,
    background: GlobalColors.gray,
    surface: Color(0xFFFAFBFB),
    onBackground: Colors.white,
    error: _lightFillColor,
    onError: _lightFillColor,
    onPrimary: _lightFillColor,
    onSecondary: Color(0xFF322942),
    onSurface: Color(0xFF241E30),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: GlobalColors.primary,
    primaryContainer: Colors.white,
    secondary: GlobalColors.primary,
    secondaryContainer: GlobalColors.primary,
    background: GlobalColors.darkBackgroundColor,
    surface: Colors.white,
    onBackground: Color(0x0DFFFFFF),
    // White with 0.05 opacity
    error: _darkFillColor,
    onError: _darkFillColor,
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    brightness: Brightness.dark,
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  // Helper method to create TextStyle with Tajawal font
  static TextStyle textStyle({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
    TextDecoration? decoration,
    double? height,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight ?? _regular,
      fontSize: fontSize ?? 14.0,
      color: color,
      decoration: decoration,
      height: height,
    );
  }

  static final TextTheme _textTheme = TextTheme(
    headlineMedium: textStyle(fontWeight: _bold, fontSize: 20.0),
    bodySmall: textStyle(fontWeight: _semiBold, fontSize: 16.0),
    headlineSmall: textStyle(fontWeight: _medium, fontSize: 16.0),
    titleMedium: textStyle(fontWeight: _medium, fontSize: 16.0),
    labelSmall: textStyle(fontWeight: _medium, fontSize: 12.0),
    bodyLarge: textStyle(fontWeight: _regular, fontSize: 14.0),
    titleSmall: textStyle(fontWeight: _medium, fontSize: 14.0),
    bodyMedium: textStyle(fontWeight: _regular, fontSize: 16.0),
    titleLarge: textStyle(fontWeight: _bold, fontSize: 16.0),
    labelLarge: textStyle(fontWeight: _semiBold, fontSize: 14.0),
  );
}
