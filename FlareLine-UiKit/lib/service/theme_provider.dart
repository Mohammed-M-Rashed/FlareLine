import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends GetxController {
  final _themeMode = ThemeMode.light.obs;

  ThemeMode get themeMode => _themeMode.value;
  bool get isDark => _themeMode.value == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
  }

  void toggleThemeMode() {
    _themeMode.value = _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
