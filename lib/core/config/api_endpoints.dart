class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String getCurrentUser = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User management
  static const String createUser = '/users/create';
  static const String getAllUsers = '/users/all';
  static const String updateUser = '/users/update';
  static const String activateUser = '/users/activate';
  static const String deactivateUser = '/users/deactivate';
  
  // Company management
  static const String createCompany = '/company/create';
  static const String getAllCompanies = '/company/select';
  static const String updateCompany = '/company/update';
  
  // Admin API endpoints
  static const String adminGetAllCompanies = '/admin/companies';
  static const String adminGetCoursesBySpecialization = '/admin/courses-by-specialization';
  static const String adminGetAllTrainingCenters = '/admin/training-centers';
  static const String adminGetTrainingCenterBranches = '/admin/training-center-branches';
  static const String adminGetTrainingPlans = '/admin/training-plans-plan-preparation';

  // Course management
  static const String courses = '/courses';
  static const String courseCategories = '/course-categories';
  static const String courseDetails = '/courses/details';
  static const String enrollCourse = '/courses/enroll';
  
  // New Course API endpoints
  static const String createCourse = '/course/create';
  static const String selectCourses = '/course/select';
  static const String selectCoursesForCompanyAccount = '/course/company-account';
  static const String getCoursesBySpecializationForCompanyAccount = '/course/by-specialization';
  static const String updateCourse = '/course/update';
  static const String courseByCode = '/course/by-code';
  static const String courseSearch = '/course/search';
  static const String courseByStatus = '/course/by-status';
  
  
  // Specializations
  static const String specializations = '/specializations';
  static const String specializationDetails = '/specializations/details';
  
  // Specialization management - API endpoints
  static const String createSpecialization = '/specialization/create';
  static const String updateSpecialization = '/specialization/update';
  static const String selectSpecializations = '/specialization/select';
  static const String selectSpecializationsForCompanyAccount = '/specialization/company-account';
  
  // Training centers - New API endpoints
  static const String createTrainingCenter = '/training-center/create';
  static const String getAllTrainingCenters = '/training-center/select';
  static const String getApprovedTrainingCenters = '/training-center/approved';
  static const String updateTrainingCenter = '/training-center/update';
  static const String acceptTrainingCenter = '/training-center/accept';
  static const String rejectTrainingCenter = '/training-center/reject';
  static const String getTrainingCentersByStatus = '/training-center/by-status';
  
  // Training center branches - New API endpoints
  static const String createTrainingCenterBranch = '/training-center-branch/create';
  static const String getAllTrainingCenterBranches = '/training-center-branch/select';
  static const String updateTrainingCenterBranch = '/training-center-branch/update';
  
  // Trainer management - New API endpoints
  static const String createTrainer = '/trainer/create';
  static const String getAllTrainers = '/trainer/select';
  static const String updateTrainer = '/trainer/update';
  static const String acceptTrainer = '/trainer/accept';
  static const String rejectTrainer = '/trainer/reject';
  static const String getTrainersByStatus = '/trainer/by-status';
  
  // Special Course Request management - API endpoints
  // Company Account Routes
  static const String createSpecialCourseRequest = '/special-course-request/create';
  static const String updateSpecialCourseRequest = '/special-course-request/update';
  static const String getSpecialCourseRequestsByCompany = '/special-course-request/get-by-company';
  static const String forwardSpecialCourseRequest = '/special-course-request/forward';
  
  // System Administrator & Admin Routes
  static const String getAllSpecialCourseRequests = '/special-course-request/get-all';
  static const String approveSpecialCourseRequest = '/special-course-request/approve';
  static const String rejectSpecialCourseRequest = '/special-course-request/reject';
  
  // Training Plan management - Role-based API endpoints
  // Admin Role endpoints
  static const String getAllTrainingPlans = '/training-plans';
  static const String showTrainingPlan = '/training-plans/show';
  static const String createTrainingPlan = '/training-plans/store';
  static const String updateTrainingPlan = '/training-plans/update';
  static const String getTrainingPlansByStatus = '/training-plans/status';
  static const String getTrainingPlansByYear = '/training-plans/year';
  static const String getTrainingPlansByCompany = '/training-plans/by-company';
  static const String moveToPlanPreparation = '/training-plans/move-to-plan-preparation';
  static const String moveToTrainingGeneralManagerApproval = '/training-plans/move-to-training-general-manager-approval';
  
  // General Training Director Role endpoints
  static const String getTrainingPlansForGeneralManager = '/training-plans/general-manager';
  static const String moveToBoardChairmanApproval = '/training-plans/move-to-board-chairman-approval';
  
  // Board Chairman Role endpoints
  static const String getTrainingPlansForBoardChairman = '/training-plans/board-chairman';
  static const String approveTrainingPlan = '/training-plans/approve';
  
  // Company Account Role endpoints
  static const String getTrainingPlansForCompany = '/training-plans/company';
  static const String showTrainingPlanForCompany = '/training-plans/company/show';
  static const String getApprovedTrainingPlansWithCompanyCourses = '/training-plans/company/approved-with-courses';
  
  // Plan Course Assignments - Store and Retrieve endpoints
  static const String storePlanCourseAssignments = '/plan-course-assignments/store';
  static const String getPlanCourseAssignmentsByTrainingPlan = '/plan-course-assignments/by-training-plan';
  static const String getCoursesByPlanAndCompany = '/plan-course-assignments/courses-by-plan-company';
  
  // Nomination management - New API endpoints
  static const String createNominations = '/nomination/create';
  static const String getNominationsByPlanCourseAssignment = '/nomination/by-plan-course-assignment';
  static const String getTrainingFullyApprovedNominations = '/nomination/training-fully-approved';
  static const String updateToCompanyApproved = '/nomination/update-to-company-approved';
  static const String updateToTrainingApproved = '/nomination/update-to-training-approved';
  
  // Training Needs management - API endpoints
  // System Administrator & Admin Routes
  static const String addTrainingNeed = '/training-need/add';
  static const String updateTrainingNeed = '/training-need/update';
  static const String getAllTrainingNeeds = '/training-need/get-all';
  static const String forwardTrainingNeed = '/training-need/forward';
  static const String approveTrainingNeed = '/training-need/approve';
  static const String rejectTrainingNeed = '/training-need/reject';
  
  // Company Account Routes
  static const String getTrainingNeedsByCompany = '/training-need/get-by-company';
  
  // Legacy endpoints (keeping for backward compatibility)
  static const String createTrainingNeed = '/training-need/create';
  static const String getTrainingNeedsByStatus = '/training-need/by-status';
  
  // Legacy training center endpoints (keeping for backward compatibility)
  static const String trainingCenters = '/training-centers';
  static const String centerDetails = '/training-centers/details';
  
  // Dashboard and analytics
  static const String dashboardStats = '/dashboard/stats';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  
  // File uploads
  static const String uploadFile = '/upload';
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
}
