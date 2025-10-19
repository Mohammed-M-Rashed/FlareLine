import 'package:get/get.dart';
import 'auth_service.dart';
import '../auth/auth_provider.dart';

class MenuPermissionService {
  // Define menu permissions based on roles
  static const Map<String, List<String>> _menuPermissions = {
    // Dashboard - Available to all authenticated users
    '/dashboard': ['system_administrator', 'admin', 'company_account', 'training_general_manager', 'board_chairman'],
    
    // User Management - System Administrator and Admin only
    '/userManagement': ['system_administrator', 'admin'],
    
    // Company Management - System Administrator and Admin only
    '/companyManagement': ['system_administrator', 'admin'],
    
    // Cooperative Company Management - Admin only
    '/cooperativeCompanyManagement': ['admin'],
    
    // Country Management - Admin only
    '/countryManagement': ['admin'],
    
    // City Management - Admin only
    '/cityManagement': ['admin'],
    
    // Education Levels Management - System Administrator and Admin only
    '/educationLevelsManagement': ['system_administrator', 'admin'],
    
    // Education Specializations Management - System Administrator and Admin only
    '/educationSpecializationsManagement': ['system_administrator', 'admin'],
    
    // Languages Management - System Administrator and Admin only
    '/languagesManagement': ['system_administrator', 'admin'],
    
    // Specialization Management - System Administrator, Admin (read-only)
    '/specializationManagement': ['system_administrator', 'admin', ],
    
    // Training Center Management - System Administrator and Admin only
    '/trainingCenterManagement': ['system_administrator', 'admin'],
    
    // Training Center Branch Management - System Administrator and Admin only
    '/trainingCenterBranchManagement': ['system_administrator', 'admin'],
    
    // Course Management - System Administrator, Admin (read-only)
    '/courseManagement': ['system_administrator', 'admin'],
    
    // Trainer Management - System Administrator and Admin only
    '/trainerManagement': ['system_administrator', 'admin'],
    
    // Training Need Management - System Administrator, Admin, and Company Account
    '/trainingNeedManagement': ['system_administrator', 'admin', 'company_account'],
    
    // Special Course Request Management - System Administrator, Admin, and Company Account
    '/special-course-request': ['system_administrator', 'admin', 'company_account'],
    
    // Training Plan Management - All roles with different access levels
    '/training-plan': ['system_administrator', 'admin', 'company_account', 'training_general_manager', 'board_chairman'],
    
    // Plan Course Assignment Management - System Administrator, Admin
    '/plan-course-assignment-management': ['system_administrator', 'admin'],
    
    // Nomination Management - Company Account only
    '/nomination-management': ['company_account'],
    
    // Nomination Monitoring - System Administrator, Admin, and Company Account
    '/nomination-monitoring': ['system_administrator', 'admin', 'company_account'],
  };

  // Check if user has permission to access a specific menu item
  static bool hasMenuPermission(String menuPath) {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        print('🚫 MENU PERMISSION: No user or roles found');
        return false;
      }

      // Get required roles for this menu
      final requiredRoles = _menuPermissions[menuPath];
      if (requiredRoles == null) {
        print('⚠️ MENU PERMISSION: No permission defined for menu: $menuPath');
        return false; // Deny access if no permission is defined
      }

      // Check if user has any of the required roles
      final userRoles = user.roles.map((role) => role.name).toList();
      final hasPermission = requiredRoles.any((role) => userRoles.contains(role));
      
      print('🔍 MENU PERMISSION: Menu: $menuPath, Required: $requiredRoles, User: $userRoles, Has Access: $hasPermission');
      
      // Special debug for country and city management
      if (menuPath == '/countryManagement' || menuPath == '/cityManagement') {
        print('🔍 SPECIAL DEBUG: Checking $menuPath');
        print('🔍 SPECIAL DEBUG: User roles: $userRoles');
        print('🔍 SPECIAL DEBUG: Required roles: $requiredRoles');
        print('🔍 SPECIAL DEBUG: User has admin role: ${userRoles.contains('admin')}');
        print('🔍 SPECIAL DEBUG: User has system_administrator role: ${userRoles.contains('system_administrator')}');
      }
      return hasPermission;
    } catch (e) {
      print('❌ MENU PERMISSION: Error checking menu permission: $e');
      return false;
    }
  }

  // Filter menu list based on user permissions
  static List<Map<String, dynamic>> filterMenuByPermissions(List<Map<String, dynamic>> menuGroups) {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        print('🚫 MENU FILTER: No user or roles found, returning empty menu');
        return [];
      }

      final filteredGroups = <Map<String, dynamic>>[];
      
      for (final group in menuGroups) {
        final groupName = group['groupName'] as String;
        final menuList = group['menuList'] as List<dynamic>;
        
        // Filter menu items based on permissions
        final filteredMenuList = menuList.where((menuItem) {
          final menuPath = menuItem['path'] as String;
          return hasMenuPermission(menuPath);
        }).toList();
        
        // Only include groups that have at least one accessible menu item
        if (filteredMenuList.isNotEmpty) {
          filteredGroups.add({
            'groupName': groupName,
            'menuList': filteredMenuList,
          });
        }
      }
      
      print('✅ MENU FILTER: Filtered ${menuGroups.length} groups to ${filteredGroups.length} groups');
      return filteredGroups;
    } catch (e) {
      print('❌ MENU FILTER: Error filtering menu: $e');
      return [];
    }
  }

  // Get user's accessible menu paths
  static List<String> getAccessibleMenuPaths() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        return [];
      }

      final accessiblePaths = <String>[];
      
      for (final entry in _menuPermissions.entries) {
        final menuPath = entry.key;
        final requiredRoles = entry.value;
        final userRoles = user.roles.map((role) => role.name).toList();
        
        if (requiredRoles.any((role) => userRoles.contains(role))) {
          accessiblePaths.add(menuPath);
        }
      }
      
      print('✅ ACCESSIBLE PATHS: User has access to ${accessiblePaths.length} menu paths');
      return accessiblePaths;
    } catch (e) {
      print('❌ ACCESSIBLE PATHS: Error getting accessible paths: $e');
      return [];
    }
  }

  // Check if user can access any menu in a group
  static bool hasGroupAccess(List<dynamic> menuList) {
    try {
      for (final menuItem in menuList) {
        final menuPath = menuItem['path'] as String;
        if (hasMenuPermission(menuPath)) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ GROUP ACCESS: Error checking group access: $e');
      return false;
    }
  }

  // Get user's role-based menu summary
  static Map<String, dynamic> getMenuSummary() {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.userData;
      
      if (user == null || user.roles.isEmpty) {
        return {
          'userRoles': [],
          'accessibleMenus': 0,
          'totalMenus': _menuPermissions.length,
          'permissionLevel': 'none'
        };
      }

      final userRoles = user.roles.map((role) => role.name).toList();
      final accessiblePaths = getAccessibleMenuPaths();
      
      String permissionLevel = 'none';
      if (userRoles.contains('system_administrator')) {
        permissionLevel = 'system_administrator';
      } else if (userRoles.contains('admin')) {
        permissionLevel = 'admin';
      } else if (userRoles.contains('company_account')) {
        permissionLevel = 'company_account';
      } else if (userRoles.contains('training_general_manager')) {
        permissionLevel = 'training_general_manager';
      } else if (userRoles.contains('board_chairman')) {
        permissionLevel = 'board_chairman';
      }

      return {
        'userRoles': userRoles,
        'accessibleMenus': accessiblePaths.length,
        'totalMenus': _menuPermissions.length,
        'permissionLevel': permissionLevel,
        'accessiblePaths': accessiblePaths,
      };
    } catch (e) {
      print('❌ MENU SUMMARY: Error getting menu summary: $e');
      return {
        'userRoles': [],
        'accessibleMenus': 0,
        'totalMenus': _menuPermissions.length,
        'permissionLevel': 'none'
      };
    }
  }
}
