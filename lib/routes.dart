import 'package:flareline/deferred_widget.dart';
import 'package:flareline/pages/modal/modal_page.dart' deferred as modal;
import 'package:flareline/pages/table/contacts_page.dart' deferred as contacts;
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

import 'package:flareline/pages/specializations/specialization_management_page.dart';
import 'package:flareline/pages/training_centers/training_center_management_page.dart';
import 'package:flareline/pages/courses/course_management_page.dart';
import 'package:flareline/pages/training_programs/training_program_management_page.dart';
import 'package:get/get.dart';

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
    name: '/contacts',
    page: () => DeferredWidget(contacts.loadLibrary, () => contacts.ContactsPage()),
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
              name: '/specializationManagement',
              page: () => const SpecializationManagementPage(),
            ),
            GetPage(
              name: '/trainingCenterManagement',
              page: () => const TrainingCenterManagementPage(),
            ),
            GetPage(
              name: '/courseManagement',
              page: () => const CourseManagementPage(),
            ),
            GetPage(
              name: '/trainingProgramManagement',
              page: () => const TrainingProgramManagementPage(),
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
