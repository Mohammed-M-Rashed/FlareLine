library flareline_uikit;

import 'package:flutter/material.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';

class BreakTab extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isActive;

  const BreakTab({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? FlarelineColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : FlarelineColors.darkBlackText,
                fontFamily: 'Tajawal', // Use Tajawal font
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.white70 : FlarelineColors.darkTextBody,
                  fontFamily: 'Tajawal', // Use Tajawal font
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BreakTabGroup extends StatelessWidget {
  final List<BreakTab> tabs;
  final int activeIndex;
  final ValueChanged<int>? onTabChanged;

  const BreakTabGroup({
    super.key,
    required this.tabs,
    required this.activeIndex,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: BreakTab(
            title: tab.title,
            subtitle: tab.subtitle,
            isActive: index == activeIndex,
            onTap: () => onTabChanged?.call(index),
          ),
        );
      }).toList(),
    );
  }
}
