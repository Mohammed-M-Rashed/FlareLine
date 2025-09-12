import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/loading/loading.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/models/nomination_model.dart';
import 'package:flareline/core/services/nomination_service.dart';
import 'package:flareline/core/models/company_model.dart' as company_model;
import 'package:flareline/core/services/company_service.dart';
import 'package:flareline/core/models/training_plan_model.dart' as training_plan_model;
import 'package:flareline/core/services/training_plan_service.dart';
import 'package:flareline/core/models/training_plan_by_company_model.dart';
import 'package:flareline/core/services/training_plan_by_company_service.dart';
import 'package:flareline/core/models/course_model.dart' as course_model;
import 'package:flareline/core/services/course_service.dart';
import 'package:flareline/core/models/course_assignment_model.dart';
import 'package:flareline/core/services/course_assignment_service.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';

// Model class for nomination entries
class NominationEntry {
  final String id;
  final String employeeName;
  final String jobNumber;
  final String phoneNumber;
  final String email;
  final String englishName;
  final String specialization;
  final String department;
  final int yearsOfExperience;
  final String companyName;
  final String trainingPlanName;
  final String courseName;

  NominationEntry({
    required this.id,
    required this.employeeName,
    required this.jobNumber,
    required this.phoneNumber,
    required this.email,
    required this.englishName,
    required this.specialization,
    required this.department,
    required this.yearsOfExperience,
    required this.companyName,
    required this.trainingPlanName,
    required this.courseName,
  });
}

class NominationManagementPage extends LayoutWidget {
  const NominationManagementPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Nomination Management';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        NominationManagementWidget(),
      ],
    );
  }
}

class NominationManagementWidget extends StatefulWidget {
  const NominationManagementWidget({super.key});

  @override
  State<NominationManagementWidget> createState() => _NominationManagementWidgetState();
}

class _NominationManagementWidgetState extends State<NominationManagementWidget> {
  // State for dropdowns
  int? _selectedCompanyId;
  int? _selectedTrainingPlanId;
  int? _selectedCourseId;
  int? _selectedPlanCourseAssignmentId; // New field for API integration
  
  // Data lists
  List<TrainingPlanByCompany> _trainingPlans = [];
  List<CourseAssignment> _courses = [];
  List<NominationEntry> _nominations = [];
  
  // Loading states
  bool _isLoadingCompanies = false;
  bool _isLoadingTrainingPlans = false;
  bool _isLoadingCourses = false;
  
  // Filtering and pagination
  String? _selectedFilterCompany;
  int _currentPage = 0;
  int _itemsPerPage = 10;
  
  // Form controllers for adding nominations
  final _formKey = GlobalKey<FormState>();
  final _employeeNameController = TextEditingController();
  final _jobNumberController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _englishNameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();

  // Sample employee data for auto-fill
  final List<Map<String, dynamic>> _sampleEmployees = [
    {
      'jobNumber': 'EMP001',
      'employeeName': 'أحمد محمد العلي',
      'englishName': 'Ahmed Mohammed Al-Ali',
      'phoneNumber': '+966501234567',
      'email': 'ahmed.ali@company.com',
      'specialization': 'تطوير البرمجيات',
      'department': 'قسم تقنية المعلومات',
      'yearsOfExperience': 5,
    },
    {
      'jobNumber': 'EMP002',
      'employeeName': 'فاطمة عبدالله السعيد',
      'englishName': 'Fatima Abdullah Al-Saeed',
      'phoneNumber': '+966502345678',
      'email': 'fatima.saeed@company.com',
      'specialization': 'إدارة الموارد البشرية',
      'department': 'قسم الموارد البشرية',
      'yearsOfExperience': 3,
    },
    {
      'jobNumber': 'EMP003',
      'employeeName': 'خالد سعد الدوسري',
      'englishName': 'Khalid Saad Al-Dosari',
      'phoneNumber': '+966503456789',
      'email': 'khalid.dosari@company.com',
      'specialization': 'المحاسبة والمالية',
      'department': 'قسم المالية',
      'yearsOfExperience': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    // Don't load training plans on init - wait for company selection
    // Don't load courses on init - wait for company and training plan selection
    
    // Add listener to job number controller for auto-fill
    _jobNumberController.addListener(_onJobNumberChanged);
  }

  @override
  void dispose() {
    _jobNumberController.removeListener(_onJobNumberChanged);
    _employeeNameController.dispose();
    _jobNumberController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _englishNameController.dispose();
    _specializationController.dispose();
    _departmentController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  // Auto-fill method when job number changes
  void _onJobNumberChanged() {
    final jobNumber = _jobNumberController.text.trim();
    if (jobNumber.isNotEmpty) {
      final employee = _sampleEmployees.firstWhere(
        (emp) => emp['jobNumber'] == jobNumber,
        orElse: () => <String, dynamic>{},
      );
      
      if (employee.isNotEmpty) {
        _employeeNameController.text = employee['employeeName'] ?? '';
        _englishNameController.text = employee['englishName'] ?? '';
        _phoneNumberController.text = employee['phoneNumber'] ?? '';
        _emailController.text = employee['email'] ?? '';
        _specializationController.text = employee['specialization'] ?? '';
        _departmentController.text = employee['department'] ?? '';
        _yearsOfExperienceController.text = (employee['yearsOfExperience'] ?? 0).toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GetBuilder<NominationDataProvider>(
          init: NominationDataProvider(),
          builder: (provider) => _buildWidget(context, provider),
        ),
      ),
    );
  }

  Widget _buildWidget(BuildContext context, NominationDataProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeaderSection(),
              const SizedBox(height: 24),
              
              // Nomination Form Section
              _buildNominationFormSection(),
              const SizedBox(height: 24),
              
              // Nominations Table
              _buildNominationsTable(),
              const SizedBox(height: 16),
              
              // Save Button Section
              _buildSaveButton(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nomination Management',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage employee nominations for training courses',
                  style: TextStyle(
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
                  btnText: Get.find<NominationDataProvider>().isLoading ? 'Loading...' : 'Refresh',
                  type: 'secondary',
                  onTap: Get.find<NominationDataProvider>().isLoading ? null : () async {
                    try {
                      await Get.find<NominationDataProvider>().refreshData();
                      _showSuccessToast('Nominations data refreshed successfully');
                    } catch (e) {
                      _showErrorToast('Error refreshing nominations: ${e.toString()}');
                    }
                  },
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNominationFormSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Nomination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Helper text
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Enter job number (EMP001, EMP002, or EMP003) to auto-fill employee data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Dropdowns section
            _buildDropdownsSection(),
            const SizedBox(height: 16),
            
            // Employee information form fields
            _buildEmployeeFormFields(),
            const SizedBox(height: 16),
            
            // Add button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: ButtonWidget(
                    btnText: 'Add Nomination',
                    type: 'primary',
                    onTap: _addNomination,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignment Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Mobile layout - single column
                return Column(
                  children: [
                    _buildCompanyDropdown(),
                    const SizedBox(height: 12),
                    _buildTrainingPlanDropdown(),
                    const SizedBox(height: 12),
                    _buildCourseDropdown(),
                  ],
                );
              } else {
                // Desktop layout - three columns
                return Row(
                  children: [
                    Expanded(child: _buildCompanyDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTrainingPlanDropdown()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCourseDropdown()),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeFormFields() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employee Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          // First row
          Row(
            children: [
              Expanded(
                child: OutBorderTextFormField(
                  controller: _employeeNameController,
                  labelText: 'Employee Name *',
                  hintText: 'Enter employee name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Employee name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutBorderTextFormField(
                  controller: _jobNumberController,
                  labelText: 'Job Number *',
                  hintText: 'Enter job number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Job number is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second row
          Row(
            children: [
              Expanded(
                child: OutBorderTextFormField(
                  controller: _phoneNumberController,
                  labelText: 'Phone Number *',
                  hintText: 'Enter phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutBorderTextFormField(
                  controller: _emailController,
                  labelText: 'Email *',
                  hintText: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Third row
          Row(
            children: [
              Expanded(
                child: OutBorderTextFormField(
                  controller: _englishNameController,
                  labelText: 'English Name *',
                  hintText: 'Enter English name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'English name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutBorderTextFormField(
                  controller: _specializationController,
                  labelText: 'Specialization *',
                  hintText: 'Enter specialization',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Specialization is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fourth row
          Row(
            children: [
              Expanded(
                child: OutBorderTextFormField(
                  controller: _departmentController,
                  labelText: 'Department *',
                  hintText: 'Enter department',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Department is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutBorderTextFormField(
                  controller: _yearsOfExperienceController,
                  labelText: 'Years of Experience *',
                  hintText: 'Enter years of experience',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Years of experience is required';
                    }
                    final years = int.tryParse(value);
                    if (years == null || years < 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDropdown() {
    return GetBuilder<NominationDataProvider>(
      builder: (provider) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<int>(
                        value: _selectedCompanyId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: _isLoadingCompanies 
                              ? 'Loading companies...' 
                              : Get.find<NominationDataProvider>().companies.isEmpty 
                                  ? 'No companies available' 
                                  : 'Select company',
                          hintStyle: TextStyle(fontSize: isMobile ? 14 : 13),
                          prefixIcon: _isLoadingCompanies 
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                                  ),
                                )
                              : Icon(Icons.business, color: Colors.blue.shade600, size: 18),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 12, 
                            vertical: isMobile ? 12 : 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                          ),
                          filled: true,
                          fillColor: _isLoadingCompanies ? Colors.grey.shade50 : Colors.white,
                        ),
                        items: Get.find<NominationDataProvider>().companies.map<DropdownMenuItem<int>>((company) {
                          return DropdownMenuItem<int>(
                            value: company.id,
                            child: Text(
                              company.name,
                              style: TextStyle(fontSize: isMobile ? 14 : 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoadingCompanies || Get.find<NominationDataProvider>().companies.isEmpty ? null : (value) {
                          setState(() {
                            _selectedCompanyId = value;
                            _selectedTrainingPlanId = null;
                            _selectedCourseId = null;
                            _selectedPlanCourseAssignmentId = null;
                            _trainingPlans.clear();
                            _courses.clear();
                          });
                          // Load training plans for the selected company
                          if (value != null) {
                            _loadTrainingPlansByCompany(value);
                          }
                        },
                        style: TextStyle(fontSize: isMobile ? 14 : 13),
                        dropdownColor: Colors.white,
                        menuMaxHeight: isMobile ? 300 : 250,
                      )),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: _isLoadingCompanies 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                              ),
                            )
                          : const Icon(Icons.refresh, size: 16),
                      onPressed: _isLoadingCompanies ? null : () {
                        _loadCompanies();
                      },
                      tooltip: _isLoadingCompanies ? 'Loading...' : 'Refresh',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue.shade700,
                        minimumSize: Size(isMobile ? 40 : 32, isMobile ? 40 : 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTrainingPlanDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training Plan',
              style: TextStyle(
                fontSize: isMobile ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                value: _selectedTrainingPlanId,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _isLoadingTrainingPlans 
                      ? 'Loading training plans...' 
                      : _selectedCompanyId == null
                          ? 'Select company first'
                          : _trainingPlans.isEmpty
                              ? 'No training plans available'
                              : 'Select training plan',
                  hintStyle: TextStyle(fontSize: isMobile ? 14 : 13),
                  prefixIcon: _isLoadingTrainingPlans 
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                          ),
                        )
                      : Icon(Icons.school, color: Colors.blue.shade600, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 12, 
                    vertical: isMobile ? 12 : 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: _isLoadingTrainingPlans 
                      ? Colors.grey.shade50 
                      : (_selectedCompanyId == null)
                          ? Colors.grey.shade100
                          : Colors.white,
                ),
                items: _trainingPlans.map<DropdownMenuItem<int>>((plan) {
                  return DropdownMenuItem<int>(
                    value: plan.id,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 4,
                        horizontal: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 13, 
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: isMobile ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(plan.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _getStatusColor(plan.status).withOpacity(0.3)),
                                ),
                                child: Text(
                                  plan.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 10,
                                    fontWeight: FontWeight.w500,
                                    color: _getStatusColor(plan.status),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${plan.year}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 10, 
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (isMobile && plan.planCourseAssignments.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.book,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${plan.planCourseAssignments.length} course${plan.planCourseAssignments.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (_isLoadingTrainingPlans || _selectedCompanyId == null) ? null : (value) {
                  setState(() {
                    _selectedTrainingPlanId = value;
                    _selectedCourseId = null;
                    _selectedPlanCourseAssignmentId = null;
                    _courses.clear();
                  });
                  if (value != null && _selectedCompanyId != null) {
                    _loadCoursesByTrainingPlan(value);
                  }
                },
                style: TextStyle(fontSize: isMobile ? 14 : 13),
                dropdownColor: Colors.white,
                menuMaxHeight: isMobile ? 300 : 250,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: (_isLoadingTrainingPlans || _selectedCompanyId == null) 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildCourseDropdown() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course',
              style: TextStyle(
                fontSize: isMobile ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                value: _selectedCourseId,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _isLoadingCourses 
                      ? 'Loading courses...' 
                      : _selectedCompanyId == null
                          ? 'Select company first'
                          : _selectedTrainingPlanId == null 
                              ? 'Select training plan first'
                              : _courses.isEmpty
                                  ? 'No courses available'
                                  : 'Select course',
                  hintStyle: TextStyle(fontSize: isMobile ? 14 : 13),
                  prefixIcon: _isLoadingCourses 
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                          ),
                        )
                      : Icon(Icons.book, color: Colors.blue.shade600, size: 18),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 12, 
                    vertical: isMobile ? 12 : 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  filled: true,
                  fillColor: _isLoadingCourses 
                      ? Colors.grey.shade50 
                      : (_selectedCompanyId == null || _selectedTrainingPlanId == null)
                          ? Colors.grey.shade100
                          : Colors.white,
                ),
                items: _courses.map<DropdownMenuItem<int>>((course) {
                  return DropdownMenuItem<int>(
                    value: course.id,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 8 : 4,
                        horizontal: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            course.title,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 13, 
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: isMobile ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Text(
                                  course.code,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  course.specialization.name,
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 10, 
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (isMobile && course.assignments.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${course.assignments.length} assignment${course.assignments.length > 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (_isLoadingCourses || _selectedCompanyId == null || _selectedTrainingPlanId == null) ? null : (value) {
                  setState(() {
                    _selectedCourseId = value;
                    // Find the plan course assignment ID for the selected course
                    if (value != null) {
                      final selectedCourse = _courses.firstWhere((course) => course.id == value);
                      if (selectedCourse.assignments.isNotEmpty) {
                        _selectedPlanCourseAssignmentId = selectedCourse.assignments.first.id;
                        print('🎯 Selected plan course assignment ID: $_selectedPlanCourseAssignmentId');
                      } else {
                        _selectedPlanCourseAssignmentId = null;
                        print('⚠️ No assignments found for selected course');
                      }
                    } else {
                      _selectedPlanCourseAssignmentId = null;
                    }
                  });
                },
                style: TextStyle(fontSize: isMobile ? 14 : 13),
                dropdownColor: Colors.white,
                menuMaxHeight: isMobile ? 300 : 250,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: (_isLoadingCourses || _selectedCompanyId == null || _selectedTrainingPlanId == null) 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNominationsTable() {
    print('Building table with ${_nominations.length} nominations');
    print('Filtered nominations: ${_filteredNominations.length}');
    print('Paginated nominations: ${_paginatedNominations.length}');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Nominations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Count summary
          CountSummaryWidgetEn(
            count: _nominations.length,
            itemName: 'nomination',
            itemNamePlural: 'nominations',
            icon: Icons.person_add,
            color: Colors.purple,
            filteredCount: _filteredNominations.length,
            showFilteredCount: _selectedFilterCompany != null && _selectedFilterCompany != 'All',
          ),
          const SizedBox(height: 16),
          
          _buildFilterSection(),
          const SizedBox(height: 16),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Filter by Company:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilterCompany,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              hint: const Text('Select Company'),
              items: _availableCompanyNames.map((String company) {
                return DropdownMenuItem<String>(
                  value: company,
                  child: Text(
                    company,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilterCompany = newValue;
                  _currentPage = 0;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedFilterCompany != null && _selectedFilterCompany != 'All')
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                setState(() {
                  _selectedFilterCompany = null;
                });
              },
              tooltip: 'Clear Filter',
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (_nominations.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Nominations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add nominations using the form above to see them here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // For mobile screens, use card layout
        if (constraints.maxWidth < 768) {
          return _buildMobileTable();
        }
        // For desktop screens, use data table
        return _buildDesktopTable();
      },
    );
  }

  Widget _buildMobileTable() {
    return Column(
      children: [
        // Nominations cards
        ..._paginatedNominations.map((nomination) => _buildMobileCard(nomination)).toList(),
        
        // Pagination controls for mobile
        if (_filteredNominations.length > _itemsPerPage) ...[
          const SizedBox(height: 16),
          _buildMobilePagination(),
        ],
      ],
    );
  }

  Widget _buildMobilePagination() {
    final totalPages = (_filteredNominations.length / _itemsPerPage).ceil();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Page info
          Text(
            'Page ${_currentPage + 1} of $totalPages',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // Pagination buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous button
              ElevatedButton.icon(
                onPressed: _currentPage > 0 ? () {
                  setState(() {
                    _currentPage--;
                  });
                } : null,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                ),
              ),
              
              // Next button
              ElevatedButton.icon(
                onPressed: _currentPage < totalPages - 1 ? () {
                  setState(() {
                    _currentPage++;
                  });
                } : null,
                icon: const Icon(Icons.chevron_right, size: 18),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(NominationEntry nomination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with employee name and job number
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomination.employeeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nomination.jobNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {
                  _deleteNomination(nomination);
                },
                tooltip: 'Delete Nomination',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Contact information
          _buildMobileInfoRow(Icons.phone, nomination.phoneNumber),
          const SizedBox(height: 8),
          _buildMobileInfoRow(Icons.email, nomination.email),
          const SizedBox(height: 8),
          _buildMobileInfoRow(Icons.business, nomination.companyName),
          const SizedBox(height: 8),
          _buildMobileInfoRow(Icons.school, nomination.courseName),
          const SizedBox(height: 8),
          _buildMobileInfoRow(Icons.work, '${nomination.yearsOfExperience} years experience'),
        ],
      ),
    );
  }

  Widget _buildMobileInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable() {
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
                'Employee',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Contact',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Company',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Course',
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Experience',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Actions',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            numeric: false,
          ),
        ],
        rows: _paginatedNominations.map((nomination) => DataRow(
          onSelectChanged: (selected) {},
          cells: [
            DataCell(_buildEmployeeInfoCell(nomination)),
            DataCell(_buildContactInfoCell(nomination)),
            DataCell(_buildCompanyCell(nomination)),
            DataCell(_buildCourseCell(nomination)),
            DataCell(_buildExperienceCell(nomination)),
            DataCell(_buildActionsCell(nomination)),
          ],
        )).toList(),
      ),
    );
  }

  // Table cell builders for desktop view
  Widget _buildEmployeeInfoCell(NominationEntry nomination) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nomination.employeeName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            nomination.jobNumber,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCell(NominationEntry nomination) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nomination.phoneNumber,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            nomination.email,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCell(NominationEntry nomination) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 80,
        maxWidth: 100,
      ),
      child: Text(
        '${nomination.yearsOfExperience} years',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCompanyCell(NominationEntry nomination) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        nomination.companyName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCourseCell(NominationEntry nomination) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        maxWidth: 150,
      ),
      child: Text(
        nomination.courseName,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionsCell(NominationEntry nomination) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Only delete button - edit button removed
        IconButton(
          icon: const Icon(Icons.delete, size: 18),
          onPressed: () {
            _deleteNomination(nomination);
          },
          tooltip: 'Delete Nomination',
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: ButtonWidget(
        btnText: 'Save Nominations',
        type: 'primary',
        onTap: _nominations.isNotEmpty ? _saveNominations : null,
      ),
    );
  }

  // Get filtered nominations
  List<NominationEntry> get _filteredNominations {
    if (_selectedFilterCompany == null || _selectedFilterCompany == 'All') {
      return _nominations;
    }
    return _nominations.where((nomination) {
      return nomination.companyName == _selectedFilterCompany;
    }).toList();
  }

  // Get unique company names from nominations
  List<String> get _availableCompanyNames {
    final companyNames = _nominations.map((nomination) => nomination.companyName).toSet().toList();
    companyNames.sort();
    return ['All', ...companyNames];
  }

  // Get paginated nominations
  List<NominationEntry> get _paginatedNominations {
    final filteredNominations = _filteredNominations;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredNominations.length);
    return filteredNominations.sublist(startIndex, endIndex);
  }

  // Load methods
  Future<void> _loadCompanies() async {
    print('🔄 Loading companies...');
    setState(() {
      _isLoadingCompanies = true;
    });
    
    try {
      final response = await CompanyService.getAllCompanies();
      print('📡 Company API Response: success=${response.success}, dataCount=${response.data.length}');
      
      if (response.success) {
        final provider = Get.find<NominationDataProvider>();
        provider.setCompanies(response.data);
        setState(() {
          _isLoadingCompanies = false;
        });
        print('✅ Companies loaded successfully: ${response.data.length} companies');
      } else {
        setState(() {
          _isLoadingCompanies = false;
        });
        print('❌ Company API failed: ${response.messageEn}');
        _showErrorToast('Failed to load companies: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCompanies = false;
      });
      print('💥 Company loading error: $e');
      _showErrorToast('Error loading companies: ${e.toString()}');
    }
  }

  Future<void> _loadTrainingPlansByCompany(int companyId) async {
    print('🔄 Loading training plans for company ID: $companyId');
    setState(() {
      _isLoadingTrainingPlans = true;
    });

    try {
      final response = await TrainingPlanByCompanyService.getTrainingPlansByCompany(
        companyId: companyId,
      );
      print('📡 Training Plan API Response: success=${response.success}, dataCount=${response.data.length}');

      if (response.success) {
        setState(() {
          _trainingPlans = response.data;
          _isLoadingTrainingPlans = false;
        });
        print('✅ Training plans loaded successfully: ${response.data.length} plans for company $companyId');
      } else {
        setState(() {
          _isLoadingTrainingPlans = false;
        });
        print('❌ Training Plan API failed: ${response.messageEn}');
        _showErrorToast('Failed to load training plans: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingTrainingPlans = false;
      });
      print('💥 Training plan loading error: $e');
      _showErrorToast('Error loading training plans: ${e.toString()}');
    }
  }

  Future<void> _loadCoursesByTrainingPlan(int trainingPlanId) async {
    if (_selectedCompanyId == null) {
      print('❌ Cannot load courses: No company selected');
      _showErrorToast('Please select a company first');
      return;
    }

    print('🔄 Loading courses for training plan ID: $trainingPlanId, company ID: $_selectedCompanyId');
    setState(() {
      _isLoadingCourses = true;
    });

    try {
      final response = await CourseAssignmentService.getCoursesByPlanAndCompany(
        trainingPlanId: trainingPlanId,
        companyId: _selectedCompanyId!,
      );
      print('📡 Course API Response: success=${response.success}, dataCount=${response.data.length}');

      if (response.success) {
        setState(() {
          _courses = response.data;
          _isLoadingCourses = false;
        });
        print('✅ Courses loaded successfully: ${response.data.length} courses for plan $trainingPlanId and company $_selectedCompanyId');
      } else {
        setState(() {
          _isLoadingCourses = false;
        });
        print('❌ Course API failed: ${response.messageEn}');
        _showErrorToast('Failed to load courses: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      print('💥 Course loading error: $e');
      _showErrorToast('Error loading courses: ${e.toString()}');
    }
  }

  void _addNomination() {
    print('🔄 Attempting to add nomination...');
    
    if (_formKey.currentState!.validate()) {
      if (_selectedCompanyId == null) {
        print('❌ Validation failed: No company selected');
        _showErrorToast('Please select a company first');
        return;
      }
      if (_selectedTrainingPlanId == null) {
        print('❌ Validation failed: No training plan selected');
        _showErrorToast('Please select a training plan first');
        return;
      }
      if (_selectedCourseId == null) {
        print('❌ Validation failed: No course selected');
        _showErrorToast('Please select a course first');
        return;
      }
      if (_selectedPlanCourseAssignmentId == null) {
        print('❌ Validation failed: No plan course assignment ID found');
        _showErrorToast('No course assignment found. Please select a different course.');
        return;
      }
      
      // Check if lists are populated
      if (_isLoadingCompanies) {
        print('❌ Validation failed: Companies still loading');
        _showErrorToast('Companies are still loading. Please wait and try again.');
        return;
      }
      if (Get.find<NominationDataProvider>().companies.isEmpty) {
        print('❌ Validation failed: No companies available');
        _showErrorToast('No companies available. Please refresh or contact administrator.');
        return;
      }
      if (_trainingPlans.isEmpty) {
        print('❌ Validation failed: No training plans available');
        _showErrorToast('Training plans are still loading. Please wait and try again.');
        return;
      }
      if (_courses.isEmpty) {
        print('❌ Validation failed: No courses available');
        _showErrorToast('Courses are still loading. Please wait and try again.');
        return;
      }

      // Debug information
      print('Selected IDs - Company: $_selectedCompanyId, TrainingPlan: $_selectedTrainingPlanId, Course: $_selectedCourseId');
      print('Available companies: ${Get.find<NominationDataProvider>().companies.length}');
      print('Available training plans: ${_trainingPlans.length}');
      print('Available courses: ${_courses.length}');

      // Get names safely with fallbacks
      final companies = Get.find<NominationDataProvider>().companies;
      print('Looking for company with ID: $_selectedCompanyId');
      print('Available companies: ${companies.map((c) => '${c.id}: ${c.name}').join(', ')}');
      
      final companyName = companies
          .where((c) => c.id == _selectedCompanyId)
          .isNotEmpty
          ? companies.firstWhere((c) => c.id == _selectedCompanyId).name
          : 'Unknown Company';
      
      print('Selected company name: $companyName');
      
      final trainingPlanName = _trainingPlans
          .where((t) => t.id == _selectedTrainingPlanId)
          .isNotEmpty
          ? _trainingPlans.firstWhere((t) => t.id == _selectedTrainingPlanId).title
          : 'Unknown Training Plan';
      
      final courseName = _courses
          .where((c) => c.id == _selectedCourseId)
          .isNotEmpty
          ? _courses.firstWhere((c) => c.id == _selectedCourseId).title
          : 'Unknown Course';

      final nomination = NominationEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeName: _employeeNameController.text.trim(),
        jobNumber: _jobNumberController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: _emailController.text.trim(),
        englishName: _englishNameController.text.trim(),
        specialization: _specializationController.text.trim(),
        department: _departmentController.text.trim(),
        yearsOfExperience: int.parse(_yearsOfExperienceController.text.trim()),
        companyName: companyName,
        trainingPlanName: trainingPlanName,
        courseName: courseName,
      );

      setState(() {
        _nominations.add(nomination);
      });
      
      print('✅ Nomination added successfully:');
      print('   - Employee: ${nomination.employeeName} (${nomination.jobNumber})');
      print('   - Company: ${nomination.companyName}');
      print('   - Training Plan: ${nomination.trainingPlanName}');
      print('   - Course: ${nomination.courseName}');
      print('   - Total nominations: ${_nominations.length}');
      
      _clearForm();
      _showSuccessToast('Nomination added successfully');
    }
  }

  void _clearForm() {
    _employeeNameController.clear();
    _jobNumberController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _englishNameController.clear();
    _specializationController.clear();
    _departmentController.clear();
    _yearsOfExperienceController.clear();
  }



  void _deleteNomination(NominationEntry nomination) {
    print('🗑️ Delete nomination requested for: ${nomination.employeeName} (${nomination.jobNumber})');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the nomination for ${nomination.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Delete cancelled by user');
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('✅ Deleting nomination: ${nomination.employeeName} (${nomination.jobNumber})');
              setState(() {
                _nominations.removeWhere((n) => n.id == nomination.id);
              });
              Navigator.of(context).pop();
              print('✅ Nomination deleted successfully. Remaining nominations: ${_nominations.length}');
              _showSuccessToast('Nomination deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNominations() async {
    print('💾 Attempting to save nominations...');
    
    if (_nominations.isEmpty) {
      print('❌ No nominations to save');
      _showErrorToast('No nominations to save');
      return;
    }

    if (_selectedPlanCourseAssignmentId == null) {
      print('❌ No plan course assignment ID selected');
      _showErrorToast('Please select a course first');
      return;
    }

    try {
      print('📊 Preparing to save ${_nominations.length} nominations');
      print('🎯 Plan Course Assignment ID: $_selectedPlanCourseAssignmentId');
      _showLoadingToast('Saving nominations...');

      // Convert nominations to new API format
      final List<Nomination> apiNominations = _nominations.map((nomination) {
        return Nomination(
          employeeName: nomination.employeeName,
          employeeNumber: nomination.jobNumber,
          phone: nomination.phoneNumber,
          email: nomination.email,
          specialization: nomination.specialization,
          department: nomination.department,
          experienceYears: nomination.yearsOfExperience,
          planCourseAssignmentId: _selectedPlanCourseAssignmentId,
          companyName: nomination.companyName,
          trainingPlanName: nomination.trainingPlanName,
          courseName: nomination.courseName,
        );
      }).toList();

      print('📡 Calling API to create nominations...');
      
      // Call the new API
      final response = await NominationService.createNominations(
        planCourseAssignmentId: _selectedPlanCourseAssignmentId!,
        nominations: apiNominations,
      );

      if (response.statusCode == 200) {
        print('✅ Nominations saved successfully');
        print('📊 Created ${response.data?.length ?? 0} nominations');
        _showSuccessToast(response.messageEn);
        
        // Clear the form and nominations list
        setState(() {
          _nominations.clear();
          _clearForm();
        });
      } else {
        print('❌ Failed to save nominations: ${response.messageEn}');
        _showErrorToast(response.messageEn);
      }
    } catch (e) {
      print('💥 Error saving nominations: $e');
      _showErrorToast('Error saving nominations: ${e.toString()}');
    }
  }

  void _showSuccessToast(String message) {
    // Log success to console
    print('✅ SUCCESS: $message');
    
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    // Log error to console
    print('❌ ERROR: $message');
    print('📍 Stack trace: ${StackTrace.current}');
    
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  void _showLoadingToast(String message) {
    // Log loading to console
    print('⏳ LOADING: $message');
    
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: const Text('Loading', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 2),
      icon: const Icon(Icons.hourglass_empty, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

}


// Data Provider
class NominationDataProvider extends GetxController {
  final _nominations = <Nomination>[].obs;
  final _isLoading = false.obs;
  final _companies = <company_model.Company>[].obs;

  List<Nomination> get nominations => _nominations;
  bool get isLoading => _isLoading.value;
  List<company_model.Company> get companies => _companies;

  void setCompanies(List<company_model.Company> value) => _companies.value = value;

  Future<void> loadNominations() async {
    _isLoading.value = true;
    try {
      final response = await NominationService.getAllNominations();
      if (response.statusCode == 200) {
        _nominations.value = response.data ?? [];
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      await loadNominations();
      update();
    } catch (e) {
      rethrow;
    }
  }
}
