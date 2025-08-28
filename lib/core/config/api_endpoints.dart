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
  
  // Training programs
  static const String trainingPrograms = '/training-programs';
  static const String programDetails = '/training-programs/details';
  static const String enrollProgram = '/training-programs/enroll';
  
  // Specializations
  static const String specializations = '/specializations';
  static const String specializationDetails = '/specializations/details';
  

  
  // Training centers
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
