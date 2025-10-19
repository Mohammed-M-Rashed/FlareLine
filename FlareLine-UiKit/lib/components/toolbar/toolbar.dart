library flareline_uikit;
import 'package:flareline_uikit/components/badge/anim_badge.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/forms/search_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline_uikit/service/localization_provider.dart';
import 'package:flareline_uikit/service/theme_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/core/services/auth_service.dart';
import 'package:flareline_uikit/components/forms/select_widget.dart';

class ToolBarWidget extends StatelessWidget {
  bool? showMore;
  bool? showChangeTheme;
  final Widget? userInfoWidget;
  final Widget? rightSideWidget;

  ToolBarWidget({super.key, this.showMore, this.showChangeTheme, this.userInfoWidget, this.rightSideWidget});

  @override
  Widget build(BuildContext context) {
    return _toolsBarWidget(context);
  }

  _toolsBarWidget(BuildContext context) {
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.all(10),
      child: Row(children: [
        // Left side - Hamburger menu and custom text
        ResponsiveBuilder(builder: (context, sizingInformation) {
          // Check the sizing information here and return your UI
          if ((showMore ?? false) ||
              sizingInformation.deviceScreenType != DeviceScreenType.desktop) {
            return InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200, width: 1)),
                alignment: Alignment.center,
                child: const Icon(Icons.more_vert),
              ),
              onTap: () {
                if (Scaffold.of(context).isDrawerOpen) {
                  Scaffold.of(context).closeDrawer();
                  return;
                }
                Scaffold.of(context).openDrawer();
              },
            );
          }

          return const SizedBox();
        }),
        
        const SizedBox(width: 10),
        
        // Custom text widget on the left
        if (rightSideWidget != null) rightSideWidget!,

        // Spacer to push content to opposite sides
        const Spacer(),
        
        // Right side - Theme toggle and user info
        if (showChangeTheme ?? false) const ToggleWidget(),
        if (showChangeTheme ?? false) const SizedBox(width: 10),
        
        // User info widget on the right
        if(userInfoWidget!=null)
          userInfoWidget!,
          
        InkWell(
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            child: const Icon(Icons.arrow_drop_down),
          ),
          onTap: () async {
            await showMenu(
              color: Colors.white,
              context: context,
              position: RelativeRect.fromLTRB(
                  0, 80, MediaQuery.of(context).size.width - 100, 0),
              items: <PopupMenuItem<String>>[
                // PopupMenuItem<String>(
                //   value: 'value01',
                //   child: Text('ملفي الشخصي'),
                //   onTap: () async {
                //     onProfileClick(context);
                //   },
                // ),
                // PopupMenuItem<String>(
                //   value: 'value03',
                //   child: Text('الإعدادات'),
                //   onTap: () async {
                //
                //   },
                // ),
                PopupMenuItem<String>(
                  value: 'value05',
                  child: Text('تسجيل الخروج'),
                  onTap: () {
                    onLogoutClick(context);
                  },
                )
              ],
            );
          },
        ),
      ]),
    );
  }

  void onProfileClick(BuildContext context){
    Get.toNamed('/profile');
  }


  void onSettingClick(BuildContext context){
    Get.toNamed('/settings');
  }

  Future<void> onLogoutClick(BuildContext context) async {
    // Sign out using AuthService
    print('🚪 TOOLBAR: User clicked logout');
    await AuthService.signOut(context);
    print('🚪 TOOLBAR: Navigating to login page');
    Get.offAllNamed('/');
  }

  // Remove language switcher widget as we only support Arabic
  // Widget _languagesWidget(BuildContext context) {
  //   return GetBuilder<LocalizationProvider>(
  //     builder: (localizationProvider) {
  //       return Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: localizationProvider.supportedLocales.map((e) {
  //           return SizedBox(
  //             width: 50,
  //             height: 20,
  //             child: ButtonWidget(
  //               btnText: e.languageCode,
  //               type: e.languageCode == localizationProvider.languageCode
  //                   ? ButtonType.primary.type
  //                   : null,
  //               onTap: () {
  //                 localizationProvider.setLocale(e);
  //               },
  //             ),
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }


}

class ToggleWidget extends StatelessWidget {
  const ToggleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeProvider>(
      builder: (themeProvider) {
        bool isDark = themeProvider.isDark;
        return InkWell(
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 3),
         
              decoration: BoxDecoration(
                  color: FlarelineColors.background,
                  borderRadius: BorderRadius.circular(45)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: isDark ? Colors.transparent : Colors.white,
                    child: SvgPicture.asset('assets/toolbar/sun.svg',
                        width: 18,
                        height: 18,
                        color: isDark
                            ? FlarelineColors.darkTextBody
                            : FlarelineColors.primary),
                  ),
                  CircleAvatar(
                     radius: 15,
                    backgroundColor: isDark ? Colors.white : Colors.transparent,
                    child: SvgPicture.asset('assets/toolbar/moon.svg',
                        width: 18,
                        height: 18,
                        color: isDark
                            ? FlarelineColors.primary
                            : FlarelineColors.darkTextBody),
                  ),
                ],
              )),
          onTap: () {
            themeProvider.toggleThemeMode();
          },
        );
      },
    );
  }
}
