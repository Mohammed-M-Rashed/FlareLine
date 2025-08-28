import 'package:flareline/pages/auth/sign_in/sign_in_provider.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SignInWidget extends GetView<SignInProvider> {
  SignInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // Check the sizing information here and return your UI
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Center(
            child: contentDesktopWidget(context),
          );
        }

        return contentMobileWidget(context);
      },
    ));
  }

  Widget contentDesktopWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonCard(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.appName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(AppLocalizations.of(context)!.slogan),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: 350,
                        child: SvgPicture.asset('assets/signin/main.svg',
                            semanticsLabel: ''),
                      )
                    ],
                  )),
              const VerticalDivider(
                width: 1,
                color: GlobalColors.background,
              ),
              Expanded(
                child: _signInFormWidget(context),
              )
            ]),
          )
        ],
      ),
    );
  }

  Widget contentMobileWidget(BuildContext context) {
    return SingleChildScrollView(
      child: CommonCard(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: _signInFormWidget(context)),
    );
  }

  Widget _signInFormWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.signIn,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Welcome back! Please sign in to your account.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutBorderTextFormField(
              labelText: AppLocalizations.of(context)!.email,
              hintText: AppLocalizations.of(context)!.emailHint,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email address';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              suffixWidget: SvgPicture.asset(
                'assets/signin/email.svg',
                width: 22,
                height: 22,
              ),
              controller: controller.emailController,
            ),
            const SizedBox(
              height: 16,
            ),
            OutBorderTextFormField(
              obscureText: true,
              labelText: AppLocalizations.of(context)!.password,
              hintText: AppLocalizations.of(context)!.passwordHint,
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              suffixWidget: SvgPicture.asset(
                'assets/signin/lock.svg',
                width: 22,
                height: 22,
              ),
              controller: controller.passwordController,
            ),
            const SizedBox(
              height: 32,
            ),
            Obx(() => ButtonWidget(
              type: ButtonType.primary.type,
              btnText: controller.isLoading ? 'Signing in...' : AppLocalizations.of(context)!.signIn,
              onTap: controller.isLoading ? null : () {
                controller.signIn(context);
              },
            )),
            const SizedBox(
              height: 16,
            ),
          ],
        ));
  }
}
