import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/title_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';

class ButtonPage extends LayoutWidget {
  const ButtonPage({super.key});

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        TitleCard(
            title: AppLocalizations.of(context)!.normalButton, childWidget: _normalButtonsWidget(context)),
        const SizedBox(
          height: 20,
        ),
        TitleCard(
            title: AppLocalizations.of(context)!.buttonWithIcon,
            childWidget: _iconButtonsWidget(context)),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }

  @override
  String breakTabTitle(BuildContext context) {
    return AppLocalizations.of(context)!.buttonsPageTitle;
  }

  Widget _normalButtonsWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'افتراضي',
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'افتراضي',
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'افتراضي',
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'افتراضي',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.normal,
                textColor: GlobalColors.normal,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'أولي',
                borderRadius: 0,
                type: ButtonType.primary.type,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'أولي',
                borderRadius: 5,
                type: ButtonType.primary.type,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'أولي',
                borderRadius: 30,
                type: ButtonType.primary.type,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'أولي',
                color: Colors.white,
                borderRadius: 5,
                borderColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'نجح',
                type: ButtonType.success.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'نجح',
                type: ButtonType.success.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'نجح',
                type: ButtonType.success.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'نجح',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.success,
                textColor: GlobalColors.success,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'معلومات',
                type: ButtonType.info.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'معلومات',
                type: ButtonType.info.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'معلومات',
                type: ButtonType.info.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'معلومات',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.info,
                textColor: GlobalColors.info,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'تحذير',
                type: ButtonType.warn.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'تحذير',
                type: ButtonType.warn.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'تحذير',
                type: ButtonType.warn.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'تحذير',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.warn,
                textColor: GlobalColors.warn,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'خطر',
                type: ButtonType.danger.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'خطر',
                type: ButtonType.danger.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'خطر',
                type: ButtonType.danger.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'خطر',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.danger,
                textColor: GlobalColors.danger,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'داكن',
                type: ButtonType.dark.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'داكن',
                type: ButtonType.dark.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'داكن',
                type: ButtonType.dark.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                btnText: 'داكن',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.dark,
                textColor: GlobalColors.dark,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget _iconButtonsWidget(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: GlobalColors.normal,
                ),
                btnText: 'افتراضي مع أيقونة',
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: GlobalColors.normal,
                ),
                btnText: 'افتراضي مع أيقونة',
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: GlobalColors.normal,
                ),
                btnText: 'افتراضي مع أيقونة',
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: GlobalColors.normal,
                ),
                btnText: 'افتراضي مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.normal,
                textColor: GlobalColors.normal,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                ),
                btnText: 'أولي مع أيقونة',
                type: ButtonType.primary.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                ),
                btnText: 'أولي مع أيقونة',
                type: ButtonType.primary.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                ),
                btnText: 'أولي مع أيقونة',
                type: ButtonType.primary.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.email_outlined,
                  color: GlobalColors.primary,
                ),
                btnText: 'أولي مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.primary,
                textColor: GlobalColors.primary,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'نجح مع أيقونة',
                type: ButtonType.success.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'نجح مع أيقونة',
                type: ButtonType.success.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'نجح مع أيقونة',
                type: ButtonType.success.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: GlobalColors.success,
                ),
                btnText: 'نجح مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.success,
                textColor: GlobalColors.success,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'معلومات مع أيقونة',
                type: ButtonType.info.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'معلومات مع أيقونة',
                type: ButtonType.info.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'معلومات مع أيقونة',
                type: ButtonType.info.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: GlobalColors.info,
                ),
                btnText: 'معلومات مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.info,
                textColor: GlobalColors.info,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'تحذير مع أيقونة',
                type: ButtonType.warn.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'تحذير مع أيقونة',
                type: ButtonType.warn.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'تحذير مع أيقونة',
                type: ButtonType.warn.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: GlobalColors.warn,
                ),
                btnText: 'تحذير مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.warn,
                textColor: GlobalColors.warn,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'خطر مع أيقونة',
                type: ButtonType.danger.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'خطر مع أيقونة',
                type: ButtonType.danger.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: Colors.white,
                ),
                btnText: 'خطر مع أيقونة',
                type: ButtonType.danger.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: const Icon(
                  Icons.shopping_cart_checkout,
                  color: GlobalColors.danger,
                ),
                btnText: 'خطر مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.danger,
                textColor: GlobalColors.danger,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
                btnText: 'داكن مع أيقونة',
                type: ButtonType.dark.type,
                borderRadius: 0,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
                btnText: 'داكن مع أيقونة',
                type: ButtonType.dark.type,
                borderRadius: 5,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),
                btnText: 'داكن مع أيقونة',
                type: ButtonType.dark.type,
                borderRadius: 30,
              ),
            ),
            SizedBox(
              width: 180,
              child: ButtonWidget(
                iconWidget: Icon(
                  Icons.favorite_border,
                  color: GlobalColors.dark,
                ),
                btnText: 'داكن مع أيقونة',
                color: Colors.white,
                borderRadius: 5,
                borderColor: GlobalColors.dark,
                textColor: GlobalColors.dark,
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
