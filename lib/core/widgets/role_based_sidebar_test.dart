import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/menu_permission_service.dart';
import '../auth/auth_provider.dart';
import '../models/auth_model.dart';

/// Test widget to demonstrate role-based sidebar functionality
class RoleBasedSidebarTest extends StatefulWidget {
  const RoleBasedSidebarTest({super.key});

  @override
  State<RoleBasedSidebarTest> createState() => _RoleBasedSidebarTestState();
}

class _RoleBasedSidebarTestState extends State<RoleBasedSidebarTest> {
  String _selectedRole = 'company_account';
  List<String> _availableRoles = [
    'system_administrator',
    'admin', 
    'company_account',
    'training_general_manager',
    'board_chairman'
  ];

  @override
  void initState() {
    super.initState();
    _simulateUserRole();
  }

  void _simulateUserRole() {
    // Simulate different user roles for testing
    final mockUser = AuthUserModel(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      status: 'active',
      roles: [
        UserRole(
          id: 1,
          name: _selectedRole,
          displayName: _getRoleDisplayName(_selectedRole),
          description: 'Test role for ${_getRoleDisplayName(_selectedRole)}',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          pivot: {},
        )
      ],
      companyId: _selectedRole == 'company_account' ? 1 : null,
    );

    // Update the auth controller with mock user
    final authController = Get.find<AuthController>();
    authController.updateUser(mockUser);
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'system_administrator':
        return 'مدير النظام';
      case 'admin':
        return 'مدير';
      case 'company_account':
        return 'حساب شركة';
      case 'training_general_manager':
        return 'مدير عام التدريب';
      case 'board_chairman':
        return 'رئيس مجلس الإدارة';
      default:
        return 'مستخدم';
    }
  }

  void _changeRole(String newRole) {
    setState(() {
      _selectedRole = newRole;
    });
    _simulateUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار القائمة المبنية على الأدوار'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اختر دور المستخدم للاختبار:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: _availableRoles.map((role) {
                        return ElevatedButton(
                          onPressed: () => _changeRole(role),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedRole == role 
                                ? Colors.blue 
                                : Colors.grey[300],
                            foregroundColor: _selectedRole == role 
                                ? Colors.white 
                                : Colors.black,
                          ),
                          child: Text(_getRoleDisplayName(role)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Current Role Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات الدور الحالي:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('الدور: ${_getRoleDisplayName(_selectedRole)}'),
                    Text('الرمز: $_selectedRole'),
                    const SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: Future.value(MenuPermissionService.getMenuSummary()),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final summary = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الصفحات المتاحة: ${summary['accessibleMenus']} من ${summary['totalMenus']}'),
                              Text('مستوى الصلاحية: ${summary['permissionLevel']}'),
                            ],
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Accessible Menus
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الصفحات المتاحة:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FutureBuilder<List<String>>(
                          future: Future.value(MenuPermissionService.getAccessibleMenuPaths()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final accessiblePaths = snapshot.data!;
                              if (accessiblePaths.isEmpty) {
                                return const Center(
                                  child: Text('لا توجد صفحات متاحة لهذا الدور'),
                                );
                              }
                              return ListView.builder(
                                itemCount: accessiblePaths.length,
                                itemBuilder: (context, index) {
                                  final path = accessiblePaths[index];
                                  return ListTile(
                                    leading: const Icon(Icons.check_circle, color: Colors.green),
                                    title: Text(path),
                                    subtitle: Text(_getPathDescription(path)),
                                  );
                                },
                              );
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPathDescription(String path) {
    switch (path) {
      case '/dashboard':
        return 'لوحة التحكم الرئيسية';
      case '/userManagement':
        return 'إدارة المستخدمين والصلاحيات';
      case '/companyManagement':
        return 'إدارة بيانات الشركات';
      case '/specializationManagement':
        return 'إدارة التخصصات التدريبية';
      case '/trainingCenterManagement':
        return 'إدارة مراكز التدريب المعتمدة';
      case '/trainingCenterBranchManagement':
        return 'إدارة فروع مراكز التدريب';
      case '/courseManagement':
        return 'إدارة الدورات التدريبية';
      case '/trainerManagement':
        return 'إدارة المدربين المعتمدين';
      case '/trainingNeedManagement':
        return 'إدارة احتياجات التدريب للشركات';
      case '/special-course-request':
        return 'إدارة طلبات الدورات الخاصة';
      case '/training-plan':
        return 'إدارة خطط التدريب والموافقات';
      case '/plan-course-assignment-management':
        return 'إدارة تخصيص الدورات للخطط';
      case '/nomination-management':
        return 'إدارة ترشيحات الموظفين للدورات';
      case '/nomination-monitoring':
        return 'مراقبة ومتابعة حالة الترشيحات';
      default:
        return 'صفحة غير معروفة';
    }
  }
}
