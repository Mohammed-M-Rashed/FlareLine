/// ملف النصوص العربية
/// يحتوي على جميع النصوص المستخدمة في التطبيق بالعربية
class StringsAr {
  // عناوين عامة
  static const String appName = 'نظام إدارة التدريب';
  
  // أزرار عامة
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String close = 'إغلاق';
  static const String confirm = 'تأكيد';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String ok = 'موافق';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String previous = 'السابق';
  static const String submit = 'إرسال';
  static const String reset = 'إعادة تعيين';
  static const String clear = 'مسح';
  static const String refresh = 'تحديث';
  static const String view = 'عرض';
  static const String download = 'تحميل';
  static const String upload = 'رفع';
  static const String select = 'اختيار';
  static const String selectAll = 'تحديد الكل';
  static const String deselectAll = 'إلغاء تحديد الكل';
  
  // حالات عامة
  static const String active = 'نشط';
  static const String inactive = 'غير نشط';
  static const String pending = 'قيد الانتظار';
  static const String approved = 'مقبول';
  static const String rejected = 'مرفوض';
  static const String suspended = 'معلق';
  static const String draft = 'مسودة';
  static const String published = 'منشور';
  static const String archived = 'مؤرشف';
  static const String deleted = 'محذوف';
  
  // رسائل عامة
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String noResults = 'لا توجد نتائج';
  static const String error = 'حدث خطأ';
  static const String success = 'تمت العملية بنجاح';
  static const String warning = 'تحذير';
  static const String info = 'معلومات';
  static const String required = 'مطلوب';
  static const String optional = 'اختياري';
  static const String notAvailable = 'غير متوفر';
  
  // الشركات
  static const String companies = 'الشركات';
  static const String company = 'شركة';
  static const String companyManagement = 'إدارة الشركات';
  static const String addCompany = 'إضافة شركة';
  static const String editCompany = 'تعديل الشركة';
  static const String deleteCompany = 'حذف الشركة';
  static const String companyName = 'اسم الشركة';
  static const String companyAddress = 'عنوان الشركة';
  static const String companyPhone = 'هاتف الشركة';
  static const String companyEmail = 'بريد الشركة الإلكتروني';
  static const String companyLogo = 'شعار الشركة';
  static const String companyApiUrl = 'رابط API الشركة';
  static const String companyDetails = 'تفاصيل الشركة';
  static const String companyInformation = 'معلومات الشركة';
  static const String cooperativeCompanies = 'الشركات التعاونية';
  static const String cooperativeCompany = 'شركة تعاونية';
  
  // المستخدمون
  static const String users = 'المستخدمون';
  static const String user = 'مستخدم';
  static const String userManagement = 'إدارة المستخدمين';
  static const String addUser = 'إضافة مستخدم';
  static const String editUser = 'تعديل المستخدم';
  static const String deleteUser = 'حذف المستخدم';
  static const String userName = 'اسم المستخدم';
  static const String userEmail = 'البريد الإلكتروني';
  static const String userPassword = 'كلمة المرور';
  static const String userRole = 'الدور';
  static const String userStatus = 'الحالة';
  static const String userDetails = 'تفاصيل المستخدم';
  
  // الدورات
  static const String courses = 'الدورات';
  static const String course = 'دورة';
  static const String courseManagement = 'إدارة الدورات';
  static const String addCourse = 'إضافة دورة';
  static const String editCourse = 'تعديل الدورة';
  static const String deleteCourse = 'حذف الدورة';
  static const String courseName = 'اسم الدورة';
  static const String courseCode = 'رمز الدورة';
  static const String courseDescription = 'وصف الدورة';
  static const String courseDuration = 'مدة الدورة';
  static const String courseType = 'نوع الدورة';
  static const String courseStatus = 'حالة الدورة';
  static const String courseDetails = 'تفاصيل الدورة';
  static const String courseAttachment = 'مرفق الدورة';
  static const String courseSpecialization = 'تخصص الدورة';
  
  // المدن والدول
  static const String countries = 'الدول';
  static const String country = 'دولة';
  static const String cities = 'المدن';
  static const String city = 'مدينة';
  static const String cityManagement = 'إدارة المدن';
  static const String addCity = 'إضافة مدينة';
  static const String editCity = 'تعديل المدينة';
  static const String deleteCity = 'حذف المدينة';
  static const String cityName = 'اسم المدينة';
  static const String countryName = 'اسم الدولة';
  
  // المرفقات والصور
  static const String image = 'صورة';
  static const String file = 'ملف';
  static const String attachment = 'مرفق';
  static const String selectImage = 'اختيار صورة';
  static const String selectFile = 'اختيار ملف';
  static const String changeImage = 'تغيير الصورة';
  static const String removeImage = 'إزالة الصورة';
  static const String noImageSelected = 'لم يتم اختيار صورة';
  static const String noFileSelected = 'لم يتم اختيار ملف';
  static const String invalidImage = 'صورة غير صالحة';
  static const String invalidFile = 'ملف غير صالح';
  static const String imageUploaded = 'تم رفع الصورة';
  static const String fileUploaded = 'تم رفع الملف';
  static const String attachFile = 'إرفاق ملف';
  
  // التحقق من المدخلات
  static const String fieldRequired = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صالح';
  static const String invalidPhone = 'رقم الهاتف غير صالح';
  static const String invalidUrl = 'الرابط غير صالح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordsDoNotMatch = 'كلمات المرور غير متطابقة';
  static const String nameTooShort = 'الاسم قصير جداً';
  static const String nameTooLong = 'الاسم طويل جداً';
  
  // رسائل النجاح
  static const String saveSuccess = 'تم الحفظ بنجاح';
  static const String updateSuccess = 'تم التحديث بنجاح';
  static const String deleteSuccess = 'تم الحذف بنجاح';
  static const String createSuccess = 'تم الإنشاء بنجاح';
  static const String uploadSuccess = 'تم الرفع بنجاح';
  static const String submitSuccess = 'تم الإرسال بنجاح';
  static const String loginSuccess = 'تم تسجيل الدخول بنجاح';
  static const String logoutSuccess = 'تم تسجيل الخروج بنجاح';
  
  // رسائل الخطأ
  static const String saveError = 'فشل الحفظ';
  static const String updateError = 'فشل التحديث';
  static const String deleteError = 'فشل الحذف';
  static const String createError = 'فشل الإنشاء';
  static const String uploadError = 'فشل الرفع';
  static const String submitError = 'فشل الإرسال';
  static const String loginError = 'فشل تسجيل الدخول';
  static const String logoutError = 'فشل تسجيل الخروج';
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String serverError = 'خطأ في الخادم';
  static const String unknownError = 'خطأ غير معروف';
  static const String validationError = 'خطأ في التحقق من البيانات';
  static const String authError = 'خطأ في المصادقة';
  static const String permissionError = 'ليس لديك صلاحية لهذه العملية';
  static const String notFoundError = 'المورد المطلوب غير موجود';
  static const String timeoutError = 'انتهت مهلة الاتصال';
  
  // رسائل التأكيد
  static const String confirmDelete = 'هل أنت متأكد من الحذف؟';
  static const String confirmSubmit = 'هل أنت متأكد من الإرسال؟';
  static const String confirmCancel = 'هل أنت متأكد من الإلغاء؟';
  static const String confirmLogout = 'هل أنت متأكد من تسجيل الخروج؟';
  static const String deleteWarning = 'هذا الإجراء لا يمكن التراجع عنه';
  
  // التواريخ والأوقات
  static const String createdAt = 'تاريخ الإنشاء';
  static const String updatedAt = 'تاريخ التحديث';
  static const String date = 'التاريخ';
  static const String time = 'الوقت';
  static const String from = 'من';
  static const String to = 'إلى';
  static const String startDate = 'تاريخ البدء';
  static const String endDate = 'تاريخ الانتهاء';
  
  // الأدوار والصلاحيات
  static const String roles = 'الأدوار';
  static const String role = 'الدور';
  static const String permissions = 'الصلاحيات';
  static const String permission = 'الصلاحية';
  static const String systemAdministrator = 'مدير النظام';
  static const String trainingGeneralManager = 'المدير العام للتدريب';
  static const String boardChairman = 'رئيس مجلس الإدارة';
  static const String companyAccount = 'حساب شركة';
  
  // التحميل والمعالجة
  static const String processing = 'جاري المعالجة...';
  static const String uploading = 'جاري الرفع...';
  static const String downloading = 'جاري التحميل...';
  static const String saving = 'جاري الحفظ...';
  static const String deleting = 'جاري الحذف...';
  static const String updating = 'جاري التحديث...';
  static const String creating = 'جاري الإنشاء...';
  static const String submitting = 'جاري الإرسال...';
  static const String loggingIn = 'جاري تسجيل الدخول...';
  static const String loggingOut = 'جاري تسجيل الخروج...';
  
  // أخرى
  static const String total = 'المجموع';
  static const String count = 'العدد';
  static const String name = 'الاسم';
  static const String description = 'الوصف';
  static const String address = 'العنوان';
  static const String phone = 'الهاتف';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String status = 'الحالة';
  static const String type = 'النوع';
  static const String category = 'الفئة';
  static const String notes = 'ملاحظات';
  static const String actions = 'الإجراءات';
  static const String details = 'التفاصيل';
  static const String information = 'معلومات';
  static const String settings = 'الإعدادات';
  static const String profile = 'الملف الشخصي';
  static const String logout = 'تسجيل الخروج';
  static const String login = 'تسجيل الدخول';
  static const String register = 'تسجيل';
  static const String all = 'الكل';
  static const String none = 'لا شيء';
  static const String other = 'أخرى';
  static const String more = 'المزيد';
  static const String less = 'أقل';
  static const String show = 'عرض';
  static const String hide = 'إخفاء';
  static const String expand = 'توسيع';
  static const String collapse = 'طي';
  static const String copy = 'نسخ';
  static const String paste = 'لصق';
  static const String cut = 'قص';
  static const String print = 'طباعة';
  static const String export = 'تصدير';
  static const String import = 'استيراد';
}

