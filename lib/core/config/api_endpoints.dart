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
  
  // Course management
  static const String courses = '/courses';
  static const String courseCategories = '/course-categories';
  static const String courseDetails = '/courses/details';
  static const String enrollCourse = '/courses/enroll';
  
  // New Course API endpoints
  static const String createCourse = '/course/create';
  static const String selectCourses = '/course/select';
  static const String updateCourse = '/course/update';
  static const String courseByCode = '/course/by-code';
  static const String courseSearch = '/course/search';
  static const String courseByStatus = '/course/by-status';
  
  
  // Specializations
  static const String specializations = '/specializations';
  static const String specializationDetails = '/specializations/details';
  
  // Training centers - New API endpoints
  static const String createTrainingCenter = '/training-center/create';
  static const String getAllTrainingCenters = '/training-center/select';
  static const String getApprovedTrainingCenters = '/training-center/approved';
  static const String updateTrainingCenter = '/training-center/update';
  
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
  
  // Special Course Request management - New API endpoints
  static const String createSpecialCourseRequest = '/special-course-request/create';
  static const String getAllSpecialCourseRequests = '/special-course-request/select';
  static const String updateSpecialCourseRequest = '/special-course-request/update';
  static const String approveSpecialCourseRequest = '/special-course-request/approve';
  static const String rejectSpecialCourseRequest = '/special-course-request/reject';
  static const String getSpecialCourseRequestsByStatus = '/special-course-request/by-status';
  
  // Training Plan management - New API endpoints
  static const String getAllTrainingPlans = '/training-plans';
  static const String showTrainingPlan = '/training-plans/show';
  static const String createTrainingPlan = '/training-plans/store';
  static const String updateTrainingPlan = '/training-plans/update';
  static const String getTrainingPlansByStatus = '/training-plans/status';
  static const String getTrainingPlansByYear = '/training-plans/year';
  static const String getTrainingPlansByCompany = '/training-plans/by-company';
  static const String submitTrainingPlan = '/training-plans/submit';
  static const String approveTrainingPlan = '/training-plans/approve';
  static const String rejectTrainingPlan = '/training-plans/reject';
  
  // Plan Course Assignments - Store and Retrieve endpoints
  static const String storePlanCourseAssignments = '/plan-course-assignments/store';
  static const String getPlanCourseAssignmentsByTrainingPlan = '/plan-course-assignments/by-training-plan';
  static const String getCoursesByPlanAndCompany = '/plan-course-assignments/courses-by-plan-company';
  
  // Nomination management - New API endpoints
  static const String createNominations = '/nomination/create';
  static const String getNominationsByPlanCourseAssignment = '/nomination/by-plan-course-assignment';
  
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
