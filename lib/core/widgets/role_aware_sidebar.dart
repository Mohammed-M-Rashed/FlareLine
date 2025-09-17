import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/menu_permission_service.dart';
import '../auth/auth_provider.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flareline_uikit/components/sidebar/side_menu.dart';

class RoleAwareSidebar extends StatelessWidget {
  final double? width;
  final String? appName;
  final String? sideBarAsset;
  final Widget? logoWidget;
  final bool? isDark;
  final Color? darkBg;
  final Color? lightBg;
  final Widget? footerWidget;
  final double? logoFontSize;
  late final ValueNotifier<String> expandedMenuName;

  RoleAwareSidebar({
    super.key,
    this.darkBg,
    this.lightBg,
    this.width,
    this.appName,
    this.sideBarAsset,
    this.logoWidget,
    this.footerWidget,
    this.logoFontSize = 20,
    this.isDark,
  }) : expandedMenuName = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = isDark ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: (isDarkTheme ? darkBg : Colors.white),
      width: width ?? 280,
      child: Column(children: [
        _logoWidget(context, isDarkTheme),
        const SizedBox(height: 30),
        Expanded(child: _sideListWidget(context, isDarkTheme)),
        if (footerWidget != null) footerWidget!
      ]),
    );
  }

  Widget _logoWidget(BuildContext context, bool isDarkTheme) {
    if (logoWidget != null) {
      return logoWidget!;
    }

    return Row(
      children: [
        const SizedBox(width: 8),
        SvgPicture.asset(
          'assets/logo/logo_white.svg',
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            appName ?? 'Training System',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : FlarelineColors.darkBlackText,
              fontSize: logoFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sideListWidget(BuildContext context, bool isDarkTheme) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final userRoles = authController.userData?.roles.map((e) => e.name).toList() ?? [];

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: FutureBuilder(
            future: DefaultAssetBundle.of(context).loadString(sideBarAsset ?? 'assets/routes/menu_route_ar.json'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List listMenu = json.decode(snapshot.data.toString());
              // Convert List<dynamic> to List<Map<String, dynamic>>
              final List<Map<String, dynamic>> menuGroups = listMenu
                  .map((group) => Map<String, dynamic>.from(group))
                  .toList();
              final filteredListMenu = MenuPermissionService.filterMenuByPermissions(menuGroups);

              if (filteredListMenu.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: isDarkTheme ? Colors.white60 : FlarelineColors.darkBlackText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد قوائم متاحة لدورك',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkTheme ? Colors.white60 : FlarelineColors.darkBlackText,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(left: 20, right: 10),
                itemBuilder: (ctx, index) {
                  return _buildMenuItem(ctx, index, filteredListMenu, isDarkTheme, expandedMenuName);
                },
                separatorBuilder: (ctx, index) => const SizedBox(height: 10),
                itemCount: filteredListMenu.length,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, List listMenu, bool isDark, ValueNotifier<String> expandedMenuName) {
    var groupElement = listMenu.elementAt(index);
    List menuList = groupElement['menuList'];
    String groupName = groupElement['groupName'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupName.isNotEmpty)
          Text(
            groupName,
            style: TextStyle(
              fontSize: 20,
              color: isDark ? Colors.white60 : FlarelineColors.darkBlackText,
            ),
          ),
        if (groupName.isNotEmpty) const SizedBox(height: 10),
        ...menuList.map((e) => _buildSimpleMenuItem(context, e, isDark, expandedMenuName)).toList(),
      ],
    );
  }

  Widget _buildSimpleMenuItem(BuildContext context, Map<String, dynamic> menuItem, bool isDark, ValueNotifier<String> expandedMenuName) {
    final String itemMenuName = menuItem['menuName'] ?? '';
    final String path = menuItem['path'] ?? '';
    final String icon = menuItem['icon'] ?? '';
    final List<dynamic>? childList = menuItem['childList'];

    // Check if this menu item should be visible
    if (!MenuPermissionService.hasMenuPermission(path)) {
      return const SizedBox.shrink();
    }

    final bool isSelected = childList != null && childList.isNotEmpty
        ? false
        : _isSelectedPath(context, path);

    return Column(
      children: [
        InkWell(
          onTap: () {
            if (childList != null && childList.isNotEmpty) {
              _setExpandedMenuName(itemMenuName, expandedMenuName);
            } else {
              _pushOrJump(context, menuItem);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? FlarelineColors.darkBackground : FlarelineColors.gray)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (icon.isNotEmpty)
                  SvgPicture.asset(
                    icon,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : FlarelineColors.darkBlackText,
                      BlendMode.srcIn,
                    ),
                  ),
                if (icon.isNotEmpty) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    itemMenuName,
                    style: TextStyle(
                      color: isDark ? Colors.white : FlarelineColors.darkBlackText,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (childList != null && childList.isNotEmpty)
                  ValueListenableBuilder<String>(
                    valueListenable: expandedMenuName,
                    builder: (context, expandedMenu, child) {
                      return Icon(
                        expandedMenu == itemMenuName
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isDark ? Colors.white60 : FlarelineColors.darkBlackText,
                        size: 20,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        if (childList != null && childList.isNotEmpty)
          ValueListenableBuilder<String>(
            valueListenable: expandedMenuName,
            builder: (context, expandedMenu, child) {
              return Visibility(
                visible: expandedMenu == itemMenuName,
                child: Column(
                  children: childList
                      .where((subMenu) => MenuPermissionService.hasMenuPermission(subMenu['path'] ?? ''))
                      .map((subMenu) => _buildSubMenuItem(context, subMenu, isDark))
                      .toList(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSubMenuItem(BuildContext context, Map<String, dynamic> subMenuItem, bool isDark) {
    final bool isSelected = _isSelectedPath(context, subMenuItem['path'] ?? '');
    final String itemMenuName = subMenuItem['menuName'] ?? '';

    return InkWell(
      onTap: () => _pushOrJump(context, subMenuItem),
      child: Container(
        padding: const EdgeInsets.only(left: 50, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? FlarelineColors.darkBackground : FlarelineColors.gray)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                itemMenuName,
                style: TextStyle(
                  color: isDark ? Colors.white : FlarelineColors.darkBlackText,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setExpandedMenuName(String menuName, ValueNotifier<String> expandedMenuName) {
    if (expandedMenuName.value == menuName) {
      expandedMenuName.value = '';
    } else {
      expandedMenuName.value = menuName;
    }
  }

  bool _isSelectedPath(BuildContext context, String path) {
    final String? routePath = ModalRoute.of(context)?.settings?.name;
    return routePath == path;
  }

  void _pushOrJump(BuildContext context, Map<String, dynamic> menuItem) {
    if (Scaffold.of(context).isDrawerOpen) {
      Scaffold.of(context).closeDrawer();
    }

    final String path = menuItem['path'];
    final String? routePath = ModalRoute.of(context)?.settings?.name;

    if (path == routePath) {
      return;
    }

    // Check permission before navigation
    if (!MenuPermissionService.hasMenuPermission(path)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ليس لديك صلاحية للوصول إلى هذه الصفحة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(path);
  }
}