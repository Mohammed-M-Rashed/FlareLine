import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/core/theme/global_theme.dart';
import 'package:flareline_uikit/service/localization_provider.dart';
import 'package:flareline_uikit/service/theme_provider.dart';
import 'package:flareline/core/auth/auth_provider.dart';
import 'package:flareline/pages/auth/sign_in/sign_in_provider.dart';
import 'package:flareline/core/services/training_center_service.dart';
import 'package:flareline/routes.dart';
import 'package:flutter/material.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1080, 720),
      minimumSize: Size(480, 360),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize GetX controllers
  Get.put(AuthController());
  Get.put(ThemeProvider());
  final localizationProvider = Get.put(LocalizationProvider());
  // Only support Arabic locale
  localizationProvider.setSupportedLocales([const Locale('ar')]);
  Get.put(SignInProvider());
  
  // Initialize global services

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationProvider>(
      init: LocalizationProvider(),
      builder: (localizationController) {
        return GetBuilder<ThemeProvider>(
          init: ThemeProvider(),
          builder: (themeController) {
            return ToastificationWrapper(
              child: GetMaterialApp(
                navigatorKey: RouteConfiguration.navigatorKey,
                title: 'نظام التدريب',
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                locale: const Locale('ar'), // Always use Arabic
                supportedLocales: const [Locale('ar')], // Only support Arabic
                getPages: RouteConfiguration.getPages,
                themeMode: themeController.isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                theme: _buildLightTheme(),
                darkTheme: _buildDarkTheme(),
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
                    child: widget!,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Build light theme with global font configuration
  ThemeData _buildLightTheme() {
    final baseTheme = GlobalTheme.lightThemeData;
    return baseTheme.copyWith(
      // Ensure all text uses Tajawal font by default
      textTheme: baseTheme.textTheme.apply(
        fontFamily: GlobalTheme.fontFamily,
        bodyColor: baseTheme.textTheme.bodyLarge?.color,
        displayColor: baseTheme.textTheme.displayLarge?.color,
      ),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(
        fontFamily: GlobalTheme.fontFamily,
        bodyColor: baseTheme.primaryTextTheme.bodyLarge?.color,
        displayColor: baseTheme.primaryTextTheme.displayLarge?.color,
      ),
      // Apply font to all input decorations
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        labelStyle: baseTheme.inputDecorationTheme.labelStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        hintStyle: baseTheme.inputDecorationTheme.hintStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        errorStyle: baseTheme.inputDecorationTheme.errorStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      // Apply font to all dialog themes
      dialogTheme: baseTheme.dialogTheme.copyWith(
        titleTextStyle: baseTheme.dialogTheme.titleTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        contentTextStyle: baseTheme.dialogTheme.contentTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all snackbar themes
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        contentTextStyle: baseTheme.snackBarTheme.contentTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all tooltip themes
      tooltipTheme: baseTheme.tooltipTheme.copyWith(
        textStyle: baseTheme.tooltipTheme.textStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
    );
  }

  /// Build dark theme with global font configuration
  ThemeData _buildDarkTheme() {
    final baseTheme = GlobalTheme.darkThemeData;
    return baseTheme.copyWith(
      // Ensure all text uses Tajawal font by default
      textTheme: baseTheme.textTheme.apply(
        fontFamily: GlobalTheme.fontFamily,
        bodyColor: baseTheme.textTheme.bodyLarge?.color,
        displayColor: baseTheme.textTheme.displayLarge?.color,
      ),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(
        fontFamily: GlobalTheme.fontFamily,
        bodyColor: baseTheme.primaryTextTheme.bodyLarge?.color,
        displayColor: baseTheme.primaryTextTheme.displayLarge?.color,
      ),
      // Apply font to all input decorations
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        labelStyle: baseTheme.inputDecorationTheme.labelStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        hintStyle: baseTheme.inputDecorationTheme.hintStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        errorStyle: baseTheme.inputDecorationTheme.errorStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: TextStyle(fontFamily: GlobalTheme.fontFamily),
        ),
      ),
      // Apply font to all dialog themes
      dialogTheme: baseTheme.dialogTheme.copyWith(
        titleTextStyle: baseTheme.dialogTheme.titleTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
        contentTextStyle: baseTheme.dialogTheme.contentTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all snackbar themes
      snackBarTheme: baseTheme.snackBarTheme.copyWith(
        contentTextStyle: baseTheme.snackBarTheme.contentTextStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
      // Apply font to all tooltip themes
      tooltipTheme: baseTheme.tooltipTheme.copyWith(
        textStyle: baseTheme.tooltipTheme.textStyle?.copyWith(
          fontFamily: GlobalTheme.fontFamily,
        ),
      ),
    );
  }
}
