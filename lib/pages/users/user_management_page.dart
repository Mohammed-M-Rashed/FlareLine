import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/services/user_service.dart';
import 'package:flareline/core/services/company_service.dart';
import 'package:toastification/toastification.dart';

import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/core/models/company_model.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';

import 'package:get/get.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flareline/core/services/auth_service.dart';
import 'package:flareline/core/theme/global_theme.dart';

class UserManagementPage extends LayoutWidget {
  const UserManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'إدارة المستخدمين';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        UserManagementWidget(),
      ],
    );
  }
}

class UserManagementWidget extends StatelessWidget {
  const UserManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<_UserDataProvider>(
          init: _UserDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, _UserDataProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إدارة المستخدمين',
                            style: GlobalTheme.textStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'إدارة مستخدمي النظام والشركات والأقسام',
                            style: GlobalTheme.textStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Obx(() => ButtonWidget(
                            btnText: provider.isLoading ? 'جاري التحميل...' : 'تحديث',
                            type: 'secondary',
                            onTap: provider.isLoading ? null : () async {
                              try {
                                await provider.refreshData();
                                _showSuccessToast('Users data refreshed successfully');
                              } catch (e) {
                                _showErrorToast('فشل في تحديث بيانات المستخدمين: ${e.toString()}');
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 140,
                          child: ButtonWidget(
                            btnText: 'إضافة مستخدم',
                            type: 'primary',
                            onTap: () {
                              _showAddUserForm(context, provider);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
                             Obx(() {
                 if (provider.isLoading) {
                   return const LoadingWidget();
                 }

                 final users = provider.users;

                 if (users.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.people_outline,
                           size: 64,
                           color: Colors.grey[400],
                         ),
                         const SizedBox(height: 16),
                         Text(
                           'لا يوجد مستخدمين',
                           style: GlobalTheme.textStyle(
                             fontSize: 18,
                             color: Colors.grey[600],
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           'ابدأ بإضافة أول مستخدم',
                           style: GlobalTheme.textStyle(
                             fontSize: 14,
                             color: Colors.grey[500],
                           ),
                         ),
                         const SizedBox(height: 16),
                         ButtonWidget(
                           btnText: 'إضافة أول مستخدم',
                           type: 'primary',
                           onTap: () {
                             _showAddUserForm(context, provider);
                           },
                         ),
                       ],
                     ),
                   );
                 }

                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // User count and summary
                     CountSummaryWidget(
                       count: users.length,
                       itemName: 'مستخدم',
                       itemNamePlural: 'مستخدمين',
                       icon: Icons.people,
                       color: Colors.blue,
                     ),
                     const SizedBox(height: 16),
                     
                     // Data table
                     LayoutBuilder(
                       builder: (context, constraints) {
                         return Container(
                           width: double.infinity,
                           child: DataTable(
                             headingRowColor: MaterialStateProperty.resolveWith(
                               (states) => GlobalColors.lightGray,
                             ),
                             horizontalMargin: 12,
                             showBottomBorder: true,
                             showCheckboxColumn: false,
                             headingTextStyle: TextStyle(
                               fontWeight: FontWeight.bold,
                               color: Colors.black,
                               fontSize: 13,
                             ),
                             dividerThickness: 1,
                             columnSpacing: 8,
                             dataTextStyle: TextStyle(
                               fontSize: 12,
                               color: Colors.black87,
                             ),
                             dataRowMinHeight: 60,
                             dataRowMaxHeight: 60,
                             headingRowHeight: 50,
                             columns: [
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'الاسم',
                                     textAlign: TextAlign.start,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'البريد الإلكتروني',
                                     textAlign: TextAlign.start,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'الدور',
                                     textAlign: TextAlign.start,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'الشركة',
                                     textAlign: TextAlign.start,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'الحالة',
                                     textAlign: TextAlign.center,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                               DataColumn(
                                 label: Expanded(
                                   child: Text(
                                     'الإجراءات',
                                     textAlign: TextAlign.center,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                                 numeric: false,
                               ),
                             ],
                             rows: provider.pagedUsers
                                 .map((user) => DataRow(
                                       onSelectChanged: (selected) {},
                                       cells: [
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 120,
                                               maxWidth: 180,
                                             ),
                                             child: Row(
                                               children: [
                                                 CircleAvatar(
                                                   backgroundImage: AssetImage(UserService.getDefaultAvatar()),
                                                   radius: 16,
                                                 ),
                                                 const SizedBox(width: 8),
                                                 Expanded(
                                                   child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       Text(
                                                         user.name,
                                                         style: const TextStyle(
                                                           fontWeight: FontWeight.w600,
                                                           fontSize: 12,
                                                         ),
                                                         overflow: TextOverflow.ellipsis,
                                                       ),
                                                     ],
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 150,
                                               maxWidth: 220,
                                             ),
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 Text(
                                                   user.email,
                                                   style: const TextStyle(
                                                     fontSize: 12,
                                                     color: Colors.black87,
                                                   ),
                                                   overflow: TextOverflow.ellipsis,
                                                 ),
                                                 if (user.createdAt.isNotEmpty)
                                                   Text(
                                                     'Created: ${_formatDate(user.createdAt)}',
                                                     style: TextStyle(
                                                       fontSize: 10,
                                                       color: Colors.grey[600],
                                                     ),
                                                   ),
                                               ],
                                             ),
                                           ),
                                         ),
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 100,
                                               maxWidth: 150,
                                             ),
                                             child: Container(
                                               padding: const EdgeInsets.symmetric(
                                                 horizontal: 8,
                                                 vertical: 4,
                                               ),
                                               decoration: BoxDecoration(
                                                 color: Colors.purple.shade50,
                                                 borderRadius: BorderRadius.circular(16),
                                                 border: Border.all(
                                                   color: Colors.purple.shade200,
                                                   width: 1,
                                                 ),
                                               ),
                                               child: Text(
                                                 user.getFirstRoleDisplayName(),
                                                 style: TextStyle(
                                                   fontWeight: FontWeight.w500,
                                                   fontSize: 11,
                                                   color: Colors.purple.shade700,
                                                 ),
                                                 textAlign: TextAlign.center,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                             ),
                                           ),
                                         ),
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 100,
                                               maxWidth: 150,
                                             ),
                                             child: Tooltip(
                                               message: user.company?.name ?? 'لا توجد شركة مخصصة',
                                               child: Container(
                                                 padding: const EdgeInsets.symmetric(
                                                   horizontal: 8,
                                                   vertical: 4,
                                                 ),
                                                 decoration: BoxDecoration(
                                                   color: Colors.blue.shade50,
                                                   borderRadius: BorderRadius.circular(16),
                                                   border: Border.all(
                                                     color: Colors.blue.shade200,
                                                     width: 1,
                                                   ),
                                                 ),
                                                 child: Text(
                                                   user.company?.name ?? 'No company',
                                                   style: TextStyle(
                                                     fontWeight: FontWeight.w500,
                                                     fontSize: 11,
                                                     color: Colors.blue.shade700,
                                                   ),
                                                   textAlign: TextAlign.center,
                                                   overflow: TextOverflow.ellipsis,
                                                 ),
                                               ),
                                             ),
                                           ),
                                         ),
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 80,
                                               maxWidth: 120,
                                             ),
                                             child: Container(
                                               padding: const EdgeInsets.symmetric(
                                                 horizontal: 8,
                                                 vertical: 4,
                                               ),
                                               decoration: BoxDecoration(
                                                 color: user.statusColor.withOpacity(0.1),
                                                 borderRadius: BorderRadius.circular(16),
                                                 border: Border.all(
                                                   color: user.statusColor,
                                                   width: 1,
                                                 ),
                                               ),
                                               child: Text(
                                                 user.statusDisplayText,
                                                 style: TextStyle(
                                                   fontWeight: FontWeight.w500,
                                                   fontSize: 11,
                                                   color: user.statusColor,
                                                 ),
                                                 textAlign: TextAlign.center,
                                                 overflow: TextOverflow.ellipsis,
                                               ),
                                             ),
                                           ),
                                         ),
                                         DataCell(
                                           Container(
                                             constraints: const BoxConstraints(
                                               minWidth: 80,
                                               maxWidth: 100,
                                             ),
                                             child: Row(
                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 // View button
                                                 IconButton(
                                                   icon: const Icon(
                                                     Icons.visibility,
                                                     size: 18,
                                                   ),
                                                   onPressed: () {
                                                     _showViewUserDialog(context, user);
                                                   },
                                                   tooltip: 'View Details',
                                                   style: IconButton.styleFrom(
                                                     backgroundColor: Colors.grey.shade50,
                                                     foregroundColor: Colors.grey.shade700,
                                                   ),
                                                 ),
                                                 const SizedBox(width: 4),
                                                 // Edit button
                                                 IconButton(
                                                   icon: const Icon(
                                                     Icons.edit,
                                                     size: 18,
                                                   ),
                                                   onPressed: () {
                                                     _showEditUserForm(context, user, provider);
                                                   },
                                                   tooltip: 'Edit User',
                                                   style: IconButton.styleFrom(
                                                     backgroundColor: Colors.blue.shade50,
                                                     foregroundColor: Colors.blue.shade700,
                                                   ),
                                                 ),
                                                 const SizedBox(width: 4),
                                                 // Activation/Deactivation button
                                                 IconButton(
                                                   icon: Icon(
                                                     user.isActive ? Icons.block : Icons.check_circle,
                                                     size: 18,
                                                   ),
                                                   onPressed: (AuthService.isSystemAdministrator() && user.canChangeStatus)
                                                     ? () {
                                                         provider.toggleUserStatus(context, user);
                                                       }
                                                     : null,
                                                   tooltip: _getStatusToggleTooltip(user),
                                                   style: IconButton.styleFrom(
                                                     backgroundColor: _getStatusToggleBackgroundColor(user),
                                                     foregroundColor: _getStatusToggleForegroundColor(user),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ),
                                         ),
                                       ],
                                     ))
                                 .toList(),
                           ),
                         );
                       },
                     ),
                     const SizedBox(height: 12),
                     // Pagination controls
                     Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         const Text(
                           'Rows per page:',
                           style: TextStyle(fontSize: 12),
                         ),
                         const SizedBox(width: 8),
                         DropdownButton<int>(
                           value: provider.rowsPerPage,
                           items: const [10, 20, 50]
                               .map((n) => DropdownMenuItem<int>(
                                     value: n,
                                     child: Text('$n', style: TextStyle(fontSize: 12)),
                                   ))
                               .toList(),
                           onChanged: (value) {
                             if (value != null) provider.setRowsPerPage(value);
                           },
                         ),
                         const SizedBox(width: 16),
                         Text(
                           'Page ${provider.currentPage + 1} of ${provider.totalPages}',
                           style: const TextStyle(fontSize: 12),
                         ),
                         IconButton(
                           icon: const Icon(Icons.chevron_left, size: 20),
                           onPressed: provider.currentPage > 0
                               ? () => provider.prevPage()
                               : null,
                           tooltip: 'Previous page',
                         ),
                         IconButton(
                           icon: const Icon(Icons.chevron_right, size: 20),
                           onPressed: (provider.currentPage + 1) < provider.totalPages
                               ? () => provider.nextPage()
                               : null,
                           tooltip: 'Next page',
                         ),
                       ],
                     ),
                   ],
                 );
               }),
            ],
          ),
        );
      },
    );
  }

     void _showAddUserForm(BuildContext context, _UserDataProvider provider) {
     final formKey = GlobalKey<FormState>();
     final nameController = TextEditingController();
     final emailController = TextEditingController();
     final emailVerifiedAtController = TextEditingController();
     // These controllers are no longer needed with dropdown implementation
     
     // Auto-generate initial password
     String generatedPassword = _generateRandomPassword();
     final passwordController = TextEditingController(text: generatedPassword);
     
           // Role selection
      String? selectedRole;
      final List<Map<String, String>> userRoles = [
        {
          'value': 'system_administrator',
          'label': 'System Administrator',
        },
        {
          'value': 'admin',
          'label': 'Administrator',
        },
        {
          'value': 'company_account',
          'label': 'Company Account',
        },
      ];
      
      // Company selection
      Company? selectedCompany;
      List<Company> companies = [];
      bool isLoadingCompanies = false;
      
      // Loading state for form submission
      bool isSubmitting = false;

      ModalDialog.show(
        context: context,
        title: 'إضافة مستخدم جديد',
        showTitle: true,
        modalType: ModalType.large,
        footer: StatefulBuilder(
          builder: (BuildContext context, StateSetter setFooterState) {
            return Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    child: ButtonWidget(
                      btnText: isSubmitting ? 'جاري الإنشاء...' : 'حفظ',
                      onTap: isSubmitting ? null : () async {
                        // Check if role requires company
                        bool requiresCompany = !['system_administrator'].contains(selectedRole);
                        
                        // Validate form based on role requirements
                        bool isFormValid = formKey.currentState!.validate() && 
                                         selectedRole != null && 
                                         (!requiresCompany || selectedCompany != null);
                        
                        if (isFormValid) {
                          // Set loading state
                          setFooterState(() {
                            isSubmitting = true;
                          });
                         
                          try {
                            // Create user with new model structure
                            final newUser = User(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text,
                              role: selectedRole ?? 'user',  // Keep for backward compatibility
                              roles: [
                                Role(
                                  name: selectedRole ?? 'company_account',
                                  displayName: _getRoleDisplayName(selectedRole ?? 'company_account'),
                                ),
                              ],
                              emailVerifiedAt: emailVerifiedAtController.text.isNotEmpty ? emailVerifiedAtController.text : null,
                              createdAt: DateTime.now().toIso8601String(),
                              updatedAt: DateTime.now().toIso8601String(),
                              companyId: requiresCompany ? selectedCompany?.id : null,
                              status: 'active', // Default status for new users
                              company: requiresCompany ? selectedCompany : null,
                            );
                            
                            // Create user via API
                            final result = await UserService.createUser(context, newUser);
                            if (result is bool && result) {
                              // Close modal first for smooth UX
                              Get.back();
                              // Show success message with generated password
                              _showPasswordInfoDialog(context, nameController.text.trim(), passwordController.text);
                              // Add user to local array for instant table update
                              provider.addUser(newUser);
                            } else if (result is String) {
                              try {
                                // Parse the JSON response to extract m_ar message
                                final Map<String, dynamic> responseData = json.decode(result as String);
                                final String? mArMessage = responseData['m_ar'];
                                
                                // Close modal first for smooth UX
                                Get.back();
                                
                                // Show success notification with m_ar message
                                                                 _showSuccessToast(mArMessage ?? 'تم إنشاء المستخدم بنجاح');
                                // Add user to local array for instant table update
                                provider.addUser(newUser);
                              } catch (e) {
                                // If parsing fails, show the original result
                                Get.back();
                                _showSuccessToast(result.toString());
                                // Add user to local array for instant table update
                                provider.addUser(newUser);
                              }
                            }
                          } catch (e) {
                            // Handle any errors
                                                         _showErrorToast('خطأ في إنشاء المستخدم: ${e.toString()}');
                          } finally {
                            // Reset loading state
                            setFooterState(() {
                              isSubmitting = false;
                            });
                          }
                        } else if (selectedRole == null) {
                          // Show error for missing role selection
                          _showErrorToast('Please select a user role');
                        }
                      },
                      type: ButtonType.primary.type,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // Full screen width with small padding
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Increased to 90% for better fit
            minHeight: 500, // Reduced minimum height
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // Initialize companies on first build
              if (companies.isEmpty && !isLoadingCompanies) {
                setModalState(() {
                  isLoadingCompanies = true;
                });
                
                CompanyService.getAllCompanies().then((response) {
                  if (response.success) {
                    setModalState(() {
                      companies = response.data;
                      isLoadingCompanies = false;
                    });
                  } else {
                    setModalState(() {
                      isLoadingCompanies = false;
                    });
                                         _showErrorToast('فشل في تحميل الشركات');
                  }
                }).catchError((error) {
                  setModalState(() {
                    isLoadingCompanies = false;
                  });
                  _showErrorToast('خطأ في تحميل الشركات: $error');
                });
              }
              
              return Flexible(
                child: SingleChildScrollView(
                padding: const EdgeInsets.all(24), // Reduced padding to prevent overflow
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18), // Reduced padding from 20 to 18
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_add,
                              color: Colors.blue.shade600,
                              size: 24, // Reduced icon size
                            ),
                            const SizedBox(width: 12), // Reduced spacing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'معلومات المستخدم',
                                    style: TextStyle(
                                      fontSize: 18, // Reduced font size
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'املأ التفاصيل أدناه لإنشاء حساب مستخدم جديد',
                                    style: TextStyle(
                                      fontSize: 14, // Reduced font size
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced spacing from 24 to 20
                      
                      // Form Fields Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Personal Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                                                 // Section Header
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding from 10 to 8
                                   decoration: BoxDecoration(
                                     color: Colors.grey.shade100,
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Row(
                                     children: [
                                       Icon(
                                         Icons.person,
                                         color: Colors.blue.shade600,
                                         size: 18, // Reduced icon size
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         'المعلومات الشخصية',
                                         style: TextStyle(
                                           fontSize: 15, // Reduced font size
                                           fontWeight: FontWeight.w600,
                                           color: Colors.blue.shade700,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                                const SizedBox(height: 16), // Reduced spacing
                                
                                // Name Field
                                OutBorderTextFormField(
                                  labelText: 'الاسم الكامل *',
                                  hintText: 'أدخل الاسم الكامل',
                                  controller: nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال اسم';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16), // Reduced spacing from 20 to 16
                                
                                // Email Field
                                OutBorderTextFormField(
                                  labelText: 'عنوان البريد الإلكتروني *',
                                  hintText: 'أدخل عنوان البريد الإلكتروني',
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى إدخال بريد إلكتروني';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'يرجى إدخال عنوان بريد إلكتروني صحيح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16), // Reduced spacing from 20 to 16
                                
                                // Role Selection
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'دور المستخدم *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced vertical padding from 4 to 3
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedRole,
                                          hint: Text(
                                            'Select user role',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          items: userRoles.map((role) {
                                            return DropdownMenuItem<String>(
                                              value: role['value'],
                                              child: Text(
                                                role['label']!,
                                                style: GlobalTheme.textStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setModalState(() {
                                              selectedRole = newValue;
                                              
                                              // Reset company if role doesn't require it
                                              if (['system_administrator'].contains(newValue)) {
                                                selectedCompany = null;
                                              }
                                            });
                                            // Trigger form validation
                                            formKey.currentState?.validate();
                                          },
                                        ),
                                      ),
                                    ),
                                    if (selectedRole == null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Please select a user role',
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 20), // Reduced spacing between columns from 24 to 20
                          
                          // Right Column - Organization & Security
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding from 10 to 8
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: Colors.blue.shade600,
                                        size: 18, // Reduced icon size
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Organization & Security',
                                        style: TextStyle(
                                          fontSize: 15, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14), // Reduced spacing from 16 to 14
                                
                                // Company Selection - Only show for roles that require it
                                if (!['system_administrator'].contains(selectedRole))
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Company *',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced vertical padding from 4 to 3
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: isLoadingCompanies
                                            ? const Center(child: CircularProgressIndicator())
                                            : DropdownButtonHideUnderline(
                                                child: DropdownButton<Company>(
                                                  value: selectedCompany,
                                                  hint: Text(
                                                    'Select company',
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  isExpanded: true,
                                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                                  items: companies.map((company) {
                                                    return DropdownMenuItem<Company>(
                                                      value: company,
                                                      child: Text(
                                                        company.name,
                                                        style: GlobalTheme.textStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (Company? newValue) {
                                                    setModalState(() {
                                                      selectedCompany = newValue;
                                                    });
                                                    

                                                  },
                                                ),
                                              ),
                                      ),
                                      if (selectedCompany == null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Please select a company',
                                            style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                

                                

                              ],
                            ),
                          ),
                        ],
                                             ),
                       
                       const SizedBox(height: 20), // Reduced spacing from 24 to 20
                       
                                              // Password Section - Full Width
                       Container(
                         width: double.infinity,
                         padding: const EdgeInsets.all(18), // Reduced padding from 20 to 18
                         decoration: BoxDecoration(
                           color: Colors.grey.shade50,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.grey.shade200),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Section Header
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced padding
                               decoration: BoxDecoration(
                                 color: Colors.grey.shade100,
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Row(
                                 children: [
                                   Icon(
                                     Icons.security,
                                     color: Colors.blue.shade600,
                                     size: 18, // Reduced icon size
                                   ),
                                   const SizedBox(width: 8),
                                   Text(
                                     'Password Configuration',
                                     style: TextStyle(
                                       fontSize: 15, // Reduced font size
                                       fontWeight: FontWeight.w600,
                                       color: Colors.blue.shade700,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(height: 14), // Reduced spacing from 16 to 14
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password Field
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Password',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lock,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Auto-generated',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      OutBorderTextFormField(
                                        labelText: '',
                                        hintText: 'Password will be auto-generated',
                                        controller: passwordController,
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Regenerate Button
                                Container(
                                  height: 44, // Reduced height from 48 to 44
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final newPassword = _generateRandomPassword();
                                      passwordController.text = newPassword;
                                      generatedPassword = newPassword;
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text(
                                      'Regenerate',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade700,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.blue.shade200),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                                                         ),
                             
                             const SizedBox(height: 10), // Reduced spacing from 12 to 10
                             
                             // Password Info and Strength
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password Info
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14), // Reduced padding from 16 to 14
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Password will be automatically generated. Users can change it after their first login.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Password Strength Indicator
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.security,
                                          size: 18,
                                          color: Colors.green.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Password Strength: Strong',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '✓ 12 characters • ✓ Uppercase • ✓ Lowercase • ✓ Numbers • ✓ Symbols',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                                               ),
                       
                       const SizedBox(height: 20), // Reduced spacing from 24 to 20
                       
                                              // Form Footer Info
                       Container(
                         width: double.infinity,
                         padding: const EdgeInsets.all(14), // Reduced padding from 16 to 14
                         decoration: BoxDecoration(
                           color: Colors.grey.shade50,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.grey.shade200),
                         ),
                         child: Row(
                           children: [
                             Icon(
                               Icons.info_outline,
                               color: Colors.grey.shade600,
                               size: 20, // Reduced icon size
                             ),
                             const SizedBox(width: 12), // Reduced spacing
                             Expanded(
                               child: Text(
                                 'All fields marked with * are required. The password will be automatically generated and can be changed by the user after first login.',
                                 style: TextStyle(
                                   fontSize: 13, // Reduced font size
                                   color: Colors.grey.shade700,
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ),
              ));
            },
          ),
        ),
      );
  }

     void _showEditUserForm(BuildContext context, User user, _UserDataProvider provider) {
     final formKey = GlobalKey<FormState>();
     final nameController = TextEditingController(text: user.name);
     final emailController = TextEditingController(text: user.email);

     // These controllers are no longer needed with dropdown implementation
     
                                                                       // Role selection for edit form
        String? selectedRole = user.getFirstRoleName();
        
        // If user has a system-level role, clear company
        if (['system_administrator'].contains(selectedRole)) {
          // These will be set to null when companies are loaded
        }
       
       final List<Map<String, String>> userRoles = [
        {
          'value': 'system_administrator',
          'label': 'System Administrator',
        },
        {
          'value': 'admin',
          'label': 'Administrator',
        },
        {
          'value': 'company_account',
          'label': 'Company Account',
        },
      ];
      
      // Company selection
      Company? selectedCompany;
      List<Company> companies = [];
      bool isLoadingCompanies = false;
      
      // Loading state for form submission
      bool isSubmitting = false;

                                                 ModalDialog.show(
          context: context,
          title: 'Edit User',
          showTitle: true,
          modalType: ModalType.large,
         footer: StatefulBuilder(
           builder: (BuildContext context, StateSetter setFooterState) {
             return Container(
               margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
               child: Row(
                 children: [
                   const Spacer(),
                   SizedBox(
                     width: 120,
                     child: ButtonWidget(
                       btnText: isSubmitting ? 'Updating...' : 'Save',
                       onTap: isSubmitting ? null : () async {
                         // Check if role requires company
                         bool requiresCompany = !['system_administrator'].contains(selectedRole);
                         
                         // Validate form based on role requirements
                         bool isFormValid = formKey.currentState!.validate() && 
                                          selectedRole != null && 
                                          (!requiresCompany || selectedCompany != null);
                         
                         if (isFormValid) {
                           // Set loading state
                           setFooterState(() {
                             isSubmitting = true;
                           });
                           
                           try {
                             // Create updated user with new model structure
                             final updatedUser = User(
                               id: user.id,
                               name: nameController.text.trim(),
                               email: emailController.text.trim(),
                               role: selectedRole ?? user.role, // Keep for backward compatibility
                               roles: [
                                 Role(
                                   name: selectedRole ?? user.role ?? 'company_account',
                                   displayName: _getRoleDisplayName(selectedRole ?? user.role ?? 'company_account'),
                                 ),
                               ],
                               status: user.status ?? 'active',
                               createdAt: user.createdAt,
                               updatedAt: DateTime.now().toIso8601String(),
                               companyId: requiresCompany ? selectedCompany?.id : null,
                               company: requiresCompany ? selectedCompany : null,
                             );
                             
                             // Update user via API
                             final result = await UserService.updateUser(context, updatedUser);
                             if (result is bool && result) {
                               // Close modal first for smooth UX
                               Get.back();
                               // Show success notification
                               _showSuccessToast('User updated successfully');
                               // Update user in local array for instant table update
                               provider.updateUser(updatedUser);
                             } else if (result is String) {
                               try {
                                 // Parse the JSON response to extract m_ar message
                                 final Map<String, dynamic> responseData = json.decode(result as String);
                                 final String? mArMessage = responseData['m_ar'];
                                 
                                 // Close modal first for smooth UX
                                 Get.back();
                                 
                                 // Show success notification with m_ar message
                                 _showSuccessToast(mArMessage ?? 'تم تحديث المستخدم بنجاح');
                                 // Update user in local array for instant table update
                                 provider.updateUser(updatedUser);
                               } catch (e) {
                                 // If parsing fails, show the original result
                                 Get.back();
                                 _showSuccessToast(result.toString());
                                 // Update user in local array for instant table update
                                 provider.updateUser(updatedUser);
                               }
                             }
                           } catch (e) {
                             // Handle any errors
                             _showErrorToast('خطأ في تحديث المستخدم: ${e.toString()}');
                           } finally {
                             // Reset loading state
                             setFooterState(() {
                               isSubmitting = false;
                             });
                           }
                         } else if (selectedRole == null) {
                           // Show error for missing role selection
                           _showErrorToast('Please select a user role');
                         } else if (requiresCompany && selectedCompany == null) {
                           // Show error for missing company selection only if required
                           _showErrorToast('Please select a company');
                         }
                       },
                       type: ButtonType.primary.type,
                     ),
                   ),
                 ],
               ),
             );
           },
         ),
         child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // Full screen width with small padding
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Increased to 90% for better fit
            minHeight: 500, // Minimum height to ensure form fits
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              // Initialize companies on first build
              if (companies.isEmpty && !isLoadingCompanies) {
                setModalState(() {
                  isLoadingCompanies = true;
                });
                
                CompanyService.getAllCompanies().then((response) {
                  if (response.success) {
                    setModalState(() {
                      companies = response.data;
                      isLoadingCompanies = false;
                      
                      // Only pre-select company if the role requires it
                      bool requiresCompany = !['system_administrator'].contains(selectedRole);
                      
                      if (requiresCompany && user.companyId != null) {
                        selectedCompany = companies.firstWhere(
                          (company) => company.id == user.companyId,
                          orElse: () => companies.first,
                        );
                      } else {
                        // For system-level roles, clear company
                        selectedCompany = null;
                      }
                    });
                  } else {
                    setModalState(() {
                      isLoadingCompanies = false;
                    });
                  }
                }).catchError((error) {
                  setModalState(() {
                    isLoadingCompanies = false;
                  });
                  _showErrorToast('خطأ في تحميل الشركات: $error');
                });
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24), // Consistent padding with Add User Form
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18), // Reduced padding from 20 to 18
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.blue.shade600,
                              size: 24, // Reduced icon size
                            ),
                            const SizedBox(width: 12), // Reduced spacing
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit User Information',
                                    style: TextStyle(
                                      fontSize: 18, // Reduced font size
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Update the user details below',
                                    style: TextStyle(
                                      fontSize: 14, // Reduced font size
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced spacing from 24 to 20
                      
                      // Two-column layout for form fields
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Personal Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding from 10 to 8
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.blue.shade600,
                                        size: 18, // Reduced icon size
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Personal Information',
                                        style: TextStyle(
                                          fontSize: 15, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16), // Reduced spacing
                                
                                // Name Field
                                OutBorderTextFormField(
                                  labelText: 'Full Name',
                                  hintText: 'Enter full name',
                                  controller: nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Email Field
                                OutBorderTextFormField(
                                  labelText: 'Email Address',
                                  hintText: 'Enter email address',
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Role Selection Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Role *',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced vertical padding from 4 to 3
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedRole,
                                          hint: Text(
                                            'Select user role',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 14,
                                            ),
                                          ),
                                          isExpanded: true,
                                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          items: userRoles.map((role) {
                                            return DropdownMenuItem<String>(
                                              value: role['value'],
                                              child: Text(
                                                role['label']!,
                                                style: GlobalTheme.textStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setModalState(() {
                                              selectedRole = newValue;
                                              
                                              // Reset company if role doesn't require it
                                              if (['system_administrator'].contains(newValue)) {
                                                selectedCompany = null;
                                              }
                                            });
                                            // Trigger form validation
                                            formKey.currentState?.validate();
                                          },
                                        ),
                                      ),
                                    ),
                                    if (selectedRole == null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Please select a user role',
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 20), // Reduced spacing between columns from 24 to 20
                          
                          // Right Column - Organization & Security
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding from 10 to 8
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.business,
                                        color: Colors.blue.shade600,
                                        size: 18, // Reduced icon size
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Organization & Security',
                                        style: TextStyle(
                                          fontSize: 15, // Reduced font size
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14), // Reduced spacing from 16 to 14
                                
                                // Company Selection - Only show for roles that require it
                                if (!['system_administrator'].contains(selectedRole))
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Company *',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced vertical padding from 4 to 3
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: isLoadingCompanies
                                            ? const Center(child: CircularProgressIndicator())
                                            : DropdownButtonHideUnderline(
                                                child: DropdownButton<Company>(
                                                  value: selectedCompany,
                                                  hint: Text(
                                                    'Select company',
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  isExpanded: true,
                                                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                                  items: companies.map((company) {
                                                    return DropdownMenuItem<Company>(
                                                      value: company,
                                                      child: Text(
                                                        company.name,
                                                        style: GlobalTheme.textStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (Company? newValue) {
                                                    setModalState(() {
                                                      selectedCompany = newValue;
                                                    });
                                                  },
                                                ),
                                              ),
                                      ),
                                      if (selectedCompany == null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Please select a company',
                                            style: TextStyle(
                                              color: Colors.red[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                

                                

                                const SizedBox(height: 16), // Reduced spacing from 20 to 16
                                

                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20), // Reduced spacing from 24 to 20
                      
                      // Password Section - Full Width
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18), // Reduced padding from 20 to 18
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced padding
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Colors.blue.shade600,
                                    size: 18, // Reduced icon size
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Password Management',
                                    style: TextStyle(
                                      fontSize: 15, // Reduced font size
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14), // Reduced spacing from 16 to 14
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password Field
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Password',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lock,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Auto-generated',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      OutBorderTextFormField(
                                        labelText: '',
                                        hintText: 'Password will be auto-generated',
                                        controller: TextEditingController(text: '••••••••••••'),
                                        obscureText: true,
                                        enabled: false,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Regenerate Button
                                Container(
                                  height: 44, // Reduced height from 48 to 44
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Generate new password for edit form
                                      final newPassword = _generateRandomPassword();
                                      // You can show a dialog with the new password here
                                      _showInfoToast('New password generated: $newPassword');
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text(
                                      'Generate New',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade700,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: Colors.blue.shade200),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 10), // Reduced spacing from 12 to 10
                            
                            // Password Info and Strength
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Password Info
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14), // Reduced padding from 16 to 14
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 18,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Password can be regenerated. Users can change it after their next login.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Password Strength Indicator
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.security,
                                          size: 18,
                                          color: Colors.green.shade600,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Password Strength: Strong',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '✓ 12 characters • ✓ Uppercase • ✓ Lowercase • ✓ Numbers • ✓ Symbols',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Reduced spacing from 24 to 20
                      
                      // Form Footer Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14), // Reduced padding from 16 to 14
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey.shade600,
                              size: 20, // Reduced icon size
                            ),
                            const SizedBox(width: 12), // Reduced spacing
                            Expanded(
                              child: Text(
                                'All fields marked with * are required. The password can be regenerated and changed by the user after their next login.',
                                style: TextStyle(
                                  fontSize: 13, // Reduced font size
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
                                                       
    );
  }

     void _showPasswordInfoDialog(BuildContext context, String username, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'New User Created',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A new user account has been created for $username.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username: $username',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Password: $password',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: password));
                              _showInfoToast('Password copied to clipboard');
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy Password',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please inform the user to change their password after their first login.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      },
    );
  }

  /// Shows a success toast notification for user operations in Arabic
  void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for user operations in Arabic
  void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for user operations in Arabic
  void _showInfoToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  /// Get tooltip text for status toggle button
  String _getStatusToggleTooltip(User user) {
    if (!AuthService.isSystemAdministrator()) {
      return 'يتطلب دور مدير النظام';
    }
    
    if (user.isSystemAdministrator) {
      return 'لا يمكن تغيير حالة مدير النظام';
    }
    
    if (user.isActive) {
      return 'إلغاء تفعيل المستخدم';
    } else {
      return 'تفعيل المستخدم';
    }
  }

  /// Get background color for status toggle button
  Color _getStatusToggleBackgroundColor(User user) {
    if (!AuthService.isSystemAdministrator() || user.isSystemAdministrator) {
      return Colors.grey.shade100;
    }
    
    if (user.isActive) {
      return Colors.red.shade50;
    } else {
      return Colors.green.shade50;
    }
  }

  /// Get foreground color for status toggle button
  Color _getStatusToggleForegroundColor(User user) {
    if (!AuthService.isSystemAdministrator() || user.isSystemAdministrator) {
      return Colors.grey.shade400;
    }
    
    if (user.isActive) {
      return Colors.red.shade700;
    } else {
      return Colors.green.shade700;
    }
  }

  void _showViewUserDialog(BuildContext context, User user) {
    ModalDialog.show(
      context: context,
      title: 'User Details',
      showTitle: true,
      modalType: ModalType.large,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Information Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'User Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDetailRow('Name', user.name),
                        _buildDetailRow('Email', user.email),
                        _buildDetailRow('Role', _getRoleDisplayName(user.role ?? '')),
                        if (user.company != null)
                          _buildDetailRow('Company', user.company!.name),
                        _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
                        if (user.emailVerifiedAt != null)
                          _buildDetailRow('Email Verified At', user.emailVerifiedAt!),
                        if (user.createdAt != null)
                          _buildDetailRow('Created At', user.createdAt!),
                        if (user.updatedAt != null)
                          _buildDetailRow('Updated At', user.updatedAt!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserDataProvider extends GetxController {
  final _users = <User>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 0.obs;
  final _rowsPerPage = 10.obs;

  List<User> get users => _users;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get rowsPerPage => _rowsPerPage.value;
  int get totalItems => _users.length;
  int get totalPages {
    final total = totalItems;
    if (total == 0) return 1;
    final pages = (total / rowsPerPage).ceil();
    return pages < 1 ? 1 : pages;
  }
  List<User> get pagedUsers {
    if (totalItems == 0) return const <User>[];
    final start = currentPage * rowsPerPage;
    var end = start + rowsPerPage;
    if (start >= totalItems) {
      _currentPage.value = totalPages - 1;
      return pagedUsers;
    }
    if (end > totalItems) end = totalItems;
    return _users.sublist(start, end);
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<List<User>> loadData() async {
    _isLoading.value = true;
    try {
      final users = await UserService.getUsers(Get.context!);
      _users.value = users;
      _currentPage.value = 0;
      update(); // Notify GetX that data has changed
      return users;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Add a new user to the local array
  void addUser(User newUser) {
    _users.add(newUser);
    update(); // Notify GetX that data has changed
  }

  // Update an existing user in the local array
  void updateUser(User updatedUser) {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      update(); // Notify GetX that data has changed
    }
  }

  void setRowsPerPage(int value) {
    _rowsPerPage.value = value;
    _currentPage.value = 0;
    update();
  }

  void nextPage() {
    if ((currentPage + 1) * rowsPerPage < totalItems) {
      _currentPage.value++;
      update();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      _currentPage.value--;
      update();
    }
  }

  // Toggle user status (activate/deactivate)
  void toggleUserStatus(BuildContext context, User user) {
    // Check if current user has permission to perform this action
    if (!AuthService.isSystemAdministrator()) {
      _showErrorToast('ليس لديك صلاحية لتنفيذ هذا الإجراء. يتطلب دور مدير النظام.');
      return;
    }

    // Check if the target user is a system administrator
    if (user.isSystemAdministrator) {
      _showErrorToast('لا يمكن تغيير حالة مدير النظام');
      return;
    }

    // Validate if user status can be changed
    final statusChangeValidation = UserService.validateStatusChange(user);
    if (statusChangeValidation != null) {
      _showErrorToast(statusChangeValidation);
      return;
    }

    // Check specific activation/deactivation restrictions
    final isCurrentlyActive = user.isActive;
    String? restrictionMessage;
    
    if (isCurrentlyActive) {
      restrictionMessage = UserService.canDeactivateUser(user);
    } else {
      restrictionMessage = UserService.canActivateUser(user);
    }
    
    if (restrictionMessage != null) {
      _showErrorToast(restrictionMessage);
      return;
    }

    final action = isCurrentlyActive ? 'deactivate' : 'activate';
    final actionText = isCurrentlyActive ? 'إلغاء التفعيل' : 'التفعيل';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'تأكيد $actionText',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد $actionText المستخدم "${user.name}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performStatusToggle(context, user, action);
              },
              style: TextButton.styleFrom(
                backgroundColor: isCurrentlyActive ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  // Perform the actual status toggle
  Future<void> _performStatusToggle(BuildContext context, User user, String action) async {
    try {
      bool success = false;
      
      if (action == 'activate') {
        success = await UserService.activateUser(context, user.id!);
      } else {
        success = await UserService.deactivateUser(context, user.id!);
      }
      
      if (success) {
        // Update the user's status locally
        final updatedUser = User(
          id: user.id,
          name: user.name,
          email: user.email,
          password: user.password,
          role: user.role,
          roles: user.roles,
          emailVerifiedAt: user.emailVerifiedAt,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          companyId: user.companyId,
          status: action == 'activate' ? 'active' : 'inactive',
          company: user.company,
        );
        
        updateUser(updatedUser);
        
        // Show success message
        if (context.mounted) {
          final actionText = action == 'activate' ? 'تم تفعيل' : 'تم إلغاء تفعيل';
          _showSuccessToast('$actionText المستخدم "${user.name}" بنجاح');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorToast('حدث خطأ أثناء تغيير حالة المستخدم: $e');
      }
    }
  }

  /// Shows a success toast notification for user operations in Arabic
  void _showSuccessToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for user operations in Arabic
  void _showErrorToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for user operations in Arabic
  void _showInfoToast(String message) {
    toastification.show(
      context: Get.context!,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }
}

// Helper method to format dates
String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}

 // Helper method to generate a random password
 String _generateRandomPassword() {
   // Ensure at least one character from each category
   const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   const lowercase = 'abcdefghijklmnopqrstuvwxyz';
   const numbers = '0123456789';
   const symbols = '!@#\$%^&*()_+';
   
   final random = Random();
   
   // Start with one character from each category
   String password = '';
   password += uppercase[random.nextInt(uppercase.length)];
   password += lowercase[random.nextInt(lowercase.length)];
   password += numbers[random.nextInt(numbers.length)];
   password += symbols[random.nextInt(symbols.length)];
   
   // Fill the rest with random characters from all categories
   const allChars = uppercase + lowercase + numbers + symbols;
   for (int i = 0; i < 8; i++) {
     password += allChars[random.nextInt(allChars.length)];
   }
   
   // Shuffle the password to make it more random
   final passwordList = password.split('');
   passwordList.shuffle(random);
   return passwordList.join();
  }


// Helper method to get role display name
String _getRoleDisplayName(String roleValue) {
   if (roleValue.isEmpty || roleValue == 'null' || roleValue == 'undefined') {
     return 'N/A';
   }
   
   switch (roleValue.toLowerCase()) {
     case 'system_administrator':
       return 'System Administrator';
     case 'admin':
     case 'administrator':
       return 'Administrator';
     case 'company_account':
       return 'Company Account';
     default:
       // For any other role values, return 'N/A' since only three roles are allowed
       return 'N/A';
   }
 }
