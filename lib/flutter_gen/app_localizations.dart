import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'flutter_gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @alertsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحذيرات'**
  String get alertsPageTitle;

  /// No description provided for @alertsTitle.
  ///
  /// In ar, this message translates to:
  /// **'هناك حاجة للاهتمام'**
  String get alertsTitle;

  /// No description provided for @alertsMessage.
  ///
  /// In ar, this message translates to:
  /// **'ليس لورم إيبسوم مجرد نص وهمية لصناعة الطباعة والطباعة'**
  String get alertsMessage;

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'فلارلاين'**
  String get appName;

  /// No description provided for @slogan.
  ///
  /// In ar, this message translates to:
  /// **'تطوير ويب بسيط أسرع'**
  String get slogan;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In ar, this message translates to:
  /// **'6+ أحرف'**
  String get passwordHint;

  /// No description provided for @signInWithGithub.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Github'**
  String get signInWithGithub;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithMicrosoft.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Microsoft'**
  String get signInWithMicrosoft;

  /// No description provided for @signInWithTwitter.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Twitter'**
  String get signInWithTwitter;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل'**
  String get signUp;

  /// No description provided for @startForFree.
  ///
  /// In ar, this message translates to:
  /// **'البدء مجانًا'**
  String get startForFree;

  /// No description provided for @signUpTip.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل في فلارلاين'**
  String get signUpTip;

  /// No description provided for @retypePassword.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور'**
  String get retypePassword;

  /// No description provided for @retypePasswordHint.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور الخاصة بك'**
  String get retypePasswordHint;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل باستخدام Google'**
  String get signUpWithGoogle;

  /// No description provided for @haveAnAccount.
  ///
  /// In ar, this message translates to:
  /// **'هل لديك حساب بالفعل؟'**
  String get haveAnAccount;

  /// No description provided for @normalButton.
  ///
  /// In ar, this message translates to:
  /// **'زر عادي'**
  String get normalButton;

  /// No description provided for @buttonWithIcon.
  ///
  /// In ar, this message translates to:
  /// **'زر مع أيقونة'**
  String get buttonWithIcon;

  /// No description provided for @buttonsPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأزرار'**
  String get buttonsPageTitle;

  /// No description provided for @btnName.
  ///
  /// In ar, this message translates to:
  /// **'زر'**
  String get btnName;

  /// No description provided for @calendarPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get calendarPageTitle;

  /// No description provided for @chartPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرسم البياني'**
  String get chartPageTitle;

  /// No description provided for @totalViews.
  ///
  /// In ar, this message translates to:
  /// **'المشاهدات الإجمالية'**
  String get totalViews;

  /// No description provided for @totalProfit.
  ///
  /// In ar, this message translates to:
  /// **'الربح الإجمالي'**
  String get totalProfit;

  /// No description provided for @totalProduct.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الإجمالية'**
  String get totalProduct;

  /// No description provided for @totalUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمين الإجماليين'**
  String get totalUsers;

  /// No description provided for @formElements.
  ///
  /// In ar, this message translates to:
  /// **'عناصر النموذج'**
  String get formElements;

  /// No description provided for @inputFields.
  ///
  /// In ar, this message translates to:
  /// **'حقول الإدخال'**
  String get inputFields;

  /// No description provided for @defaultInput.
  ///
  /// In ar, this message translates to:
  /// **'الإدخال الافتراضي'**
  String get defaultInput;

  /// No description provided for @activeInput.
  ///
  /// In ar, this message translates to:
  /// **'الإدخال النشط'**
  String get activeInput;

  /// No description provided for @disabledLabel.
  ///
  /// In ar, this message translates to:
  /// **'العلامة المعطلة'**
  String get disabledLabel;

  /// No description provided for @toggleSwitchInput.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الإدخال'**
  String get toggleSwitchInput;

  /// No description provided for @switchLabel.
  ///
  /// In ar, this message translates to:
  /// **'علامة التبديل'**
  String get switchLabel;

  /// No description provided for @timeAndDate.
  ///
  /// In ar, this message translates to:
  /// **'الوقت والتاريخ'**
  String get timeAndDate;

  /// No description provided for @datePicker.
  ///
  /// In ar, this message translates to:
  /// **'محدد التاريخ'**
  String get datePicker;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @fileUpload.
  ///
  /// In ar, this message translates to:
  /// **'رفع الملف'**
  String get fileUpload;

  /// No description provided for @attachFile.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق الملف'**
  String get attachFile;

  /// No description provided for @selectImage.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصورة'**
  String get selectImage;

  /// No description provided for @textareaFields.
  ///
  /// In ar, this message translates to:
  /// **'حقول النص'**
  String get textareaFields;

  /// No description provided for @defaultTextarea.
  ///
  /// In ar, this message translates to:
  /// **'النص الافتراضي'**
  String get defaultTextarea;

  /// No description provided for @activeTextarea.
  ///
  /// In ar, this message translates to:
  /// **'النص النشط'**
  String get activeTextarea;

  /// No description provided for @disabledTextarea.
  ///
  /// In ar, this message translates to:
  /// **'النص المعطل'**
  String get disabledTextarea;

  /// No description provided for @checkboxAndRadis.
  ///
  /// In ar, this message translates to:
  /// **'خانات الاختيار والراديو'**
  String get checkboxAndRadis;

  /// No description provided for @selectInput.
  ///
  /// In ar, this message translates to:
  /// **'اختر الإدخال'**
  String get selectInput;

  /// No description provided for @selectCountry.
  ///
  /// In ar, this message translates to:
  /// **'اختر الدولة'**
  String get selectCountry;

  /// No description provided for @multiselect.
  ///
  /// In ar, this message translates to:
  /// **'قائمة منسدلة متعددة الاختيار'**
  String get multiselect;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @formLayoutPageTitle.
  ///
  /// In ar, this message translates to:
  /// **'تخطيط النموذج'**
  String get formLayoutPageTitle;

  /// No description provided for @contactForm.
  ///
  /// In ar, this message translates to:
  /// **'نموذج الاتصال'**
  String get contactForm;

  /// No description provided for @firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الأول'**
  String get firstNameHint;

  /// No description provided for @lastName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الأخير'**
  String get lastNameHint;

  /// No description provided for @subject.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع'**
  String get subject;

  /// No description provided for @subjectHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل موضوعك'**
  String get subjectHint;

  /// No description provided for @selectSubjectHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر موضوعك'**
  String get selectSubjectHint;

  /// No description provided for @message.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة'**
  String get message;

  /// No description provided for @messageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك'**
  String get messageHint;

  /// No description provided for @sendMessage.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرسالة'**
  String get sendMessage;

  /// No description provided for @rememberMe.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get rememberMe;

  /// No description provided for @forgetPwd.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgetPwd;

  /// No description provided for @signInForm.
  ///
  /// In ar, this message translates to:
  /// **'نموذج تسجيل الدخول؟'**
  String get signInForm;

  /// No description provided for @signUpForm.
  ///
  /// In ar, this message translates to:
  /// **'نموذج التسجيل؟'**
  String get signUpForm;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get fullNameHint;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تحرير'**
  String get edit;

  /// No description provided for @posts.
  ///
  /// In ar, this message translates to:
  /// **'المشاركات'**
  String get posts;

  /// No description provided for @followers.
  ///
  /// In ar, this message translates to:
  /// **'المتابعون'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In ar, this message translates to:
  /// **'يتابع'**
  String get following;

  /// No description provided for @aboutMe.
  ///
  /// In ar, this message translates to:
  /// **'عنيد'**
  String get aboutMe;

  /// No description provided for @followMeOn.
  ///
  /// In ar, this message translates to:
  /// **'تابعني على'**
  String get followMeOn;

  /// No description provided for @resetPwd.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPwd;

  /// No description provided for @emailReceiveResetLink.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان بريدك الإلكتروني لتلقي وصلة إعادة تعيين كلمة المرور.'**
  String get emailReceiveResetLink;

  /// No description provided for @sendPwdResetLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال وصلة إعادة تعيين'**
  String get sendPwdResetLink;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfo;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك'**
  String get phoneNumberHint;

  /// No description provided for @userName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get userName;

  /// No description provided for @userNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المستخدم'**
  String get userNameHint;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @yourPhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورك'**
  String get yourPhoto;

  /// No description provided for @editYourPhoto.
  ///
  /// In ar, this message translates to:
  /// **'تحرير صورتك'**
  String get editYourPhoto;

  /// No description provided for @bio.
  ///
  /// In ar, this message translates to:
  /// **'السيرة الشخصية'**
  String get bio;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @clickToUpload.
  ///
  /// In ar, this message translates to:
  /// **'انقر لتحميل أو اسحب'**
  String get clickToUpload;

  /// No description provided for @topChannels.
  ///
  /// In ar, this message translates to:
  /// **'القنوات الأعلى'**
  String get topChannels;

  /// No description provided for @topProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات الأعلى'**
  String get topProducts;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جار التحميل'**
  String get loading;

  /// No description provided for @visitors.
  ///
  /// In ar, this message translates to:
  /// **'الزوار'**
  String get visitors;

  /// No description provided for @source.
  ///
  /// In ar, this message translates to:
  /// **'المصدر'**
  String get source;

  /// No description provided for @revenues.
  ///
  /// In ar, this message translates to:
  /// **'الإيرادات'**
  String get revenues;

  /// No description provided for @sales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get sales;

  /// No description provided for @conversation.
  ///
  /// In ar, this message translates to:
  /// **'التحويل'**
  String get conversation;

  /// No description provided for @groupMenu.
  ///
  /// In ar, this message translates to:
  /// **'القائمة'**
  String get groupMenu;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @calendar.
  ///
  /// In ar, this message translates to:
  /// **'التقويم'**
  String get calendar;

  /// No description provided for @forms.
  ///
  /// In ar, this message translates to:
  /// **'النماذج'**
  String get forms;

  /// No description provided for @tables.
  ///
  /// In ar, this message translates to:
  /// **'الجداول'**
  String get tables;

  /// No description provided for @others.
  ///
  /// In ar, this message translates to:
  /// **'آخرون'**
  String get others;

  /// No description provided for @chart.
  ///
  /// In ar, this message translates to:
  /// **'الرسم البياني'**
  String get chart;

  /// No description provided for @uiElements.
  ///
  /// In ar, this message translates to:
  /// **'عناصر واجهة المستخدم'**
  String get uiElements;

  /// No description provided for @alerts.
  ///
  /// In ar, this message translates to:
  /// **'تحذيرات'**
  String get alerts;

  /// No description provided for @buttons.
  ///
  /// In ar, this message translates to:
  /// **'الأزرار'**
  String get buttons;

  /// No description provided for @basicChart.
  ///
  /// In ar, this message translates to:
  /// **'رسم بياني أساسي'**
  String get basicChart;

  /// No description provided for @eCommerce.
  ///
  /// In ar, this message translates to:
  /// **'التجارة إلكترونية'**
  String get eCommerce;

  /// No description provided for @authentication.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة'**
  String get authentication;

  /// No description provided for @advanceTable.
  ///
  /// In ar, this message translates to:
  /// **'جدول متقدم'**
  String get advanceTable;

  /// No description provided for @profitThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'الربح هذا الأسبوع'**
  String get profitThisWeek;

  /// No description provided for @package.
  ///
  /// In ar, this message translates to:
  /// **'حزمة'**
  String get package;

  /// No description provided for @invoiceDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الفاتورة'**
  String get invoiceDate;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات'**
  String get actions;

  /// No description provided for @productName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @sold.
  ///
  /// In ar, this message translates to:
  /// **'مباعة'**
  String get sold;

  /// No description provided for @profit.
  ///
  /// In ar, this message translates to:
  /// **'ربح'**
  String get profit;

  /// No description provided for @alertTips.
  ///
  /// In ar, this message translates to:
  /// **'نصائح التحذيرات'**
  String get alertTips;

  /// No description provided for @alertDialog.
  ///
  /// In ar, this message translates to:
  /// **'حوار التحذيرات'**
  String get alertDialog;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get info;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @warn.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warn;

  /// No description provided for @danger.
  ///
  /// In ar, this message translates to:
  /// **'خطر'**
  String get danger;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @simpleAlert.
  ///
  /// In ar, this message translates to:
  /// **'تحذير بسيط'**
  String get simpleAlert;

  /// No description provided for @simple.
  ///
  /// In ar, this message translates to:
  /// **'بسيط'**
  String get simple;

  /// No description provided for @simpleConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد بسيط'**
  String get simpleConfirm;

  /// No description provided for @rflutterAlert.
  ///
  /// In ar, this message translates to:
  /// **'تحذير RFlutter'**
  String get rflutterAlert;

  /// No description provided for @rflutterTip.
  ///
  /// In ar, this message translates to:
  /// **'Flutter أكثر رائعة مع RFlutter Alert.'**
  String get rflutterTip;

  /// No description provided for @cool.
  ///
  /// In ar, this message translates to:
  /// **'جذاب'**
  String get cool;

  /// No description provided for @seeDetail.
  ///
  /// In ar, this message translates to:
  /// **'انظر التفاصيل...'**
  String get seeDetail;

  /// No description provided for @tryMore.
  ///
  /// In ar, this message translates to:
  /// **'حاول المزيد...'**
  String get tryMore;

  /// No description provided for @colorPicker.
  ///
  /// In ar, this message translates to:
  /// **'محدد اللون'**
  String get colorPicker;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
