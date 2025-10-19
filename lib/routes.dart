import 'package:flareline/deferred_widget.dart';
import 'package:flareline/pages/modal/modal_page.dart' deferred as modal;
import 'package:flareline/pages/toast/toast_page.dart' deferred as toast;
import 'package:flareline/pages/tools/tools_page.dart' deferred as tools;
import 'package:flutter/material.dart';
import 'package:flareline/pages/alerts/alert_page.dart' deferred as alert;
import 'package:flareline/pages/button/button_page.dart' deferred as button;
import 'package:flareline/pages/form/form_elements_page.dart' deferred as formElements;
import 'package:flareline/pages/form/form_layout_page.dart' deferred as formLayout;
import 'package:flareline/pages/auth/sign_in/sign_in_page.dart' deferred as signIn;
import 'package:flareline/pages/auth/sign_up/sign_up_page.dart' deferred as signUp;
import 'package:flareline/pages/calendar/calendar_page.dart' deferred as calendar;
import 'package:flareline/pages/chart/chart_page.dart' deferred as chart;
import 'package:flareline/pages/dashboard/ecommerce_page.dart';
import 'package:flareline/pages/inbox/index.dart' deferred as inbox;
import 'package:flareline/pages/invoice/invoice_page.dart' deferred as invoice;
import 'package:flareline/pages/profile/profile_page.dart' deferred as profile;
import 'package:flareline/pages/resetpwd/reset_pwd_page.dart' deferred as resetPwd;
import 'package:flareline/pages/setting/settings_page.dart' deferred as settings;
import 'package:flareline/pages/table/tables_page.dart' deferred as tables;
import 'package:flareline/pages/users/user_management_page.dart';
import 'package:flareline/pages/companies/company_management_page.dart';
import 'package:flareline/pages/cooperative_companies/cooperative_company_management_page.dart';
import 'package:flareline/pages/countries/country_management_page.dart';
import 'package:flareline/pages/cities/city_management_page.dart';
import 'package:flareline/pages/education_levels/education_levels_management_page.dart';
import 'package:flareline/pages/education_specializations/education_specializations_management_page.dart';
import 'package:flareline/pages/languages/languages_management_page.dart';

import 'package:flareline/pages/specializations/specialization_management_page.dart';
import 'package:flareline/pages/training_centers/training_center_management_page.dart';
import 'package:flareline/pages/training_center_branches/training_center_branch_management_page.dart';
import 'package:flareline/pages/courses/course_management_page.dart';
import 'package:flareline/pages/trainers/trainer_management_page.dart';
import 'package:flareline/pages/training_needs/training_need_management_page.dart';
import 'package:flareline/pages/training_plans/training_plan_management_page.dart';
import 'package:flareline/pages/plan_course_assignments/plan_course_assignment_management_page.dart';
import 'package:flareline/pages/nominations/nomination_management_page.dart';
import 'package:flareline/pages/nominations/nomination_monitoring_page.dart';
import 'package:flareline/core/widgets/role_based_sidebar_test.dart';
import 'package:get/get.dart';
import 'package:flareline/pages/special_course_requests/special_course_request_management_page.dart';

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

final List<GetPage> routes = [
  GetPage(
    name: '/',
    page: () => DeferredWidget(signIn.loadLibrary, () => signIn.SignInWidget()),
  ),
  GetPage(
    name: '/dashboard',
    page: () => const EcommercePage(),
  ),
  GetPage(
    name: '/calendar',
    page: () => DeferredWidget(calendar.loadLibrary, () => calendar.CalendarPage()),
  ),
  GetPage(
    name: '/profile',
    page: () => DeferredWidget(profile.loadLibrary, () => profile.ProfilePage()),
  ),
  GetPage(
    name: '/formElements',
    page: () => DeferredWidget(formElements.loadLibrary, () => formElements.FormElementsPage()),
  ),
  GetPage(
    name: '/formLayout',
    page: () => DeferredWidget(formLayout.loadLibrary, () => formLayout.FormLayoutPage()),
  ),
  GetPage(
    name: '/signIn',
    page: () => DeferredWidget(signIn.loadLibrary, () => signIn.SignInWidget()),
  ),
  GetPage(
    name: '/signUp',
    page: () => DeferredWidget(signUp.loadLibrary, () => signUp.SignUpWidget()),
  ),
  GetPage(
    name: '/resetPwd',
    page: () => DeferredWidget(resetPwd.loadLibrary, () => resetPwd.ResetPwdWidget()),
  ),
  GetPage(
    name: '/invoice',
    page: () => DeferredWidget(invoice.loadLibrary, () => invoice.InvoicePage()),
  ),
  GetPage(
    name: '/inbox',
    page: () => DeferredWidget(inbox.loadLibrary, () => inbox.InboxWidget()),
  ),
  GetPage(
    name: '/tables',
    page: () => DeferredWidget(tables.loadLibrary, () => tables.TablesPage()),
  ),
  GetPage(
    name: '/settings',
    page: () => DeferredWidget(settings.loadLibrary, () => settings.SettingsPage()),
  ),
  GetPage(
    name: '/basicChart',
    page: () => DeferredWidget(chart.loadLibrary, () => chart.ChartPage()),
  ),
  GetPage(
    name: '/buttons',
    page: () => DeferredWidget(button.loadLibrary, () => button.ButtonPage()),
  ),
  GetPage(
    name: '/alerts',
    page: () => DeferredWidget(alert.loadLibrary, () => alert.AlertPage()),
  ),
  GetPage(
    name: '/tools',
    page: () => DeferredWidget(tools.loadLibrary, () => tools.ToolsPage()),
  ),
  GetPage(
    name: '/toast',
    page: () => DeferredWidget(toast.loadLibrary, () => toast.ToastPage()),
  ),
  GetPage(
    name: '/modal',
    page: () => DeferredWidget(modal.loadLibrary, () => modal.ModalPage()),
  ),
  GetPage(
    name: '/userManagement',
    page: () => const UserManagementPage(),
  ),
  GetPage(
    name: '/companyManagement',
    page: () => const CompanyManagementPage(),
  ),
  GetPage(
    name: '/cooperativeCompanyManagement',
    page: () => const CooperativeCompanyManagementPage(),
  ),
  GetPage(
    name: '/countryManagement',
    page: () => const CountryManagementPage(),
  ),
  GetPage(
    name: '/cityManagement',
    page: () => const CityManagementPage(),
  ),
  GetPage(
    name: '/educationLevelsManagement',
    page: () => const EducationLevelsManagementPage(),
  ),
  GetPage(
    name: '/educationSpecializationsManagement',
    page: () => const EducationSpecializationsManagementPage(),
  ),
  GetPage(
    name: '/languagesManagement',
    page: () => const LanguagesManagementPage(),
  ),

            GetPage(
              name: '/specializationManagement',
              page: () => const SpecializationManagementPage(),
            ),
            GetPage(
              name: '/trainingCenterManagement',
              page: () => const TrainingCenterManagementPage(),
            ),
            GetPage(
              name: '/trainingCenterBranchManagement',
              page: () => const TrainingCenterBranchManagementPage(),
            ),
            GetPage(
              name: '/courseManagement',
              page: () => const CourseManagementPage(),
            ),
            GetPage(
              name: '/trainerManagement',
              page: () => const TrainerManagementPage(),
            ),
            GetPage(
              name: '/trainingNeedManagement',
              page: () => const TrainingNeedManagementPage(),
            ),
            GetPage(
              name: '/special-course-request',
              page: () => const SpecialCourseRequestManagementPage(),
            ),
            GetPage(
              name: '/training-plan',
              page: () => const TrainingPlanManagementPage(),
            ),
            GetPage(
              name: '/plan-course-assignment-management',
              page: () => const PlanCourseAssignmentManagementPage(),
            ),
            GetPage(
              name: '/nomination-management',
              page: () => const NominationManagementPage(),
              // Note: Role-based access control is handled within the page component
              // This ensures only company_account users can access the nomination management
            ),
            GetPage(
              name: '/nomination-monitoring',
              page: () => const NominationMonitoringPage(),
              // Note: Role-based access control is handled within the page component
              // This ensures admin and company_account users can access nomination monitoring
            ),
            GetPage(
              name: '/role-based-sidebar-test',
              page: () => const RoleBasedSidebarTest(),
            ),
];

class RouteConfiguration {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'Rex');

  static BuildContext? get navigatorContext =>
      navigatorKey.currentState?.context;

  static List<GetPage> get getPages => routes;
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
