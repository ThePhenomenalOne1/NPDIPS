import 'package:flutter/material.dart';
import 'package:dipstore_ui/core/theme/app_colors.dart';

class SearchTag extends StatelessWidget {
  final String label;
  const SearchTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textMainLight, // Explicit dark text
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
