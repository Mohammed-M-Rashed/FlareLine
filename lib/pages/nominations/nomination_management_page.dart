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
import 'package:flareline/core/services/auth_service.dart';
import 'package:toastification/toastification.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flareline/core/i18n/strings_ar.dart';
import 'package:flareline/core/ui/notification_service.dart' as notification_svc;

// Import the new model classes
import 'package:flareline/core/models/training_plan_model.dart';

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
  final int? courseAssignmentId; // Track which course assignment this nomination belongs to

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
    this.courseAssignmentId,
  });
}

class NominationManagementPage extends LayoutWidget {
  const NominationManagementPage({super.key});


  @override
  Widget contentDesktopWidget(BuildContext context) {
    // Check if user has company account role
    if (!AuthService.hasRole('company_account')) {
      return _buildAccessDeniedWidget(context);
    }
    
    return const Column(
      children: [
        SizedBox(height: 16),
        NominationManagementWidget(),
      ],
    );
  }

  Widget _buildAccessDeniedWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Access Denied',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This page is only accessible to Company Accounts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ButtonWidget(
            btnText: 'العودة',
            type: 'primary',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
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
  int? _selectedCompanyId; // Will be set from logged-in user's company
  int? _selectedTrainingPlanId;
  int? _selectedCourseAssignmentId;
  int? _selectedPlanCourseAssignmentId; // New field for API integration
  
  // Data lists
  List<ApprovedTrainingPlanWithCourses> _approvedTrainingPlans = [];
  List<PlanCourseAssignmentWithCourse> _availableCourses = [];
  List<NominationEntry> _nominations = [];
  
  // Seat tracking
  Map<int, int> _originalSeats = {}; // courseAssignmentId -> original seats
  Map<int, int> _remainingSeats = {}; // courseAssignmentId -> remaining seats
  
  // Loading states
  bool _isLoadingTrainingPlans = false;
  bool _isLoadingCourses = false;
  bool _isLoadingExistingNominations = false;
  
  // Filtering and pagination
  String? _selectedFilterCompany;
  int _currentPage = 0;
  int _itemsPerPage = 10;
  
  // Access control
  bool _hasAccess = false;
  
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
    
    // Check access permissions
    _checkAccess();
    
    if (_hasAccess) {
      // Get company ID from logged-in user
      _getUserCompanyId();
    
    // Add listener to job number controller for auto-fill
    _jobNumberController.addListener(_onJobNumberChanged);
    }
  }
  
  void _getUserCompanyId() {
    try {
      final user = AuthService.getCurrentUser();
      if (user != null && user.companyId != null) {
        setState(() {
          _selectedCompanyId = user.companyId;
        });
        print('✅ NOMINATION: User company ID set to: ${user.companyId}');
        print('✅ NOMINATION: User company name: ${user.company?.name ?? 'Unknown'}');
        
        // Load approved training plans with courses for the user's company
        _loadApprovedTrainingPlansWithCourses();
      } else {
        print('❌ NOMINATION: No company ID found for current user');
        _showErrorToast('Unable to determine your company. Please contact support.');
      }
    } catch (e) {
      print('❌ NOMINATION: Error getting user company ID: $e');
      _showErrorToast('Error loading user information. Please try again.');
    }
  }
  
  void _checkAccess() {
    setState(() {
      _hasAccess = AuthService.hasRole('company_account');
    });
    
    if (!_hasAccess) {
      print('🚫 NOMINATION MANAGEMENT: Access denied - User does not have company_account role');
      _showErrorToast('Access denied. This page is only accessible to Company Accounts.');
    } else {
      print('✅ NOMINATION MANAGEMENT: Access granted - User has company_account role');
    }
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
    // Check access first
    if (!_hasAccess) {
      return _buildAccessDeniedWidget(context);
    }
    
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
  
  Widget _buildAccessDeniedWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Access Denied',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This page is only accessible to Company Accounts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ButtonWidget(
            btnText: 'العودة',
            type: 'primary',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
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

              // Seat Tracking Section
              _buildSeatTrackingSection(),
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
                  btnText: Get.find<NominationDataProvider>().isLoading ? 'جاري التحميل...' : 'تحديث',
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

  Widget _buildSeatTrackingSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_seat,
                    color: Colors.green.shade600,
                    size: isMobile ? 18 : 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Seat Availability Tracking',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedCourseAssignmentId != null) ...[
                _buildSelectedCourseSeatInfo(isMobile),
              ] else ...[
                _buildGeneralSeatInfo(isMobile),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedCourseSeatInfo(bool isMobile) {
    final selectedCourse = _availableCourses.firstWhere(
      (course) => course.id == _selectedCourseAssignmentId,
      orElse: () => _availableCourses.first,
    );
    
    final originalSeats = _originalSeats[_selectedCourseAssignmentId!] ?? 0;
    final remainingSeats = _remainingSeats[_selectedCourseAssignmentId!] ?? 0;
    final usedSeats = originalSeats - remainingSeats;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Course: ${selectedCourse.course?.title ?? 'Unknown Course'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        isMobile 
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Total Seats',
                        originalSeats.toString(),
                        Colors.blue,
                        Icons.event_seat,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Used Seats',
                        usedSeats.toString(),
                        Colors.orange,
                        Icons.person,
                        isMobile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildSeatInfoCard(
                  'Available Seats',
                  remainingSeats.toString(),
                  remainingSeats > 0 ? Colors.green : Colors.red,
                  remainingSeats > 0 ? Icons.check_circle : Icons.cancel,
                  isMobile,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildSeatInfoCard(
                    'Total Seats',
                    originalSeats.toString(),
                    Colors.blue,
                    Icons.event_seat,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeatInfoCard(
                    'Used Seats',
                    usedSeats.toString(),
                    Colors.orange,
                    Icons.person,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeatInfoCard(
                    'Available',
                    remainingSeats.toString(),
                    remainingSeats > 0 ? Colors.green : Colors.red,
                    remainingSeats > 0 ? Icons.check_circle : Icons.cancel,
                    isMobile,
                  ),
                ),
              ],
            ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: originalSeats > 0 ? usedSeats / originalSeats : 0,
            child: Container(
              decoration: BoxDecoration(
                color: remainingSeats > 0 ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSeatInfo(bool isMobile) {
    final totalCourses = _availableCourses.length;
    final totalSeats = _originalSeats.values.fold(0, (sum, seats) => sum + seats);
    final totalUsed = _originalSeats.entries.fold(0, (sum, entry) {
      final remaining = _remainingSeats[entry.key] ?? entry.value;
      return sum + (entry.value - remaining);
    });
    final totalAvailable = totalSeats - totalUsed;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Seat Availability',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        isMobile 
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Courses',
                        totalCourses.toString(),
                        Colors.blue,
                        Icons.book,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Total Seats',
                        totalSeats.toString(),
                        Colors.blue,
                        Icons.event_seat,
                        isMobile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Used',
                        totalUsed.toString(),
                        Colors.orange,
                        Icons.person,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSeatInfoCard(
                        'Available',
                        totalAvailable.toString(),
                        totalAvailable > 0 ? Colors.green : Colors.red,
                        totalAvailable > 0 ? Icons.check_circle : Icons.cancel,
                        isMobile,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildSeatInfoCard(
                    'Courses',
                    totalCourses.toString(),
                    Colors.blue,
                    Icons.book,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeatInfoCard(
                    'Total Seats',
                    totalSeats.toString(),
                    Colors.blue,
                    Icons.event_seat,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeatInfoCard(
                    'Used',
                    totalUsed.toString(),
                    Colors.orange,
                    Icons.person,
                    isMobile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeatInfoCard(
                    'Available',
                    totalAvailable.toString(),
                    totalAvailable > 0 ? Colors.green : Colors.red,
                    totalAvailable > 0 ? Icons.check_circle : Icons.cancel,
                    isMobile,
                  ),
                ),
              ],
            ),
        if (totalSeats > 0) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: totalUsed / totalSeats,
              child: Container(
                decoration: BoxDecoration(
                  color: totalAvailable > 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSeatInfoCard(String title, String value, Color color, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 16 : 20,
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 1 : 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
                  'إضافة ترشيح',
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
                    btnText: 'إضافة ترشيح',
                    type: 'primary',
                    onTap: _canAddNomination() ? _addNomination : null,
                  ),
                ),
              ],
            ),
            
            // Show seat availability message
            if (_selectedCourseAssignmentId != null) ...[
              const SizedBox(height: 8),
              _buildSeatAvailabilityMessage(),
            ],
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
          // Show company info (read-only)
          _buildCompanyInfo(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Mobile layout - single column
                return Column(
                  children: [
                    _buildTrainingPlanDropdown(),
                    const SizedBox(height: 12),
                    _buildCourseDropdown(),
                  ],
                );
              } else {
                // Desktop layout - two columns
                return Row(
                  children: [
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
  
  Widget _buildCompanyInfo() {
    final user = AuthService.getCurrentUser();
    final companyName = user?.company?.name ?? 'Your Company';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Company: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            companyName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
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
                          : _approvedTrainingPlans.isEmpty
                              ? 'No training plans available'
                              : 'Select training plan',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 14 : 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: _isLoadingTrainingPlans 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                          ),
                        )
                      : Icon(Icons.school, color: Colors.blue.shade600, size: 20),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 14, 
                    vertical: isMobile ? 16 : 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                  ),
                  filled: true,
                  fillColor: _isLoadingTrainingPlans 
                      ? Colors.grey.shade50 
                      : (_selectedCompanyId == null)
                          ? Colors.grey.shade100
                          : Colors.white,
                ),
                items: _approvedTrainingPlans.map<DropdownMenuItem<int>>((plan) {
                  return DropdownMenuItem<int>(
                    value: plan.id,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 8,
                        horizontal: isMobile ? 16 : 12,
                      ),
                      child: Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 13, 
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: isMobile ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return _approvedTrainingPlans.map<Widget>((plan) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 8,
                        horizontal: isMobile ? 16 : 12,
                      ),
                      child: Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: _isLoadingTrainingPlans ? null : (value) {
                  setState(() {
                    _selectedTrainingPlanId = value;
                    _selectedCourseAssignmentId = null;
                    _selectedPlanCourseAssignmentId = null;
                    // Clear nominations when training plan changes
                    _nominations.clear();
                  });
                  if (value != null) {
                    _filterCoursesByTrainingPlan(value);
                  }
                  // Recalculate seat tracking after clearing nominations
                  _recalculateSeatTracking();
                },
                style: TextStyle(
                  fontSize: isMobile ? 14 : 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                menuMaxHeight: isMobile ? 300 : 250,
                isDense: false,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: (_isLoadingTrainingPlans || _selectedCompanyId == null) 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                  size: 24,
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
                value: _selectedCourseAssignmentId,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _isLoadingCourses 
                      ? 'Loading courses...' 
                          : _selectedTrainingPlanId == null 
                              ? 'Select training plan first'
                          : _availableCourses.isEmpty
                                  ? 'No courses available'
                                  : 'Select course',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 14 : 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: _isLoadingCourses 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                          ),
                        )
                      : Icon(Icons.book, color: Colors.blue.shade600, size: 20),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 14, 
                    vertical: isMobile ? 16 : 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                    borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
                  ),
                  filled: true,
                  fillColor: _isLoadingCourses 
                      ? Colors.grey.shade50 
                      : (_selectedCompanyId == null || _selectedTrainingPlanId == null)
                          ? Colors.grey.shade100
                          : Colors.white,
                ),
                items: _availableCourses.map<DropdownMenuItem<int>>((courseAssignment) {
                  return DropdownMenuItem<int>(
                    value: courseAssignment.id,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 8,
                        horizontal: isMobile ? 16 : 12,
                      ),
                      child: Text(
                        courseAssignment.course?.title ?? 'Unknown Course',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 13, 
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: isMobile ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return _availableCourses.map<Widget>((courseAssignment) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isMobile ? 12 : 8,
                        horizontal: isMobile ? 16 : 12,
                      ),
                      child: Text(
                        courseAssignment.course?.title ?? 'Unknown Course',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: (_isLoadingCourses || _selectedTrainingPlanId == null) ? null : (value) {
                  setState(() {
                    _selectedCourseAssignmentId = value;
                    _selectedPlanCourseAssignmentId = value; // Now they're the same since we're using assignment ID
                    print('🎯 Selected course assignment ID: $_selectedCourseAssignmentId');
                  });
                  
                  // Load existing nominations for the selected course
                  if (value != null) {
                    _loadExistingNominations();
                  } else {
                    // Clear nominations if no course is selected
                    setState(() {
                      _nominations.clear();
                    });
                    _recalculateSeatTracking();
                  }
                },
                style: TextStyle(
                  fontSize: isMobile ? 14 : 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                menuMaxHeight: isMobile ? 300 : 250,
                isDense: false,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: (_isLoadingCourses || _selectedCompanyId == null || _selectedTrainingPlanId == null) 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                  size: 24,
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
              if (_selectedCourseAssignmentId != null && _nominations.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_download,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Loaded from server',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    // Show loading indicator when fetching existing nominations
    if (_isLoadingExistingNominations) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Existing Nominations...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch nominations for the selected course.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
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
              _selectedCourseAssignmentId != null 
                  ? 'No existing nominations found for this course. Add nominations using the form above.'
                  : 'Add nominations using the form above to see them here.',
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
      child: Row(
        children: [
          Expanded(
      child: ButtonWidget(
        btnText: 'حفظ الترشيحات',
        type: 'primary',
        onTap: _nominations.isNotEmpty ? _saveNominations : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ButtonWidget(
              btnText: 'مسح النموذج',
              type: 'secondary',
              onTap: _nominations.isNotEmpty ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('مسح النموذج'),
                    content: const Text('Are you sure you want to clear the form and reset seat tracking? This will remove all nominations from the table.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _nominations.clear();
                            _clearForm(resetSeatTracking: true);
                          });
                          Navigator.of(context).pop();
                          _showSuccessToast('Form cleared and seat tracking reset');
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              } : null,
            ),
          ),
        ],
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

  Future<void> _loadApprovedTrainingPlansWithCourses() async {
    print('🔄 NOMINATION: Loading approved training plans with courses');
    setState(() {
      _isLoadingTrainingPlans = true;
    });

    try {
      final response = await TrainingPlanService.getApprovedTrainingPlansWithCompanyCourses();
      print('📡 NOMINATION: API Response: success=${response.success}, dataCount=${response.data.length}');

      if (response.success) {
        setState(() {
          _approvedTrainingPlans = response.data;
          _isLoadingTrainingPlans = false;
        });
        print('✅ NOMINATION: Approved training plans loaded successfully: ${response.data.length} plans');
        
        // Extract all available courses from all training plans
        _extractAvailableCourses();
      } else {
        setState(() {
          _isLoadingTrainingPlans = false;
        });
        print('❌ NOMINATION: API failed: ${response.messageEn}');
        _showErrorToast('Failed to load training plans: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingTrainingPlans = false;
      });
      print('💥 NOMINATION: Error loading approved training plans: $e');
      _showErrorToast('Error loading training plans: ${e.toString()}');
    }
  }

  void _extractAvailableCourses() {
    final allCourses = <PlanCourseAssignmentWithCourse>[];
    
    for (final plan in _approvedTrainingPlans) {
      allCourses.addAll(plan.planCourseAssignments);
    }
    
    // Initialize seat tracking
    final originalSeats = <int, int>{};
    final remainingSeats = <int, int>{};
    
    for (final course in allCourses) {
      originalSeats[course.id] = course.seats;
      remainingSeats[course.id] = course.seats;
    }
    
    setState(() {
      _availableCourses = allCourses;
      _originalSeats = originalSeats;
      _remainingSeats = remainingSeats;
    });
    
    // Recalculate seat tracking based on existing nominations
    _recalculateSeatTracking();
    
    print('✅ NOMINATION: Extracted ${allCourses.length} available courses from ${_approvedTrainingPlans.length} training plans');
    print('✅ NOMINATION: Initialized seat tracking for ${originalSeats.length} courses');
  }

  void _recalculateSeatTracking() {
    // Reset to original values first
    _remainingSeats = Map.from(_originalSeats);
    
    // Deduct seats for existing nominations
    for (final nomination in _nominations) {
      if (nomination.courseAssignmentId != null) {
        final currentSeats = _remainingSeats[nomination.courseAssignmentId!] ?? 0;
        if (currentSeats > 0) {
          _remainingSeats[nomination.courseAssignmentId!] = currentSeats - 1;
          print('🎯 Seat recalculated: ${currentSeats} -> ${currentSeats - 1} for course assignment ${nomination.courseAssignmentId}');
        }
      }
    }
    
    print('✅ NOMINATION: Seat tracking recalculated based on ${_nominations.length} existing nominations');
  }

  Future<void> _loadExistingNominations() async {
    if (_selectedTrainingPlanId == null || _selectedCompanyId == null || _selectedCourseAssignmentId == null) {
      print('❌ NOMINATION: Cannot load existing nominations - missing required IDs');
      return;
    }

    // Find the selected course to get the course ID
    final selectedCourseAssignment = _availableCourses.firstWhere(
      (course) => course.id == _selectedCourseAssignmentId,
      orElse: () => _availableCourses.first,
    );
    
    if (selectedCourseAssignment.course?.id == null) {
      print('❌ NOMINATION: Cannot load existing nominations - course ID not found');
      return;
    }

    setState(() {
      _isLoadingExistingNominations = true;
    });

    try {
      print('🔄 NOMINATION: Loading existing nominations...');
      print('📊 NOMINATION: Training Plan ID: $_selectedTrainingPlanId');
      print('🏢 NOMINATION: Company ID: $_selectedCompanyId');
      print('🎓 NOMINATION: Course ID: ${selectedCourseAssignment.course!.id}');

      final response = await NominationService.getNominationsByTrainingPlanAndCourse(
        trainingPlanId: _selectedTrainingPlanId!,
        companyId: _selectedCompanyId!,
        courseId: selectedCourseAssignment.course!.id,
      );

      print('📡 NOMINATION: API response received');
      print('📊 NOMINATION: Status code: ${response.statusCode}');
      print('📄 NOMINATION: Message: ${response.messageEn}');

      if (response.statusCode == 200 && response.data != null) {
        // Convert API nominations to NominationEntry objects
        final existingNominations = response.data!.map((apiNomination) {
          return NominationEntry(
            id: apiNomination.id.toString(),
            employeeName: apiNomination.employeeName,
            jobNumber: apiNomination.employeeNumber,
            phoneNumber: apiNomination.phone ?? '',
            email: apiNomination.email ?? '',
            englishName: '', // Not provided by API
            specialization: apiNomination.specialization ?? '',
            department: apiNomination.department ?? '',
            yearsOfExperience: apiNomination.experienceYears ?? 0,
            companyName: AuthService.getCurrentUser()?.company?.name ?? 'Unknown Company',
            trainingPlanName: _approvedTrainingPlans
                .firstWhere((plan) => plan.id == _selectedTrainingPlanId)
                .title,
            courseName: selectedCourseAssignment.course!.title ?? 'Unknown Course',
            courseAssignmentId: _selectedCourseAssignmentId,
          );
        }).toList();

        setState(() {
          // Replace current nominations with existing ones from API
          _nominations = existingNominations;
          _isLoadingExistingNominations = false;
        });

        // Recalculate seat tracking based on existing nominations
        _recalculateSeatTracking();

        print('✅ NOMINATION: Loaded ${existingNominations.length} existing nominations');
        print('🎯 NOMINATION: Remaining seats: ${_remainingSeats[_selectedCourseAssignmentId] ?? 0}');
      } else {
        setState(() {
          // Clear nominations if no existing ones found
          _nominations.clear();
          _isLoadingExistingNominations = false;
        });
        
        // Reset seat tracking
        _recalculateSeatTracking();
        
        print('ℹ️ NOMINATION: No existing nominations found or API error: ${response.messageEn}');
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoadingExistingNominations = false;
      });
      
      print('💥 NOMINATION: Error loading existing nominations: $e');
      print('💥 NOMINATION: Stack trace: $stackTrace');
      _showErrorToast('Error loading existing nominations: ${e.toString()}');
    }
  }

  void _filterCoursesByTrainingPlan(int trainingPlanId) {
    final selectedPlan = _approvedTrainingPlans.firstWhere(
      (plan) => plan.id == trainingPlanId,
      orElse: () => _approvedTrainingPlans.first,
    );
    
        setState(() {
      _availableCourses = selectedPlan.planCourseAssignments;
    });
    
    print('✅ NOMINATION: Filtered ${selectedPlan.planCourseAssignments.length} courses for training plan: ${selectedPlan.title}');
  }



  bool _canAddNomination() {
    // Check if all required fields are selected
    if (_selectedTrainingPlanId == null || 
        _selectedCourseAssignmentId == null || 
        _selectedCompanyId == null) {
      return false;
    }
    
    // Check if seats are available
    final remainingSeats = _remainingSeats[_selectedCourseAssignmentId!] ?? 0;
    return remainingSeats > 0;
  }

  Widget _buildSeatAvailabilityMessage() {
    final remainingSeats = _remainingSeats[_selectedCourseAssignmentId!] ?? 0;
    final originalSeats = _originalSeats[_selectedCourseAssignmentId!] ?? 0;
    final usedSeats = originalSeats - remainingSeats;
    
    if (remainingSeats <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'All seats are filled ($usedSeats/$originalSeats). Cannot add more nominations.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$remainingSeats of $originalSeats seats available. You can add $remainingSeats more nomination${remainingSeats == 1 ? '' : 's'}.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _addNomination() {
    print('🔄 NOMINATION PAGE: Starting add nomination process');
    print('📊 NOMINATION PAGE: Current form state validation...');
    
    // Additional security check - ensure user has company account role
    if (!AuthService.hasRole('company_account')) {
      print('❌ NOMINATION PAGE: Access denied - User does not have company_account role');
      _showErrorToast('Access denied. Only company accounts can create nominations.');
      return;
    }
    
    print('✅ NOMINATION PAGE: User has company_account role - proceeding with validation');
    
    if (_formKey.currentState!.validate()) {
      if (_selectedCompanyId == null) {
        print('❌ Validation failed: No company ID available');
        _showErrorToast('Unable to determine your company. Please contact support.');
        return;
      }
      if (_selectedTrainingPlanId == null) {
        print('❌ Validation failed: No training plan selected');
        _showErrorToast('Please select a training plan first');
        return;
      }
      if (_selectedCourseAssignmentId == null) {
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
      if (_approvedTrainingPlans.isEmpty) {
        print('❌ Validation failed: No training plans available');
        _showErrorToast('Training plans are still loading. Please wait and try again.');
        return;
      }
      if (_availableCourses.isEmpty) {
        print('❌ Validation failed: No courses available');
        _showErrorToast('Courses are still loading. Please wait and try again.');
        return;
      }

      // Check seat availability before adding nomination
      final remainingSeats = _remainingSeats[_selectedCourseAssignmentId!] ?? 0;
      if (remainingSeats <= 0) {
        print('❌ Seat validation failed: No available seats for course assignment $_selectedCourseAssignmentId');
        print('🎯 Current remaining seats: $remainingSeats');
        _showErrorToast('No available seats for this course. All seats have been filled.');
        return;
      }

      // Debug information
      print('Selected IDs - Company: $_selectedCompanyId, TrainingPlan: $_selectedTrainingPlanId, CourseAssignment: $_selectedCourseAssignmentId');
      print('Available training plans: ${_approvedTrainingPlans.length}');
      print('Available courses: ${_availableCourses.length}');
      print('🎯 Seat validation passed: $remainingSeats seats remaining');

      // Get company name from user data
      final user = AuthService.getCurrentUser();
      final companyName = user?.company?.name ?? 'Your Company';
      
      print('Selected company name: $companyName');
      
      final trainingPlanName = _approvedTrainingPlans
          .where((t) => t.id == _selectedTrainingPlanId)
          .isNotEmpty
          ? _approvedTrainingPlans.firstWhere((t) => t.id == _selectedTrainingPlanId).title
          : 'Unknown Training Plan';
      
      final selectedCourseAssignment = _availableCourses.firstWhere(
        (c) => c.id == _selectedCourseAssignmentId,
        orElse: () => _availableCourses.first,
      );
      final courseName = selectedCourseAssignment.course?.title ?? 'Unknown Course';

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
        courseAssignmentId: _selectedCourseAssignmentId,
      );

      setState(() {
        _nominations.add(nomination);
        
        // Reduce available seats for the selected course (we already validated seats are available)
        if (_selectedCourseAssignmentId != null) {
          final currentSeats = _remainingSeats[_selectedCourseAssignmentId!] ?? 0;
          _remainingSeats[_selectedCourseAssignmentId!] = currentSeats - 1;
          print('🎯 Seat reduced: ${currentSeats} -> ${currentSeats - 1} for course assignment $_selectedCourseAssignmentId');
        }
      });
      
      print('✅ Nomination added successfully:');
      print('   - Employee: ${nomination.employeeName} (${nomination.jobNumber})');
      print('   - Company: ${nomination.companyName}');
      print('   - Remaining seats: ${_remainingSeats[_selectedCourseAssignmentId] ?? 0}');
      print('   - Training Plan: ${nomination.trainingPlanName}');
      print('   - Course: ${nomination.courseName}');
      print('   - Total nominations: ${_nominations.length}');
      
      _clearForm();
      _showSuccessToast('Nomination added successfully');
    }
  }

  void _clearForm({bool resetSeatTracking = false}) {
    _employeeNameController.clear();
    _jobNumberController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _englishNameController.clear();
    _specializationController.clear();
    _departmentController.clear();
    _yearsOfExperienceController.clear();
    
    // Only reset seat tracking if explicitly requested (e.g., when form is manually cleared)
    if (resetSeatTracking) {
      setState(() {
        _remainingSeats = Map.from(_originalSeats);
      });
      print('✅ NOMINATION PAGE: Form cleared and seat tracking reset');
    } else {
      print('✅ NOMINATION PAGE: Form cleared (seat tracking preserved)');
    }
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
                
                // Restore seat if this nomination had a course assignment ID
                if (nomination.courseAssignmentId != null) {
                  final currentSeats = _remainingSeats[nomination.courseAssignmentId!] ?? 0;
                  _remainingSeats[nomination.courseAssignmentId!] = currentSeats + 1;
                  print('🎯 Seat restored: ${currentSeats} -> ${currentSeats + 1} for course assignment ${nomination.courseAssignmentId}');
                }
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
    print('💾 NOMINATION PAGE: Starting save nominations process');
    print('📊 NOMINATION PAGE: Current nominations count: ${_nominations.length}');
    
    if (_nominations.isEmpty) {
      print('❌ NOMINATION PAGE: No nominations to save');
      _showErrorToast('No nominations to save');
      return;
    }

    if (_selectedPlanCourseAssignmentId == null) {
      print('❌ NOMINATION PAGE: No plan course assignment ID selected');
      _showErrorToast('Please select a course first');
      return;
    }

    // Final seat validation before saving
    if (_selectedCourseAssignmentId != null) {
      final originalSeats = _originalSeats[_selectedCourseAssignmentId!] ?? 0;
      final currentNominations = _nominations.where((n) => n.courseAssignmentId == _selectedCourseAssignmentId).length;
      
      if (currentNominations > originalSeats) {
        print('❌ NOMINATION PAGE: Seat validation failed during save');
        print('🎯 NOMINATION PAGE: Nominations: $currentNominations, Available seats: $originalSeats');
        _showErrorToast('Cannot save nominations. You have $currentNominations nominations but only $originalSeats seats available.');
        return;
      }
      
      print('✅ NOMINATION PAGE: Final seat validation passed - $currentNominations nominations for $originalSeats seats');
    }

    try {
      print('📊 NOMINATION PAGE: Preparing to save ${_nominations.length} nominations');
      print('🎯 NOMINATION PAGE: Plan Course Assignment ID: $_selectedPlanCourseAssignmentId');
      print('🏢 NOMINATION PAGE: Company ID: $_selectedCompanyId');
      print('📚 NOMINATION PAGE: Training Plan ID: $_selectedTrainingPlanId');
      print('🎓 NOMINATION PAGE: Course Assignment ID: $_selectedCourseAssignmentId');
      
      _showLoadingToast('Saving nominations...');

      // Convert nominations to new API format
      print('🔄 NOMINATION PAGE: Converting nominations to API format...');
      final List<Nomination> apiNominations = _nominations.map((nomination) {
        print('📝 NOMINATION PAGE: Converting nomination for ${nomination.employeeName} (${nomination.jobNumber})');
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

      print('📡 NOMINATION PAGE: Calling API to create nominations...');
      print('📋 NOMINATION PAGE: API nominations data: ${apiNominations.map((n) => n.toApiJson()).toList()}');
      
      // Call the new API
      final response = await NominationService.createNominations(
        planCourseAssignmentId: _selectedPlanCourseAssignmentId!,
        nominations: apiNominations,
      );

      print('📡 NOMINATION PAGE: API response received');
      print('📊 NOMINATION PAGE: Response status code: ${response.statusCode}');
      print('📄 NOMINATION PAGE: Response message EN: ${response.messageEn}');
      print('📄 NOMINATION PAGE: Response message AR: ${response.messageAr}');
      print('📊 NOMINATION PAGE: Response data count: ${response.data?.length ?? 0}');

      if (response.statusCode == 200) {
        print('✅ NOMINATION PAGE: Nominations saved successfully');
        print('📊 NOMINATION PAGE: Created ${response.data?.length ?? 0} nominations');
        _showSuccessToast(response.messageEn);
        
        // Clear the form and nominations list
        setState(() {
          _nominations.clear();
          _clearForm();
          // Reset seat tracking to original values
          _remainingSeats = Map.from(_originalSeats);
        });
        print('✅ NOMINATION PAGE: Form cleared and nominations list reset');
        print('✅ NOMINATION PAGE: Seat tracking reset to original values');
      } else {
        print('❌ NOMINATION PAGE: Failed to save nominations');
        print('❌ NOMINATION PAGE: Error status: ${response.statusCode}');
        print('❌ NOMINATION PAGE: Error message: ${response.messageEn}');
        _showErrorToast(response.messageEn);
      }
    } catch (e, stackTrace) {
      print('💥 NOMINATION PAGE: Exception occurred during save');
      print('💥 NOMINATION PAGE: Exception type: ${e.runtimeType}');
      print('💥 NOMINATION PAGE: Exception message: ${e.toString()}');
      print('💥 NOMINATION PAGE: Stack trace: $stackTrace');
      _showErrorToast('Error saving nominations: ${e.toString()}');
    }
  }

  void _showSuccessToast(String message) {
    // Log success to console
    print('✅ SUCCESS: $message');
    
    notification_svc.NotificationService.showSuccess(context, message, operationId: 'nomination:success');
  }

  void _showErrorToast(String message) {
    // Log error to console
    print('❌ ERROR: $message');
    print('📍 Stack trace: ${StackTrace.current}');
    
    notification_svc.NotificationService.showError(context, message, operationId: 'nomination:error');
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
