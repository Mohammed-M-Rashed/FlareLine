
import 'package:flareline_uikit/components/toolbar/toolbar.dart';
import 'package:flareline_uikit/service/localization_provider.dart';
import 'package:flareline_uikit/widget/flareline_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flareline/core/auth/auth_provider.dart';
import 'package:flareline/core/widgets/role_aware_sidebar.dart';

abstract class LayoutWidget extends FlarelineLayoutWidget {
  const LayoutWidget({super.key});

  @override
  String sideBarAsset(BuildContext context) {
    return 'assets/routes/menu_route_ar.json';
  }

  @override
  Widget sideBarWidget(BuildContext context) {
    return RoleAwareSidebar(
      sideBarAsset: sideBarAsset(context),
      isDark: isDarkTheme(context),
      darkBg: sideBarDarkColor,
      lightBg: sideBarLightColor,
      width: 280,
      appName: 'نظام التدريب',
    );
  }

  @override
  Widget? toolbarWidget(BuildContext context, bool showDrawer) {
    return ToolBarWidget(
      showMore: showDrawer,
      showChangeTheme: false,
      userInfoWidget: _userInfoWidget(context),
    );
  }

  Widget _userInfoWidget(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authController.userData?.name ??
                  (authController.userEmail.isNotEmpty ? authController.userEmail : 'زائر'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  authController.userData?.roles.firstOrNull?.displayName ?? 'مستخدم',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            const CircleAvatar(
              backgroundImage: AssetImage('assets/user/user-01.png'),
              radius: 22,
            )
          ],
        );
      },
    );
  }
}
