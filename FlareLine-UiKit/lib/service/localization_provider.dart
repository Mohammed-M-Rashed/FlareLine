import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationProvider extends GetxController {
  static const Locale ar = Locale('ar');

  @override
  void onInit() {
    super.onInit();
    // Always use Arabic locale
    _locale.value = ar;
  }

  final _locale = const Locale.fromSubtags(languageCode: 'ar').obs;
  final _supportedLocales = <Locale>[ar].obs;

  Locale get locale => _locale.value;
  String get languageCode => locale.languageCode;
  List<Locale> get supportedLocales => _supportedLocales;

  final box = GetStorage();

  // Remove setLocale method as we only support Arabic
  // void setLocale(Locale locale) {
  //   _locale.value = locale;
  //   box.write("locale", locale.languageCode);
  // }

  void setSupportedLocales(List<Locale> supportedLocales) {
    // Only support Arabic
    _supportedLocales.value = [ar];
  }
}
