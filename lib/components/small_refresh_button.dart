import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class SmallRefreshButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String? tooltip;

  const SmallRefreshButton({
    super.key,
    this.onTap,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'تحديث البيانات',
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: FlarelineColors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(FlarelineColors.textSecondary),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    size: 18,
                    color: FlarelineColors.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}
