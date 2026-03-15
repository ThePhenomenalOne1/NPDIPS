import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class CategoryPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  const CategoryPill({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Glassy look for Pills
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // ignore: unused_local_variable
    final baseColor = isSelected
        ? AppColors.primary
        : (isDark ? Colors.white : Colors.black);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.8)
                    : Theme.of(context).cardTheme.color?.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
