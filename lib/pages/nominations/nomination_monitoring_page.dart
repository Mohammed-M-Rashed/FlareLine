import 'package:flutter/material.dart';
import 'package:get/get.dart';

// UI Kit imports
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';

// Core imports
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/widgets/count_summary_widget.dart';

// Service imports
import 'package:flareline/core/services/auth_service.dart';
import 'package:flareline/core/services/training_plan_service.dart';
import 'package:flareline/core/services/nomination_service.dart';
import 'package:flareline/core/services/company_service.dart';

// Model imports
import 'package:flareline/core/models/training_plan_model.dart';
import 'package:flareline/core/models/nomination_model.dart';
import 'package:flareline/core/models/company_model.dart' as company_model;

// Utils
import 'package:toastification/toastification.dart';

// Model class for monitoring entries
class NominationMonitoringEntry {
  final String id;
  final String employeeName;
  final String employeeNumber;
  final String? phone;
  final String? email;
  final String? specialization;
  final String? department;
  final int? experienceYears;
  final String status;
  final String companyName;
  final String trainingPlanName;
  final String courseName;
  final DateTime createdAt;
  final DateTime updatedAt;

  NominationMonitoringEntry({
    required this.id,
    required this.employeeName,
    required this.employeeNumber,
    this.phone,
    this.email,
    this.specialization,
    this.department,
    this.experienceYears,
    required this.status,
    required this.companyName,
    required this.trainingPlanName,
    required this.courseName,
    required this.createdAt,
    required this.updatedAt,
  });
}

class NominationMonitoringPage extends LayoutWidget {
  const NominationMonitoringPage({super.key});

  @override
  String getTitle(BuildContext context) => 'Nomination Monitoring';

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const NominationMonitoringWidget();
  }
}

class NominationMonitoringWidget extends StatefulWidget {
  const NominationMonitoringWidget({super.key});

  @override
  State<NominationMonitoringWidget> createState() => _NominationMonitoringWidgetState();
}

class _NominationMonitoringWidgetState extends State<NominationMonitoringWidget> {
  final _formKey = GlobalKey<FormState>();
  
  // Access control
  bool _hasAccess = false;
  bool _isAdmin = false;
  bool _isCompany = false;
  
  // Selected values
  int? _selectedCompanyId;
  int? _selectedTrainingPlanId;
  int? _selectedCourseAssignmentId;
  
  // Data lists
  List<company_model.Company> _companies = [];
  List<ApprovedTrainingPlanWithCourses> _approvedTrainingPlans = [];
  List<PlanCourseAssignmentWithCourse> _availableCourses = [];
  List<NominationMonitoringEntry> _nominations = [];
  
  // Loading states
  bool _isLoadingCompanies = false;
  bool _isLoadingTrainingPlans = false;
  bool _isLoadingCourses = false;
  bool _isLoadingNominations = false;
  
  // Filtering and pagination
  String? _selectedFilterStatus;
  int _currentPage = 0;
  int _itemsPerPage = 10;
  
  @override
  void initState() {
    super.initState();
    _checkAccess();
  }
  
  void _checkAccess() {
    setState(() {
      _isAdmin = AuthService.hasRole('admin');
      _isCompany = AuthService.hasRole('company_account');
      _hasAccess = _isAdmin || _isCompany;
    });
    
    if (_hasAccess) {
      if (_isAdmin) {
        _loadCompanies();
        // Admin users can see all training plans immediately
        _loadApprovedTrainingPlansWithCourses();
      } else if (_isCompany) {
        _getUserCompanyId();
      }
    }
  }
  
  void _getUserCompanyId() {
    final user = AuthService.getCurrentUser();
    if (user?.company?.id != null) {
      setState(() {
        _selectedCompanyId = user!.company!.id;
      });
      _loadApprovedTrainingPlansWithCourses();
    }
  }
  
  Future<void> _loadCompanies() async {
    print('🔄 NOMINATION MONITORING: Loading companies for admin user using /admin/companies endpoint');
    setState(() {
      _isLoadingCompanies = true;
    });
    
    try {
      final response = await CompanyService.adminGetAllCompanies();
      print('📡 NOMINATION MONITORING: Admin companies API response: success=${response.success}, dataCount=${response.data.length}');

      if (response.success) {
        setState(() {
          _companies = response.data;
          _isLoadingCompanies = false;
        });
        print('✅ NOMINATION MONITORING: Companies loaded successfully using /admin/companies: ${response.data.length} companies');
      } else {
        setState(() {
          _isLoadingCompanies = false;
        });
        print('❌ NOMINATION MONITORING: Admin API failed: ${response.messageEn}');
        _showErrorToast('Failed to load companies: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingCompanies = false;
      });
      print('💥 NOMINATION MONITORING: Error loading companies from /admin/companies: $e');
      _showErrorToast('Error loading companies: ${e.toString()}');
    }
  }
  
  Future<void> _loadApprovedTrainingPlansWithCourses() async {
    // For company users, require company ID. For admin users, load all training plans
    if (_selectedCompanyId == null && _isCompany) return;
    
    print('🔄 NOMINATION MONITORING: Loading approved training plans with courses');
    print('👤 User type: ${_isAdmin ? 'Admin' : 'Company'}, Selected Company ID: $_selectedCompanyId');
    
    setState(() {
      _isLoadingTrainingPlans = true;
    });

    try {
      if (_isAdmin) {
        // For admin users, we'll show a message that they need to select a company first
        // to see training plans, since the current API structure requires company context
        setState(() {
          _approvedTrainingPlans = [];
          _isLoadingTrainingPlans = false;
        });
        print('👑 ADMIN: Admin user needs to select a company to view training plans');
        
        // Extract available courses (will be empty initially)
        _extractAvailableCourses();
      } else {
        // Company users: Load company-specific training plans
        print('🏢 COMPANY: Loading company-specific approved training plans');
        final response = await TrainingPlanService.getApprovedTrainingPlansWithCompanyCourses();
        print('📡 NOMINATION MONITORING: Company API Response: success=${response.success}, dataCount=${response.data.length}');

        if (response.success) {
          setState(() {
            _approvedTrainingPlans = response.data;
            _isLoadingTrainingPlans = false;
          });
          print('✅ NOMINATION MONITORING: Company training plans loaded successfully: ${response.data.length} plans');
          
          // Extract all available courses from all training plans
          _extractAvailableCourses();
        } else {
          setState(() {
            _isLoadingTrainingPlans = false;
          });
          print('❌ NOMINATION MONITORING: Company API failed: ${response.messageEn}');
          _showErrorToast('Failed to load training plans: ${response.messageEn}');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingTrainingPlans = false;
      });
      print('💥 NOMINATION MONITORING: Error loading approved training plans: $e');
      _showErrorToast('Error loading training plans: ${e.toString()}');
    }
  }

  Future<void> _loadTrainingPlansForAdminSelectedCompany(int companyId) async {
    print('👑 ADMIN: Loading training plans for selected company ID: $companyId');
    setState(() {
      _isLoadingTrainingPlans = true;
    });

    try {
      // Use the training plans by company endpoint for admin users
      final response = await TrainingPlanService.getTrainingPlansByCompany(companyId);
      print('📡 ADMIN: Training plans by company API Response: success=${response.success}, dataCount=${response.data.length}');

      if (response.success) {
        // Filter only approved training plans with courses
        final approvedPlans = response.data.where((plan) => 
          plan.status == 'approved' && 
          plan.planCourseAssignments != null && 
          plan.planCourseAssignments!.isNotEmpty
        ).toList();

        // Convert to ApprovedTrainingPlanWithCourses format
        final convertedPlans = <ApprovedTrainingPlanWithCourses>[];
        for (final plan in approvedPlans) {
          // Convert PlanCourseAssignment to PlanCourseAssignmentWithCourse
          final courseAssignments = <PlanCourseAssignmentWithCourse>[];
          for (final assignment in plan.planCourseAssignments!) {
            // Filter assignments for the selected company
            if (assignment.companyId == companyId) {
              courseAssignments.add(PlanCourseAssignmentWithCourse(
                id: assignment.id,
                trainingPlanId: assignment.trainingPlanId,
                companyId: assignment.companyId,
                courseId: assignment.courseId,
                trainingCenterBranchId: assignment.trainingCenterBranchId,
                startDate: assignment.startDate ?? DateTime.now(),
                endDate: assignment.endDate ?? DateTime.now(),
                seats: assignment.seats ?? 0,
                createdAt: null, // PlanCourseAssignment doesn't have createdAt
                updatedAt: null, // PlanCourseAssignment doesn't have updatedAt
                company: assignment.company,
                course: assignment.course,
              ));
            }
          }

          if (courseAssignments.isNotEmpty) {
            convertedPlans.add(ApprovedTrainingPlanWithCourses(
              id: plan.id!,
              title: plan.title,
              year: plan.year,
              status: plan.status,
              createdBy: plan.createdBy,
              createdAt: plan.createdAt,
              updatedAt: plan.updatedAt,
              creator: plan.creator,
              planCourseAssignments: courseAssignments,
            ));
          }
        }

        setState(() {
          _approvedTrainingPlans = convertedPlans;
          _isLoadingTrainingPlans = false;
        });
        print('✅ ADMIN: Training plans loaded successfully: ${convertedPlans.length} approved plans for company $companyId');
        
        // Extract all available courses from all training plans
        _extractAvailableCourses();
      } else {
        setState(() {
          _isLoadingTrainingPlans = false;
        });
        print('❌ ADMIN: API failed: ${response.messageEn}');
        _showErrorToast('Failed to load training plans for selected company: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _isLoadingTrainingPlans = false;
      });
      print('💥 ADMIN: Error loading training plans for company $companyId: $e');
      _showErrorToast('Error loading training plans: ${e.toString()}');
    }
  }
  
  void _extractAvailableCourses() {
    final allCourses = <PlanCourseAssignmentWithCourse>[];
    
    for (final plan in _approvedTrainingPlans) {
      if (_isAdmin && _selectedCompanyId != null) {
        // For admin users, filter courses by selected company
        final companyCourses = plan.planCourseAssignments.where((assignment) => 
          assignment.companyId == _selectedCompanyId
        ).toList();
        allCourses.addAll(companyCourses);
      } else {
        // For company users or admin without company selection, show all courses
        allCourses.addAll(plan.planCourseAssignments);
      }
    }
    
    setState(() {
      _availableCourses = allCourses;
    });
    
    print('✅ NOMINATION MONITORING: Extracted ${allCourses.length} available courses');
    if (_isAdmin && _selectedCompanyId != null) {
      print('🔍 ADMIN: Filtered courses for company ID: $_selectedCompanyId');
    }
  }
  
  void _filterCoursesByTrainingPlan(int trainingPlanId) {
    final selectedPlan = _approvedTrainingPlans.firstWhere(
      (plan) => plan.id == trainingPlanId,
      orElse: () => _approvedTrainingPlans.first,
    );
    
    List<PlanCourseAssignmentWithCourse> filteredCourses;
    
    if (_isAdmin && _selectedCompanyId != null) {
      // For admin users, filter courses by selected company
      filteredCourses = selectedPlan.planCourseAssignments.where((assignment) => 
        assignment.companyId == _selectedCompanyId
      ).toList();
      print('🔍 ADMIN: Filtered courses for training plan $trainingPlanId and company $_selectedCompanyId: ${filteredCourses.length} courses');
    } else {
      // For company users or admin without company selection, show all courses
      filteredCourses = selectedPlan.planCourseAssignments;
      print('📚 Showing all courses for training plan $trainingPlanId: ${filteredCourses.length} courses');
    }
    
    setState(() {
      _availableCourses = filteredCourses;
    });
  }
  
  Future<void> _loadNominations() async {
    if (_selectedCourseAssignmentId == null || _selectedTrainingPlanId == null) {
      print('❌ NOMINATION MONITORING: Cannot load nominations - missing required selections');
      return;
    }

    // Get the course ID from the selected course assignment
    final selectedCourse = _availableCourses.firstWhere(
      (course) => course.id == _selectedCourseAssignmentId,
      orElse: () => _availableCourses.first,
    );

    if (selectedCourse.course?.id == null) {
      print('❌ NOMINATION MONITORING: Cannot load nominations - course ID not found');
      _showErrorToast('Unable to load nominations: Course information not available');
      return;
    }

    setState(() {
      _isLoadingNominations = true;
    });

    try {
      // Use the same endpoint for both Admin and Company accounts
      final companyId = _isAdmin ? _selectedCompanyId : AuthService.getCurrentUser()?.companyId;
      
      if (companyId == null) {
        print('❌ NOMINATION MONITORING: Cannot load nominations - company ID not found');
        _showErrorToast(_isAdmin ? 'Please select a company first' : 'Unable to determine your company');
        setState(() {
          _isLoadingNominations = false;
        });
        return;
      }

      print('📋 UNIFIED: Loading nominations using /nomination/by-plan-course-assignment endpoint');
      print('👤 User Type: ${_isAdmin ? 'Admin' : 'Company'}');
      print('🏢 Company ID: $companyId');
      print('📊 Plan ID: $_selectedTrainingPlanId');
      print('🎓 Course ID: ${selectedCourse.course!.id}');

      final response = await NominationService.getNominationsByTrainingPlanAndCourse(
        trainingPlanId: _selectedTrainingPlanId!,
        companyId: companyId,
        courseId: selectedCourse.course!.id,
      );

      if (response.statusCode == 200 && response.data != null) {
        final nominations = response.data!.map((nomination) {
          return NominationMonitoringEntry(
            id: nomination.id.toString(),
            employeeName: nomination.employeeName,
            employeeNumber: nomination.employeeNumber,
            phone: nomination.phone,
            email: nomination.email,
            specialization: nomination.specialization,
            department: nomination.department,
            experienceYears: nomination.experienceYears,
            status: nomination.status ?? 'unknown',
            companyName: _isAdmin 
                ? _companies.firstWhere((c) => c.id == companyId, orElse: () => _companies.first).name
                : AuthService.getCurrentUser()?.company?.name ?? 'Your Company',
            trainingPlanName: _approvedTrainingPlans.firstWhere((p) => p.id == _selectedTrainingPlanId).title,
            courseName: selectedCourse.course!.title ?? 'Unknown Course',
            createdAt: nomination.createdAt ?? DateTime.now(),
            updatedAt: nomination.updatedAt ?? DateTime.now(),
          );
        }).toList();

        setState(() {
          _nominations = nominations;
          _isLoadingNominations = false;
        });

        print('✅ UNIFIED: Loaded ${nominations.length} nominations for ${_isAdmin ? 'Admin' : 'Company'} user');
      } else {
        setState(() {
          _nominations = [];
          _isLoadingNominations = false;
        });
        print('❌ UNIFIED: Failed to load nominations: ${response.messageEn}');
        _showErrorToast('Failed to load nominations: ${response.messageEn}');
      }
    } catch (e) {
      setState(() {
        _nominations = [];
        _isLoadingNominations = false;
      });
      print('💥 NOMINATION MONITORING: Error loading nominations: $e');
      _showErrorToast('Error loading nominations: ${e.toString()}');
    }
  }
  
  // Check if Company Approve button should be shown (only when all nominations are draft)
  bool get _shouldShowCompanyApprove {
    if (_nominations.isEmpty) return false;
    return _nominations.every((nomination) => nomination.status.toLowerCase() == 'draft');
  }
  
  // Check if Training Approve button should be shown (only when all nominations are company_approved)
  bool get _shouldShowTrainingApprove {
    if (_nominations.isEmpty) return false;
    return _nominations.every((nomination) => nomination.status.toLowerCase() == 'company_approved');
  }
  
  Future<void> _bulkApproveNominations() async {
    if (_selectedCourseAssignmentId == null || _selectedTrainingPlanId == null) {
      _showErrorToast('Please select a training plan and course first');
      return;
    }

    // Get the course ID from the selected course assignment
    final selectedCourse = _availableCourses.firstWhere(
      (course) => course.id == _selectedCourseAssignmentId,
      orElse: () => _availableCourses.first,
    );

    if (selectedCourse.course?.id == null) {
      _showErrorToast('Unable to approve nominations: Course information not available');
      return;
    }

    // Determine which approval to perform based on current status
    String dialogTitle = '';
    String dialogContent = '';
    
    if (_shouldShowCompanyApprove) {
      // All nominations are draft - perform company approval
      dialogTitle = 'Approve to Company Approved';
      dialogContent = 'This will update all draft nominations to company_approved status for the selected course. Continue?';
    } else if (_shouldShowTrainingApprove) {
      // All nominations are company_approved - perform training approval
      if (_isAdmin && _selectedCompanyId == null) {
        _showErrorToast('Please select a company first');
        return;
      }
      dialogTitle = 'Approve to Training Approved';
      dialogContent = 'This will update all company_approved nominations to training_approved status for the selected course. Continue?';
    } else {
      _showErrorToast('No nominations available for approval');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                if (_shouldShowCompanyApprove) {
                  await _performCompanyApproval(selectedCourse.course!.id);
                } else if (_shouldShowTrainingApprove) {
                  await _performAdminApproval(selectedCourse.course!.id);
                }
              } catch (e) {
                _showErrorToast('Error during approval: ${e.toString()}');
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAdminApproval(int courseId) async {
    print('👑 ADMIN: Performing bulk approval to training_approved');
    
    final response = await NominationService.updateToTrainingApproved(
      companyId: _selectedCompanyId!,
      planId: _selectedTrainingPlanId!,
      courseId: courseId,
    );

    if (response.statusCode == 200) {
      final updatedCount = response.data?['updated_count'] ?? 0;
      _showSuccessToast('Successfully updated $updatedCount nominations to training approved');
      
      // Reload nominations to show updated status
      await _loadNominations();
    } else {
      _showErrorToast('Failed to approve nominations: ${response.messageEn}');
    }
  }

  Future<void> _performCompanyApproval(int courseId) async {
    print('🏢 COMPANY: Performing bulk approval to company_approved');
    
    final companyId = AuthService.getCurrentUser()?.companyId;
    if (companyId == null) {
      _showErrorToast('Unable to determine your company');
      return;
    }

    final response = await NominationService.updateToCompanyApproved(
      companyId: companyId,
      planId: _selectedTrainingPlanId!,
      courseId: courseId,
    );

    if (response.statusCode == 200) {
      final updatedCount = response.data?['updated_count'] ?? 0;
      _showSuccessToast('Successfully updated $updatedCount nominations to company approved');
      
      // Reload nominations to show updated status
      await _loadNominations();
    } else {
      _showErrorToast('Failed to approve nominations: ${response.messageEn}');
    }
  }
  
  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  
  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_hasAccess) {
      return _buildAccessDeniedWidget(context);
    }
    
    return CommonCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              _buildHeaderSection(),
              const SizedBox(height: 24),
              
              // Filter Section
              _buildFilterSection(),
              const SizedBox(height: 24),
              
              // Approve Button Section
              if (_nominations.isNotEmpty && (_shouldShowCompanyApprove || _shouldShowTrainingApprove)) ...[
                _buildApproveButtonSection(),
                const SizedBox(height: 16),
              ],
              
              // Nominations Table
              _buildNominationsTable(),
              const SizedBox(height: 16),
            ],
          ),
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
            'This page is only accessible to Admin and Company Accounts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ButtonWidget(
            btnText: 'Go Back',
            type: 'primary',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
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
                Row(
                  children: [
                    Icon(
                      Icons.monitor_heart,
                      color: Colors.blue.shade600,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nomination Monitoring',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isAdmin ? Colors.purple.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isAdmin ? Colors.purple.shade200 : Colors.blue.shade200),
                      ),
                      child: Text(
                        _isAdmin ? 'Admin View' : 'Company View',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isAdmin ? Colors.purple.shade700 : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor and manage nomination approvals for training courses',
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
                child: ButtonWidget(
                  btnText: 'Refresh',
                  type: 'secondary',
                  onTap: () {
                    _loadNominations();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Container(
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
            Text(
              'Filter Nominations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                
                if (isMobile) {
                  return Column(
                    children: [
                      if (_isAdmin) ...[
                        _buildCompanyDropdown(isMobile),
                        const SizedBox(height: 16),
                      ],
                      _buildTrainingPlanDropdown(isMobile),
                      const SizedBox(height: 16),
                      _buildCourseDropdown(isMobile),
                      const SizedBox(height: 16),
                      _buildStatusFilter(isMobile),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      if (_isAdmin) ...[
                        Row(
                          children: [
                            Expanded(child: _buildCompanyDropdown(isMobile)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTrainingPlanDropdown(isMobile)),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildCompanyInfo(),
                        const SizedBox(height: 16),
                        _buildTrainingPlanDropdown(isMobile),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(child: _buildCourseDropdown(isMobile)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatusFilter(isMobile)),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompanyDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<int>(
            value: _selectedCompanyId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: _isLoadingCompanies 
                  ? 'Loading companies...' 
                  : _companies.isEmpty
                      ? 'No companies available'
                      : 'Select company',
              hintStyle: TextStyle(
                fontSize: isMobile ? 14 : 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: _isLoadingCompanies 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                      ),
                    )
                  : Icon(Icons.business, color: Colors.blue.shade600, size: 20),
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
              fillColor: _isLoadingCompanies ? Colors.grey.shade50 : Colors.white,
            ),
            items: _companies.map<DropdownMenuItem<int>>((company) {
              return DropdownMenuItem<int>(
                value: company.id,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 8,
                    horizontal: isMobile ? 16 : 12,
                  ),
                  child: Text(
                    company.name,
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
            onChanged: _isLoadingCompanies ? null : (value) {
              setState(() {
                _selectedCompanyId = value;
                _selectedTrainingPlanId = null;
                _selectedCourseAssignmentId = null;
                _nominations.clear();
              });
              if (value != null) {
                if (_isAdmin) {
                  // For admin users, load training plans for the selected company
                  _loadTrainingPlansForAdminSelectedCompany(value);
                } else {
                  // For company users, load training plans
                  _loadApprovedTrainingPlansWithCourses();
                }
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
              color: _isLoadingCompanies ? Colors.grey[400] : Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompanyInfo() {
    final user = AuthService.getCurrentUser();
    final companyName = user?.company?.name ?? 'Unknown Company';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.business, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Your Company',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrainingPlanDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Plan',
          style: TextStyle(
            fontSize: 14,
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
                _nominations.clear();
              });
              if (value != null) {
                _filterCoursesByTrainingPlan(value);
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
              color: (_isLoadingTrainingPlans || _selectedCompanyId == null) 
                  ? Colors.grey[400] 
                  : Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourseDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course',
          style: TextStyle(
            fontSize: 14,
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
              });
              
              if (value != null) {
                _loadNominations();
              } else {
                setState(() {
                  _nominations.clear();
                });
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
  }
  
  Widget _buildStatusFilter(bool isMobile) {
    final statusOptions = [
      {'value': null, 'label': 'All Statuses'},
      {'value': 'draft', 'label': 'Draft'},
      {'value': 'company_approved', 'label': 'Company Approved'},
      {'value': 'training_approved', 'label': 'Training Approved'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Filter',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: DropdownButtonFormField<String?>(
            value: _selectedFilterStatus,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Filter by status',
              hintStyle: TextStyle(
                fontSize: isMobile ? 14 : 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(Icons.filter_list, color: Colors.blue.shade600, size: 20),
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
              fillColor: Colors.white,
            ),
            items: statusOptions.map<DropdownMenuItem<String?>>((option) {
              return DropdownMenuItem<String?>(
                value: option['value'] as String?,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 12 : 8,
                    horizontal: isMobile ? 16 : 12,
                  ),
                  child: Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 13, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilterStatus = value;
              });
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
              color: Colors.grey[600],
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildApproveButtonSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Icon(
                _shouldShowCompanyApprove ? Icons.business : Icons.admin_panel_settings,
                color: Colors.green.shade600,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shouldShowCompanyApprove ? 'Company Approval Required' : 'Training Approval Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _shouldShowCompanyApprove 
                          ? 'Approve all draft nominations for your company'
                          : 'Approve all company-approved nominations for training',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 200,
                    minWidth: 120,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ButtonWidget(
                    btnText: _shouldShowCompanyApprove ? 'Approve Company' : 'Approve Training',
                    type: 'primary',
                    onTap: _bulkApproveNominations,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildNominationsTable() {
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

              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Count summary
          CountSummaryWidget(
            count: _nominations.length,
            itemName: 'nomination',
            itemNamePlural: 'nominations',
            icon: Icons.person_add,
            color: Colors.purple,
            filteredCount: _filteredNominations.length,
            showFilteredCount: _selectedFilterStatus != null,
          ),
          const SizedBox(height: 16),
          
          _buildTable(),
        ],
      ),
    );
  }
  
  Widget _buildTable() {
    // Show loading indicator when fetching nominations
    if (_isLoadingNominations) {
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
              'Loading Nominations...',
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
              Icons.monitor_heart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Nominations Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCourseAssignmentId != null 
                  ? 'No nominations found for the selected course.'
                  : 'Select a course to view nominations.',
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
  
  Widget _buildMobileCard(NominationMonitoringEntry nomination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with name and status
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
                      'ID: ${nomination.employeeNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(nomination.status),
            ],
          ),
          const SizedBox(height: 12),
          
          // Details
          _buildInfoRow(Icons.business, 'Company', nomination.companyName),
          _buildInfoRow(Icons.school, 'Training Plan', nomination.trainingPlanName),
          _buildInfoRow(Icons.book, 'Course', nomination.courseName),
          if (nomination.department != null)
            _buildInfoRow(Icons.apartment, 'Department', nomination.department!),
          if (nomination.experienceYears != null)
            _buildInfoRow(Icons.work, 'Experience', '${nomination.experienceYears} years'),
          
          const SizedBox(height: 16),
          
          // Actions
          if (_isAdmin) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ButtonWidget(
                      btnText: 'Approve',
                      type: 'primary',
                      onTap: _bulkApproveNominations,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ButtonWidget(
                      btnText: 'View Details',
                      type: 'secondary',
                      onTap: () {
                        // TODO: Implement view details
                      },
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ButtonWidget(
                btnText: 'View Details',
                type: 'secondary',
                onTap: () {
                  // TODO: Implement view details
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
  
  Widget _buildDesktopTable() {
    return Container(
      width: double.infinity,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith(
          (states) => Colors.grey.shade100,
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
                'Status',
                textAlign: TextAlign.center,
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
        ],
        rows: _paginatedNominations.map((nomination) => DataRow(
          onSelectChanged: (selected) {},
          cells: [
            DataCell(_buildEmployeeInfoCell(nomination)),
            DataCell(_buildCompanyCell(nomination)),
            DataCell(_buildCourseCell(nomination)),
            DataCell(_buildStatusCell(nomination)),
            DataCell(_buildExperienceCell(nomination)),
          ],
        )).toList(),
      ),
    );
  }
  
  Widget _buildEmployeeInfoCell(NominationMonitoringEntry nomination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          nomination.employeeName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  Widget _buildCompanyCell(NominationMonitoringEntry nomination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        nomination.companyName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  Widget _buildCourseCell(NominationMonitoringEntry nomination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            nomination.courseName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            nomination.trainingPlanName,
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
  
  Widget _buildStatusCell(NominationMonitoringEntry nomination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: _buildStatusBadge(nomination.status),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    MaterialColor statusColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'draft':
        statusColor = Colors.grey;
        statusText = 'Draft';
        break;
      case 'company_approved':
        statusColor = Colors.blue;
        statusText = 'Company Approved';
        break;
      case 'training_approved':
        statusColor = Colors.green;
        statusText = 'Training Approved';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.shade50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: statusColor.shade700,
        ),
      ),
    );
  }
  
  Widget _buildExperienceCell(NominationMonitoringEntry nomination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          nomination.experienceYears != null 
              ? '${nomination.experienceYears} years'
              : 'N/A',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
  
  
  // Get filtered nominations
  List<NominationMonitoringEntry> get _filteredNominations {
    if (_selectedFilterStatus == null) {
      return _nominations;
    }
    return _nominations.where((nomination) {
      return nomination.status == _selectedFilterStatus;
    }).toList();
  }
  
  // Get paginated nominations
  List<NominationMonitoringEntry> get _paginatedNominations {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredNominations.length);
    return _filteredNominations.sublist(startIndex, endIndex);
  }
}
