import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/title_card.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ModalPage extends LayoutWidget {
  /// Shows a success toast notification for modal operations in Arabic
  void _showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text('نجح', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an error toast notification for modal operations in Arabic
  void _showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('خطأ', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 6),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  /// Shows an info toast notification for modal operations in Arabic
  void _showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text('معلومات', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(message),
      autoCloseDuration: const Duration(seconds: 4),
      icon: const Icon(Icons.info_outline, color: Colors.white),
      style: ToastificationStyle.flatColored,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  @override
  String breakTabTitle(BuildContext context) {
    // TODO: implement breakTabTitle
    return 'Modal';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return Column(
      children: [
        TitleCard(title: 'Modal Toast', childWidget: _dialogWidgets(context)),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _dialogWidgets(BuildContext context) {
    return Column(
      children: [
        ButtonWidget(
          btnText: 'Simple Modal',
          color: Colors.white,
          borderRadius: 5,
          borderColor: GlobalColors.normal,
          textColor: GlobalColors.normal,
          onTap: () {
            ModalDialog.show(
                context: context,
                title: 'Simple Modal',
                showFooter: false,
                modalType: ModalType.small,
                showTitleDivider: true,
                child: const Text(
                    'FlareLine is a free and open-source admin dashboard template built on Flutter providing developers with everything they need to create a feature-rich and data-driven: back-end, dashboard, or admin panel solution for any sort of web/mac/windows/android/iOS project.'));
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ButtonWidget(
          btnText: 'Modal with footer',
          color: Colors.white,
          borderRadius: 5,
          borderColor: GlobalColors.normal,
          textColor: GlobalColors.normal,
          onTap: () {
            ModalDialog.show(
                context: context,
                title: 'Modal with footer',
                showFooter: true,
                modalType: ModalType.small,
                showTitleDivider: true,
                onCancelTap: () {
                  _showInfoToast(context, 'تم الإلغاء');
                },
                onSaveTap: () {
                  _showSuccessToast(context, 'تم الحفظ بنجاح');
                },
                child: const Text(
                    'FlareLine is a free and open-source admin dashboard template built on Flutter providing developers with everything they need to create a feature-rich and data-driven: back-end, dashboard, or admin panel solution for any sort of web/mac/windows/android/iOS project.'));
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ButtonWidget(
          btnText: 'Medium Modal',
          color: Colors.white,
          borderRadius: 5,
          borderColor: GlobalColors.normal,
          textColor: GlobalColors.normal,
          onTap: () {
            ModalDialog.show(
                context: context,
                title: 'Medium Modal',
                showFooter: false,
                modalType: ModalType.medium,
                showTitleDivider: true,
                child: const Text(
                    'FlareLine is a free and open-source admin dashboard template built on Flutter providing developers with everything they need to create a feature-rich and data-driven: back-end, dashboard, or admin panel solution for any sort of web/mac/windows/android/iOS project.'));
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ButtonWidget(
          btnText: 'Large Modal',
          color: Colors.white,
          borderRadius: 5,
          borderColor: GlobalColors.normal,
          textColor: GlobalColors.normal,
          onTap: () {
            ModalDialog.show(
                context: context,
                title: 'Large Modal',
                showFooter: false,
                modalType: ModalType.large,
                showTitleDivider: true,
                child: const Text(
                    'FlareLine is a free and open-source admin dashboard template built on Flutter providing developers with everything they need to create a feature-rich and data-driven: back-end, dashboard, or admin panel solution for any sort of web/mac/windows/android/iOS project.'));
          },
        ),
        const SizedBox(
          height: 20,
        ),
        ButtonWidget(
          btnText: 'Large Modal Widget',
          color: Colors.white,
          borderRadius: 5,
          borderColor: GlobalColors.normal,
          textColor: GlobalColors.normal,
          onTap: () {
            ModalDialog.show(
                context: context,
                title: 'Large Modal',
                showFooter: false,
                modalType: ModalType.large,
                showTitleDivider: true,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,

                ));
          },
        ),
      ],
    );
  }
}
